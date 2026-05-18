import 'package:flutter/material.dart';
import '../models/cena.dart';
import '../models/game_progress.dart';
import '../services/audio_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class CenaScreen extends StatefulWidget {
  final Cena cena;
  final GameProgress gameProgress;

  const CenaScreen({
    super.key,
    required this.cena,
    required this.gameProgress,
  });

  @override
  State<CenaScreen> createState() => _CenaScreenState();
}

class _CenaScreenState extends State<CenaScreen> {
  int _falaAtualIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  late List<Fala> _falasAtuais;
  late GameProgress _progress;

  int _acertos = 0;
  bool _avaliou = false;

  int? _opcaoSelecionadaIndex;
  bool _bloquearOpcoes = false;
  String? _statusAvaliacao;
  String? _currentBackground;

  @override
  void initState() {
    super.initState();
    _falasAtuais = List.from(widget.cena.falas);
    _progress = widget.gameProgress;
    AudioService().pauseBgm();
    if (widget.cena.backgroundMusic != null) {
      AudioService().playSceneBgm(widget.cena.backgroundMusic!);
    }
  }

  @override
  void dispose() {
    if (widget.cena.backgroundMusic != null) {
      AudioService().stopSceneBgm();
    }
    AudioService().resumeBgm();
    super.dispose();
  }

  void _avancarFala() async {
    if (_bloquearOpcoes) return;
    if (_falaAtualIndex < _falasAtuais.length - 1) {
      final currentNpc = _getUltimaFalaComNpc(_falaAtualIndex)?.personagem;
      setState(() {
        _falaAtualIndex++;
        if (_falasAtuais[_falaAtualIndex].backgroundAsset != null) {
          _currentBackground = _falasAtuais[_falaAtualIndex].backgroundAsset;
        }
      });
      final nextNpc = _getUltimaFalaComNpc(_falaAtualIndex)?.personagem;
      if (nextNpc != null && nextNpc != currentNpc) {
        AudioService().playDialogSfx();
      }
    } else {
      if (widget.cena.idProva != null && !_avaliou) {
        
        final aprovado = _acertos >= (widget.cena.acertosParaAprovacao ?? 99);
        
        setState(() {
          _avaliou = true;
          _statusAvaliacao = aprovado ? 'APROVADO' : 'REPROVADO';
        });

        _progress = _progress.registrarAvaliacao(
          widget.cena.idProva!, 
          Avaliacao(acertos: _acertos, aprovado: aprovado, completada: true)
        );

        final falasAdicionais = aprovado ? widget.cena.falasAprovado : widget.cena.falasReprovado;
        if (falasAdicionais != null && falasAdicionais.isNotEmpty) {
          final currentNpc = _getUltimaFalaComNpc(_falaAtualIndex)?.personagem;
          setState(() {
            _falasAtuais.addAll(falasAdicionais);
            _falaAtualIndex++;
            if (_falasAtuais[_falaAtualIndex].backgroundAsset != null) {
              _currentBackground = _falasAtuais[_falaAtualIndex].backgroundAsset;
            }
          });
          final nextNpc = _getUltimaFalaComNpc(_falaAtualIndex)?.personagem;
          if (nextNpc != null && nextNpc != currentNpc) {
            AudioService().playDialogSfx();
          }
          return;
        }
      }

      // Fim da cena
      AudioService().playClickSfx();
      
      try {
        final uid = _authService.currentUser?.uid;
        if (uid != null) {
          _progress = _progress.completarCena(widget.cena.id);
          await _firestoreService.saveProgress(uid, _progress);
        }
      } catch (e) {
        debugPrint("Erro ao salvar progresso: $e");
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _escolherOpcao(int index) {
    if (_bloquearOpcoes) return;

    final falaAtual = _falasAtuais[_falaAtualIndex];
    if (falaAtual.opcoes == null) return;

    final opcaoSelecionada = falaAtual.opcoes![index];
    final isDicaAtiva = falaAtual.bencaoAutoCompletar != null && 
        _progress.bencaos.toMap()[falaAtual.bencaoAutoCompletar] == true;

    if (isDicaAtiva && !opcaoSelecionada.correta) {
       return;
    }

    setState(() {
      _opcaoSelecionadaIndex = index;
      _bloquearOpcoes = true;
      if (opcaoSelecionada.correta) {
        _acertos++;
      }
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      
      setState(() {
        _opcaoSelecionadaIndex = null;
        _bloquearOpcoes = false;

        if (opcaoSelecionada.consequencia != null &&
            opcaoSelecionada.consequencia!.isNotEmpty) {
          _falasAtuais.insertAll(
            _falaAtualIndex + 1,
            opcaoSelecionada.consequencia!,
          );
        }

        if (opcaoSelecionada.concedeBencao != null) {
          _progress = _progress.concederBencao(opcaoSelecionada.concedeBencao!);
          final uid = _authService.currentUser?.uid;
          if (uid != null) {
             _firestoreService.saveProgress(uid, _progress);
          }
        }
      });
      _avancarFala();
    });
  }

  Fala? _getUltimaFalaComNpc(int currentIndex) {
    for (int i = currentIndex; i >= 0; i--) {
      if (_falasAtuais[i].personagem.assetImagem != null && _falasAtuais[i].personagem.assetImagem!.isNotEmpty) {
        return _falasAtuais[i];
      }
    }
    return null;
  }

  String _getTituloDica(String bencaoId) {
    switch (bencaoId) {
      case 'livroFlutter':
        return 'Dica da Vitória';
      case 'anotacoesValdir':
        return 'Dica do Lucas';
      case 'rascunhoJulia':
        return 'Dica da Julia';
      default:
        return 'Dica Especial';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_falasAtuais.isEmpty) return const SizedBox.shrink();

    final fala = _falasAtuais[_falaAtualIndex];
    final ultimaFalaComNpc = _getUltimaFalaComNpc(_falaAtualIndex);

    bool isDicaAtiva = fala.bencaoAutoCompletar != null && 
                       _progress.bencaos.toMap()[fala.bencaoAutoCompletar] == true;

    return Scaffold(
      body: GestureDetector(
        onTap: (fala.opcoes == null || fala.opcoes!.isEmpty) && !_bloquearOpcoes ? _avancarFala : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background da Cena
            Image.asset(
              _currentBackground ?? widget.cena.backgroundAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF1A1A2E),
              ),
              width: double.infinity,
              height: double.infinity,
            ),

            // Camada de escurecimento suave para contraste
            Container(
              color: Colors.black.withValues(alpha: 0.2),
            ),

            // Renderização do Personagem Atual com Efeito de Fade
            if (ultimaFalaComNpc != null)
              Align(
                alignment: ultimaFalaComNpc.posicao == PosicaoPersonagem.direita 
                    ? Alignment.bottomRight 
                    : Alignment.bottomLeft,
                child: Transform.translate(
                  offset: Offset(ultimaFalaComNpc.posicao == PosicaoPersonagem.direita ? 15.0 : -15.0, 0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 180.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Image.asset(
                        ultimaFalaComNpc.personagem.assetImagem!,
                        key: ValueKey<String>(ultimaFalaComNpc.personagem.assetImagem!),
                        height: 400, // Slightly bigger
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ),

            // Badge Superior de Status (Aprovado/Reprovado)
            if (_statusAvaliacao != null)
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 64.0),
                  child: AnimatedOpacity(
                    opacity: _avaliou ? 1.0 : 0.0,
                    duration: const Duration(seconds: 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: _statusAvaliacao == 'APROVADO' 
                            ? Colors.green.withValues(alpha: 0.8) 
                            : Colors.red.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                           color: _statusAvaliacao == 'APROVADO' ? Colors.greenAccent : Colors.redAccent,
                           width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Text(
                        _statusAvaliacao!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Caixa de Diálogo (Bottom)
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1810).withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF8B6914).withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome do Personagem
                        Text(
                          fala.personagem.nome,
                          style: TextStyle(
                            color: fala.personagem.nome == 'Estudante' 
                                ? const Color(0xFFC7CEEA) 
                                : const Color(0xFF8B6914),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontStyle: fala.personagem.nome == 'Estudante' ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Texto da Fala
                        Text.rich(
                          TextSpan(
                            text: fala.texto,
                            children: [
                              if (isDicaAtiva)
                                TextSpan(
                                  text: '\n(${_getTituloDica(fala.bencaoAutoCompletar!)})',
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          style: TextStyle(
                            color: fala.personagem.nome == 'Estudante'
                                ? Colors.white
                                : const Color(0xFFE8D5B5),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                            fontStyle: fala.personagem.nome == 'Estudante' ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (fala.opcoes != null && fala.opcoes!.isNotEmpty)
                          ...fala.opcoes!.asMap().entries.map((entry) {
                            final index = entry.key;
                            final opcao = entry.value;

                            bool isDisabledByDica = isDicaAtiva && !opcao.correta;
                            bool isHighlightedByDica = isDicaAtiva && opcao.correta;

                            Color borderColor = const Color(0xFF8B6914).withValues(alpha: 0.4);
                            Color bgColor = const Color(0xFF3E2723);

                            if (_opcaoSelecionadaIndex == index) {
                                borderColor = opcao.correta ? Colors.green : Colors.red;
                                bgColor = opcao.correta ? Colors.green.withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.5);
                            } else if (isHighlightedByDica) {
                                borderColor = Colors.green;
                                bgColor = Colors.green.withValues(alpha: 0.15);
                            } else if (isDisabledByDica) {
                                borderColor = Colors.grey.withValues(alpha: 0.3);
                                bgColor = Colors.grey.withValues(alpha: 0.1);
                            }

                            return Padding(
                              key: ValueKey('$_falaAtualIndex-$index'),
                              padding: const EdgeInsets.only(top: 8.0),
                              child: _BotaoOpcao(
                                texto: opcao.texto,
                                borderColor: borderColor,
                                backgroundColor: bgColor,
                                textColor: isDisabledByDica ? Colors.grey : const Color(0xFFE8D5B5),
                                onTap: isDisabledByDica || _bloquearOpcoes ? null : () => _escolherOpcao(index),
                              ),
                            );
                          }),

                        if (fala.opcoes == null || fala.opcoes!.isEmpty)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Toque para continuar',
                                  style: TextStyle(
                                    color: const Color(0xFFE8D5B5).withValues(alpha: 0.5),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12,
                                  color: const Color(0xFFE8D5B5).withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotaoOpcao extends StatelessWidget {
  final String texto;
  final VoidCallback? onTap;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;

  const _BotaoOpcao({
    required this.texto, 
    required this.onTap,
    required this.borderColor,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor, 
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                texto,
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

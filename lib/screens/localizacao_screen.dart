import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/localizacao_service.dart';

/// Tela que captura e exibe a posição atual do dispositivo.
///
/// Ao abrir, solicita automaticamente a permissão de localização via
/// pop-up nativo do sistema. Se concedida, inicia o stream contínuo do
/// GPS e imprime as coordenadas no console do desenvolvedor enquanto
/// o dispositivo se move.
class LocalizacaoScreen extends StatefulWidget {
  const LocalizacaoScreen({super.key});

  @override
  State<LocalizacaoScreen> createState() => _LocalizacaoScreenState();
}

class _LocalizacaoScreenState extends State<LocalizacaoScreen> {
  final LocalizacaoService _service = LocalizacaoService();

  Position? _posicao;
  String? _erro;
  bool _carregando = false;
  // Rastreia se a permissão foi negada permanentemente para exibir botão
  // de atalho para as configurações do dispositivo.
  bool _negadaPermanentemente = false;

  @override
  void initState() {
    super.initState();
    // Solicita permissão e inicia o stream logo que a tela é construída,
    // sem esperar o usuário tocar em nenhum botão.
    WidgetsBinding.instance.addPostFrameCallback((_) => _iniciar());
  }

  @override
  void dispose() {
    // Para o stream de GPS para evitar vazamento de memória.
    _service.pararMonitoramento();
    super.dispose();
  }

  /// Ponto de entrada: verifica/solicita permissão e, se ok, inicia stream.
  Future<void> _iniciar() async {
    setState(() {
      _carregando = true;
      _erro = null;
      _negadaPermanentemente = false;
    });

    try {
      // Verifica estado atual sem disparar o pop-up ainda.
      final permissaoAtual = await _service.verificarPermissao();

      if (permissaoAtual == LocationPermission.deniedForever) {
        // Já foi negada permanentemente em sessão anterior.
        _tratarNegacaoPermanente();
        return;
      }

      if (permissaoAtual == LocationPermission.denied) {
        // Ainda não foi solicitada (ou foi negada mas pode pedir de novo):
        // exibe o pop-up nativo do sistema operacional.
        final novaPermissao = await _service.solicitarPermissao();

        if (novaPermissao == LocationPermission.denied) {
          // Usuário tocou em "Não permitir" no pop-up.
          _tratarNegacao();
          return;
        }

        if (novaPermissao == LocationPermission.deniedForever) {
          _tratarNegacaoPermanente();
          return;
        }
      }

      // Permissão concedida: inicia o monitoramento contínuo.
      await _service.iniciarMonitoramento(
        onPosicao: (pos) {
          if (mounted) setState(() => _posicao = pos);
        },
        onErro: (erro) {
          if (mounted) setState(() => _erro = erro.toString());
        },
      );
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  /// Permissão negada pelo usuário no pop-up — mostra diálogo explicativo.
  void _tratarNegacao() {
    setState(() {
      _carregando = false;
      _erro = 'Permissão de localização negada pelo usuário.';
    });

    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.location_off, size: 48, color: Colors.orange),
        title: const Text('Localização necessária'),
        content: const Text(
          'Este aplicativo precisa da sua localização para funcionar como '
          'jogo de RPG baseado em posição real.\n\n'
          'Toque em "Tentar novamente" para conceder a permissão.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Volta para a tela anterior.
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _iniciar(); // Solicita novamente.
            },
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  /// Permissão negada permanentemente — orienta o usuário a ir às configurações.
  void _tratarNegacaoPermanente() {
    setState(() {
      _carregando = false;
      _negadaPermanentemente = true;
      _erro = 'Permissão negada permanentemente. Abra as Configurações do '
          'dispositivo e habilite a localização para este app.';
    });

    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.lock, size: 48, color: Colors.red),
        title: const Text('Permissão bloqueada'),
        content: const Text(
          'Você negou a permissão de localização permanentemente.\n\n'
          'Para usar este recurso, acesse:\n'
          'Configurações → Privacidade → Localização → rpg_mobile_2026\n'
          'e selecione "Ao usar o app".',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Fechar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Abre a tela de configurações nativa do dispositivo.
              Geolocator.openAppSettings();
            },
            child: const Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Minha Localização',
          style: TextStyle(color: Color(0xFF4A4E69), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4A4E69)),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE2F0CB),
              Color(0xFFFFDAC1),
              Color(0xFFC7CEEA),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: _construirConteudo()),
          ),
        ),
      ),
    );
  }

  Widget _construirConteudo() {
    if (_carregando) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Aguardando permissão e sinal GPS…',
            style: TextStyle(color: Color(0xFF4A4E69)),
          ),
        ],
      );
    }

    if (_erro != null) {
      return _MensagemErro(
        mensagem: _erro!,
        negadaPermanentemente: _negadaPermanentemente,
        onTentarNovamente:
            _negadaPermanentemente ? Geolocator.openAppSettings : _iniciar,
      );
    }

    if (_posicao != null) {
      return _PosicaoCard(posicao: _posicao!);
    }

    // Estado de aguardo enquanto o primeiro fix do GPS ainda não chegou.
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.gps_not_fixed, size: 80, color: Color(0xFF4A4E69)),
        SizedBox(height: 16),
        Text(
          'Aguardando sinal GPS…',
          style: TextStyle(color: Color(0xFF4A4E69)),
        ),
      ],
    );
  }
}

/// Exibe latitude, longitude e precisão quando o GPS está ativo.
class _PosicaoCard extends StatelessWidget {
  final Position posicao;
  const _PosicaoCard({required this.posicao});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.gps_fixed, size: 64, color: Color(0xFF2D6A4F)),
        const SizedBox(height: 8),
        const Text(
          'Monitorando continuamente',
          style: TextStyle(fontSize: 12, color: Color(0xFF2D6A4F), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _linha('Latitude', posicao.latitude.toStringAsFixed(6)),
        _linha('Longitude', posicao.longitude.toStringAsFixed(6)),
        _linha('Precisão', '${posicao.accuracy.toStringAsFixed(1)} m'),
        const SizedBox(height: 8),
        Text(
          'Última atualização: ${_formatarHora(posicao.timestamp)}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6A6E89)),
        ),
      ],
    );
  }

  Widget _linha(String rotulo, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          '$rotulo: $valor',
          style: const TextStyle(fontSize: 18, color: Color(0xFF4A4E69), fontWeight: FontWeight.w600),
        ),
      );

  String _formatarHora(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';
}

/// Exibe mensagem de erro com ação contextual (tentar novamente ou abrir
/// configurações, dependendo do tipo de negação).
class _MensagemErro extends StatelessWidget {
  final String mensagem;
  final bool negadaPermanentemente;
  final dynamic Function() onTentarNovamente;

  const _MensagemErro({
    required this.mensagem,
    required this.negadaPermanentemente,
    required this.onTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          negadaPermanentemente ? Icons.lock : Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        Text(
          mensagem,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF4A4E69), fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          icon: Icon(
            negadaPermanentemente ? Icons.settings : Icons.refresh,
          ),
          label: Text(
            negadaPermanentemente ? 'Abrir Configurações' : 'Tentar novamente',
          ),
          onPressed: onTentarNovamente,
        ),
      ],
    );
  }
}

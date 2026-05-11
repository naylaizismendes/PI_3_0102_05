import 'package:flutter/material.dart';
import 'localizacao_screen.dart';
import 'ambientes_screen.dart';
import '../services/auth_service.dart';
import 'campanha_screen.dart';
import '../services/audio_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String _nomeJogador = '';

  @override
  void initState() {
    super.initState();
    AudioService().playMenuBgm();
    // Verifica se o jogador já tem nome definido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarNome();
    });
  }

  Future<void> _verificarNome() async {
    // Convidado não precisa de popup — vai como "Guest"
    if (_authService.isGuest) {
      setState(() => _nomeJogador = 'Guest');
      return;
    }
    final nome = _authService.displayName;
    if (nome == null || nome.trim().isEmpty) {
      await _mostrarPopupNome();
    }
    // Atualiza o nome exibido após o popup (ou se já tinha)
    setState(() {
      _nomeJogador = _authService.displayName ?? '';
    });
  }

  Future<void> _mostrarPopupNome() async {
    final controller = TextEditingController();
    String? erro;

    await showDialog(
      context: context,
      barrierDismissible: false, // Não fecha tocando fora
      builder: (ctx) {
        return PopScope(
          canPop: false, // Bloqueia botão voltar do Android
          child: StatefulBuilder(
            builder: (ctx, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.white,
                title: const Text(
                  'Como você se chama?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4E69),
                  ),
                  textAlign: TextAlign.center,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Os personagens vão te chamar por esse nome durante o jogo.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B6F8A)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Seu nome',
                        hintStyle: const TextStyle(color: Color(0xFFB0B3C6)),
                        filled: true,
                        fillColor: const Color(0xFFF5F6FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2D6A4F), width: 1.5),
                        ),
                        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4A4E69)),
                        errorText: erro,
                      ),
                    ),
                  ],
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D6A4F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        final texto = controller.text.trim();
                        if (texto.isEmpty) {
                          setDialogState(() => erro = 'Digite um nome para continuar');
                          return;
                        }
                        await _authService.updateName(texto);
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                      child: const Text('Confirmar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF2D6A4F), size: 34),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onSelected: (value) async {
                if (value == 'logout' || value == 'criar_conta') {
                  AudioService().playClickSfx();
                  await _authService.signOut();
                }
              },
              itemBuilder: (BuildContext context) => [
                if (_authService.isGuest)
                  const PopupMenuItem(
                    value: 'criar_conta',
                    child: Row(
                      children: [
                        Icon(Icons.person_add_rounded, color: Color(0xFF2D6A4F), size: 20),
                        SizedBox(width: 12),
                        Text('Criar conta', style: TextStyle(color: Color(0xFF2D6A4F), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                else
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, color: Color(0xFF9D0208), size: 20),
                        SizedBox(width: 12),
                        Text('Sair da conta', style: TextStyle(color: Color(0xFF9D0208), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícone principal
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/jogador/player_icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  const SizedBox(height: 16),
                  Text(
                    'Bem-vindo(a), ${_nomeJogador.isEmpty ? '...' : _nomeJogador}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4A4E69),
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),


                  const SizedBox(height: 48),
                  const SizedBox(height: 24),

                  // Card Menu
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Menu de Navegação',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A4E69),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _BotaoEstilizado(
                          icone: Icons.play_arrow_rounded,
                          texto: 'Iniciar',
                          corBase: const Color(0xFF2D6A4F),
                          corTexto: Colors.white,
                          aoPressionar: () async {
                            AudioService().playClickSfx();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CampanhaScreen(),
                              ),
                            );
                            AudioService().playMenuBgm();
                          },
                        ),
                        const SizedBox(height: 12),
                        _BotaoEstilizado(
                          icone: Icons.my_location_rounded,
                          texto: 'Minha Localização',
                          corBase: const Color(0xFFB5EAD7),
                          corTexto: const Color(0xFF2D6A4F),
                          aoPressionar: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LocalizacaoScreen(),
                              ),
                            );
                            AudioService().playMenuBgm();
                          },
                        ),
                        const SizedBox(height: 12),
                        _BotaoEstilizado(
                          icone: Icons.explore_rounded,
                          texto: 'Ambientes do Jogo',
                          corBase: const Color(0xFFFFB7B2),
                          corTexto: const Color(0xFF9D0208),
                          aoPressionar: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AmbientesScreen(),
                              ),
                            );
                            AudioService().playMenuBgm();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BotaoEstilizado extends StatelessWidget {
  final IconData icone;
  final String texto;
  final Color corBase;
  final Color corTexto;
  final VoidCallback aoPressionar;

  const _BotaoEstilizado({
    required this.icone,
    required this.texto,
    required this.corBase,
    required this.corTexto,
    required this.aoPressionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: corBase,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: corBase.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            AudioService().playClickSfx();
            aoPressionar();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icone,
                    color: corTexto,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    texto,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: corTexto,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: corTexto.withValues(alpha: 0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

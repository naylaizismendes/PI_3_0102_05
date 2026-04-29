import 'package:flutter/material.dart';
import 'localizacao_screen.dart';
import 'ambientes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo com gradiente suave em tons pastéis inspirados no mapa
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE2F0CB), // Verde pastel (gramados do mapa)
              Color(0xFFFFDAC1), // Pêssego/Laranja pastel (telhados)
              Color(0xFFC7CEEA), // Roxo/Azul pastel (ruas e sombras)
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título e Branding
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/player_icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Caminho da Aprovação',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4A4E69),
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explore a PUC-Campinas e sobreviva ao Projeto Integrador!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6A6E89),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Card de Menu com efeito glass
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
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
                        const SizedBox(height: 20),
                        _BotaoEstilizado(
                          icone: Icons.my_location_rounded,
                          texto: 'Minha Localização',
                          corBase: const Color(0xFFB5EAD7), // Verde água pastel
                          corTexto: const Color(0xFF2D6A4F),
                          aoPressionar: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LocalizacaoScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _BotaoEstilizado(
                          icone: Icons.explore_rounded,
                          texto: 'Ambientes do Jogo',
                          corBase: const Color(0xFFFFB7B2), // Rosa/Salmão pastel
                          corTexto: const Color(0xFF9D0208),
                          aoPressionar: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AmbientesScreen(),
                              ),
                            );
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
            color: corBase.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: aoPressionar,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icone, color: corTexto, size: 24),
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
                  color: corTexto.withOpacity(0.5),
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

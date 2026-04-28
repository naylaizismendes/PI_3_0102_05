import 'package:flutter/material.dart';
import 'localizacao_screen.dart';
import 'ambientes_screen.dart';

/// Tela inicial do jogo. Apresenta título e botões de navegação
/// para as funcionalidades já implementadas na Sprint 1.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RPG Mobile 2026')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore, size: 96, color: Colors.deepPurple),
            SizedBox(height: 16),
            Text(
              'Bem-vindo, aventureiro!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Explore o Campus I da PUC-Campinas\ne descubra novos ambientes.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            _BotaoMenu(
              icone: Icons.my_location,
              texto: 'Minha Localização',
              destino: LocalizacaoScreen(),
            ),
            SizedBox(height: 12),
            _BotaoMenu(
              icone: Icons.map,
              texto: 'Ambientes do Jogo',
              destino: AmbientesScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão de menu reutilizável. Extraído em widget próprio para
/// manter o `build` da HomeScreen curto e legível.
class _BotaoMenu extends StatelessWidget {
  final IconData icone;
  final String texto;
  final Widget destino;

  const _BotaoMenu({
    required this.icone,
    required this.texto,
    required this.destino,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        icon: Icon(icone),
        label: Text(texto),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destino),
          );
        },
      ),
    );
  }
}

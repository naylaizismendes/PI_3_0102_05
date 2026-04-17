import 'package:flutter/material.dart';
import '../data/ambientes_mock.dart';
import '../models/ambiente.dart';

/// Tela que lista todos os ambientes cadastrados estaticamente.
/// Na Sprint 1 a lista é fixa; na Sprint 2 virá do banco de dados.
class AmbientesScreen extends StatelessWidget {
  const AmbientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ambientes do Jogo')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: ambientesMock.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ambiente = ambientesMock[index];
          return _AmbienteCard(ambiente: ambiente);
        },
      ),
    );
  }
}

/// Cartão que exibe nome, descrição e coordenadas de um ambiente.
class _AmbienteCard extends StatelessWidget {
  final Ambiente ambiente;
  const _AmbienteCard({required this.ambiente});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.place, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ambiente.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(ambiente.descricao),
            const SizedBox(height: 8),
            Text(
              'Lat: ${ambiente.latitude}  |  Long: ${ambiente.longitude}\n'
              'Raio: ${ambiente.raioMetros.toStringAsFixed(0)} m',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/ambientes_mock.dart';
import '../models/ambiente.dart';

class AmbientesScreen extends StatelessWidget {
  const AmbientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Ambientes do Jogo',
          style: TextStyle(color: Color(0xFF4A4E69), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4A4E69)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE2F0CB), // Verde pastel
              Color(0xFFFFDAC1), // Pêssego pastel
              Color(0xFFC7CEEA), // Roxo pastel
            ],
          ),
        ),
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ambientesMock.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final ambiente = ambientesMock[index];
              return _AmbienteCard(ambiente: ambiente);
            },
          ),
        ),
      ),
    );
  }
}

class _AmbienteCard extends StatelessWidget {
  final Ambiente ambiente;
  const _AmbienteCard({required this.ambiente});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB7B2), // Salmão pastel
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.place_rounded, color: Color(0xFF9D0208)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ambiente.nome,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4A4E69),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ambiente.descricao,
            style: const TextStyle(fontSize: 15, color: Color(0xFF6A6E89), height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '📍 Lat: ${ambiente.latitude.toStringAsFixed(5)}  |  Long: ${ambiente.longitude.toStringAsFixed(5)}\n📏 Raio de interação: ${ambiente.raioMetros.toStringAsFixed(0)}m',
              style: const TextStyle(fontSize: 13, color: Color(0xFF4A4E69), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

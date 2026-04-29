import 'package:flutter/material.dart';
import '../models/ambiente.dart';

class AmbienteDetalheScreen extends StatelessWidget {
  final Ambiente ambiente;

  const AmbienteDetalheScreen({super.key, required this.ambiente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Detalhes do Ambiente',
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB7B2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.location_city_rounded, size: 80, color: Color(0xFF9D0208)),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        ambiente.nome,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF4A4E69),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        ambiente.descricao,
                        style: const TextStyle(fontSize: 16, color: Color(0xFF6A6E89), height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '📍 Latitude: ${ambiente.latitude.toStringAsFixed(5)}',
                              style: const TextStyle(fontSize: 14, color: Color(0xFF4A4E69), fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '📍 Longitude: ${ambiente.longitude.toStringAsFixed(5)}',
                              style: const TextStyle(fontSize: 14, color: Color(0xFF4A4E69), fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '📏 Raio de interação: ${ambiente.raioMetros.toStringAsFixed(0)}m',
                              style: const TextStyle(fontSize: 14, color: Color(0xFF4A4E69), fontWeight: FontWeight.w600),
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
        ),
      ),
    );
  }
}

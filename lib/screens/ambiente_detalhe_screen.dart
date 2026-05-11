import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ambiente.dart';
import '../services/audio_service.dart';
import '../services/localizacao_service.dart';

class AmbienteDetalheScreen extends StatelessWidget {
  final Ambiente ambiente;
  final Position? posicaoAtual;
  final bool desbloqueado;

  const AmbienteDetalheScreen({
    super.key, 
    required this.ambiente,
    this.posicaoAtual,
    this.desbloqueado = false,
  });

  @override
  Widget build(BuildContext context) {
    bool dentroDaArea = false;
    final LocalizacaoService service = LocalizacaoService();

    if (posicaoAtual != null) {
      if (ambiente.poligono.length >= 3) {
        dentroDaArea = service.isPontoDentroDoPoligono(posicaoAtual!, ambiente.poligono);
      } else {
        final dist = service.distanciaEmMetros(
          lat1: posicaoAtual!.latitude,
          lon1: posicaoAtual!.longitude,
          lat2: ambiente.centro.latitude,
          lon2: ambiente.centro.longitude,
        );
        dentroDaArea = dist <= ambiente.raioMetros;
      }
    }

    String textoBotao = 'Entrar no Ambiente';
    Color corBotao = const Color(0xFF2D6A4F);
    bool podeEntrar = true;

    if (!desbloqueado) {
      textoBotao = 'Bloqueado pela Narrativa';
      corBotao = Colors.grey.shade600;
      podeEntrar = false;
    } else if (!dentroDaArea) {
      textoBotao = 'Muito longe para interagir';
      corBotao = Colors.grey.shade400;
      podeEntrar = false;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Detalhes do Ambiente',
          style:
              TextStyle(color: Color(0xFF4A4E69), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AudioService().playBackSfx();
            Navigator.pop(context);
          },
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          ambiente.imagem,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 120,
                            height: 120,
                            color: const Color(0xFFFFB7B2),
                            child: const Icon(Icons.location_city_rounded,
                                size: 60, color: Color(0xFF9D0208)),
                          ),
                        ),
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
                        style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6A6E89),
                            height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '📍 Centro (Lat): ${ambiente.centro.latitude.toStringAsFixed(5)}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4A4E69),
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '📍 Centro (Long): ${ambiente.centro.longitude.toStringAsFixed(5)}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4A4E69),
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botão de Interação
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: podeEntrar ? () {
                            AudioService().playClickSfx();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Entrando em ${ambiente.nome}... (Em breve)'),
                                backgroundColor: const Color(0xFF2D6A4F),
                              ),
                            );
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: corBotao,
                            disabledBackgroundColor: corBotao,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: podeEntrar ? 4 : 0,
                          ),
                          child: Text(
                            textoBotao,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: podeEntrar ? Colors.white : Colors.white70,
                            ),
                          ),
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

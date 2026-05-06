import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ambiente.dart';
import '../services/localizacao_service.dart';
import '../services/audio_service.dart';
import 'ambiente_detalhe_screen.dart';

class AmbientesScreen extends StatefulWidget {
  const AmbientesScreen({super.key});

  @override
  State<AmbientesScreen> createState() => _AmbientesScreenState();
}

class _AmbientesScreenState extends State<AmbientesScreen> {
  final LocalizacaoService _service = LocalizacaoService();
  List<Ambiente> _ambientes = [];
  Position? _posicaoAtual;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final jsonString =
        await rootBundle.loadString('assets/data/ambientes.json');
    final jsonList = jsonDecode(jsonString) as List;
    final ambientesCarregados =
        jsonList.map((j) => Ambiente.fromJson(j)).toList();

    final pos = await _service.obterUltimaPosicaoSalva();

    setState(() {
      _ambientes = ambientesCarregados;
      _posicaoAtual = pos;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Ambientes do Jogo',
          style:
              TextStyle(color: Color(0xFF4A4E69), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AudioService().playClickSfx();
            Navigator.pop(context);
          },
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
          child: _carregando
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ambientes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final ambiente = _ambientes[index];
                    return _AmbienteCard(
                      ambiente: ambiente,
                      posicaoAtual: _posicaoAtual,
                      service: _service,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _AmbienteCard extends StatelessWidget {
  final Ambiente ambiente;
  final Position? posicaoAtual;
  final LocalizacaoService service;

  const _AmbienteCard({
    required this.ambiente,
    required this.posicaoAtual,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    double? distancia;
    bool dentroDaArea = false;

    if (posicaoAtual != null) {
      distancia = service.distanciaEmMetros(
        lat1: posicaoAtual!.latitude,
        lon1: posicaoAtual!.longitude,
        lat2: ambiente.centro.latitude,
        lon2: ambiente.centro.longitude,
      );
      
      if (ambiente.poligono.length >= 3) {
        dentroDaArea = service.isPontoDentroDoPoligono(posicaoAtual!, ambiente.poligono);
      } else {
        // Fallback legado para os que ainda usam ponto central + raio
        dentroDaArea = distancia! <= ambiente.raioMetros;
      }
    }

    return GestureDetector(
      onTap: () {
        AudioService().playClickSfx();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AmbienteDetalheScreen(
              ambiente: ambiente,
              posicaoAtual: posicaoAtual,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: dentroDaArea ? Colors.white : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: dentroDaArea
              ? Border.all(color: const Color(0xFF2D6A4F), width: 2)
              : null,
          boxShadow: [
            if (dentroDaArea)
              BoxShadow(
                color: const Color(0xFF2D6A4F).withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              )
            else
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    ambiente.imagem,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: const Color(0xFFFFB7B2),
                      child: const Icon(Icons.place_rounded, color: Color(0xFF9D0208)),
                    ),
                  ),
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
              style: const TextStyle(
                  fontSize: 15, color: Color(0xFF6A6E89), height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📍 Centro (Lat): ${ambiente.centro.latitude.toStringAsFixed(5)}  |  Long: ${ambiente.centro.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4A4E69),
                        fontWeight: FontWeight.w600),
                  ),
                  if (distancia != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '🚶 Distância ao centro: ${distancia.toStringAsFixed(0)}m',
                        style: TextStyle(
                          fontSize: 13,
                          color: dentroDaArea
                              ? const Color(0xFF2D6A4F)
                              : const Color(0xFF9D0208),
                          fontWeight: FontWeight.bold,
                        ),
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/localizacao_service.dart';
import '../services/audio_service.dart';
import '../models/ambiente.dart';
import 'ambiente_detalhe_screen.dart';

class CampanhaScreen extends StatefulWidget {
  const CampanhaScreen({super.key});

  @override
  State<CampanhaScreen> createState() => _CampanhaScreenState();
}

class _CampanhaScreenState extends State<CampanhaScreen> {
  final LocalizacaoService _service = LocalizacaoService();
  Position? _posicao;
  String? _erro;
  bool _carregando = false;
  List<Ambiente> _ambientes = [];

  final LatLngBounds _limitesMapa = LatLngBounds(
    const LatLng(-22.834790669949925, -47.05333005212148), // Sudoeste
    const LatLng(-22.83179896419191, -47.05132320737695), // Nordeste
  );

  @override
  void initState() {
    super.initState();
    AudioService().playMapBgm();
    _carregarAmbientes().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _iniciar());
    });
  }

  Future<void> _carregarAmbientes() async {
    final jsonString = await rootBundle.loadString('assets/data/ambientes.json');
    final jsonList = jsonDecode(jsonString) as List;
    if (mounted) {
      setState(() {
        _ambientes = jsonList.map((j) => Ambiente.fromJson(j)).toList();
      });
    }
  }

  @override
  void dispose() {
    _service.pararMonitoramento();
    AudioService().stopBgm();
    super.dispose();
  }

  Future<void> _iniciar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final permissaoAtual = await _service.verificarPermissao();
      
      if (permissaoAtual == LocationPermission.deniedForever) {
        setState(() {
          _erro = 'Permissão negada permanentemente. Por favor, habilite nas configurações do app.';
          _carregando = false;
        });
        await Geolocator.openAppSettings();
        return;
      }

      if (permissaoAtual == LocationPermission.denied) {
        final novaPermissao = await _service.solicitarPermissao();
        if (novaPermissao == LocationPermission.denied || novaPermissao == LocationPermission.deniedForever) {
          setState(() {
            _erro = 'Permissão de localização necessária.';
            _carregando = false;
          });
          return;
        }
      }

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

  bool _estaNaAreaJogavel(Position pos) {
    return pos.latitude >= _limitesMapa.southWest.latitude &&
           pos.latitude <= _limitesMapa.northEast.latitude &&
           pos.longitude >= _limitesMapa.southWest.longitude &&
           pos.longitude <= _limitesMapa.northEast.longitude;
  }

  @override
  Widget build(BuildContext context) {
    bool mostrarLocalizador = false;
    if (_posicao != null) {
      mostrarLocalizador = _estaNaAreaJogavel(_posicao!);
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: const Text(
          'Campanha',
          style: TextStyle(color: Color(0xFF4A4E69), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AudioService().playClickSfx();
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xFFE2F0CB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4A4E69)),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFE2F0CB),
              child: _posicao == null 
                ? const SizedBox.shrink()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final screenHeight = constraints.maxHeight;
                      
                      final mapWidth = _limitesMapa.northEast.longitude - _limitesMapa.southWest.longitude;
                      final mapHeight = _limitesMapa.northEast.latitude - _limitesMapa.southWest.latitude;
                      
                      // Correção de Projeção Mercator para a latitude de Campinas (-22.83 graus).
                      // Como a Terra é esférica, 1 grau de longitude aqui é menor que 1 grau no Equador.
                      // Sem isso, o cálculo errava por ~8% e deixava você arrastar a imagem em 70 pixels!
                      const cosLat = 0.9216; 
                      
                      final viewportHeight = mapWidth * (screenHeight / screenWidth) * cosLat;
                      final extraHeight = viewportHeight - mapHeight;
                      
                      LatLngBounds constraintBounds = _limitesMapa;
                      
                      if (extraHeight > 0) {
                        // Folga de 1.001 é menos de 1 pixel real, trava completamente o arraste
                        constraintBounds = LatLngBounds(
                          LatLng(_limitesMapa.southWest.latitude - (extraHeight / 2) * 1.001, _limitesMapa.southWest.longitude),
                          LatLng(_limitesMapa.northEast.latitude + (extraHeight / 2) * 1.001, _limitesMapa.northEast.longitude),
                        );
                      } else {
                        final viewportWidth = (mapHeight / cosLat) * (screenWidth / screenHeight);
                        final extraWidth = viewportWidth - mapWidth;
                        constraintBounds = LatLngBounds(
                          LatLng(_limitesMapa.southWest.latitude, _limitesMapa.southWest.longitude - (extraWidth / 2) * 1.001),
                          LatLng(_limitesMapa.northEast.latitude, _limitesMapa.northEast.longitude + (extraWidth / 2) * 1.001),
                        );
                      }

                      return FlutterMap(
                        options: MapOptions(
                          initialCameraFit: CameraFit.bounds(
                            bounds: _limitesMapa,
                            padding: EdgeInsets.zero,
                          ),
                          cameraConstraint: CameraConstraint.contain(
                            bounds: constraintBounds,
                          ),
                          maxZoom: 20.0,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                          ),
                        ),
                        children: [
                          OverlayImageLayer(
                            overlayImages: [
                              OverlayImage(
                                bounds: _limitesMapa,
                                imageProvider: const AssetImage('assets/images/mapa.png'),
                              ),
                            ],
                          ),
                          if (mostrarLocalizador && _posicao != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(_posicao!.latitude, _posicao!.longitude),
                                  width: 40,
                                  height: 40,
                                  child: Image.asset('assets/images/jogador/indicador.png'),
                                ),
                              ],
                            ),
                          // Markers dos ambientes sempre renderizam
                          MarkerLayer(
                            markers: _ambientes.map((ambiente) {
                              bool podeEntrar = false;
                              if (_posicao != null) {
                                if (ambiente.poligono.length >= 3) {
                                  podeEntrar = _service.isPontoDentroDoPoligono(_posicao!, ambiente.poligono);
                                } else {
                                  final dist = _service.distanciaEmMetros(
                                    lat1: _posicao!.latitude,
                                    lon1: _posicao!.longitude,
                                    lat2: ambiente.centro.latitude,
                                    lon2: ambiente.centro.longitude,
                                  );
                                  podeEntrar = dist <= ambiente.raioMetros;
                                }
                              }

                              return Marker(
                                point: ambiente.centro,
                                width: 100,
                                height: 40,
                                alignment: Alignment.topCenter,
                                child: GestureDetector(
                                  onTap: () {
                                    AudioService().playClickSfx();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AmbienteDetalheScreen(
                                          ambiente: ambiente,
                                          posicaoAtual: _posicao,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: podeEntrar ? const Color(0xFF2D6A4F) : Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: podeEntrar ? Colors.white : const Color(0xFF4A4E69), 
                                        width: 2,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      ambiente.nome,
                                      style: TextStyle(
                                        color: podeEntrar ? Colors.white : const Color(0xFF4A4E69),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_carregando)
                      const CircularProgressIndicator(),
                    if (_erro != null)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(_erro!, style: const TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _iniciar,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Tentar novamente'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red.shade900,
                            ),
                          ),
                        ],
                      ),
                    if (_posicao != null && !mostrarLocalizador)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                          ],
                        ),
                        child: const Text(
                          'Usuário fora da área jogável',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

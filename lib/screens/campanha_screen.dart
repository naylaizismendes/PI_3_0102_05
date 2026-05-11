import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/localizacao_service.dart';
import '../services/firestore_service.dart';
import '../services/audio_service.dart';
import '../models/ambiente.dart';
import '../models/game_progress.dart';
import 'ambiente_detalhe_screen.dart';

class CampanhaScreen extends StatefulWidget {
  const CampanhaScreen({super.key});

  @override
  State<CampanhaScreen> createState() => _CampanhaScreenState();
}

class _CampanhaScreenState extends State<CampanhaScreen> with SingleTickerProviderStateMixin {
  final LocalizacaoService _service = LocalizacaoService();
  final FirestoreService _firestoreService = FirestoreService();
  Position? _posicao;
  String? _erro;
  bool _carregando = false;
  late Future<List<Ambiente>> _futureAmbientes;
  GameProgress _gameProgress = GameProgress.initial();
  
  AnimationController? _animController;
  Animation<double>? _bounceAnimation;

  // VARIAVEIS DE CALIBRACAO DA IMAGEM DO MAPA
  // Ajuste estes valores caso o mapa desenhado (ruas, árvores) não bata com o GPS real.
  // Valores positivos na Lat movem a imagem pro Norte. Positivos na Lng movem pro Leste.
  static const double _offsetLat =  0.000040; // Ajuste inicial estimado para o Sul
  static const double _offsetLng =  -0.000040;  // Ajuste inicial estimado para o Leste

  final LatLngBounds _limitesMapa = LatLngBounds(
    LatLng(-22.834790669949925 + _offsetLat, -47.05333005212148 + _offsetLng), // Sudoeste
    LatLng(-22.83179896419191 + _offsetLat, -47.05132320737695 + _offsetLng), // Nordeste
  );

  @override
  void initState() {
    super.initState();
    AudioService().playMapBgm();
    
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _bounceAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _animController!, curve: Curves.easeInOut),
    );

    _futureAmbientes = _carregarAmbientes();
    _carregarProgresso();
    WidgetsBinding.instance.addPostFrameCallback((_) => _iniciar());
  }

  Future<List<Ambiente>> _carregarAmbientes() async {
    final jsonString = await rootBundle.loadString('assets/data/ambientes.json');
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((j) => Ambiente.fromJson(j)).toList();
  }


  Future<void> _carregarProgresso() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final progress = await _firestoreService.getProgress(user.uid);
      if (mounted) {
        setState(() => _gameProgress = progress);
      }
    } catch (_) {
    }
  }

  @override
  void dispose() {
    _animController?.dispose();
    _service.pararMonitoramento();
    // A música agora é global e contínua, não para aqui.
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
            AudioService().playBackSfx();
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
                          // Markers dos ambientes via FutureBuilder (renderizados primeiro, para ficarem no fundo)
                          FutureBuilder<List<Ambiente>>(
                            future: _futureAmbientes,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const MarkerLayer(markers: []);
                              
                              final ambientes = snapshot.data!;
                              return MarkerLayer(
                                markers: ambientes.map((ambiente) {
                                  final desbloqueado = _gameProgress.isEnvironmentUnlocked(ambiente.id);

                                  bool dentroDoPoligono = false;
                                  if (_posicao != null) {
                                    if (ambiente.poligono.length >= 3) {
                                      dentroDoPoligono = _service.isPontoDentroDoPoligono(_posicao!, ambiente.poligono);
                                    } else {
                                      final dist = _service.distanciaEmMetros(
                                        lat1: _posicao!.latitude,
                                        lon1: _posicao!.longitude,
                                        lat2: ambiente.centro.latitude,
                                        lon2: ambiente.centro.longitude,
                                      );
                                      dentroDoPoligono = dist <= ambiente.raioMetros;
                                    }
                                  }


                                  final bool podeEntrar = desbloqueado && dentroDoPoligono;

                                  return Marker(
                                    point: ambiente.centro,
                                    width: 80,
                                    height: 104, // 52 * 2
                                    alignment: Alignment.center,
                                    child: Align(
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
                                              desbloqueado: desbloqueado,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: !desbloqueado
                                                ? Colors.grey.shade700
                                                : podeEntrar
                                                  ? const Color(0xFF2D6A4F)
                                                  : Colors.white.withOpacity(0.9),
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
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (!desbloqueado)
                                                  const Padding(
                                                    padding: EdgeInsets.only(right: 4),
                                                    child: Icon(Icons.lock, size: 12, color: Colors.white70),
                                                  ),
                                                Flexible(
                                                  child: Text(
                                                    ambiente.nome,
                                                    style: TextStyle(
                                                      color: !desbloqueado
                                                        ? Colors.white70
                                                        : podeEntrar
                                                          ? Colors.white
                                                          : const Color(0xFF4A4E69),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Setinha apontando para baixo usando um container rotacionado
                                          Transform.translate(
                                            offset: const Offset(0, -4), // Sobe a setinha para mesclar e tampar a borda de baixo do card
                                            child: Transform.rotate(
                                              angle: 3.14159 / 4, // Rotaciona 45 graus para o losango virar uma seta
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: !desbloqueado
                                                    ? Colors.grey.shade700
                                                    : podeEntrar
                                                      ? const Color(0xFF2D6A4F)
                                                      : Colors.white.withOpacity(0.9),
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color: podeEntrar ? Colors.white : const Color(0xFF4A4E69), 
                                                      width: 2,
                                                    ),
                                                    right: BorderSide(
                                                      color: podeEntrar ? Colors.white : const Color(0xFF4A4E69), 
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          // Marcador do jogador (renderizado por último, para ficar sempre no topo)
                          if (mostrarLocalizador && _posicao != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(_posicao!.latitude, _posicao!.longitude),
                                  width: 48,
                                  height: 96,
                                  alignment: Alignment.center,
                                  child: IgnorePointer(
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: _bounceAnimation != null 
                                        ? AnimatedBuilder(
                                          animation: _bounceAnimation!,
                                          builder: (context, child) {
                                            return Transform.translate(
                                              offset: Offset(0, _bounceAnimation!.value),
                                              child: child,
                                            );
                                          },
                                          child: Image.asset('assets/images/jogador/indicador.png'),
                                        )
                                      : Image.asset('assets/images/jogador/indicador.png'),
                                    ),
                                  ),
                                  ),
                                ],
                            ),
                        ],
                      );
                    },
                  ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 12),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C3A1E),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _gameProgress.jogoFinalizado
                            ? Icons.emoji_events_rounded
                            : Icons.navigation_rounded,
                        color: const Color(0xFFFFD6A5),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _gameProgress.orientacaoAtual,
                        style: const TextStyle(
                          color: Color(0xFFFFE8CC),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

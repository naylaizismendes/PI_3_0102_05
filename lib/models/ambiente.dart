import 'package:latlong2/latlong.dart';

class Ambiente {
  final String id;
  final String nome;
  final String descricao;
  final List<LatLng> poligono;
  final double raioMetros; // Legado
  final bool desbloqueado;
  final String imagem;

  // O centro será calculado automaticamente com base no polígono
  final LatLng centro;

  Ambiente({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.poligono,
    this.raioMetros = 0,
    required this.imagem,
    this.desbloqueado = false,
  }) : centro = _calcularCentro(poligono);

  static LatLng _calcularCentro(List<LatLng> pontos) {
    if (pontos.isEmpty) return const LatLng(0, 0);
    double latSum = 0;
    double lngSum = 0;
    for (var ponto in pontos) {
      latSum += ponto.latitude;
      lngSum += ponto.longitude;
    }
    return LatLng(latSum / pontos.length, lngSum / pontos.length);
  }

  factory Ambiente.fromJson(Map<String, dynamic> json) {
    List<LatLng> pts = [];
    if (json['poligono'] != null) {
      for (var p in json['poligono']) {
        pts.add(LatLng(p['lat'], p['lng']));
      }
    } else if (json['latitude'] != null && json['longitude'] != null) {
      // Fallback para o modelo antigo caso ainda existam dados não migrados
      pts.add(LatLng((json['latitude'] as num).toDouble(), (json['longitude'] as num).toDouble()));
    }

    return Ambiente(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      poligono: pts,
      raioMetros: (json['raioMetros'] as num?)?.toDouble() ?? 0,
      imagem: json['imagem'] ?? 'assets/images/player_icon.png',
      desbloqueado: json['desbloqueado'] ?? false,
    );
  }
}

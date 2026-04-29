class Ambiente {
  final String id;
  final String nome;
  final String descricao;
  final double latitude;
  final double longitude;
  final double raioMetros;
  final bool desbloqueado;
  final String imagem;

  const Ambiente({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.latitude,
    required this.longitude,
    required this.raioMetros,
    required this.imagem,
    this.desbloqueado = false,
  });

  factory Ambiente.fromJson(Map<String, dynamic> json) {
    return Ambiente(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      raioMetros: (json['raioMetros'] as num).toDouble(),
      imagem: json['imagem'] ?? 'assets/images/player_icon.png',
      desbloqueado: json['desbloqueado'] ?? false,
    );
  }
}

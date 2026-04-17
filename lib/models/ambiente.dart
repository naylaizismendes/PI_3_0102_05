/// Representa um ambiente do RPG mapeado para uma localização real do campus.
///
/// Cada ambiente possui coordenadas (lat/long) e um raio de ativação em metros.
/// O jogador "entra" no ambiente quando sua posição está dentro desse raio.
class Ambiente {
  final String id;
  final String nome;
  final String descricao;
  final double latitude;
  final double longitude;
  final double raioMetros;
  final bool desbloqueado;

  const Ambiente({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.latitude,
    required this.longitude,
    required this.raioMetros,
    this.desbloqueado = false,
  });
}

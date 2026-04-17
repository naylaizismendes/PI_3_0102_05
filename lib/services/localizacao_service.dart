import 'package:geolocator/geolocator.dart';

/// Serviço responsável por encapsular toda a lógica de geolocalização.
///
/// Manter isso em um arquivo separado (em vez de dentro da tela) facilita:
/// - Reutilizar o serviço em várias telas
/// - Testar a lógica de forma isolada
/// - Trocar a implementação no futuro sem quebrar as telas
class LocalizacaoService {
  /// Solicita permissão e retorna a posição atual do dispositivo.
  ///
  /// Lança uma [Exception] com mensagem amigável caso algo dê errado,
  /// para que a tela possa exibir o erro ao usuário.
  Future<Position> obterPosicaoAtual() async {
    // 1. Verifica se o GPS do dispositivo está ligado.
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      throw Exception('Serviço de localização desativado. Ative o GPS.');
    }

    // 2. Verifica/solicita permissão de uso da localização.
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        throw Exception('Permissão de localização negada pelo usuário.');
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão negada permanentemente. Ajuste nas configurações.',
      );
    }

    // 3. Tudo certo: captura a posição atual com alta precisão.
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Calcula a distância em metros entre duas coordenadas.
  /// Útil para verificar se o jogador está dentro do raio de um ambiente.
  double distanciaEmMetros({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}

import 'dart:async';
import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço responsável por encapsular toda a lógica de geolocalização.
///
/// Manter isso em um arquivo separado (em vez de dentro da tela) facilita:
/// - Reutilizar o serviço em várias telas
/// - Testar a lógica de forma isolada
/// - Trocar a implementação no futuro sem quebrar as telas
class LocalizacaoService {
  // StreamSubscription mantém a referência ao listener do GPS,
  // permitindo cancelá-lo quando a tela for descartada.
  StreamSubscription<Position>? _posicaoSubscription;

  /// Verifica se o serviço de localização está ativo e se o aplicativo
  /// já possui permissão concedida.
  Future<LocationPermission> verificarPermissao() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      return LocationPermission.denied;
    }
    return Geolocator.checkPermission();
  }

  /// Exibe o pop-up nativo do sistema operacional solicitando permissão
  /// de localização ao usuário.
  ///
  /// Retorna o [LocationPermission] resultante após a interação.
  /// Lança [Exception] quando o GPS está desligado.
  Future<LocationPermission> solicitarPermissao() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      throw Exception('Serviço de localização desativado. Ative o GPS.');
    }

    // requestPermission() dispara o alerta nativo do iOS/Android.
    final permissao = await Geolocator.requestPermission();
    developer.log(
      'Permissão de localização: $permissao',
      name: 'LocalizacaoService',
    );
    return permissao;
  }

  /// Solicita permissão (se necessário) e retorna a posição atual do
  /// dispositivo uma única vez.
  Future<Position> obterPosicaoAtual() async {
    final permissao = await _garantirPermissao();
    if (permissao != LocationPermission.whileInUse &&
        permissao != LocationPermission.always) {
      _lancarErroPermissao(permissao);
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    developer.log(
      'Posição capturada — lat: ${pos.latitude}, lon: ${pos.longitude}',
      name: 'LocalizacaoService',
    );
    await _salvarUltimaPosicao(pos);

    return pos;
  }

  /// Inicia o monitoramento contínuo do GPS e imprime cada atualização
  /// no console do desenvolvedor.
  ///
  /// O [onPosicao] é chamado sempre que uma nova coordenada chega.
  /// O [onErro] é chamado caso ocorra alguma falha durante o stream.
  ///
  /// Chame [pararMonitoramento] quando a tela for descartada.
  Future<void> iniciarMonitoramento({
    required void Function(Position posicao) onPosicao,
    void Function(Object erro)? onErro,
  }) async {
    // Garante que já temos permissão antes de abrir o stream.
    final permissao = await _garantirPermissao();
    if (permissao != LocationPermission.whileInUse &&
        permissao != LocationPermission.always) {
      _lancarErroPermissao(permissao);
    }

    const configuracoes = LocationSettings(
      accuracy: LocationAccuracy.high,
      // Emite nova posição a cada 5 metros percorridos (Android).
      distanceFilter: 5,
    );

    _posicaoSubscription = Geolocator.getPositionStream(
      locationSettings: configuracoes,
    ).listen(
      (Position pos) {
        // Imprime continuamente no console do desenvolvedor.
        developer.log(
          '[GPS] lat: ${pos.latitude.toStringAsFixed(6)}, '
          'lon: ${pos.longitude.toStringAsFixed(6)}, '
          'precisão: ${pos.accuracy.toStringAsFixed(1)} m',
          name: 'LocalizacaoService',
        );
        _salvarUltimaPosicao(pos);
        onPosicao(pos);
      },
      onError: (Object erro) {
        developer.log(
          'Erro no stream de GPS: $erro',
          name: 'LocalizacaoService',
          error: erro,
        );
        onErro?.call(erro);
      },
    );
  }

  /// Para o monitoramento contínuo e libera recursos.
  /// Deve ser chamado no [State.dispose] da tela que usa o stream.
  void pararMonitoramento() {
    _posicaoSubscription?.cancel();
    _posicaoSubscription = null;
    developer.log('Monitoramento GPS encerrado.', name: 'LocalizacaoService');
  }

  /// Calcula a distância em metros entre duas coordenadas.
  double distanciaEmMetros({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Salva a última posição conhecida localmente.
  Future<void> _salvarUltimaPosicao(Position pos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ultima_lat', pos.latitude);
    await prefs.setDouble('ultima_lon', pos.longitude);
  }

  /// Recupera a última posição salva, se houver.
  Future<Position?> obterUltimaPosicaoSalva() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('ultima_lat');
    final lon = prefs.getDouble('ultima_lon');
    if (lat != null && lon != null) {
      return Position(
        latitude: lat,
        longitude: lon,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
    }
    return null;
  }

  Future<LocationPermission> _garantirPermissao() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      throw Exception('Serviço de localização desativado. Ative o GPS.');
    }

    LocationPermission permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      // Dispara o alerta nativo do sistema operacional.
      permissao = await Geolocator.requestPermission();
    }

    return permissao;
  }

  Never _lancarErroPermissao(LocationPermission permissao) {
    if (permissao == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão negada permanentemente. '
        'Abra as Configurações do dispositivo para habilitá-la.',
      );
    }
    throw Exception('Permissão de localização negada pelo usuário.');
  }
}

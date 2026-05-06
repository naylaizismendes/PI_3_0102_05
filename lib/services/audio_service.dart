import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  Future<void> playMenuBgm() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    // Para evitar erros caso o arquivo não exista no modo dev, podemos usar try/catch ou deixar o audioplayers lidar.
    try {
      await _bgmPlayer.play(AssetSource('audio/menu.mp3'));
    } catch (e) {
      print('Erro ao tocar BGM Menu: $e');
    }
  }

  Future<void> playMapBgm() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    try {
      await _bgmPlayer.play(AssetSource('audio/mapa.mp3'));
    } catch (e) {
      print('Erro ao tocar BGM Mapa: $e');
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  Future<void> playClickSfx() async {
    try {
      await _sfxPlayer.play(AssetSource('audio/click.mp3'));
    } catch (e) {
      print('Erro ao tocar SFX: $e');
    }
  }
}

import 'package:flutter/widgets.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService with WidgetsBindingObserver {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal() {
    WidgetsBinding.instance.addObserver(this);
    
    // Configurar o AudioContext manualmente para as plataformas
    AudioPlayer.global.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none, // Fundamental para não parar a música
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      if (_isBgmPlaying) {
        _bgmPlayer.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isBgmPlaying) {
        _bgmPlayer.resume();
      }
    }
  }

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isBgmPlaying = false;

  Future<void> playGlobalBgm() async {
    if (_isBgmPlaying) return; // Não reinicia a música se já estiver tocando
    
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.7); // Volume (70%)
    
    try {
      await _bgmPlayer.play(AssetSource('audio/menu music.mp3'));
      _isBgmPlaying = true;
    } catch (e) {
      print('Erro ao tocar BGM Global: $e');
    }
  }

  // Mantemos as funções antigas apontando para a nova, para não quebrar as telas existentes
  Future<void> playMenuBgm() async => playGlobalBgm();
  Future<void> playMapBgm() async => playGlobalBgm();

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
    _isBgmPlaying = false;
  }

  Future<void> playClickSfx() async {
    try {
      await _sfxPlayer.play(AssetSource('audio/buttom click.mp3'));
    } catch (e) {
      print('Erro ao tocar SFX: $e');
    }
  }

  Future<void> playBackSfx() async {
    try {
      await _sfxPlayer.play(AssetSource('audio/click voltar.mp3'));
    } catch (e) {
      print('Erro ao tocar SFX (Voltar): $e');
    }
  }
}

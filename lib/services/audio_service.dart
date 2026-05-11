import 'package:flutter/widgets.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService with WidgetsBindingObserver {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal() {
    WidgetsBinding.instance.addObserver(this);
    
    AudioPlayer.global.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none,
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
    if (_isBgmPlaying) return;
    
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.7);
    
    try {
      await _bgmPlayer.play(AssetSource('audio/menu music.mp3'));
      _isBgmPlaying = true;
    } catch (_) {}
  }

  Future<void> playMenuBgm() async => playGlobalBgm();
  Future<void> playMapBgm() async => playGlobalBgm();

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
    _isBgmPlaying = false;
  }

  Future<void> playClickSfx() async {
    try {
      await _sfxPlayer.play(AssetSource('audio/buttom click.mp3'));
    } catch (_) {}
  }

  Future<void> playBackSfx() async {
    try {
      await _sfxPlayer.play(AssetSource('audio/click voltar.mp3'));
    } catch (_) {}
  }
}

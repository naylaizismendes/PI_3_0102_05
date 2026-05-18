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

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _sceneBgmPlayer = AudioPlayer();
  bool _isBgmPlaying = false;
  bool _isBgmPausedManually = false;
  bool _isSceneBgmPlaying = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      if (_isBgmPlaying) {
        _bgmPlayer.pause();
      }
      if (_isSceneBgmPlaying) {
        _sceneBgmPlayer.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isBgmPlaying && !_isBgmPausedManually) {
        _bgmPlayer.resume();
      }
      if (_isSceneBgmPlaying) {
        _sceneBgmPlayer.resume();
      }
    }
  }

  Future<void> playGlobalBgm() async {
    if (_isBgmPlaying) return;
    
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.7);
    
    try {
      await _bgmPlayer.play(AssetSource('audio/menu music.mp3'));
      _isBgmPlaying = true;
      _isBgmPausedManually = false;
    } catch (_) {}
  }

  Future<void> playSceneBgm(String assetPath) async {
    if (_isSceneBgmPlaying) return;
    await _sceneBgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _sceneBgmPlayer.setVolume(0.5);
    try {
      await _sceneBgmPlayer.play(AssetSource(assetPath));
      _isSceneBgmPlaying = true;
    } catch (_) {}
  }

  Future<void> stopSceneBgm() async {
    await _sceneBgmPlayer.stop();
    _isSceneBgmPlaying = false;
  }

  Future<void> playMenuBgm() async => playGlobalBgm();
  Future<void> playMapBgm() async => playGlobalBgm();

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
    _isBgmPlaying = false;
    _isBgmPausedManually = false;
  }

  Future<void> pauseBgm() async {
    if (_isBgmPlaying) {
      _isBgmPausedManually = true;
      await _bgmPlayer.pause();
    }
  }

  Future<void> resumeBgm() async {
    if (_isBgmPlaying) {
      _isBgmPausedManually = false;
      await _bgmPlayer.resume();
    }
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

  Future<void> playDialogSfx() async {
    try {
      await _sfxPlayer.play(AssetSource('audio/dialogo.mp3'));
    } catch (_) {}
  }
}

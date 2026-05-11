import 'package:cloud_firestore/cloud_firestore.dart';

class GameProgress {
  final int currentScene;
  final Map<String, bool> completedScenes;
  final DateTime? updatedAt;
  final bool jogoFinalizado;

  const GameProgress({
    required this.currentScene,
    required this.completedScenes,
    this.updatedAt,
    this.jogoFinalizado = false,
  });

  factory GameProgress.initial() {
    return GameProgress(
      currentScene: 1,
      completedScenes: {
        'cena_1': false,
        'cena_2': false,
        'cena_3': false,
        'cena_4': false,
        'cena_5': false,
        'cena_6': false,
        'cena_7': false,
        'cena_8': false,
      },
    );
  }

  factory GameProgress.fromFirestore(Map<String, dynamic> data) {
    final rawScenes = data['completedScenes'] as Map<String, dynamic>? ?? {};
    final scenes = <String, bool>{};

    for (int i = 1; i <= 8; i++) {
      final key = 'cena_$i';
      scenes[key] = rawScenes[key] == true;
    }

    return GameProgress(
      currentScene: (data['currentScene'] as num?)?.toInt() ?? 1,
      completedScenes: scenes,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      jogoFinalizado: data['jogoFinalizado'] == true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'currentScene': currentScene,
      'completedScenes': completedScenes,
      'updatedAt': FieldValue.serverTimestamp(),
      'jogoFinalizado': jogoFinalizado,
    };
  }

  bool isSceneCompleted(int sceneIndex) {
    return completedScenes['cena_$sceneIndex'] == true;
  }

  static const Map<String, int?> _unlockRequirements = {
    'h15': null,
    'biblioteca': 1,
    'cta': 3,
    'lab_a': 4,
    'lab_b': 5,
    'auditorio': 6,
  };

  bool isEnvironmentUnlocked(String ambienteId) {
    final requirement = _unlockRequirements[ambienteId];
    if (requirement == null) return true;
    return isSceneCompleted(requirement);
  }

  Map<String, bool> getUnlockedEnvironments() {
    return _unlockRequirements.map(
      (ambienteId, _) => MapEntry(ambienteId, isEnvironmentUnlocked(ambienteId)),
    );
  }

  static const Map<int, String> _orientacoes = {
    1: 'Vá para o H15',
    2: 'Vá para a Biblioteca',
    3: 'Volte para o H15',
    4: 'Vá para o CTA',
    5: 'Vá para o Lab A',
    6: 'Vá para o Lab B',
    7: 'Vá para o Auditório',
    8: 'Volte para o H15',
  };

  String get orientacaoAtual {
    if (jogoFinalizado) return 'Jornada concluída!';
    return _orientacoes[currentScene] ?? 'Jornada concluída!';
  }

  GameProgress completeScene(int sceneIndex) {
    final updatedScenes = Map<String, bool>.from(completedScenes);
    updatedScenes['cena_$sceneIndex'] = true;

    int nextScene = currentScene;
    if (sceneIndex >= currentScene && sceneIndex < 8) {
      nextScene = sceneIndex + 1;
    }

    return GameProgress(
      currentScene: nextScene,
      completedScenes: updatedScenes,
      updatedAt: DateTime.now(),
    );
  }

  GameProgress finalizarJogo() {
    return GameProgress(
      currentScene: currentScene,
      completedScenes: completedScenes,
      updatedAt: DateTime.now(),
      jogoFinalizado: true,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Avaliacao {
  final int acertos;
  final bool aprovado;
  final bool completada;

  const Avaliacao({
    this.acertos = 0,
    this.aprovado = false,
    this.completada = false,
  });

  factory Avaliacao.fromMap(Map<String, dynamic> data) {
    return Avaliacao(
      acertos: (data['acertos'] as num?)?.toInt() ?? 0,
      aprovado: data['aprovado'] == true,
      completada: data['completada'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'acertos': acertos,
      'aprovado': aprovado,
      'completada': completada,
    };
  }

  Avaliacao copyWith({int? acertos, bool? aprovado, bool? completada}) {
    return Avaliacao(
      acertos: acertos ?? this.acertos,
      aprovado: aprovado ?? this.aprovado,
      completada: completada ?? this.completada,
    );
  }
}

class Bencaos {
  final bool livroFlutter;
  final bool anotacoesValdir;
  final bool rascunhoJulia;

  const Bencaos({
    this.livroFlutter = false,
    this.anotacoesValdir = false,
    this.rascunhoJulia = false,
  });

  factory Bencaos.fromMap(Map<String, dynamic> data) {
    return Bencaos(
      livroFlutter: data['livroFlutter'] == true,
      anotacoesValdir: data['anotacoesValdir'] == true,
      rascunhoJulia: data['rascunhoJulia'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'livroFlutter': livroFlutter,
      'anotacoesValdir': anotacoesValdir,
      'rascunhoJulia': rascunhoJulia,
    };
  }

  Bencaos conceder(String nome) {
    return Bencaos(
      livroFlutter: nome == 'livroFlutter' ? true : livroFlutter,
      anotacoesValdir: nome == 'anotacoesValdir' ? true : anotacoesValdir,
      rascunhoJulia: nome == 'rascunhoJulia' ? true : rascunhoJulia,
    );
  }

  int get totalBencaos =>
      (livroFlutter ? 1 : 0) +
      (anotacoesValdir ? 1 : 0) +
      (rascunhoJulia ? 1 : 0);
}

class GameProgress {
  final int cenaAtual;
  final DateTime? atualizadoEm;
  final bool jogoFinalizado;
  final Bencaos bencaos;
  final Map<String, Avaliacao> avaliacoes;

  const GameProgress({
    required this.cenaAtual,
    this.atualizadoEm,
    this.jogoFinalizado = false,
    this.bencaos = const Bencaos(),
    required this.avaliacoes,
  });

  factory GameProgress.initial() {
    return const GameProgress(
      cenaAtual: 1,
      avaliacoes: {
        'primeiraProva': Avaliacao(),
        'provaFinal': Avaliacao(),
        'recuperacao': Avaliacao(),
      },
    );
  }

  factory GameProgress.fromFirestore(Map<String, dynamic> data) {
    final rawAvaliacoes = data['avaliacoes'] as Map<String, dynamic>? ?? {};
    final avaliacoes = <String, Avaliacao>{};
    for (final tipo in ['primeiraProva', 'provaFinal', 'recuperacao']) {
      final raw = rawAvaliacoes[tipo] as Map<String, dynamic>?;
      avaliacoes[tipo] = raw != null ? Avaliacao.fromMap(raw) : const Avaliacao();
    }

    final rawBencaos = data['bencaos'] as Map<String, dynamic>?;

    return GameProgress(
      cenaAtual: ((data['cenaAtual'] ?? data['currentScene']) as num?)?.toInt() ?? 1,
      atualizadoEm: ((data['atualizadoEm'] ?? data['updatedAt']) as Timestamp?)?.toDate(),
      jogoFinalizado: data['jogoFinalizado'] == true,
      bencaos: rawBencaos != null ? Bencaos.fromMap(rawBencaos) : const Bencaos(),
      avaliacoes: avaliacoes,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cenaAtual': cenaAtual,
      'atualizadoEm': FieldValue.serverTimestamp(),
      'jogoFinalizado': jogoFinalizado,
      'bencaos': bencaos.toMap(),
      'avaliacoes': avaliacoes.map((k, v) => MapEntry(k, v.toMap())),
    };
  }

  bool get jogoVencido {
    if (!jogoFinalizado) return false;
    final recup = avaliacoes['recuperacao'];
    if (recup != null && recup.completada) {
      return recup.aprovado;
    }
    final finalTest = avaliacoes['provaFinal'];
    if (finalTest != null && finalTest.completada) {
      return finalTest.aprovado;
    }
    return false;
  }

  bool cenaCompletada(int indiceCena) {
    return cenaAtual > indiceCena;
  }

  static const Map<String, int?> _unlockRequirements = {
    'h15': null,
    'biblioteca': 1,
    'cta': 3,
    'lab_a': 4,
    'lab_b': 5,
    'auditorio': 6,
  };

  static const Map<String, List<int>> _cenasDoAmbiente = {
    'h15': [1, 3, 8],
    'biblioteca': [2],
    'cta': [4],
    'lab_a': [5],
    'lab_b': [6],
    'auditorio': [7],
  };

  static const Map<String, String> _backgroundDoAmbiente = {
    'h15': 'assets/images/ambients/h15-1.png',
    'biblioteca': 'assets/images/ambients/biblioteca.png',
    'cta': 'assets/images/ambients/CTA.png',
    'lab_a': 'assets/images/ambients/lab a.png',
    'lab_b': 'assets/images/ambients/lab b.png',
    'auditorio': 'assets/images/ambients/auditorio.png',
  };

  bool isEnvironmentUnlocked(String ambienteId) {
    final requirement = _unlockRequirements[ambienteId];
    if (requirement == null) return true;
    return cenaAtual > requirement;
  }

  bool isAmbienteAtivo(String ambienteId) {
    final cenas = _cenasDoAmbiente[ambienteId];
    if (cenas == null) return false;
    return cenas.contains(cenaAtual);
  }

  String? backgroundDoAmbiente(String ambienteId) {
    return _backgroundDoAmbiente[ambienteId];
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
    return _orientacoes[cenaAtual] ?? 'Jornada concluída!';
  }

  bool get recuperacaoNecessaria {
    final primeira = avaliacoes['primeiraProva'];
    final provaFinal = avaliacoes['provaFinal'];
    if (primeira == null || provaFinal == null) return false;
    return !primeira.aprovado && primeira.completada &&
           provaFinal.aprovado && provaFinal.completada;
  }

  GameProgress completarCena(int indiceCena) {
    int proximaCena = cenaAtual;
    bool proximoJogoFinalizado = jogoFinalizado;

    if (indiceCena == cenaAtual) {
      if (indiceCena == 7) {
         if (recuperacaoNecessaria) {
            proximaCena = 8;
         } else {
            proximoJogoFinalizado = true;
         }
      } else if (indiceCena == 8) {
         proximoJogoFinalizado = true;
      } else {
         proximaCena = indiceCena + 1;
      }
    }

    return GameProgress(
      cenaAtual: proximaCena,
      atualizadoEm: DateTime.now(),
      jogoFinalizado: proximoJogoFinalizado,
      bencaos: bencaos,
      avaliacoes: avaliacoes,
    );
  }

  GameProgress registrarAvaliacao(String tipo, Avaliacao avaliacao) {
    final avaliacoesAtualizadas = Map<String, Avaliacao>.from(avaliacoes);
    avaliacoesAtualizadas[tipo] = avaliacao;

    return GameProgress(
      cenaAtual: cenaAtual,
      atualizadoEm: DateTime.now(),
      jogoFinalizado: jogoFinalizado,
      bencaos: bencaos,
      avaliacoes: avaliacoesAtualizadas,
    );
  }

  GameProgress concederBencao(String nome) {
    return GameProgress(
      cenaAtual: cenaAtual,
      atualizadoEm: DateTime.now(),
      jogoFinalizado: jogoFinalizado,
      bencaos: bencaos.conceder(nome),
      avaliacoes: avaliacoes,
    );
  }

  GameProgress finalizarJogo() {
    return GameProgress(
      cenaAtual: cenaAtual,
      atualizadoEm: DateTime.now(),
      jogoFinalizado: true,
      bencaos: bencaos,
      avaliacoes: avaliacoes,
    );
  }
}

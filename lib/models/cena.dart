
enum PosicaoPersonagem { direita, esquerda }

class Personagem {
  final String nome;
  final String? assetImagem;

  const Personagem({
    required this.nome,
    this.assetImagem,
  });
}

class OpcaoResposta {
  final String texto;
  final bool correta;
  final List<Fala>? consequencia;
  final String? concedeBencao;

  const OpcaoResposta({
    required this.texto,
    this.correta = false,
    this.consequencia,
    this.concedeBencao,
  });
}

class Fala {
  final Personagem personagem;
  final String texto;
  final PosicaoPersonagem posicao;
  final List<OpcaoResposta>? opcoes;
  final String? bencaoAutoCompletar;
  final String? backgroundAsset;

  const Fala({
    required this.personagem,
    required this.texto,
    required this.posicao,
    this.opcoes,
    this.bencaoAutoCompletar,
    this.backgroundAsset,
  });
}

class Cena {
  final int id;
  final String backgroundAsset;
  final String? backgroundMusic;
  final List<Fala> falas;
  
  // Lógica de Prova
  final String? idProva;
  final int? acertosParaAprovacao;
  final List<Fala>? falasAprovado;
  final List<Fala>? falasReprovado;

  const Cena({
    required this.id,
    required this.backgroundAsset,
    this.backgroundMusic,
    required this.falas,
    this.idProva,
    this.acertosParaAprovacao,
    this.falasAprovado,
    this.falasReprovado,
  });
}

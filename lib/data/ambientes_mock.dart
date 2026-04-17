import '../models/ambiente.dart';

/// Lista estática (mock) dos ambientes do Campus I da PUC-Campinas.
///
/// Para a Sprint 1 usamos dados fixos em memória. Na Sprint 2 essa lista
/// será substituída por dados vindos de uma API REST / banco de dados.
///
/// ATENÇÃO: As coordenadas abaixo são aproximadas e devem ser ajustadas
/// pela equipe com medições reais feitas no campus.
const List<Ambiente> ambientesMock = [
  Ambiente(
    id: 'refeitorio',
    nome: 'Refeitório',
    descricao:
        'O cheiro de comida invade o ar. Mesas longas se estendem à sua '
        'frente. Aqui a fome dos heróis é saciada antes da próxima jornada.',
    latitude: -22.8353,
    longitude: -47.0553,
    raioMetros: 25,
  ),
  Ambiente(
    id: 'mescla',
    nome: 'Mescla',
    descricao:
        'Um espaço de convivência onde os estudantes se reúnem entre aulas. '
        'Risadas e conversas ecoam pelas paredes.',
    latitude: -22.8357,
    longitude: -47.0559,
    raioMetros: 20,
  ),
  Ambiente(
    id: 'h15',
    nome: 'Prédio H15',
    descricao:
        'Salas de aula e laboratórios. É aqui que os futuros '
        'programadores forjam seus feitiços em Dart e Flutter.',
    latitude: -22.8361,
    longitude: -47.0547,
    raioMetros: 30,
  ),
  Ambiente(
    id: 'h06',
    nome: 'Prédio H06',
    descricao:
        'Corredores silenciosos e salas movimentadas. Um dos pontos de '
        'encontro dos estudantes de Sistemas de Informação.',
    latitude: -22.8349,
    longitude: -47.0561,
    raioMetros: 30,
  ),
  Ambiente(
    id: 'biblioteca_manacas',
    nome: 'Biblioteca Manacás',
    descricao:
        'Estantes repletas de conhecimento milenar. O silêncio é regra e '
        'cada livro pode conter a próxima pista da sua aventura.',
    latitude: -22.8345,
    longitude: -47.0555,
    raioMetros: 35,
  ),
];

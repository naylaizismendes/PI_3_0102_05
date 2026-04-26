import '../models/ambiente.dart';

const List<Ambiente> ambientesMock = [
  Ambiente(
    id: 'h15',
    nome: 'H15',
    descricao: 'Salas de aula e laboratórios.'
        'Prédio primncipal para aqueles que estudam tecnologias.',
    latitude: -22.83403852745762,
    longitude: -47.05253054507469,
    raioMetros: 25,
  ),
  Ambiente(
    id: 'biblioteca',
    nome: 'Biblioteca',
    descricao: 'Estantes altas de livros e corredores silenciosos. '
        'Lugar de estudo e pesquisa.',
    latitude: -22.833647949051585,
    longitude: -47.05195387018311,
    raioMetros: 20,
  ),
  Ambiente(
    id: 'cta_ba',
    nome: 'CT/BA',
    descricao: 'Salas de engenahrias e T.I.'
        'Prédio para estudos mais avançados.',
    latitude: -22.833175792641924,
    longitude: -47.05262442238137,
    raioMetros: 30,
  ),
  Ambiente(
    id: 'lab_1',
    nome: 'Laboratório 1',
    descricao:
        'Sala de informática com monitores azuis e componentes de PC espalhados.'
        'Clima de oficina.',
    latitude: -22.83261464126679,
    longitude: -47.052624422410574,
    raioMetros: 30,
  ),
  Ambiente(
    id: 'lab_2',
    nome: 'Laboratório 2',
    descricao:
        'Ambiente moderno com terminais de programação e diagramas de rede. ',
    latitude: -22.832641833677098,
    longitude: -47.0528980077,
    raioMetros: 35,
  ),
  Ambiente(
    id: 'auditorio',
    nome: 'Auditório',
    descricao:
        'Palco imponente com iluminação focada. Clima de julgamento solene. ',
    latitude: -22.833144825588214,
    longitude: -47.053164815129875,
    raioMetros: 35,
  ),
];

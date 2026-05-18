import '../models/cena.dart';
import 'personagens_data.dart';

class H15Cenas {
  static final Map<int, Cena> cenas = {
    1: const Cena(
      id: 1,
      backgroundAsset: 'assets/images/ambients/h15-1.png',
      falas: [
        Fala(
          personagem: PersonagensData.valdir,
          texto: 'Você chegou atrasado, está com cara de aluno nota 0 mesmo.',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.valdir,
          texto: 'Olha, teremos as seguintes atividades avaliativas:\numa prova sobre Dart/Flutter, que será realizada neste prédio...',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.valdir,
          texto: '...e o trabalho final, que será apresentado no Auditório.',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.estudante,
          texto: 'Melhor começar a me preparar para isso tudo.',
          posicao: PosicaoPersonagem.esquerda,
        ),
        Fala(
          personagem: PersonagensData.caique,
          texto: 'E aí mano, vi que saiu da aula do Valdir.\nEle já passou trabalho para a turma?',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.estudante,
          texto: 'Já passou tudo, na verdade: prova e uma apresentação final.',
          posicao: PosicaoPersonagem.esquerda,
        ),
        Fala(
          personagem: PersonagensData.estudante,
          texto: 'Tô bem perdido, ele não deu mais nenhum detalhe, nem sei por onde começar.',
          posicao: PosicaoPersonagem.esquerda,
        ),
        Fala(
          personagem: PersonagensData.caique,
          texto: 'Cara, ele passou a prova primeiro, né? Foca nela.',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.caique,
          texto: 'Vai até a Biblioteca e pega o livro "Flutter na prática por ZAMMETTI, Frank W.".',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.caique,
          texto: 'Isso vai te salvar, foi o que me ajudou.',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.estudante,
          texto: 'Vou fazer isso, então. Obrigado pela dica!',
          posicao: PosicaoPersonagem.esquerda,
        ),
        Fala(
          personagem: PersonagensData.caique,
          texto: 'Mas seja cauteloso com a Vitória, a bibliotecária.',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.caique,
          texto: 'Ela pode ser complicada às vezes, faça de tudo para agradá-la.',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.estudante,
          texto: 'Beleza, já ajudou muito, valeu!',
          posicao: PosicaoPersonagem.esquerda,
        ),
      ],
    ),
    3: const Cena(
      id: 3,
      backgroundAsset: 'assets/images/ambients/h15-2.png',
      idProva: 'primeiraProva',
      acertosParaAprovacao: 2,
      falas: [
        Fala(
          personagem: PersonagensData.valdir,
          texto: 'Chegou a tempo dessa vez, pega um lugar e faça a prova em silêncio absoluto.',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.valdir,
          texto: '1. Como definimos em Dart que uma variável do tipo String pode aceitar valores nulos (Null Safety)?',
          posicao: PosicaoPersonagem.direita,
          opcoes: [
            OpcaoResposta(texto: 'a) String! nome;'),
            OpcaoResposta(texto: 'b) String? nome;', correta: true),
            OpcaoResposta(texto: 'c) null String nome;'),
          ],
        ),
        Fala(
          personagem: PersonagensData.valdir,
          texto: '2. Ao utilizar o package Provider no Flutter, qual método deve ser usado para acessar um objeto e ouvir suas mudanças, reconstruindo o widget sempre que o objeto mudar?',
          posicao: PosicaoPersonagem.direita,
          opcoes: [
            OpcaoResposta(texto: 'a) context.read<T>()'),
            OpcaoResposta(texto: 'b) context.watch<T>()', correta: true),
            OpcaoResposta(texto: 'c) context.find<T>()'),
          ],
        ),
        Fala(
          personagem: PersonagensData.valdir,
          texto: '3. No Flutter, qual é a principal finalidade de se utilizar uma "Key" em um Widget?',
          posicao: PosicaoPersonagem.direita,
          bencaoAutoCompletar: 'livroFlutter',
          opcoes: [
            OpcaoResposta(texto: 'a) Identificar o widget de forma única para preservar seu estado quando ele muda de posição.', correta: true),
            OpcaoResposta(texto: 'b) Aumentar a velocidade de renderização de imagens pesadas.'),
            OpcaoResposta(texto: 'c) Mudar a cor de fundo do widget automaticamente.'),
          ],
        ),
      ],
      falasAprovado: [
        Fala(
          personagem: PersonagensData.valdir,
          texto: 'DROGA! quer dizer... Nada mal, mas ainda tem a apresentação final, se prepare antes que seja muito tarde.',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.estudante,
          texto: '...',
          posicao: PosicaoPersonagem.esquerda,
        ),
      ],
      falasReprovado: [
        Fala(
          personagem: PersonagensData.valdir,
          texto: 'HAHAHAHAH! Já esperava isso de você! Boa sorte no trabalho final, vai precisar! HAHAHHAHAH.',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.estudante,
          texto: '...',
          posicao: PosicaoPersonagem.esquerda,
        ),
      ],
    ),
    8: const Cena(
      id: 8,
      backgroundAsset: 'assets/images/ambients/h15-3.png',
      idProva: 'recuperacao',
      acertosParaAprovacao: 3, // Assuming 3 is enough out of 5, or maybe 4? Let's use 3.
      falas: [
        Fala(
          personagem: PersonagensData.valdir,
          texto: 'Você é persistente, eu admito. Mas a persistência sem inteligência é apenas teimosia. Sente-se.',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.valdir,
          texto: 'Não! insolente ,agora Comece!\n(תתחיל עכשיו, חוצפן! אל תבזבז את זמני)',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.estudante,
          texto: 'Eita... endoidou de vez! Agora começou até a falar em outra língua...',
          posicao: PosicaoPersonagem.esquerda,
        ),
        // Question 1
        Fala(
          personagem: PersonagensData.valdir,
          texto: '1. Como definimos em Dart que uma variável do tipo String pode aceitar valores nulos (Null Safety)?',
          posicao: PosicaoPersonagem.direita,
          opcoes: [
            OpcaoResposta(texto: 'a) String! nome;'),
            OpcaoResposta(texto: 'b) String? nome;', correta: true),
            OpcaoResposta(texto: 'c) null String nome;'),
          ],
        ),
        // Question 2
        Fala(
          personagem: PersonagensData.valdir,
          texto: '2. Ao utilizar o package Provider no Flutter, qual método deve ser usado para acessar um objeto e ouvir suas mudanças, reconstruindo o widget sempre que o objeto mudar?',
          posicao: PosicaoPersonagem.direita,
          opcoes: [
            OpcaoResposta(texto: 'a) context.read<T>()'),
            OpcaoResposta(texto: 'b) context.watch<T>()', correta: true),
            OpcaoResposta(texto: 'c) context.find<T>()'),
          ],
        ),
        // Question 3
        Fala(
          personagem: PersonagensData.valdir,
          texto: '3. Qual é a principal finalidade de um "InheritedWidget" no Flutter?',
          posicao: PosicaoPersonagem.direita,
          opcoes: [
            OpcaoResposta(texto: 'a) Criar animações de herança entre widgets pais e filhos.'),
            OpcaoResposta(texto: 'b) Propagar informações eficientemente pela árvore de widgets para que descendentes possam acessá-las sem passá-las manualmente.', correta: true),
            OpcaoResposta(texto: 'c) Definir o tema global do aplicativo apenas para dispositivos Android.'),
          ],
        ),
        // Question 4
        Fala(
          personagem: PersonagensData.valdir,
          texto: '4. Qual é a diferença técnica entre os comandos "Hot Reload" e "Hot Restart" no Flutter?',
          posicao: PosicaoPersonagem.direita,
          bencaoAutoCompletar: 'anotacoesValdir',
          opcoes: [
            OpcaoResposta(texto: 'a) O Hot Reload injeta o código atualizado e mantém o estado; o Hot Restart reinicia o app e redefine o estado.', correta: true),
            OpcaoResposta(texto: 'b) O Hot Restart é usado apenas para mudanças de cor, enquanto o Hot Reload serve para mudar a lógica.'),
            OpcaoResposta(texto: 'c) O Hot Reload apaga os dados do cache e o Hot Restart os preserva.'),
          ],
        ),
        // Question 5
        Fala(
          personagem: PersonagensData.valdir,
          texto: '5. No ecossistema Dart, o que define um "Isolate"?',
          posicao: PosicaoPersonagem.direita,
          bencaoAutoCompletar: 'rascunhoJulia',
          opcoes: [
            OpcaoResposta(texto: 'a) É uma função que roda na thread principal compartilhando toda a memória do sistema.'),
            OpcaoResposta(texto: 'b) É um worker de execução independente que possui sua própria memória e comunica-se via mensagens.', correta: true),
            OpcaoResposta(texto: 'c) É um tipo de widget usado para isolar elementos visuais na tela.'),
          ],
        ),
      ],
      falasAprovado: [
        Fala(
          personagem: PersonagensData.valdir,
          texto: 'Hmph... Você sobreviveu.',
          posicao: PosicaoPersonagem.direita,
          backgroundAsset: 'assets/images/ambients/h15-1.png',
        ),
        Fala(
          personagem: PersonagensData.valdir,
          texto: 'Não ache que foi mérito seu; o destino apenas resolveu ser caridoso com os medíocres hoje.',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.valdir,
          texto: 'Você está aprovado. Agora saia da minha sala e não quero ver sua cara pelos próximos seis meses!',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.caique,
          texto: 'EU SABIA! Cara, você é uma lenda!',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.caique,
          texto: 'Passar na recuperação do Valdir é para poucos. Agora sim, férias de verdade!',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.caique,
          texto: 'Parabéns, você provou que é um desenvolvedor de verdade!',
          posicao: PosicaoPersonagem.direita,
        ),
      ],
      falasReprovado: [
        Fala(
          personagem: PersonagensData.valdir,
          texto: 'Pobre coitado... Nem se eu te desse as respostas em todas as línguas do mundo...',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.valdir,
          texto: '...você entenderia a vergonha que é errar tanto o básico.',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.valdir,
          texto: 'Adeus, nos vemos na dependência no próximo semestre!',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.caique,
          texto: 'Puxa, cara... foi por pouco. Eu vi o Valdir saindo com aquela cara de quem venceu.',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.caique,
          texto: 'Mas relaxa, você deu o seu melhor e chegou mais longe que a maioria.',
          posicao: PosicaoPersonagem.direita,
        ),
        Fala(
          personagem: PersonagensData.caique,
          texto: 'Descansa agora e semestre que vem voltamos com tudo!',
          posicao: PosicaoPersonagem.direita,
        ),
      ],
    ),
  };
}

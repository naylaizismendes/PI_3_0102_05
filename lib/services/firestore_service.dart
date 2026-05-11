import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_progress.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _jogadores =>
      _db.collection('jogadores');

  Future<GameProgress> getProgress(String uid) async {
    final doc = await _jogadores.doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      final initial = GameProgress.initial();
      await _jogadores.doc(uid).set(initial.toFirestore());
      return initial;
    }

    final progress = GameProgress.fromFirestore(doc.data()!);
    final raw = doc.data()!;
    if (!raw.containsKey('cenaAtual') || !raw.containsKey('avaliacoes')) {
      await _jogadores.doc(uid).set(progress.toFirestore());
    }
    return progress;
  }

  Stream<GameProgress> watchProgress(String uid) {
    return _jogadores.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return GameProgress.initial();
      }
      return GameProgress.fromFirestore(snap.data()!);
    });
  }

  Future<GameProgress> completarCena(String uid, int indiceCena) async {
    final atual = await getProgress(uid);
    final atualizado = atual.completarCena(indiceCena);
    await _jogadores.doc(uid).set(atualizado.toFirestore());
    return atualizado;
  }

  Future<GameProgress> salvarAvaliacao(
    String uid,
    String tipoProva,
    Avaliacao avaliacao,
  ) async {
    final atual = await getProgress(uid);
    final atualizado = atual.registrarAvaliacao(tipoProva, avaliacao);
    await _jogadores.doc(uid).set(atualizado.toFirestore());
    return atualizado;
  }

  Future<GameProgress> concederBencao(String uid, String nomeBencao) async {
    final atual = await getProgress(uid);
    final atualizado = atual.concederBencao(nomeBencao);
    await _jogadores.doc(uid).set(atualizado.toFirestore());
    return atualizado;
  }

  Future<GameProgress> finalizarJogo(String uid) async {
    final atual = await getProgress(uid);
    final atualizado = atual.finalizarJogo();
    await _jogadores.doc(uid).set(atualizado.toFirestore());
    return atualizado;
  }

  Future<void> inicializarJogador(String uid) async {
    final doc = await _jogadores.doc(uid).get();
    if (!doc.exists) {
      final initial = GameProgress.initial();
      await _jogadores.doc(uid).set(initial.toFirestore());
    }
  }

  Future<void> resetarProgresso(String uid) async {
    final initial = GameProgress.initial();
    await _jogadores.doc(uid).set(initial.toFirestore());
  }
}

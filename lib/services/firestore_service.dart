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

    return GameProgress.fromFirestore(doc.data()!);
  }

  Stream<GameProgress> watchProgress(String uid) {
    return _jogadores.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return GameProgress.initial();
      }
      return GameProgress.fromFirestore(snap.data()!);
    });
  }

  Future<GameProgress> completeScene(String uid, int sceneIndex) async {
    final current = await getProgress(uid);
    final updated = current.completeScene(sceneIndex);
    await _jogadores.doc(uid).set(updated.toFirestore());
    return updated;
  }

  Future<void> initializePlayer(String uid) async {
    final doc = await _jogadores.doc(uid).get();
    if (!doc.exists) {
      final initial = GameProgress.initial();
      await _jogadores.doc(uid).set(initial.toFirestore());
    }
  }

  Future<void> resetProgress(String uid) async {
    final initial = GameProgress.initial();
    await _jogadores.doc(uid).set(initial.toFirestore());
  }
}

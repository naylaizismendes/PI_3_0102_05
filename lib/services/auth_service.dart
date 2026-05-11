import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isGuest => _auth.currentUser?.isAnonymous ?? false;

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (credential.user != null) {
      await _firestoreService.inicializarJogador(credential.user!.uid);
    }
    return credential;
  }

  Future<UserCredential> signInAsGuest() {
    return _auth.signInAnonymously();
  }

  String? get displayName => _auth.currentUser?.displayName;

  Future<void> updateName(String nome) async {
    await _auth.currentUser?.updateDisplayName(nome);
    await _auth.currentUser?.reload();
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}

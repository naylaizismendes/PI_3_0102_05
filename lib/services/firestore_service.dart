import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Escreve progresso/teste
  Future<void> salvarTeste() async {
    await _db.collection('teste_conexao').doc('status').set({
      'mensagem': 'Firebase conectado com sucesso!',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Lê progresso/teste
  Future<Map<String, dynamic>?> lerTeste() async {
    final doc = await _db.collection('teste_conexao').doc('status').get();
    return doc.data();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //metodo para substituir o cloud Functions, já que não tenho cartão de crédito e não consigui utilizar.
  Future<void> marcarLivroComoLido(String bookId, int paginas) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    //referências para os documentos no Firestore
    final bookRef = _db.collection('users').doc(userId).collection('books').doc(bookId);
    final statsRef = _db.collection('users').doc(userId).collection('stats').doc('geral');

    //o WriteBatch garante que quando um livro for atualizado, as estatisticas também sejam, isso simultaneamente.
    // Se uma falhar, a outra é cancelada.
    WriteBatch batch = _db.batch();

    //atualiza o status do livro para "Lidos"
    batch.update(bookRef, {'status': 'Lidos'});

    //incrementa os contadores de leitura no documento de estatísticas
    batch.set(statsRef, {
      'livrosLidos': FieldValue.increment(1),
      'paginasLidas': FieldValue.increment(paginas),
    }, SetOptions(merge: true)); //cria o documento se for a primeira vez

    
    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao atualizar estatísticas: $e');
    }
  }
}
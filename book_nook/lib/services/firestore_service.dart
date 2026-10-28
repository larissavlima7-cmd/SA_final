import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //remove o livro da estante do usuário
  Future<void> removerLivro(String bookId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .delete();
  }

  //atualiza a página atual em que o usuário parou
  Future<void> atualizarPaginaAtual(String bookId, int paginaAtual) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .update({'paginaAtual': paginaAtual});
  }

  //marca como lido e muda as estasticas, somando com as que já existe
  Future<void> marcarLivroComoLido(String bookId, int paginas) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final bookRef = _db.collection('users').doc(userId).collection('books').doc(bookId);
    final statsRef = _db.collection('users').doc(userId).collection('stats').doc('geral');

    WriteBatch batch = _db.batch();

    batch.update(bookRef, {
      'status': 'Lidos',
      'paginaAtual': paginas,
    });

    batch.set(statsRef, {
      'livrosLidos': FieldValue.increment(1),
      'paginasLidas': FieldValue.increment(paginas),
    }, SetOptions(merge: true));

    await batch.commit();
  }
}
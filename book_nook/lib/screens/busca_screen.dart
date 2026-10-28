import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/book_model.dart';
import '../services/api_service.dart';

//pesquisa dos livros na api
class BuscaScreen extends StatefulWidget {
  const BuscaScreen({super.key});

  @override
  State<BuscaScreen> createState() => _BuscaScreenState();
}

class _BuscaScreenState extends State<BuscaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<Book> _booksResult = [];
  bool _isLoading = false;

  // Realiza a pesquisa na Google Books API
  Future<void> _performSearch() async {
    //vai evitar que pesquise branco ou espaços
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _apiService.buscarLivros(_searchController.text);
      setState(() {
        _booksResult = results.map((item) => Book.fromJson(item)).toList();
      });
    } catch (e) {
      if (mounted) {
        //exibe o erro se der problema na comunicação com a Api
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar livros: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //salva o livro no Firestore e permitindo que ocorra a mudança de estados(quero ler, lendo, lido)
  Future<void> _addBookToLibrary(Book book, String status) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    book.status = status; 

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('books')
          .doc(book.id)
          .set(book.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${book.titulo}" adicionado a "$status"!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar livro: $e')),
        );
      }
    }
  }

  //caoxa de mensagem para escolher em qual estante guardar
  void _showShelfSelector(Book book) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar "${book.titulo}"'),
          content: const Text('Escolha a estante para guardar este livro:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addBookToLibrary(book, 'Quero Ler');
              },
              child: const Text('Quero Ler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addBookToLibrary(book, 'Lendo');
              },
              child: const Text('Lendo'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addBookToLibrary(book, 'Lidos');
              },
              child: const Text('Lidos'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Livros'),
        backgroundColor: const Color.fromARGB(255, 238, 105, 149),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Digite o título ou autor...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search, size: 30),
                  color: const Color.fromARGB(255, 238, 105, 149),
                  onPressed: _performSearch,
                ),
              ],
            ),
            const SizedBox(height: 16),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _booksResult.isEmpty
                        ? const Center(child: Text('Nenhum livro encontrado.'))
                        : ListView.builder(
                            itemCount: _booksResult.length,
                            itemBuilder: (context, index) {
                              final book = _booksResult[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: book.imagem.isNotEmpty
                                      ? Image.network(
                                          book.imagem,
                                          width: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.book, size: 40),
                                        )
                                      : const Icon(Icons.book, size: 40),
                                  title: Text(
                                    book.titulo,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text('${book.autor}\nPáginas: ${book.pagina}'),
                                  isThreeLine: true,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.bookmark_add),
                                    color: const Color.fromARGB(255, 238, 105, 149),
                                    onPressed: () => _showShelfSelector(book),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
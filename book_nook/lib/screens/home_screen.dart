import 'package:book_nook/screens/busca_screen.dart';
import 'package:book_nook/screens/dados_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

//Tela principal que mostra a minha estante ("Quero ler", "Lendo" e "Lidos")
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //manipula dados no Firestore
  final FirestoreService _firestoreService = FirestoreService();
  //ID do usuário autenticado no Firebasde
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

//atualiza o status do livro no Firestore
  Future<void> _moverStatusLivro(String bookId, String novoStatus) async {
    if (_userId == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('books')
        .doc(bookId)
        .update({'status': novoStatus});
  }

  //confirma se quer excluir o livro
  void _confirmarRemocao(String bookId, String titulo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover Livro'),
          content: Text('Tem certeza de que deseja remover "$titulo" da sua estante?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                await _firestoreService.removerLivro(bookId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"$titulo" removido da estante.')),
                  );
                }
              },
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
  }
//campo pro usuario atualizar a página atual
  void _mostrarDialogoProgresso(String bookId, String titulo, int paginaAtual, int totalPaginas) {
    final controller = TextEditingController(text: paginaAtual.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Progresso: $titulo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total de páginas: $totalPaginas'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Página atual',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final novaPagina = int.tryParse(controller.text) ?? paginaAtual;
                //verifica se a wuantidade de paginas digitadas não é maior que a do livro
                if (novaPagina >= 0 && novaPagina <= totalPaginas) {
                  await _firestoreService.atualizarPaginaAtual(bookId, novaPagina);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Progresso atualizado!')),
                    );
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book Nook - Minha Estante'),
          backgroundColor: const Color.fromARGB(255, 238, 105, 149),
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              tooltip: 'Estatísticas',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DadosScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Quero Ler'),
              Tab(text: 'Lendo'),
              Tab(text: 'Lidos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookList('Quero Ler'),
            _buildBookList('Lendo'),
            _buildBookList('Lidos'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color.fromARGB(255, 238, 105, 149),
          icon: const Icon(Icons.search),
          label: const Text('Buscar Livros'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BuscaScreen()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookList(String status) {
    if (_userId == null) {
      return const Center(child: Text('Usuário não autenticado.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('books')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Nenhum livro na estante "$status".'));
        }

        final booksDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: booksDocs.length,
          itemBuilder: (context, index) {
            final doc = booksDocs[index];
            final data = doc.data() as Map<String, dynamic>;

            final bookId = doc.id;
            final titulo = data['titulo'] ?? 'Sem título';
            final autor = data['autor'] ?? 'Sem autor';
            final imagem = data['imagem'] ?? '';
            final int paginas = (data['pagina'] ?? data['paginas'] ?? 0) as int;
            final int paginaAtual = (data['paginaAtual'] ?? 0) as int;

            final double porcentagemLivro = paginas > 0 ? (paginaAtual / paginas) : 0.0;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: imagem.isNotEmpty
                      ? Image.network(
                          imagem,
                          width: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.book, size: 40),
                        )
                      : const Icon(Icons.book, size: 40),
                  title: Text(titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$autor • $paginas págs'),
                      if (status == 'Lendo') ...[
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: porcentagemLivro,
                          backgroundColor: Colors.grey[200],
                          color: const Color.fromARGB(255, 238, 105, 149),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Página $paginaAtual de $paginas (${(porcentagemLivro * 100).toStringAsFixed(0)}%)',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButton(status, bookId, titulo, paginas, paginaAtual),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.only(left: 6),
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                        tooltip: 'Remover Livro',
                        onPressed: () => _confirmarRemocao(bookId, titulo),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(String status, String bookId, String titulo, int paginas, int paginaAtual) {
    if (status == 'Quero Ler') {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size(60, 32),
        ),
        icon: const Icon(Icons.play_arrow, size: 16),
        label: const Text('Lendo', style: TextStyle(fontSize: 11)),
        onPressed: () async {
          await _moverStatusLivro(bookId, 'Lendo');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Você começou a ler "$titulo"!')),
            );
          }
        },
      );
    } else if (status == 'Lendo') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            icon: const Icon(Icons.edit_note, color: Colors.deepPurple, size: 24),
            tooltip: 'Atualizar Página',
            onPressed: () => _mostrarDialogoProgresso(bookId, titulo, paginaAtual, paginas),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(55, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () async {
              try {
                await _firestoreService.marcarLivroComoLido(bookId, paginas);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Parabéns! "$titulo" foi concluído!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao concluir livro: $e')),
                  );
                }
              }
            },
            child: const Text('Concluir', style: TextStyle(fontSize: 11)),
          ),
        ],
      );
    } else {
      return const Icon(Icons.check_circle, color: Colors.green, size: 24);
    }
  }
}
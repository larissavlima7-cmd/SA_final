import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//página de estatisticas
class DadosScreen extends StatelessWidget {
  const DadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
//vai tratar se o usuário não esteja autenticado
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Minhas Estatísticas')),
        body: const Center(child: Text('Usuário não autenticado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Estatísticas'),
        backgroundColor: const Color.fromARGB(255, 238, 105, 149),
      ),
      //recebe as alterações da leitura dos livros em tempo real
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('books')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          
          final books = snapshot.data?.docs ?? [];
          final int totalLivros = books.length;

          int livrosLidos = 0;
          int totalPaginasLidas = 0;

          //vai percorrer todos os livros da biblioteca e soma o progresso exato
          for (var doc in books) {
            final data = doc.data() as Map<String, dynamic>;
            final String status = data['status'] ?? '';
            final int totalPaginas = (data['pagina'] ?? data['paginas'] ?? 0) as int;
            final int paginaAtual = (data['paginaAtual'] ?? 0) as int;
            
            //condição para os status dos livros
            //se o livro foi finalizado, adiciona ele na parte de lidos e soma na estatistica
            if (status == 'Lidos') {
              livrosLidos++;
              totalPaginasLidas += totalPaginas;
            //se esta no lendo, somas as paginas lidas ate agora
            } else if (status == 'Lendo') {
              totalPaginasLidas += paginaAtual;
            }
          }

          //porcentagem de livros concluídos em relação ao total da biblioteca
          final double porcentagem = totalLivros > 0 ? (livrosLidos / totalLivros) : 0.0;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Progresso da Biblioteca',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: porcentagem,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(6),
                          backgroundColor: Colors.grey[300],
                          color: const Color.fromARGB(255, 238, 105, 149),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(porcentagem * 100).toStringAsFixed(1)}% concluído',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pinkAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildStatCard(
                  icon: Icons.menu_book,
                  title: 'Livros Concluídos',
                  value: '$livrosLidos de $totalLivros',
                  color: Colors.pinkAccent,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  icon: Icons.auto_stories,
                  title: 'Páginas Lidas',
                  value: '$totalPaginasLidas',
                  color: Colors.deepPurpleAccent,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                Text(
                  value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
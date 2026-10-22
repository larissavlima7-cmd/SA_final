import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<List<dynamic>> buscarLivros(String query) async {
   
    final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query');
    
    try {
      final resposta = await http.get(url);
      if (resposta.statusCode == 200) {
        final dados = json.decode(resposta.body);
        // Retorna a lista de livros ou uma lista vazia se não encontrar nada
        return dados['items'] ?? []; 
      } else {
        throw Exception('Erro ao carregar livros da API');
      }
    } catch (e) {
      throw Exception('Erro de rede: $e');
    }
  }
}
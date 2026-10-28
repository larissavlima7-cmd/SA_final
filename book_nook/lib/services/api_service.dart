//Página para integração com a API
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //chave api para acessar os livros do Google Book Api
  final String _apiKey = 'AIzaSyAd9fNY1zkjdEBJRyks57z0FTqV80T0CcM';

  Future<List<dynamic>> buscarLivros(String query) async {
    //link da api
    final url = Uri.https('www.googleapis.com', '/books/v1/volumes', {
      'q': query,
      'maxResults': '20',
      'key': _apiKey,
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] ?? [];
      } else {
        throw Exception('Status HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro de rede: $e');
    }
  }
}
class Book {
//atributos
final String id;
final String titulo;
final String autor;
final String imagem;
final int pagina;
String status; 

Book({
required this.id,
required this.titulo,
required this.autor,
required this.imagem,
required this.pagina,
this.status = "Quero Ler", //status padrão ao salvar
});

//converte o JSON da Google Books API para o objeto
factory Book.fromJson(Map<String, dynamic> json) {
final volumeInfo = json['volumeInfo'] ?? {};
return Book(
  id: json['id'] ?? '',
  titulo: volumeInfo['title'] ?? 'Título Desconhecido',
  autor: (volumeInfo['authors'] as List<dynamic>?)?.join(', ') ?? 'Autor Desconhecido',
  imagem: volumeInfo['imageLinks']?['thumbnail'] ?? '',
  pagina: volumeInfo['pageCount'] ?? 0, 
);
}

//converte o objeto para salvar no Firestore
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'titulo': titulo,
    'autor': autor,
    'imagem': imagem,
    'pagina': pagina,
    'status': status,
  };
}
}
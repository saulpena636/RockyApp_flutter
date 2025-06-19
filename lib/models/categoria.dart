class Categoria {
  final int id;
  final String categoria;

  Categoria({required this.id, required this.categoria});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(id: json['id'], categoria: json['categoria']);
  }
}

class Movimiento {
  final int id;
  final int usuarioId;
  final String fecha;
  final String tipo;
  final String concepto;
  final double montoPresupuestado;
  final double montoReal;
  final int categoriaId;

  Movimiento({
    required this.id,
    required this.usuarioId,
    required this.fecha,
    required this.tipo,
    required this.concepto,
    required this.montoPresupuestado,
    required this.montoReal,
    required this.categoriaId,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'],
      usuarioId: json['usuario_id'],
      fecha: json['fecha'],
      tipo: json['tipo'],
      concepto: json['concepto'],
      montoPresupuestado: (json['monto_presupuestado'] as num).toDouble(),
      montoReal: (json['monto_real'] as num).toDouble(),
      categoriaId: json['categoria_id'] ?? 0, // Maneja el caso de que sea null
    );
  }
}

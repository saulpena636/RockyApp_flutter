// Modelo para los puntos del gráfico
class ProgresoPunto {
  final DateTime fecha;
  final double saldo;

  ProgresoPunto({required this.fecha, required this.saldo});

  factory ProgresoPunto.fromJson(Map<String, dynamic> json) {
    return ProgresoPunto(
      fecha: DateTime.parse(json['fecha']),
      saldo: (json['saldo'] as num).toDouble(),
    );
  }
}

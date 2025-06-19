import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/movimiento.dart';

class ResumenProvider with ChangeNotifier {
  List<Movimiento> _allMovimientos = [];
  late DateTime _selectedDate;

  // Constructor
  ResumenProvider() {
    _selectedDate = DateTime.now();
  }

  // Método para recibir los datos desde el CronogramaProvider
  void updateMovimientos(List<Movimiento> movimientos) {
    _allMovimientos = movimientos;
    notifyListeners();
  }

  // Getters para la UI
  DateTime get selectedDate => _selectedDate;
  String get selectedMonthYear =>
      DateFormat('MMMM yyyy', 'es_ES').format(_selectedDate);

  // Lógica de filtrado y cálculo
  List<Movimiento> get movimientosDelMes {
    return _allMovimientos.where((m) {
      final fechaMovimiento = DateTime.parse(m.fecha);
      return fechaMovimiento.year == _selectedDate.year &&
          fechaMovimiento.month == _selectedDate.month;
    }).toList();
  }

  double get ingresosDelMes {
    return movimientosDelMes
        .where((m) => m.tipo == 'ingreso')
        .fold(0.0, (sum, item) => sum + item.montoReal);
  }

  double get egresosDelMes {
    return movimientosDelMes
        .where((m) => m.tipo == 'egreso')
        .fold(0.0, (sum, item) => sum + item.montoReal);
  }

  // Prepara los datos para la tabla y el gráfico de pastel
  Map<String, double> get resumenPorCategoria {
    final Map<String, double> data = {};
    for (var mov in movimientosDelMes) {
      // Usaremos un placeholder si no hay categoría
      final categoriaNombre = mov.categoriaId
          .toString(); // Esto lo mapearemos a nombres reales en la UI
      data.update(
        categoriaNombre,
        (value) => value + mov.montoReal,
        ifAbsent: () => mov.montoReal,
      );
    }
    return data;
  }

  // Métodos para cambiar de mes
  void mesSiguiente() {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    notifyListeners();
  }

  void mesAnterior() {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    notifyListeners();
  }
}

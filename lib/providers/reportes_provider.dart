import 'package:flutter/material.dart';
import '../api/cronograma_api.dart';
import '../models/reporte_data.dart';

class ReportesProvider with ChangeNotifier {
  final CronogramaApiService _apiService = CronogramaApiService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _estado = {};
  List<ProgresoPunto> _progreso = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get estado => _estado;
  List<ProgresoPunto> get progreso => _progreso;

  Future<void> cargarReporte(
    int usuarioId,
    String fechaInicio,
    String fechaFin,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.estadoFinanciero(usuarioId, fechaInicio, fechaFin),
        _apiService.progresoFinanciero(usuarioId, fechaInicio, fechaFin),
      ]);

      _estado = results[0] as Map<String, dynamic>;
      final progresoData = results[1] as List<dynamic>;
      // Procesamos los datos para el gráfico
      _progreso = progresoData
          .map((item) => ProgresoPunto.fromJson(item))
          .toList();

      // Aseguramos que solo haya un punto por día (similar a tu código React)
      final Map<DateTime, ProgresoPunto> uniquePoints = {};
      for (var point in _progreso) {
        final day = DateTime(
          point.fecha.year,
          point.fecha.month,
          point.fecha.day,
        );
        uniquePoints[day] = point;
      }
      _progreso = uniquePoints.values.toList()
        ..sort((a, b) => a.fecha.compareTo(b.fecha));
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import '../models/movimiento.dart';
import '../models/categoria.dart';
import '../api/cronograma_api.dart';

class CronogramaProvider with ChangeNotifier {
  final CronogramaApiService _apiService = CronogramaApiService();

  List<Movimiento> _movimientos = [];
  List<Categoria> _categorias = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Movimiento> get movimientos => _movimientos;
  List<Categoria> get categorias => _categorias;
  Map<String, String> get mapaCategorias {
    return {for (var cat in _categorias) cat.id.toString(): cat.categoria};
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> cargarDatos(int usuarioId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cargar movimientos y categorías en paralelo
      final results = await Future.wait([
        _apiService.obtenerTodos(usuarioId),
        _apiService.getCategorias(),
      ]);
      _movimientos = results[0] as List<Movimiento>;
      _categorias = results[1] as List<Categoria>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> agregarMovimiento(
    Map<String, dynamic> datos,
    int usuarioId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.agregarMovimiento(datos);
      await cargarDatos(
        usuarioId,
      ); // Recarga los datos para mostrar el nuevo movimiento
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarMovimiento(
    int id,
    Map<String, dynamic> datos,
    int usuarioId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.actualizarMovimiento(id, datos);
      await cargarDatos(
        usuarioId,
      ); // Recarga los datos para mostrar los cambios
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método para forzar la recarga
  Future<void> recargarDatos(int usuarioId) async {
    await cargarDatos(usuarioId);
  }

  Future<bool> eliminarMovimiento(int movimientoId, int usuarioId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.eliminarMovimiento(movimientoId);
      // Si tiene éxito, recargamos la lista para que la UI se actualice
      await cargarDatos(usuarioId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false; // Asegúrate de detener la carga en caso de error
      notifyListeners();
      return false;
    }
  }
}

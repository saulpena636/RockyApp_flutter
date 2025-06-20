import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/movimiento.dart';
import '../models/categoria.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CronogramaApiService {
  final String _baseUrl = dotenv.env['API_BASE_URL']!;

  Future<List<Movimiento>> obtenerTodos(int usuarioId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movimientoFinanciero/list/$usuarioId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Movimiento> movimientos = body
          .map((dynamic item) => Movimiento.fromJson(item))
          .toList();
      return movimientos;
    } else {
      throw Exception('Error al cargar los movimientos');
    }
  }

  Future<List<Categoria>> getCategorias() async {
    final response = await http.get(Uri.parse('$_baseUrl/categoria'));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Categoria> categorias = body
          .map((dynamic item) => Categoria.fromJson(item))
          .toList();
      return categorias;
    } else {
      throw Exception('Error al cargar las categorías');
    }
  }

  // Aquí puedes añadir los métodos para agregar, actualizar y eliminar movimientos
  // Por ejemplo:
  Future<Movimiento> agregarMovimiento(Map<String, dynamic> datos) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/movimientoFinanciero'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(datos),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Movimiento.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al agregar el movimiento');
    }
  }

  Future<Movimiento> actualizarMovimiento(
    int id,
    Map<String, dynamic> datos,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/movimientoFinanciero/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(datos),
    );

    if (response.statusCode == 200) {
      return Movimiento.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar el movimiento');
    }
  }

  Future<bool> eliminarMovimiento(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/movimientoFinanciero/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    // La respuesta 'ok' de la API de FastAPI suele devolver un 200 o 204 (No Content)
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Error al eliminar el movimiento');
    }
  }

  Future<Map<String, dynamic>> estadoFinanciero(
    int usuarioId,
    String fechaInicio,
    String fechaFin,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/estado_financiero?usuario_id=$usuarioId&fecha_inicio=$fechaInicio&fecha_fin=$fechaFin',
      ),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar el estado financiero');
    }
  }

  Future<List<dynamic>> progresoFinanciero(
    int usuarioId,
    String fechaInicio,
    String fechaFin,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/progreso_financiero?usuario_id=$usuarioId&fecha_inicio=$fechaInicio&fecha_fin=$fechaFin',
      ),
    );
    if (response.statusCode == 200) {
      // El endpoint devuelve { "progreso": [...] }
      return json.decode(response.body)['progreso'];
    } else {
      throw Exception('Error al cargar el progreso financiero');
    }
  }
}

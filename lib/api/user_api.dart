import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserApiService {
  final String _baseUrl = dotenv.env['API_BASE_URL']!;

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Lanza una excepción para ser capturada en la UI o en el provider.
      throw Exception('Usuario o contraseña incorrectos');
    }
  }

  Future<Map<String, dynamic>> signup({
    required String username,
    required String nombre,
    required String apellido,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(
        'Error en el registro: ${errorData['detail'] ?? 'Inténtalo de nuevo'}',
      );
    }
  }

  // Podrías añadir la función para obtener datos del usuario aquí también
  Future<Map<String, dynamic>> getUserByUsername(String username) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/get_user_by_email/{Email}?email=$username'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener datos del usuario');
    }
  }
}

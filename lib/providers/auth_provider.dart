import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/user_api.dart';

class AuthProvider with ChangeNotifier {
  final UserApiService _userApiService = UserApiService();

  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      final response = await _userApiService.login(username, password);
      _token = response['access_token'];

      // Obtener y guardar datos del usuario
      final userData = await _userApiService.getUserByUsername(username);
      _user = userData;

      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setInt('userId', _user!['id']);
      await prefs.setString('userName', _user!['nombre']);

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signup({
    required String username,
    required String nombre,
    required String apellido,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _userApiService.signup(
        username: username,
        nombre: nombre,
        apellido: apellido,
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    // Comprueba si existe un token
    if (!prefs.containsKey('token')) {
      return false; // No hay token, no se puede iniciar sesión
    }

    final storedToken = prefs.getString('token');
    final storedUserId = prefs.getInt('userId');
    final storedUserName = prefs.getString('userName');

    // Aquí podrías añadir lógica para verificar si el token ha expirado.
    // En una app de producción, harías una llamada a un endpoint como /profile o /verify-token
    // para asegurarte de que el token sigue siendo válido en el backend.
    // Por ahora, si el token existe, asumiremos que es válido.

    _token = storedToken;
    _user = {
      'id': storedUserId,
      'nombre': storedUserName,
      // Puedes añadir más datos de usuario si los guardaste
    };

    notifyListeners(); // Notifica a los listeners que el usuario está autenticado
    return true;
  }
}

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
  bool _isAuthAttempted = false;
  bool get isAuthAttempted => _isAuthAttempted;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    print("--- AUTH PROVIDER: Método login() iniciado.");
    _setLoading(true); // Asumiendo que tienes un método para el estado de carga

    try {
      print("--- AUTH PROVIDER: Llamando a la API para obtener token...");
      final response = await _userApiService.login(username, password);
      print(
        "--- AUTH PROVIDER: Respuesta de API recibida. Token: ${response['access_token']}",
      );

      _token = response['access_token'];

      print(
        "--- AUTH PROVIDER: Llamando a la API para obtener datos del usuario...",
      );
      final userData = await _userApiService.getUserByUsername(username);
      _user = userData;
      print("--- AUTH PROVIDER: Datos del usuario recibidos: $_user");

      print("--- AUTH PROVIDER: Guardando sesión en SharedPreferences...");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setInt('userId', _user!['id']);
      await prefs.setString('userName', _user!['nombre']);
      print("--- AUTH PROVIDER: Sesión guardada.");

      _isLoading = false;
      print("--- AUTH PROVIDER: Llamando a notifyListeners() por ÉXITO...");
      notifyListeners(); // ¡LA SEÑAL CLAVE!
      return true;
    } catch (e) {
      print("--- AUTH PROVIDER: Ocurrió un error en el proceso de login: $e");
      _isLoading = false;
      print("--- AUTH PROVIDER: Llamando a notifyListeners() por FALLO...");
      notifyListeners();
      return false;
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

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      return; // Simplemente salimos si no hay token
    }

    // Si hay un token, actualizamos el estado
    _token = prefs.getString('token');
    _user = {
      'id': prefs.getInt('userId'),
      'nombre': prefs.getString('userName'),
    };

    // Y notificamos a los listeners.
    notifyListeners();
  }
}

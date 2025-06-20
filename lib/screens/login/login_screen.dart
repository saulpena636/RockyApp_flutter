import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    // Añade un print para saber que el proceso comenzó
    print("--- LOGIN SCREEN: Botón presionado. Intentando iniciar sesión...");

    // Para que no se quede el teclado abierto
    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (success) {
        print("--- LOGIN SCREEN: El provider reportó ÉXITO.");
        // No necesitamos hacer nada aquí, el AuthGate debería reaccionar.
      } else {
        print("--- LOGIN SCREEN: El provider reportó FALLO.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Fallo al iniciar sesión. Revisa tus credenciales.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      print("--- LOGIN SCREEN: Ocurrió un error inesperado: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C3E50),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Color(0xFFF4F6F7),
              borderRadius: BorderRadius.circular(16.0),
            ),
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Iniciar sesión',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text('Inicia sesión con tu usuario y contraseña'),
                SizedBox(height: 32),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    filled: true,
                    fillColor: Color(0xFFE6E0E9),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    filled: true,
                    fillColor: Color(0xFFE6E0E9),
                  ),
                ),
                SizedBox(height: 32),
                _isLoading
                    ? CircularProgressIndicator()
                    : Consumer<AuthProvider>(
                        builder: (context, auth, child) {
                          return auth.isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _login,
                                  child: Text('Iniciar sesión'),
                                  // ... (estilos)
                                );
                        },
                      ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text('Regístrate aquí!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

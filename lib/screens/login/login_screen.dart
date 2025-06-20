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
  // No necesitas _isLoading aquí si ya el AuthProvider lo maneja
  // bool _isLoading = false; // Puedes eliminar esta variable

  @override
  void initState() {
    super.initState();
    // Añade un listener para navegar cuando el usuario se autentique
    // Lo hacemos en un post-frame callback para evitar errores
    // de que el widget no está montado aún.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(
        context,
        listen: false,
      ).addListener(_authListener);
    });
  }

  @override
  void dispose() {
    // Es crucial remover el listener para evitar errores
    Provider.of<AuthProvider>(
      context,
      listen: false,
    ).removeListener(_authListener);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _authListener() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      // Navega a la pantalla principal solo si no estás ya en ella
      // Asegúrate de que tu ruta '/home' o la ruta principal sea correcta
      Navigator.of(context).pushReplacementNamed('/cronograma');
    }
  }

  Future<void> _login() async {
    // Puedes eliminar el setState para _isLoading aquí si el Consumer
    // del botón ya maneja el estado de carga del AuthProvider.
    // setState(() { _isLoading = true; });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fallo al iniciar sesión. Revisa tus credenciales.'),
        ),
      );
    }
    // El listener _authListener ahora se encargará de la navegación.
    // setState(() { _isLoading = false; }); // Puedes eliminar esta línea también
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
                Consumer<AuthProvider>(
                  // Mantén el Consumer para el estado de carga del botón
                  builder: (context, auth, child) {
                    return auth.isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _login,
                            child: Text('Iniciar sesión'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Color(0xFF3498DB),
                              foregroundColor: Colors.white,
                            ),
                          );
                  },
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text(
                    'Regístrate aquí!',
                    style: TextStyle(color: Color(0xFF3498DB)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

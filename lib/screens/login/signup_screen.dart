import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signup(
        username: _usernameController.text,
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Registro exitoso! Por favor, inicia sesión.'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en el registro. Inténtalo de nuevo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C3E50),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: Container(
              width: 920, // Ancho similar al del contenedor de React
              padding: EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Color(0xFFF4F6F7),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Registrarse',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Ingresa tus datos para registrarte',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 32),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: 'Username'),
                      validator: (value) => value!.isEmpty
                          ? 'Por favor, ingresa un username'
                          : null,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nombreController,
                            decoration: InputDecoration(labelText: 'Nombre'),
                            validator: (value) => value!.isEmpty
                                ? 'Por favor, ingresa tu nombre'
                                : null,
                          ),
                        ),
                        SizedBox(width: 32),
                        Expanded(
                          child: TextFormField(
                            controller: _apellidoController,
                            decoration: InputDecoration(labelText: 'Apellido'),
                            validator: (value) => value!.isEmpty
                                ? 'Por favor, ingresa tu apellido'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(labelText: 'Correo'),
                            validator: (value) {
                              if (value!.isEmpty)
                                return 'Por favor, ingresa tu correo';
                              if (!value.contains('@'))
                                return 'Ingresa un correo válido';
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 32),
                        Expanded(
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Por favor, ingresa una contraseña'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _signup,
                            child: Text('Regístrate'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2C3E50),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 15,
                              ),
                            ),
                          ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Vuelve a la pantalla de login
                      },
                      child: Text('¿Ya tienes cuenta? Inicia sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

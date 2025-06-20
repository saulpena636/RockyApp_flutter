import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart'; // Importa el provider
import 'screens/login/login_screen.dart';
import 'screens/cronograma/cronograma_screen.dart';
import 'screens/reportes/reportes_screen.dart';
import 'screens/login/signup_screen.dart';
import 'screens/resumen/resumen_mensual_screen.dart';
import '/providers/cronograma_provider.dart'; // Asegúrate de usar el nombre de tu paquete
import 'providers/resumen_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/reportes_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env"); // Carga las variables
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // CronogramaProvider sigue igual
        ChangeNotifierProxyProvider<AuthProvider, CronogramaProvider>(
          create: (_) => CronogramaProvider(),
          update: (_, auth, cronograma) => cronograma!,
        ),
        // Nuevo Provider: escucha a CronogramaProvider
        ChangeNotifierProxyProvider<CronogramaProvider, ResumenProvider>(
          create: (_) => ResumenProvider(),
          update: (_, cronograma, resumen) {
            // Cada vez que los movimientos en CronogramaProvider cambien,
            // se los pasamos a ResumenProvider.
            resumen!.updateMovimientos(cronograma.movimientos);
            return resumen;
          },
        ),
        ChangeNotifierProvider(create: (_) => ReportesProvider()),
      ],
      child: MaterialApp(
        title: 'Rocky App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Inter',
        ),
        debugShowCheckedModeBanner: false,
        // Define una pantalla de carga o decisión inicial
        home: AuthGate(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/cronograma': (context) => CronogramaScreen(),
          '/reportes': (context) => ReportesScreen(),
          '/signup': (context) => SignupScreen(),
          '/resumen_mensual': (context) => ResumenMensualScreen(),
        },
      ),
    );
  }
}

// Este widget decide qué pantalla mostrar basado en el estado de autenticación
class AuthGate extends StatefulWidget {
  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    // Guardamos el Future en una variable de estado para que solo se ejecute UNA VEZ.
    _initFuture = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    print("--- AUTH GATE: Widget reconstruido (build).");
    // El FutureBuilder se encarga de la carga inicial de la aplicación.
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        // 1. MIENTRAS SE VERIFICA EL TOKEN, MOSTRAMOS UNA PANTALLA DE CARGA
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. UNA VEZ VERIFICADO, EL CONSUMER TOMA EL CONTROL TOTAL
        // El Consumer se reconstruirá SIEMPRE que notifyListeners() sea llamado.
        return Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            // Si el estado es "autenticado", muestra la pantalla principal.
            // Esto funcionará tanto para el autologin como para el login manual.
            if (authProvider.isAuthenticated) {
              print("--- AUTH GATE: Decisión -> Mostrar CronogramaScreen.");
              return CronogramaScreen();
            }
            // Si no, muestra la pantalla de login.
            else {
              print("--- AUTH GATE: Decisión -> Mostrar LoginScreen.");
              return LoginScreen();
            }
          },
        );
      },
    );
  }
}

// AÑADE ESTE WIDGET DE PANTALLA DE CARGA AL FINAL DE main.dart
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Llama al método para intentar el login automático una sola vez.
    // listen: false porque esta acción no debe reconstruir este widget.
    Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

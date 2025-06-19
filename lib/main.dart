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

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Requerido para la siguiente línea
  await initializeDateFormatting(
    'es_ES',
    null,
  ); // Inicializa localización para español
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
        title: 'Finanzas App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Inter',
        ),
        debugShowCheckedModeBanner: false,
        // Define una pantalla de carga o decisión inicial
        home: AuthWrapper(),
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
class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Llamamos a tryAutoLogin aquí.
    // Usamos listen: false porque solo queremos llamar al método,
    // no necesitamos que initState se reconstruya si los datos cambian.
    Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un Consumer para que este widget se reconstruya cuando
    // el estado de autenticación cambie (después de que tryAutoLogin termine).
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          // Si el usuario está autenticado, vamos a la pantalla principal
          return CronogramaScreen();
        } else {
          // Si no, vamos a la pantalla de inicio de sesión
          return LoginScreen();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cronograma_provider.dart';
import '../../models/movimiento.dart';
import './widgets/movimiento_form.dart';
import '../login/login_screen.dart';
import 'package:intl/intl.dart';

class CronogramaScreen extends StatefulWidget {
  @override
  _CronogramaScreenState createState() => _CronogramaScreenState();
}

class _CronogramaScreenState extends State<CronogramaScreen> {
  @override
  void initState() {
    super.initState();
    // Usamos addPostFrameCallback para asegurarnos de que el context está disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Asumimos que el id del usuario está guardado en el AuthProvider
      final userId = authProvider.user?['id'];
      if (userId != null) {
        Provider.of<CronogramaProvider>(
          context,
          listen: false,
        ).cargarDatos(userId);
      }
    });
  }

  void _mostrarFormularioMovimiento({Movimiento? movimiento}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?['id'];
    if (userId == null) return;

    // showModalBottomSheet devuelve los datos que le pasamos en Navigator.pop()
    final datos = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MovimientoForm(movimiento: movimiento),
    );

    if (datos != null) {
      final cronogramaProvider = Provider.of<CronogramaProvider>(
        context,
        listen: false,
      );
      datos['usuario_id'] = userId; // Añadimos el id del usuario

      bool success;
      if (movimiento == null) {
        // Agregando nuevo movimiento
        success = await cronogramaProvider.agregarMovimiento(datos, userId);
      } else {
        // Actualizando movimiento existente
        success = await cronogramaProvider.actualizarMovimiento(
          movimiento.id,
          datos,
          userId,
        );
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Movimiento guardado con éxito')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar: ${cronogramaProvider.errorMessage}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?['nombre'] ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido ${userName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.analytics), // Un ícono para reportes
            tooltip: 'Generar Reporte',
            onPressed: _mostrarModalReporte, // Llama al nuevo método
          ),
          IconButton(
            icon: Icon(Icons.pie_chart),
            tooltip: 'Resumen Mensual',
            onPressed: () {
              Navigator.pushNamed(context, '/resumen_mensual');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              // Usamos pushAndRemoveUntil para limpiar la pila de navegación
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Consumer<CronogramaProvider>(
        builder: (context, cronogramaProvider, child) {
          if (cronogramaProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (cronogramaProvider.errorMessage != null) {
            return Center(
              child: Text('Error: ${cronogramaProvider.errorMessage}'),
            );
          }

          if (cronogramaProvider.movimientos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No hay movimientos registrados aún.',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Agregar Movimiento'),
                    onPressed: () => _mostrarFormularioMovimiento(),
                  ),
                ],
              ),
            );
          }

          // El 'return' aquí es crucial. Este es el widget que se muestra si todo está bien.
          return RefreshIndicator(
            onRefresh: () async {
              final userId = authProvider.user?['id'];
              if (userId != null) {
                await cronogramaProvider.recargarDatos(userId);
              }
            },
            child: ListView.builder(
              itemCount: cronogramaProvider.movimientos.length,
              itemBuilder: (context, index) {
                final movimiento = cronogramaProvider.movimientos[index];
                final categoriaNombre =
                    cronogramaProvider.mapaCategorias[movimiento.categoriaId
                        .toString()] ??
                    'Sin categoría';

                // El builder retorna un Dismissible por cada item.
                return Dismissible(
                  key: Key(movimiento.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirmar"),
                          content: const Text(
                            "¿Estás seguro de que deseas eliminar este movimiento?",
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("CANCELAR"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                "ELIMINAR",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) async {
                    final userId = authProvider.user?['id'];
                    if (userId != null) {
                      await cronogramaProvider.eliminarMovimiento(
                        movimiento.id,
                        userId,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Movimiento eliminado')),
                        );
                      }
                    }
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: movimiento.tipo == 'ingreso'
                            ? Colors.green
                            : Colors.red,
                        child: Icon(
                          movimiento.tipo == 'ingreso'
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(movimiento.concepto),
                      subtitle: Text('$categoriaNombre - ${movimiento.fecha}'),
                      trailing: Text(
                        '${movimiento.montoReal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: movimiento.tipo == 'ingreso'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      onTap: () {
                        _mostrarFormularioMovimiento(movimiento: movimiento);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioMovimiento(),
        child: Icon(Icons.add),
        tooltip: 'Agregar Movimiento',
      ),
    );
  }

  void _mostrarModalReporte() async {
    final now = DateTime.now();
    // Usamos showDateRangePicker, un widget nativo de Flutter para esto.
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(Duration(days: 30)),
        end: now,
      ),
    );

    if (picked != null) {
      // Si el usuario selecciona un rango, navegamos a la pantalla de reportes
      // y pasamos las fechas como argumentos.
      Navigator.pushNamed(
        context,
        '/reportes',
        arguments: {
          'fechaInicio': DateFormat('yyyy-MM-dd').format(picked.start),
          'fechaFinal': DateFormat('yyyy-MM-dd').format(picked.end),
        },
      );
    }
  }
}

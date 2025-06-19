import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/reportes_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/reporte_data.dart';

class ReportesScreen extends StatefulWidget {
  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtenemos los argumentos y cargamos los datos
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final fechaInicio = args['fechaInicio']!;
    final fechaFinal = args['fechaFinal']!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?['id'];

    if (userId != null) {
      Provider.of<ReportesProvider>(
        context,
        listen: false,
      ).cargarReporte(userId, fechaInicio, fechaFinal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final fechaInicio = args['fechaInicio']!;
    final fechaFinal = args['fechaFinal']!;

    return Scaffold(
      appBar: AppBar(title: Text('Reporte Financiero')),
      body: Consumer<ReportesProvider>(
        builder: (context, reportesProvider, child) {
          if (reportesProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (reportesProvider.errorMessage != null) {
            return Center(
              child: Text('Error: ${reportesProvider.errorMessage}'),
            );
          }

          final estado = reportesProvider.estado;
          final progreso = reportesProvider.progreso;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Este es tu reporte financiero de $fechaInicio a $fechaFinal',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 16),
                Text(
                  'Tu estado de reporte: ${estado['mensaje'] ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Text(
                  'Ingresos: \$${estado['total_ingresos'] ?? 0.0}',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                Text(
                  'Egresos: \$${estado['total_egresos'] ?? 0.0}',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                Text(
                  'Saldo Final: \$${estado['saldo_final'] ?? 0.0}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 30),

                // Gráfico de Líneas
                SizedBox(
                  height: 300,
                  child: progreso.isEmpty
                      ? Center(
                          child: Text('No hay datos de progreso para mostrar.'),
                        )
                      : LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() < progreso.length) {
                                      final fecha =
                                          progreso[value.toInt()].fecha;
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(
                                          DateFormat('MM/dd').format(fecha),
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      );
                                    }
                                    return Text('');
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(progreso.length, (index) {
                                  return FlSpot(
                                    index.toDouble(),
                                    progreso[index].saldo,
                                  );
                                }),
                                isCurved: true,
                                barWidth: 4,
                                color: Colors.blue,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.blue.withOpacity(0.3),
                                ),
                                dotData: FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

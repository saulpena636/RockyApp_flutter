import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/resumen_provider.dart';
import '../../providers/cronograma_provider.dart'; // Para el mapa de categorías

class ResumenMensualScreen extends StatelessWidget {
  const ResumenMensualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resumen Mensual')),
      body: Consumer<ResumenProvider>(
        builder: (context, resumenProvider, child) {
          final categoriasMap = Provider.of<CronogramaProvider>(
            context,
            listen: false,
          ).mapaCategorias;
          final resumenCategorias = resumenProvider.resumenPorCategoria;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Selector de Mes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left),
                        onPressed: resumenProvider.mesAnterior,
                      ),
                      Text(
                        resumenProvider.selectedMonthYear,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: resumenProvider.mesSiguiente,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // 2. Totales de Ingresos y Egresos
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Ingresos Totales: \$${resumenProvider.ingresosDelMes.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.green, fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Egresos Totales: \$${resumenProvider.egresosDelMes.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.red, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Distribución de Movimientos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  // 3. Gráfico de Pastel
                  SizedBox(
                    height: 250,
                    child: resumenCategorias.isEmpty
                        ? Center(child: Text('No hay datos para este mes.'))
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: List.generate(resumenCategorias.length, (
                                i,
                              ) {
                                final entry = resumenCategorias.entries
                                    .elementAt(i);
                                final categoriaNombre =
                                    categoriasMap[entry.key] ?? 'Sin Categoría';
                                final value = entry.value;
                                return PieChartSectionData(
                                  color: Colors
                                      .primaries[i % Colors.primaries.length],
                                  value: value,
                                  title:
                                      '${((value / resumenProvider.egresosDelMes) * 100).toStringAsFixed(0)}%',
                                  radius: 60,
                                  titleStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }),
                            ),
                          ),
                  ),

                  // 4. Tabla de Distribución
                  DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Categoría')),
                      DataColumn(label: Text('Monto'), numeric: true),
                    ],
                    rows: resumenCategorias.entries.map((entry) {
                      final categoriaNombre =
                          categoriasMap[entry.key] ?? 'Sin Categoría';
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(categoriaNombre)),
                          DataCell(Text('\$${entry.value.toStringAsFixed(2)}')),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

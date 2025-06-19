import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/movimiento.dart';
import '../../../providers/cronograma_provider.dart';
import '../../../models/categoria.dart';

class MovimientoForm extends StatefulWidget {
  final Movimiento? movimiento; // Si es null, es 'agregar'. Si no, es 'editar'.

  MovimientoForm({this.movimiento});

  @override
  _MovimientoFormState createState() => _MovimientoFormState();
}

class _MovimientoFormState extends State<MovimientoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _conceptoController;
  late TextEditingController _montoPresupuestadoController;
  late TextEditingController _montoRealController;
  late DateTime _fecha;
  String _tipo = 'ingreso';
  int? _categoriaId;

  @override
  void initState() {
    super.initState();
    final movimiento = widget.movimiento;

    _conceptoController = TextEditingController(
      text: movimiento?.concepto ?? '',
    );
    _montoPresupuestadoController = TextEditingController(
      text: movimiento?.montoPresupuestado.toString() ?? '',
    );
    _montoRealController = TextEditingController(
      text: movimiento?.montoReal.toString() ?? '',
    );
    _fecha = movimiento != null
        ? DateTime.parse(movimiento.fecha)
        : DateTime.now();
    _tipo = movimiento?.tipo ?? 'ingreso';
    _categoriaId = movimiento?.categoriaId;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _fecha) {
      setState(() {
        _fecha = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final datos = {
        'fecha': DateFormat('yyyy-MM-dd').format(_fecha),
        'tipo': _tipo,
        'concepto': _conceptoController.text,
        'monto_presupuestado': double.parse(_montoPresupuestadoController.text),
        'monto_real': double.parse(_montoRealController.text),
        'categoria_id': _categoriaId,
        // Asume que el usuario_id se manejará en el provider
      };
      Navigator.of(
        context,
      ).pop(datos); // Devuelve los datos a la pantalla anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorias = Provider.of<CronogramaProvider>(
      context,
      listen: false,
    ).categorias;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.movimiento == null
                    ? 'Agregar Movimiento'
                    : 'Editar Movimiento',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              // Campo Concepto
              TextFormField(
                controller: _conceptoController,
                decoration: InputDecoration(labelText: 'Concepto'),
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa un concepto' : null,
              ),
              // Selector de Tipo
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: InputDecoration(labelText: 'Tipo'),
                items: [
                  DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                  DropdownMenuItem(value: 'egreso', child: Text('Egreso')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipo = value!;
                  });
                },
              ),
              // Selector de Categoría
              DropdownButtonFormField<int>(
                value: _categoriaId,
                decoration: InputDecoration(labelText: 'Categoría'),
                items: categorias.map((Categoria cat) {
                  return DropdownMenuItem<int>(
                    value: cat.id,
                    child: Text(cat.categoria),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecciona una categoría' : null,
              ),
              // Montos
              TextFormField(
                controller: _montoPresupuestadoController,
                decoration: InputDecoration(labelText: 'Monto Presupuestado'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa un monto' : null,
              ),
              TextFormField(
                controller: _montoRealController,
                decoration: InputDecoration(labelText: 'Monto Real'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa un monto' : null,
              ),
              // Selector de Fecha
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha: ${DateFormat('dd/MM/yyyy').format(_fecha)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Seleccionar'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submitForm, child: Text('Guardar')),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

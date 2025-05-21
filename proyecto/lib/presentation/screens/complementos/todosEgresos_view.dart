import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/inicio_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:VanguardMoney/data/models/productos_model.dart';

class TodosEgresosScreen extends StatefulWidget {
  const TodosEgresosScreen({Key? key}) : super(key: key);

  @override
  State<TodosEgresosScreen> createState() => _TodosEgresosScreenState();
}

class _TodosEgresosScreenState extends State<TodosEgresosScreen> {
  DateTimeRange? _rangoSeleccionado;
  DateTime? _fechaSeleccionada;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    final viewModel = InicioViewModel(
      auth.user!.uid,
      auth.userData?.nombreCompleto ?? 'Usuario',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los Egresos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
          tooltip: 'Regresar al menú',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar por rango de fechas',
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(now.year - 5),
                lastDate: DateTime(now.year + 1),
                initialDateRange: _rangoSeleccionado,
              );
              if (picked != null) {
                setState(() {
                  _rangoSeleccionado = picked;
                  _fechaSeleccionada = null; // Limpiar selección individual
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Buscar por día',
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: _fechaSeleccionada ?? now,
                firstDate: DateTime(now.year - 5),
                lastDate: DateTime(now.year + 1),
              );
              if (picked != null) {
                setState(() {
                  _fechaSeleccionada = picked;
                  _rangoSeleccionado = null; // Limpiar selección de rango
                });
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<CompraModel>>(
        stream: viewModel.getAllCompras(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          var compras = snapshot.data ?? [];

          // Filtro por rango de fechas
          if (_rangoSeleccionado != null) {
            compras =
                compras.where((compra) {
                  final fecha = DateFormat(
                    'dd/MM/yyyy HH:mm:ss',
                  ).parse(compra.fechaEmision);
                  return fecha.isAfter(
                        _rangoSeleccionado!.start.subtract(
                          const Duration(days: 1),
                        ),
                      ) &&
                      fecha.isBefore(
                        _rangoSeleccionado!.end.add(const Duration(days: 1)),
                      );
                }).toList();
          }

          // Filtro por día específico
          if (_fechaSeleccionada != null) {
            compras =
                compras.where((compra) {
                  final fecha = DateFormat(
                    'dd/MM/yyyy HH:mm:ss',
                  ).parse(compra.fechaEmision);
                  return fecha.year == _fechaSeleccionada!.year &&
                      fecha.month == _fechaSeleccionada!.month &&
                      fecha.day == _fechaSeleccionada!.day;
                }).toList();
          }

          if (compras.isEmpty) {
            return const Center(child: Text('No hay egresos registrados'));
          }

          // Agrupar por día
          final Map<String, List<CompraModel>> comprasPorDia = {};
          for (var compra in compras) {
            final fecha = DateFormat('dd/MM/yyyy').format(
              DateFormat('dd/MM/yyyy HH:mm:ss').parse(compra.fechaEmision),
            );
            comprasPorDia.putIfAbsent(fecha, () => []).add(compra);
          }

          final dias =
              comprasPorDia.keys.toList()
                ..sort((a, b) => b.compareTo(a)); // Más recientes primero

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dias.length,
            itemBuilder: (context, index) {
              final dia = dias[index];
              final comprasDelDia = comprasPorDia[dia]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dia,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...comprasDelDia.map(
                    (compra) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(compra.lugarCompra),
                        subtitle: Text(
                          'Total: \$${compra.total.toStringAsFixed(2)}',
                        ),
                        trailing: Text(
                          DateFormat('HH:mm').format(
                            DateFormat(
                              'dd/MM/yyyy HH:mm:ss',
                            ).parse(compra.fechaEmision),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

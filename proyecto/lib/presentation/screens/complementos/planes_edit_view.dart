import 'package:VanguardMoney/data/models/planes_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../viewmodels/planes_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class PlanesScreen extends StatefulWidget {
  @override
  _PlanesScreenState createState() => _PlanesScreenState();
}

class _PlanesScreenState extends State<PlanesScreen> {
  final _montoTotalController = TextEditingController();
  final Map<String, TextEditingController> _montoCategoriaControllers = {
    for (var cat in categoriasPermitidas) cat: TextEditingController()
  };

  @override
  void dispose() {
    _montoTotalController.dispose();
    _montoCategoriaControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Espera a que el contexto esté listo
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final uid = authViewModel.user?.uid;
      if (uid != null) {
        final viewModel = Provider.of<PlanesViewModel>(context, listen: false);
        await viewModel.cargarPlanDesdeFirebase(uid);

        // Actualiza los controladores con los datos recuperados
        _montoTotalController.text = viewModel.montoTotal.toString();
        for (var cat in categoriasPermitidas) {
          final categoria = viewModel.categorias.firstWhere(
            (c) => c.nombre == cat,
            orElse: () => CategoriaModel(nombre: cat, montoMaximo: 0),
          );
          _montoCategoriaControllers[cat]?.text =
              categoria.montoMaximo > 0 ? categoria.montoMaximo.toString() : '';
        }
        // Sincroniza el ViewModel con los controladores para que los porcentajes funcionen
        viewModel.setMontoTotal(viewModel.montoTotal);
        for (var cat in categoriasPermitidas) {
          final categoria = viewModel.categorias.firstWhere(
            (c) => c.nombre == cat,
            orElse: () => CategoriaModel(nombre: cat, montoMaximo: 0),
          );
          if (categoria.montoMaximo > 0) {
            viewModel.agregarCategoria(cat, categoria.montoMaximo);
          }
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlanesViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(title: Text('Registrar Plan Monetario')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text('Monto total del plan:'),
                TextField(
                  controller: _montoTotalController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(hintText: 'Ej: 1000'),
                  onChanged: (value) {
                    final monto = double.tryParse(value) ?? 0.0;
                    viewModel.setMontoTotal(monto);
                  },
                ),
                SizedBox(height: 20),
                Text('Monto máximo por categoría:'),
                ...categoriasPermitidas.map((cat) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(child: Text(cat)),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: _montoCategoriaControllers[cat],
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Monto',
                              ),
                              onChanged: (value) {
                                final monto = double.tryParse(value) ?? 0.0;
                                final index = viewModel.categorias.indexWhere((c) => c.nombre == cat);
                                if (index >= 0) {
                                  viewModel.eliminarCategoria(index);
                                }
                                if (monto > 0) {
                                  viewModel.agregarCategoria(cat, monto);
                                }
                                setState(() {}); // Para actualizar el porcentaje
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Builder(
                            builder: (_) {
                              final monto = double.tryParse(_montoCategoriaControllers[cat]?.text ?? '') ?? 0.0;
                              final total = viewModel.montoTotal;
                              final porcentaje = (total > 0) ? (monto / total * 100) : 0;
                              return Text(
                                '${porcentaje.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: porcentaje > 100 ? Colors.red : Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    )),
                // Visualización de "Total usado" y "No usado"
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    children: [
                      // Total usado
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Builder(
                            builder: (_) {
                              final total = viewModel.montoTotal;
                              final usado = viewModel.montoCategorias;
                              final porcentajeUsado = (total > 0) ? (usado / total * 100) : 0;
                              final sobrepasado = porcentajeUsado > 100;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total usado',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: sobrepasado ? Colors.red : Colors.green[800],
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '\$${usado.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: sobrepasado ? Colors.red : Colors.green[900],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    '${porcentajeUsado.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: sobrepasado ? Colors.red : Colors.green[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // No usado
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blueGrey, width: 1),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Builder(
                            builder: (_) {
                              final total = viewModel.montoTotal;
                              final usado = viewModel.montoCategorias;
                              final noUsado = (total - usado).clamp(0, total);
                              final porcentaje = (total > 0) ? (noUsado / total * 100) : 0;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'No usado',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[800],
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '\$${noUsado.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.blueGrey[900],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    '${porcentaje.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: Colors.blueGrey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),

                // Botón para guardar el plan
                ElevatedButton(
                  onPressed: () async {
                    final total = viewModel.montoTotal;
                    final usado = viewModel.montoCategorias;
                    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                    final uid = authViewModel.user?.uid;

                    if (total == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Debes ingresar un monto total.')),
                      );
                      return;
                    }
                    if (usado > total) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('El total usado no puede superar el monto total.')),
                      );
                      return;
                    }
                    if (uid == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No se pudo obtener el usuario.')),
                      );
                      return;
                    }
                    try {
                      // Buscar si ya existe un plan para este usuario
                      final snapshot = await FirebaseFirestore.instance
                          .collection('planes')
                          .where('uid', isEqualTo: uid)
                          .orderBy('fecha', descending: true)
                          .limit(1)
                          .get();

                      final planData = {
                        'uid': uid,
                        'montoTotal': total,
                        'categorias': viewModel.categorias.map((cat) => {
                          'nombre': cat.nombre,
                          'montoMaximo': cat.montoMaximo,
                        }).toList(),
                        'fecha': FieldValue.serverTimestamp(),
                        'fechaLocal': DateTime.now().toIso8601String(),
                      };

                      if (snapshot.docs.isNotEmpty) {
                        // Si existe, actualiza el documento
                        await FirebaseFirestore.instance
                            .collection('planes')
                            .doc(snapshot.docs.first.id)
                            .update(planData);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('¡Plan actualizado exitosamente!')),
                        );
                      } else {
                        // Si no existe, crea uno nuevo
                        await FirebaseFirestore.instance.collection('planes').add(planData);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('¡Plan guardado exitosamente!')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al guardar el plan: $e')),
                      );
                    }
                  },
                  child: Text('Guardar plan'),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
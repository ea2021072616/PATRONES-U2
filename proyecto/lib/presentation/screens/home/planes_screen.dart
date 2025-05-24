import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/planes_model.dart';
import '../../viewmodels/planes_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../complementos/planes_edit_view.dart'; // Asegúrate de importar la pantalla de edición

class PlanesVisualizacionScreen extends StatefulWidget {
  @override
  State<PlanesVisualizacionScreen> createState() => _PlanesVisualizacionScreenState();
}

class _PlanesVisualizacionScreenState extends State<PlanesVisualizacionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final uid = authViewModel.user?.uid;
      if (uid != null) {
        await Provider.of<PlanesViewModel>(context, listen: false).cargarPlanDesdeFirebase(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlanesViewModel>(
      builder: (context, viewModel, child) {
        final categorias = viewModel.categorias;
        final montoTotal = viewModel.montoTotal;

        return Scaffold(
          appBar: AppBar(
            title: Text('Montos por Categoría'),
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                tooltip: 'Editar plan',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PlanesScreen()),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: categorias.isEmpty
                ? Center(child: Text('No hay datos de categorías guardados.'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monto total del plan: \$${montoTotal.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: categorias.length,
                          itemBuilder: (context, index) {
                            final cat = categorias[index];
                            final porcentaje = montoTotal > 0
                                ? (cat.montoMaximo / montoTotal * 100)
                                : 0;
                            return Card(
                              child: ListTile(
                                title: Text(cat.nombre),
                                subtitle: Text(
                                  'Monto: \$${cat.montoMaximo.toStringAsFixed(2)}   (${porcentaje.toStringAsFixed(1)}%)',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
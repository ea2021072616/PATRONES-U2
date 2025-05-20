import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/editar_json_recibido_viewmodel.dart';
import '../../../data/models/productos_model.dart';

class EditarJsonView extends StatelessWidget {
  const EditarJsonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EditarJsonRecibidoViewModel>(context);

    final lugarController = TextEditingController(text: viewModel.compra.lugarCompra);
    final fechaController = TextEditingController(text: viewModel.compra.fechaEmision);
    final subtotalController = TextEditingController(text: viewModel.compra.subtotal.toString());
    final impuestosController = TextEditingController(text: viewModel.compra.impuestos.toString());
    final totalController = TextEditingController(text: viewModel.compra.total.toString());

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Transacción')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: fechaController,
              decoration: const InputDecoration(labelText: 'Fecha de emisión'),
              onChanged: (value) {
                viewModel.actualizarCompra(
                  fechaEmision: value,
                  subtotal: double.tryParse(subtotalController.text) ?? 0,
                  impuestos: double.tryParse(impuestosController.text) ?? 0,
                  total: double.tryParse(totalController.text) ?? 0,
                  lugarCompra: lugarController.text,
                );
              },
            ),
            TextField(
              controller: subtotalController,
              decoration: const InputDecoration(labelText: 'Subtotal'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                viewModel.actualizarCompra(
                  fechaEmision: fechaController.text,
                  subtotal: double.tryParse(value) ?? 0,
                  impuestos: double.tryParse(impuestosController.text) ?? 0,
                  total: double.tryParse(totalController.text) ?? 0,
                  lugarCompra: lugarController.text,
                );
              },
            ),
            TextField(
              controller: impuestosController,
              decoration: const InputDecoration(labelText: 'Impuestos'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                viewModel.actualizarCompra(
                  fechaEmision: fechaController.text,
                  subtotal: double.tryParse(subtotalController.text) ?? 0,
                  impuestos: double.tryParse(value) ?? 0,
                  total: double.tryParse(totalController.text) ?? 0,
                  lugarCompra: lugarController.text,
                );
              },
            ),
            TextField(
              controller: totalController,
              decoration: const InputDecoration(labelText: 'Total'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                viewModel.actualizarCompra(
                  fechaEmision: fechaController.text,
                  subtotal: double.tryParse(subtotalController.text) ?? 0,
                  impuestos: double.tryParse(impuestosController.text) ?? 0,
                  total: double.tryParse(value) ?? 0,
                  lugarCompra: lugarController.text,
                );
              },
            ),
            TextField(
              controller: lugarController,
              decoration: const InputDecoration(labelText: 'Lugar de Transacción'),
              onChanged: (value) {
                viewModel.actualizarCompra(
                  fechaEmision: fechaController.text,
                  subtotal: double.tryParse(subtotalController.text) ?? 0,
                  impuestos: double.tryParse(impuestosController.text) ?? 0,
                  total: double.tryParse(totalController.text) ?? 0,
                  lugarCompra: value,
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Detalles:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...List.generate(viewModel.compra.productos.length, (index) {
              final producto = viewModel.compra.productos[index];
              final descController = TextEditingController(text: producto.descripcion);
              final importeController = TextEditingController(text: producto.importe.toString());
              final categoriaController = TextEditingController(text: producto.categoria);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: 'Descripción'),
                        onChanged: (value) {
                          viewModel.actualizarProducto(
                            index,
                            ProductoModel(
                              descripcion: value,
                              importe: double.tryParse(importeController.text) ?? 0,
                              categoria: categoriaController.text,
                            ),
                          );
                        },
                      ),
                      TextField(
                        controller: importeController,
                        decoration: const InputDecoration(labelText: 'Importe'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          viewModel.actualizarProducto(
                            index,
                            ProductoModel(
                              descripcion: descController.text,
                              importe: double.tryParse(value) ?? 0,
                              categoria: categoriaController.text,
                            ),
                          );
                        },
                      ),
                      TextField(
                        controller: categoriaController,
                        decoration: const InputDecoration(labelText: 'Categoría'),
                        onChanged: (value) {
                          viewModel.actualizarProducto(
                            index,
                            ProductoModel(
                              descripcion: descController.text,
                              importe: double.tryParse(importeController.text) ?? 0,
                              categoria: value,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                try {
                  await viewModel.guardarEnFirestore();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Información guardada con éxito')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al guardar la información: $e')),
                  );
                }
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
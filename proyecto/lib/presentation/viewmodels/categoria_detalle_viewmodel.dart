import 'package:flutter/material.dart';

// Supón que tienes un modelo EgresoModel
class EgresoModel {
  final String descripcion;
  final double importe;
  final String categoria;

  EgresoModel({
    required this.descripcion,
    required this.importe,
    required this.categoria,
  });
}

// Simulación de egresos (reemplaza por tu fuente de datos real)
final List<EgresoModel> egresos = [
  EgresoModel(
    descripcion: 'Supermercado',
    importe: 500,
    categoria: 'Alimentos',
  ),
  EgresoModel(descripcion: 'Cine', importe: 120, categoria: 'Entretenimiento'),
  EgresoModel(descripcion: 'Veterinario', importe: 300, categoria: 'Mascotas'),
  EgresoModel(descripcion: 'Zapatos', importe: 800, categoria: 'Ropa'),
  EgresoModel(descripcion: 'Restaurante', importe: 250, categoria: 'Alimentos'),
  // ...otros egresos
];

class CategoriaDetalleView extends StatelessWidget {
  final String categoria;

  const CategoriaDetalleView({Key? key, required this.categoria})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filtra los egresos por la categoría seleccionada
    final egresosFiltrados =
        egresos.where((e) => e.categoria == categoria).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Egresos: $categoria')),
      body:
          egresosFiltrados.isEmpty
              ? const Center(child: Text('No hay egresos en esta categoría.'))
              : ListView.separated(
                itemCount: egresosFiltrados.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final egreso = egresosFiltrados[index];
                  return ListTile(
                    leading: const Icon(Icons.money_off),
                    title: Text(egreso.descripcion),
                    subtitle: Text(
                      'Monto: \$${egreso.importe.toStringAsFixed(2)}',
                    ),
                  );
                },
              ),
    );
  }
}

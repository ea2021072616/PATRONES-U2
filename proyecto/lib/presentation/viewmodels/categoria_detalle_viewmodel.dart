import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../data/models/productos_model.dart';

class CategoriaDetalleView extends StatelessWidget {
  final String categoria;

  const CategoriaDetalleView({Key? key, required this.categoria}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Productos: $categoria')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('egresos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay productos en esta categoría.'));
          }

          // Obtener todos los productos de la categoría seleccionada
          final productosFiltrados = snapshot.data!.docs
              .map((doc) => CompraModel.fromMap(doc.data() as Map<String, dynamic>))
              .expand((compra) => compra.productos)
              .where((producto) => producto.categoria == categoria)
              .toList();

          if (productosFiltrados.isEmpty) {
            return const Center(child: Text('No hay productos en esta categoría.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total de productos: ${productosFiltrados.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: productosFiltrados.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final producto = productosFiltrados[index];
                    return ListTile(
                      leading: const Icon(Icons.shopping_cart),
                      title: Text(producto.descripcion),
                      subtitle: Text(
                        'Monto: \$${producto.importe.toStringAsFixed(2)}',
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

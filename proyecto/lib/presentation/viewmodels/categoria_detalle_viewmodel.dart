import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/productos_model.dart';
import 'auth_viewmodel.dart';

class CategoriaDetalleView extends StatelessWidget {
  final String categoria;

  const CategoriaDetalleView({Key? key, required this.categoria}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<AuthViewModel>(context, listen: false).user?.uid;
    return Scaffold(
      appBar: AppBar(title: Text('Facturas: $categoria')),
      body: uid == null
          ? const Center(child: Text('Usuario no autenticado.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('egresos')
                  .where('id_usuario', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay facturas en esta categoría.'));
                }

                // Obtiene todas las facturas (egresos) que tengan al menos un producto de la categoría seleccionada
                final facturasFiltradas = snapshot.data!.docs
                    .map((doc) => CompraModel.fromMap(doc.data() as Map<String, dynamic>))
                    .where((compra) => compra.productos.any((producto) => producto.categoria == categoria))
                    .toList();

                if (facturasFiltradas.isEmpty) {
                  return const Center(child: Text('No hay facturas en esta categoría.'));
                }

                return ListView.separated(
                  itemCount: facturasFiltradas.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final factura = facturasFiltradas[index];
                    return ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text('Factura: ${factura.lugarCompra}'),
                      subtitle: Text('Fecha: ${factura.fechaEmision}\nTotal: \$${factura.total.toStringAsFixed(2)}'),
                      onTap: () {
                        // Aquí navegas a la pantalla de detalle de la factura
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FacturaDetalleView(factura: factura, categoria: categoria),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

// Debes crear esta pantalla para mostrar los productos de la factura seleccionada
class FacturaDetalleView extends StatelessWidget {
  final CompraModel factura;
  final String categoria;

  const FacturaDetalleView({Key? key, required this.factura, required this.categoria}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Solo productos de la categoría seleccionada
    final productos = factura.productos.where((p) => p.categoria == categoria).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Factura')),
      body: ListView.separated(
        itemCount: productos.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final producto = productos[index];
          return ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: Text(producto.descripcion),
            subtitle: Text('Monto: \$${producto.importe.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}

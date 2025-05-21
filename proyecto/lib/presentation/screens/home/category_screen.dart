import 'package:flutter/material.dart';
// Agrega este import:
import '../../viewmodels/categoria_detalle_viewmodel.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({Key? key}) : super(key: key);

  // Lista de categorías por defecto
  final List<String> categorias = const [
    'Alimentos',
    'Hogar',
    'Ropa',
    'Salud',
    'Tecnología',
    'Entretenimiento',
    'Transporte',
    'Mascotas',
    'Otros',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: ListView.separated(
        itemCount: categorias.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.category),
            title: Text(categorias[index]),
            onTap: () {
              // Redirige a la pantalla de detalle de categoría
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CategoriaDetalleView(categoria: categorias[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

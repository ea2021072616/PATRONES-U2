import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../viewmodels/ia_scaner_viewmodel.dart';
import '../../viewmodels/editar_json_recibido_viewmodel.dart';
import '../../../core/utils/formato_json.dart';
import '../complementos/editar_json_view.dart';

class IaScanerScreen extends StatelessWidget {
  final String apiKey;

  const IaScanerScreen({super.key, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<IaScanerViewModel>(
      create: (context) => IaScanerViewModel(apiKey: apiKey),
      child: Scaffold(
        appBar: AppBar(title: const Text('Escanear Factura')),
        body: const IaScanerBody(),
      ),
    );
  }
}

class IaScanerBody extends StatefulWidget {
  const IaScanerBody({super.key});

  @override
  State<IaScanerBody> createState() => _IaScanerBodyState();
}

class _IaScanerBodyState extends State<IaScanerBody> {
  bool _hasNavigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = context.watch<IaScanerViewModel>();

    // Solo navega si hay mensajes y aún no se ha navegado
    if (!_hasNavigated && viewModel.messages.isNotEmpty) {
      final mensaje = viewModel.messages.last;
      final jsonMap = FileUtils.parseResponseToMap(mensaje);
      if (jsonMap != null) {
        _hasNavigated = true;
        Future.microtask(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) {
                  final vm = EditarJsonRecibidoViewModel();
                  vm.cargarDesdeJson(jsonMap);
                  return vm;
                },
                child: const EditarJsonView(),
              ),
            ),
          ).then((_) {
            // Permite volver a navegar si el usuario regresa
            setState(() {
              _hasNavigated = false;
            });
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<IaScanerViewModel>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.document_scanner,
                    color: Colors.green,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Escanear Factura',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Botones de galería y cámara
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                    onPressed: () async {
                      await viewModel.pickAndAnalyzeImageFromGallery(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green.shade700,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.green.withOpacity(0.3),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                    onPressed: () async {
                      await viewModel.captureAndAnalyzeImageFromCamera(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green.shade700,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.green.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Mostrar la imagen escaneada
            if (viewModel.currentImage != null)
              Expanded(
                child: Center(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        viewModel.currentImage!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
              ),

            // Mostrar mensaje de error
            if (viewModel.lastError != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  viewModel.lastError!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Mostrar símbolo de cargando si está procesando
            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 24.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
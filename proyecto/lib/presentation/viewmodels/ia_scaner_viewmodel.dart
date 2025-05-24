import 'dart:typed_data';
import 'package:VanguardMoney/core/utils/formato_json.dart';
import 'package:VanguardMoney/data/services/imagen_picker_service.dart';
import 'package:VanguardMoney/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class IaScanerViewModel extends ChangeNotifier {
  final GenerativeModel _model;
  late final ChatSession _chat;
  final ImagePickerService _imagePickerService = ImagePickerService();

  List<String> messages = [];
  bool isLoading = false;
  Uint8List? currentImage;
  String? lastError;

  IaScanerViewModel({required String apiKey})
      : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey) {
    _chat = _model.startChat();
  }

  // Obtiene el UID del usuario dinámicamente
  String _getUserId(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    return authViewModel.user?.uid ?? 'unknown_user';
  }

  // Analiza una imagen
  Future<void> analyzeImage(Uint8List imageBytes, BuildContext context) async {
    final userId = _getUserId(context);
    isLoading = true;
    messages.add("Analizando factura...");
    notifyListeners();

    try {
      final response = await _chat.sendMessage(
        Content.multi([
          TextPart(_getAnalysisPrompt(userId)),
          DataPart('image/jpeg', imageBytes),
        ]),
      );

      if (response.text != null) {
        messages.add(response.text!);
        await FileUtils.parseResponseToMap(response.text!);
        notifyListeners();
      }
    } catch (e) {
      lastError = 'Error al analizar la imagen: ${e.toString()}';
      messages.add(lastError!);
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Procesa una factura en texto
  Future<void> processTextInvoice(
    String invoiceText,
    BuildContext context,
  ) async {
    final userId = _getUserId(context);
    try {
      isLoading = true;
      messages.add("Procesando factura de texto...");
      notifyListeners();

      final response = await _chat.sendMessage(
        Content.text(
          _getTextAnalysisPrompt(invoiceText, userId),
        ),
      );

      if (response.text != null) {
        messages.add(response.text!);
        await FileUtils.parseResponseToMap(response.text!);
        notifyListeners();
      }
    } catch (e) {
      lastError = 'Error al procesar la factura de texto: ${e.toString()}';
      messages.add(lastError!);
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Selecciona imagen de la galería y la analiza
  Future<void> pickAndAnalyzeImageFromGallery(BuildContext context) async {
    try {
      lastError = null;
      final imageBytes = await _imagePickerService.pickImageFromGallery();
      if (imageBytes == null) return;

      currentImage = imageBytes;
      await analyzeImage(imageBytes, context);
    } catch (e) {
      lastError = 'Error al seleccionar imagen: ${e.toString()}';
      messages.add(lastError!);
      notifyListeners();
    }
  }

  // Captura imagen de la cámara y la analiza
  Future<void> captureAndAnalyzeImageFromCamera(BuildContext context) async {
    try {
      lastError = null;
      final imageBytes = await _imagePickerService.captureImageFromCamera();
      if (imageBytes == null) return;

      currentImage = imageBytes;
      await analyzeImage(imageBytes, context);
    } catch (e) {
      lastError = 'Error al capturar imagen: ${e.toString()}';
      messages.add(lastError!);
      notifyListeners();
    }
  }

  // Limpia los datos
  void clearData() {
    messages.clear();
    currentImage = null;
    lastError = null;
    isLoading = false;
    notifyListeners();
  }

  // Obtiene la fecha actual en el formato deseado
  String _getCurrentDate() {
    final now = DateTime.now();
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(now);
  }

  // Prompts reutilizables
  String _getAnalysisPrompt(String userId) {
    final currentDate = _getCurrentDate();
    return """
      Solo extrae no des más conversación ni una entrada de diálogo solo dame a la categoría que pertenece
      (Categorías: Alimentos, Hogar, Ropa, Salud, Tecnología, Entretenimiento, Transporte, Mascotas, Otros:otros no pertenece a 
      ninguna de las otras categorías),el nombre del producto,el precio, el usuario(El nombre de usuario ya esta definodo) y la fecha.Que estén en un formato json.
      En categoría_superior escribe la categoría de la factura completa (Categorías: Alimentos, Hogar, Ropa, Salud, Tecnología, Entretenimiento, Transporte, Mascotas, Otros:otros no pertenece a 
      ninguna de las otras categorías).
      Si lo que se entrega no es una factura, no respondas nada.
      Si lo que se entrega no son datos como precios o productos, no respondas nada.
      Debes de tomar el id_usuario de la app,campo que te paso, y no de la factura.
      Debes de tomar la fechaEmision del campo que te paso(currentDate), y no de la factura.
      Si la fecha no se especifica, usa la fecha actual: $currentDate.
      Si la fecha está en el futuro reemplaza la fecha por la fecha actual: $currentDate.
      No olvides rellenar el total, subtotal e impuestos(Si no se te da subtotal o impuestos escribe es esos campos "0.0").
      Si no hay lugar de compra, simplemente escribe en el campo correspondente "No especificado".

      Ejemplo de tipo de respuesta que quiero:
        
      {
        "id_usuario": "$userId",
        "fechaEmision": "$currentDate",
        "subtotal": 0.0,
        "impuestos": 0.0,
        "total": 0.0,
        "lugar_compra": "",
        "categoria_superior": "",
        "productos": [
          {
            "descripcion": "",
            "importe": 0.0,
            "categoria": ""
          }
        ]
      }

    """;
  }

  String _getTextAnalysisPrompt(String invoiceText, String userId) {
    final currentDate = _getCurrentDate();
    return """
      Solo extrae no des más conversación ni una entrada de diálogo solo dame a la categoría que pertenece
      (Categorías: Alimentos, Hogar, Ropa, Salud, Tecnología, Entretenimiento, Transporte, Mascotas, Otros:otros no pertenece a 
      ninguna de las otras categorías),el nombre del producto,el precio, el usuario(El nombre de usuario ya esta definodo) y la fecha.Que estén en un formato json.
      En categoría_superior escribe la categoría de la factura completa (Categorías: Alimentos, Hogar, Ropa, Salud, Tecnología, Entretenimiento, Transporte, Mascotas, Otros:otros no pertenece a 
      ninguna de las otras categorías).
      Si lo que se entrega no es una factura, no respondas nada.
      Si lo que se entrega no son datos como precios o productos, no respondas nada.
      Debes de tomar el id_usuario de la app,campo que te paso, y no de la factura.
      Debes de tomar la fechaEmision del campo que te paso(currentDate), y no de la factura.
      Si la fecha no se especifica, usa la fecha actual: $currentDate.
      Si la fecha está en el futuro reemplaza la fecha por la fecha actual: $currentDate.
      No olvides rellenar el total, subtotal e impuestos(Si no se te da subtotal o impuestos escribe es esos campos "0.0").
      Si no hay lugar de compra, simplemente escribe en el campo correspondente "No especificado".

      Ejemplo de tipo de respuesta que quiero:
      {
        "id_usuario": "$userId",
        "fechaEmision": "$currentDate",
        "subtotal": 0.0,
        "impuestos": 0.0,
        "total": 0.0,
        "lugar_compra": "",
        "categoria_superior": "",
        "productos": [
          {
            "descripcion": "",
            "importe": 0.0,
            "categoria": ""
          }
        ]
      }
      
      Factura:
      $invoiceText
    """;
  }
}
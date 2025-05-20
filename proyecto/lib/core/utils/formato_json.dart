import 'dart:convert';

class FileUtils {
  // Limpia y parsea el JSON recibido, ya no guarda en Firestore
  static Map<String, dynamic>? parseResponseToMap(String responseText) {
    try {
      String cleanedResponse = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      return jsonDecode(cleanedResponse);
    } catch (e) {
      print('Error al parsear JSON: ${e.toString()}');
      return null;
    }
  }
}
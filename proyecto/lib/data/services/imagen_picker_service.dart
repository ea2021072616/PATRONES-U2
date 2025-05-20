import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<Uint8List?> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;
    return await pickedFile.readAsBytes();
  }

  Future<Uint8List?> captureImageFromCamera() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 85, // Calidad media para balance entre tamaño y calidad
    );
    if (pickedFile == null) return null;
    return await pickedFile.readAsBytes();
  }
}
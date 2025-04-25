import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PhoneImage {
  Future<File?> pickImageFromGallery(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();

      // Crear una ruta destino
      final fileName = pickedFile.name; // ej: imagen.jpg
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

      return File(savedImage.path);
    }
    return null;
  }

}

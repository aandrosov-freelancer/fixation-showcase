import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class LocalImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickAndSaveImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'note_images'));
      if (!imagesDir.existsSync()) {
        await imagesDir.create(recursive: true);
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(pickedFile.path)}';
      final savedImagePath = path.join(imagesDir.path, fileName);

      final savedFile = await File(pickedFile.path).copy(savedImagePath);
      return savedFile.path;
    } catch (e) {
      return null;
    }
  }
}

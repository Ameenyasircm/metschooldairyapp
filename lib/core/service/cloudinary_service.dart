import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static const String _cloudName = 'dt9qsvvp2';
  static const String _uploadPreset = 'METSCHOOL';

  static final CloudinaryPublic _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  static Future<String> uploadImage({
    required Uint8List bytes,
    required String folder,
    required String fileName,
  }) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromByteData(
          bytes.buffer.asByteData(),
          resourceType: CloudinaryResourceType.Image,
          folder: folder,
          identifier: fileName,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image to Cloudinary: $e');
    }
  }
}

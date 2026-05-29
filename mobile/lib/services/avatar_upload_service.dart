import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/config.dart';

class AvatarUploadService {
  final _picker = ImagePicker();

  Future<XFile?> pickFromGallery() => _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

  Future<XFile?> pickFromCamera() => _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

  Future<String> uploadFile(XFile file, String token) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/auth/me/avatar');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath('avatar', file.path),
    );

    final streamed = await request.send().timeout(const Duration(seconds: 45));
    final body = await http.Response.fromStream(streamed);

    if (body.statusCode != 200) {
      String msg = 'HTTP ${body.statusCode}';
      try {
        final j = jsonDecode(body.body) as Map<String, dynamic>;
        msg = j['error'] as String? ?? msg;
      } catch (_) {}
      switch (msg) {
        case 'file_too_large':
          throw Exception('Dosya cok buyuk (max 2 MB)');
        case 'invalid_file_type':
          throw Exception('Sadece JPG, PNG veya WebP');
        case 'no_file':
          throw Exception('Dosya secilmedi');
        default:
          throw Exception(msg);
      }
    }

    final data = jsonDecode(body.body) as Map<String, dynamic>;
    final url = data['avatarUrl'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Sunucu avatar URL donmedi');
    }
    return url;
  }
}

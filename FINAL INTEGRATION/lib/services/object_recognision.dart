import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ObjectRecognitionService {
  final ImagePicker _picker = ImagePicker();

  Future<void> captureAndSendImage() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://your-backend-url/detect'));
      request.files.add(await http.MultipartFile.fromPath('image', photo.path));
      var response = await request.send();
      print('Response status: ${response.statusCode}');
    }
  }
}

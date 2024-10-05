import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ObjectRecognitionService {
  final ImagePicker _picker = ImagePicker();

  Future<List<String>> detectObjects() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://your-backend-url/detect'));
      request.files.add(await http.MultipartFile.fromPath('image', photo.path));
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseData.body);
        return List<String>.from(jsonResponse['detected_objects']);
      } else {
        return ['Error: Could not detect objects'];
      }
    }
    return [];
  }
}

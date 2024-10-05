import 'dart:convert';
import 'package:http/http.dart' as http;

class NLPService {
  Future<String> getMemoryPrompt(String query) async {
    var url = Uri.parse('http://your-backend-url/memory_prompt');
    var response = await http.post(url,
        body: jsonEncode({'query': query}),
        headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse['response'];
    } else {
      return 'Sorry, I couldn\'t understand that.';
    }
  }
}

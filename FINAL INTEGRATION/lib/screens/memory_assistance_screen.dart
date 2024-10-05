import 'package:flutter/material.dart';
import 'package:alzheimers_memory_aid/services/nlp_service.dart';

class MemoryAssistanceScreen extends StatefulWidget {
  @override
  _MemoryAssistanceScreenState createState() => _MemoryAssistanceScreenState();
}

class _MemoryAssistanceScreenState extends State<MemoryAssistanceScreen> {
  final TextEditingController _controller = TextEditingController();
  String response = "";

  void _getResponse() async {
    NLPService nlpService = NLPService();
    String query = _controller.text;
    String result = await nlpService.getMemoryPrompt(query);
    setState(() {
      response = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Memory Assistance")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Ask something...",
              ),
            ),
            ElevatedButton(
              onPressed: _getResponse,
              child: Text("Get Response"),
            ),
            SizedBox(height: 20),
            Text(response, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

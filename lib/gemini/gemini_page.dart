import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'gemini_apikey.dart';

//変更点
//geminiディレクトリ内のファイルはGeminiAPIを試しに利用した時に作ったものです

class GeminiPage extends StatefulWidget {
  const GeminiPage({super.key});

  @override
  State<GeminiPage> createState() => _GeminiPageState();
}

class _GeminiPageState extends State<GeminiPage> {
  late String _sendText = '一日1,500リクエストまで無料';

  final controller = TextEditingController();
  bool _isLoading = false;

  Future<void> callGemini() async {
    setState(() {
      _isLoading = true;
    });
    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: geminiApiKey,
    );
    final content = [
      Content.text(controller.text),
    ];
    final responce = await model.generateContent(content);
    setState(() {
      _sendText = responce.text!;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geminiに質問しよう'),
      ),
      body: GestureDetector(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _isLoading
                    ? const CircularProgressIndicator()
                    : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _sendText,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => controller.clear(), //リセット処理
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          callGemini();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.send),
      ),
    );
  }
}
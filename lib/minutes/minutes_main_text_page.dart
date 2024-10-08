import 'dart:convert';

import 'package:flutter/material.dart';
import '../domain/memo_data.dart';
import 'package:http/http.dart' as http;

class MainTextPage extends StatefulWidget {
  final MemoData memo;
  const MainTextPage({Key? key, required this.memo}) : super(key: key);

  @override
  _MainTextPageState createState() => _MainTextPageState();
}

class _MainTextPageState extends State<MainTextPage> {

  late TextEditingController _mainTextController;

  late FocusNode _mainTextNode;

  @override
  void initState() {
    _mainTextController = TextEditingController();
    _mainTextController.text = widget.memo.mainText;

    _mainTextNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _mainTextNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.blue.shade800,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          centerTitle: true,
          elevation: 0.0,
          title: Text(widget.memo.title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                // mainTextの更新
                await updateMainText();
              },
            ),
          ]
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 40,
              controller: _mainTextController,

            ),
          ),
          const SizedBox(height: 50), // 下部に50ピクセルの空白を追加
        ],
      ),
    );
  }

  Future updateMainText() async {
    final url = Uri.parse('http://localhost:8000/update_main_text/${widget.memo.id}');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'main_text': _mainTextController.text,
      }),
    );

    if (response.statusCode == 200) {
      // POSTリクエストが成功した場合
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');
    } else {
      // POSTリクエストが失敗した場合
      print('Request failed with status: ${response.statusCode}');
    }
  }
}
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../domain/memo_data.dart';
import '../network/url.dart'; // httpUrl, wsUrl の定義
import 'minutes_pdf_preview.dart';
import 'minutes_websocket.dart';
import 'voice_minutes/voice_minutes_page.dart'; // WebSocketクライアントクラス

class MainTextPage extends StatefulWidget {
  final MemoData memo;
  const MainTextPage({Key? key, required this.memo}) : super(key: key);

  @override
  _MainTextPageState createState() => _MainTextPageState();
}

class _MainTextPageState extends State<MainTextPage> {
  late TextEditingController _mainTextController;
  late FocusNode _mainTextNode;
  MeetingWebSocketClient? _webSocketClient; // WebSocket クライアント
  bool _isLoading = true; // ロード状態
  bool _isUserInput = true; // 🚀 ユーザーが入力したかどうか
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _mainTextController = TextEditingController();
    _mainTextNode = FocusNode();

    _fetchMeetingText(); // 初回ロード時に過去の議事録を取得
  }

  /// ✅ 既存の議事録 (`main_text`) を取得
  Future<void> _fetchMeetingText() async {
    final url = Uri.parse('${httpUrl}meetings/${widget.memo.id}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _mainTextController.text = data['main_text']; // 過去のテキストをセット
        _isLoading = false;
      });

      // WebSocket 接続開始
      _initializeWebSocket();
    } else {
      print("❌ Failed to fetch meeting text");
    }
  }

  /// ✅ WebSocket 初期化
  void _initializeWebSocket() {
    _webSocketClient = MeetingWebSocketClient(
      meetingId: widget.memo.id,
      onTextReceived: (receivedText) {
        // 🚀 すでに同じテキストなら変更しない
        if (_mainTextController.text != receivedText) {
          setState(() {
            _isUserInput = false; // 🚀 受信したデータなので、送信しない
            _mainTextController.text = receivedText;
          });
        }
      },
    );

    _webSocketClient!.connect(wsUrl);

    // 🚀 ユーザーが入力した場合のみ WebSocket で送信
    _mainTextController.addListener(() {
      if (_isUserInput) {
        final newText = _mainTextController.text;

        // 🚀 デバウンス処理（一定時間待ってから送信）
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(Duration(milliseconds: 300), () {
          print("📤 Sending debounced text via WebSocket: $newText");
          _webSocketClient?.sendText(newText);
        });
      }
      _isUserInput = true; // 🚀 次回の変更は「ユーザー入力」として処理
    });
  }

  @override
  void dispose() {
    _mainTextController.dispose();
    _mainTextNode.dispose();
    _webSocketClient?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.memo.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          kIsWeb
              ? const SizedBox()
              : IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VoiceMemoPage(memo: widget.memo),
                ),
              );
            },
            icon: const Icon(Icons.mic),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MinutesPdfPreview(
                    _mainTextController.text,
                    widget.memo.title,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
          ),
          /*
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              try {
                await updateMainText();
                const snackBar = SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('議事録の更新をしました。'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } catch (e) {
                final snackBar = SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(e.toString()),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
          ),
          */
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // ローディング表示
          : GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: _mainTextController,
                  focusNode: _mainTextNode,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration:
                  const InputDecoration(border: InputBorder.none),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  /// ✅ HTTP PATCH で明示的に DB を更新
  Future updateMainText() async {
    final url = Uri.parse('${httpUrl}update_main_text/${widget.memo.id}');
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'main_text': _mainTextController.text}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }
}
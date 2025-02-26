import 'package:web_socket_channel/web_socket_channel.dart';

class MeetingWebSocketClient {
  final int meetingId;
  WebSocketChannel? _channel; // `late` を削除し、`null` を許容

  Function(String)? onTextReceived;

  MeetingWebSocketClient({
    required this.meetingId,
    this.onTextReceived,
  });

  /// WebSocket 接続を開始
  void connect(String wsBaseUrl) {
    final uri = Uri.parse('${wsBaseUrl}ws/meetings/$meetingId');

    if (_channel != null) {
      print("⚠️ 既にWebSocketが接続されています。新しい接続は作成しません。");
      return;
    }

    _channel = WebSocketChannel.connect(uri);
    print("✅ WebSocket connecting to: $uri");

    _channel?.stream.listen((message) {
      // `?.` を使って null を安全に処理
      print("📩 WebSocket received message: $message");
      if (onTextReceived != null) {
        onTextReceived!(message);
      }
    }, onError: (error) {
      print('⚠️ WebSocket error: $error');
      _channel = null; // エラー発生時に `_channel` をリセット
    }, onDone: () {
      print('🔌 WebSocket closed');
      _channel = null; // WebSocket が閉じられたら `_channel` をクリア
    });
  }

  /// 議事録テキストをサーバーに送信
  void sendText(String text) {
    if (_channel == null) {
      print("⚠️ WebSocket is not connected. Cannot send message.");
      return;
    }
    _channel!.sink.add(text);
  }

  /// 切断処理
  void disconnect() {
    if (_channel == null) {
      print("⚠️ WebSocket is already disconnected.");
      return;
    }
    _channel!.sink.close();
    _channel = null;
  }
}
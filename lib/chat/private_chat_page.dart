import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labmaidfastapi/chat/pdf_viewer.dart';
import 'package:labmaidfastapi/domain/chat_data.dart';
import 'package:labmaidfastapi/domain/user_data.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../pick_export/pick_image_export.dart';
import '../save_export/save_image_export.dart';

class PrivateChatPage extends StatefulWidget {
  final int privateChatroomId;
  final UserData userData;
  final UserData myData;
  const PrivateChatPage({
    Key? key,
    required this.privateChatroomId,
    required this.userData,
    required this.myData,
  }) : super(key: key);

  @override
  State<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  final TextEditingController _messageController = TextEditingController();
  late WebSocketChannel _channel;
  final List<PrivateMessageData> _messages = [];

  Future<void> _getImageFromGallery() async {
    final pickedImage = await PickImage().pickImage();
    if (pickedImage != null) {
      String base64Image = base64Encode(pickedImage);
      final message = {
        'content': '',
        'image_data': base64Image,
        'file_data': '',
        'file_name': '',
      };
      _channel.sink.add(json.encode(message));
      _messageController.clear();
      _scrollToBottom();
    }
  }

  Future<void> _getFileFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      if (path.extension(file.name).toLowerCase() != '.pdf') {
        throw '.pdf形式のみ送信できます。';
      } else {
        if (file.bytes != null) {
          String base64File = base64Encode(file.bytes!);
          final message = {
            'content': '',
            'image_data': '',
            'file_data': base64File,
            'file_name': file.name,
          };
          _channel.sink.add(json.encode(message));
          _messageController.clear();
          _scrollToBottom();
        }
      }

    }
  }



  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isExpanded = _focusNode.hasFocus;
      });
    });
    _fetchMessageHistory();
    _connectWebSocket();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  Future<void> _fetchMessageHistory() async {
    final response = await http.get(
      Uri.parse('http://sui.al.kansai-u.ac.jp/api/private_messages/${widget.privateChatroomId}'),
    );

    if (response.statusCode == 200) {
      var responseBody = utf8.decode(response.bodyBytes);
      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);
      final List<PrivateMessageData> fetchedMessages = body.map((message) => PrivateMessageData.fromJson(message)).toList();

      setState(() {
        _messages.addAll(fetchedMessages);
      });
      _scrollToBottom(); // ここでスクロールを呼び出し
    } else {
      // エラーハンドリング
      print('Failed to load messages');
    }
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://sui.al.kansai-u.ac.jp/api/ws_private_message/${widget.privateChatroomId}/${widget.myData.id}'),
    );
    _channel.stream.listen((message) {
      final decodedMessage = json.decode(message);
      if (decodedMessage['type'] == 'broadcast') {
        final newMessage = PrivateMessageData.fromJson(json.decode(decodedMessage['message']));
        setState(() {
          _messages.add(newMessage);
          _scrollToBottom();
        });
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final message = {
        'content': _messageController.text,
        'image_data': '',
        'file_data': '',
        'file_name': '',
      };
      _channel.sink.add(json.encode(message));
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _showImageDialog(BuildContext context, String imgData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Stack(
            children: [
              // 画像表示 (サイズ統一: 300x300)
              Center(
                child: Container(
                  width: 300, // 固定サイズ
                  height: 300, // 固定サイズ
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      base64Decode(imgData),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    ),
                  ),
                ),
              ),
              // 保存ボタンを画像の右下に配置
              Positioned(
                right: 25,
                bottom: 25,
                child: FloatingActionButton(
                  onPressed: () async {
                    await SaveImage().saveImage(base64Decode(imgData));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Image Saved!'),
                      ),
                    );
                  },
                  child: const Icon(Icons.save),
                ),
              ),
              // 戻るボタンを画像の左上に配置
              Positioned(
                left: 25,
                top: 25,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.userData.name),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            onPressed: () async {
              // チャットルームインフォ

            },
            icon: const Icon(Icons.info),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMyMessage = message.userId == widget.myData.id;
                  final userData = isMyMessage ? widget.myData : widget.userData;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMyMessage) ...[
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 20,
                            backgroundImage: userData.imgData != ''
                                ? Image.memory(
                              base64Decode(userData.imgData),
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, s) {
                                return const Icon(Icons.error, color: Colors.red);
                              },
                            ).image
                                : const AssetImage('assets/images/default.png'),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Column(
                            crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (!isMyMessage)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                                  child: Text(
                                    userData.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              Container(
                                decoration: BoxDecoration(
                                  color: isMyMessage ? Colors.blue[100] : Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(isMyMessage ? 12 : 0),
                                    topRight: Radius.circular(isMyMessage ? 0 : 12),
                                    bottomLeft: const Radius.circular(12),
                                    bottomRight: const Radius.circular(12),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    message.imgData == '' && message.fileData == ''
                                        ? Text(message.content)
                                        : message.fileData == ''
                                        ? GestureDetector(
                                           onTap: () async {
                                             _showImageDialog(context, message.imgData);
                                           },
                                           child: Image.memory(
                                             base64Decode(message.imgData),
                                             fit: BoxFit.cover,
                                             errorBuilder: (context, error, stackTrace) {
                                               return const Icon(Icons.error);
                                             },
                                           ),
                                        )
                                        : GestureDetector(
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => PdfViewScreen(
                                                        pdfData: message.fileData,
                                                        pdfName: message.fileName,
                                                    ),
                                                ),
                                              );
                                            },
                                            child: ListTile(
                                              leading: Icon(switchIcon(message.fileName)),
                                              title: Text(message.fileName),
                                            ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${DateFormat.yMMMd('ja').format(message.sentAt).toString()}(${DateFormat.E('ja').format(message.sentAt)})ー${DateFormat.Hm('ja').format(message.sentAt)}',
                                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isMyMessage) ...[
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 20,
                            backgroundImage: userData.imgData != ''
                                ? Image.memory(
                              base64Decode(userData.imgData),
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, s) {
                                return const Icon(Icons.error, color: Colors.red);
                              },
                            ).image
                                : const AssetImage('assets/images/default.png'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isExpanded ? 150 : 100,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _messageController,
                              minLines: 1,
                              focusNode: _focusNode,
                              maxLines: _isExpanded ? 5 : 1,
                              decoration: const InputDecoration(
                                hintText: 'メッセージを入力',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          if (!_isExpanded) ...[
                            IconButton(
                              onPressed: () async {
                                try {
                                  await _getFileFromGallery();
                                  const snackBar = SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text('ファイルの送信をしました。'),
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
                              icon: const Icon(Icons.attach_file, color: Colors.blueGrey),
                            ),
                            IconButton(
                              onPressed: () async {
                                try {
                                  await _getImageFromGallery();
                                  const snackBar = SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text('画像の送信をしました。'),
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
                              icon: const Icon(Icons.camera_alt, color: Colors.blue),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData switchIcon(String fileName) {
    IconData icon;
    switch (path.extension(fileName).toLowerCase()) {
      case '.jpg':
      case '.jpeg':
      case '.png':
        icon = Icons.image;
        break;
      case '.pdf':
        icon = Icons.picture_as_pdf;
        break;
      case '.doc':
      case '.docx':
        icon = Icons.description;
        break;
      case '.mp4':
      case '.mov':
        icon = Icons.movie;
        break;
      case '.mp3':
      case '.wav':
        icon = Icons.audiotrack;
        break;
      default:
        icon = Icons.insert_drive_file;
    }
    return icon;
  }
}


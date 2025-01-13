import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:labmaidfastapi/chat/pdf_viewer.dart';
import 'package:labmaidfastapi/chat/private/private_chat_message_list.dart';
import 'package:labmaidfastapi/chat/private/private_chat_room_info_page.dart';
import 'package:labmaidfastapi/domain/chat_data.dart';
import 'package:labmaidfastapi/domain/user_data.dart';
import 'package:labmaidfastapi/header_footer_drawer/footer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


import '../../network/url.dart';
import '../../pick_export/pick_image_export.dart';
import '../../save_export/save_image_export.dart';


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
  int _page = 1; // 現在のページ番号
  bool _isLoading = false; // データを読み込んでいるか
  bool _hasMore = true; // もっとデータがあるかどうか

  static const _scrollValueThreshold = 0.8;


  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  final TextEditingController _messageController = TextEditingController();
  late WebSocketChannel _channel;
  final List<PrivateMessageData> _messages = [];


  Future<bool> _getImageFromGallery() async {
    try {
      // PickImageクラスから画像を取得
      final pickedImage = await PickImage().pickImage();

      if (pickedImage == null) {
        return false; // 画像が選択されなかった場合
      }

      // POSTリクエストを送信するエンドポイントのURL
      var uri = Uri.parse('${httpUrl}private_messages/${widget.privateChatroomId}');
      final request = http.MultipartRequest('POST', uri);

      Map<String, String> headers = {"Content-type": "multipart/form-data"};

      final file = http.MultipartFile.fromBytes(
        'file',
        pickedImage.bytes,
        filename: pickedImage.fileName,
      );

      request.files.add(file);
      request.headers.addAll(headers);

      request.fields.addAll({
        'user_id': widget.myData.id,
        'message_type': 'image',
        'sent_at': DateTime.now().toIso8601String(),
        'is_read': false.toString(),
        'content': ' ',
      });

      // リクエストを送信
      final stream = await request.send();
      final response = await http.Response.fromStream(stream);

      if (response.statusCode == 200) {
        _scrollToBottom();
        return true; // 成功
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
        return false; // 失敗
      }
    } catch (e) {
      print('Exception: $e');
      return false; // エラー発生時
    }
  }


  Future<bool> _getFileFromGallery() async {
    try {
      // ファイルを選択
      FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
      if (result == null || result.files.isEmpty) {
        return false; // ファイルが選択されていない場合
      }

      PlatformFile file = result.files.first;

      if (file.bytes == null) {
        throw 'ファイルの読み込みに失敗しました。';
      }

      // POSTリクエストを送信するエンドポイントのURL
      var uri = Uri.parse('${httpUrl}private_messages/${widget.privateChatroomId}');

      final request = http.MultipartRequest('POST', uri);

      Map<String, String> headers = {"Content-type": "multipart/form-data"};

      final filePost = http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name);
      request.files.add(filePost);
      request.headers.addAll(headers);

      request.fields.addAll({
        'user_id': widget.myData.id,
        'message_type': 'file',
        'sent_at': DateTime.now().toIso8601String(),
        'is_read': false.toString(),
        'content': ' ',
      });

      // リクエストを送信
      final stream = await request.send();
      final response = await http.Response.fromStream(stream);

      if (response.statusCode == 200) {
        _scrollToBottom();
        return true; // 成功
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
        return false; // 失敗
      }
    } catch (e) {
      print('Exception: $e');
      return false; // エラー発生時
    }
  }


  @override
  void initState() {
    _focusNode.addListener(() {
      setState(() {
        _isExpanded = _focusNode.hasFocus;
      });
    });
    _fetchInitialMessageHistory();
    _connectWebSocket();


    // スクロール位置のリスナーを設定
    _scrollController.addListener(_onScroll);


    super.initState();
  }


  void _onScroll() async {
    final scrollValue = _scrollController.offset / _scrollController.position.maxScrollExtent;
    if (scrollValue > _scrollValueThreshold) {
      await _fetchMoreMessageHistory();
    }
  }

  // スクロールを最下部にする関数
  void _scrollToBottom() {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
  }


  Future<void> _fetchInitialMessageHistory() async {
    if (_isLoading) return; // 読み込み中であれば処理を中断
    setState(() {
      _isLoading = true; // ローディング状態に設定
    });


    try {
      final response = await http.get(
        Uri.parse('${httpUrl}private_messages/${widget.privateChatroomId}/?page=1'),
      );


      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> body = jsonDecode(responseBody);
        final List<PrivateMessageData> fetchedMessages =
        body.map((message) => PrivateMessageData.fromJson(message)).toList();


        setState(() {
          _messages.addAll(fetchedMessages); // 初期データを設定
          _page = 2; // 次に読み込むページを設定
          _hasMore = body.isNotEmpty; // 次のページが存在するか
        });
      } else {
        print('Failed to load initial messages');
      }
    } catch (e) {
      print('Error loading initial messages: $e');
    } finally {
      setState(() {
        _isLoading = false; // ローディング状態を解除
      });
    }
  }


  Future<void> _fetchMoreMessageHistory() async {
    if (_isLoading || !_hasMore) return; // 読み込み中またはデータがもうない場合は処理を中断
    setState(() {
      _isLoading = true; // ローディング状態に設定
    });


    try {
      final response = await http.get(
        Uri.parse('${httpUrl}private_messages/${widget.privateChatroomId}/?page=$_page'),
      );


      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> body = jsonDecode(responseBody);
        final List<PrivateMessageData> fetchedMessages =
        body.map((message) => PrivateMessageData.fromJson(message)).toList();


        setState(() {
          _messages.addAll(fetchedMessages); // 取得したメッセージをリストに追加
          _page++; // 次に読み込むページを更新
          _hasMore = body.isNotEmpty; // 次のページが存在するか
        });
      } else {
        print('Failed to load more messages');
      }
    } catch (e) {
      print('Error loading more messages: $e');
    } finally {
      setState(() {
        _isLoading = false; // ローディング状態を解除
      });
    }
  }


  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('${wsUrl}ws_private_message/${widget.privateChatroomId}'),
    );
    _channel.stream.listen((message) async {
      final decodedMessage = json.decode(message);
      if (decodedMessage['type'] == 'broadcast') {
        final newMessage = PrivateMessageData.fromJson(json.decode(decodedMessage['message']));
        if (newMessage.userId != widget.myData.id) {
          //Postリクエストを送信するエンドポイントのURL
          var uri = Uri.parse('${httpUrl}message_unread_update_websocket/${widget.privateChatroomId}/${newMessage.id}');


          final response = await http.post(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'private_chat_room_id': widget.privateChatroomId,
              'private_message_id': newMessage.id,
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
        setState(() {
          _messages.insert(0, newMessage); // 先頭に newMessage を追加
          // スクロール位置が最下部付近の場合のみ自動スクロール
          if (_scrollController.hasClients &&
              _scrollController.position.pixels <= 50) { // 50はスクロール位置の閾値
            _scrollToBottom();
          }
        });
      }
      if (decodedMessage['type'] == 'unread_update') {
        final dynamic messageData = decodedMessage['message'];
        List<dynamic> updates;


        if (messageData is String) {
          // 文字列の場合は JSON デコード
          updates = json.decode(messageData) as List<dynamic>;
        } else if (messageData is List<dynamic>) {
          // 既に List の場合
          updates = messageData;
        } else {
          throw FormatException('Invalid message format: ${messageData.runtimeType}');
        }


        for (var update in updates) {
          if (update is Map<String, dynamic>) {
            // 更新データからIDとisReadを取得
            final int? id = update['id'];
            final bool? isRead = update['is_read'];


            // IDがnullでない場合のみ処理
            if (id != null) {
              // 一致するメッセージを検索
              int index = _messages.indexWhere((msg) => msg.id == id);


              if (index != -1) {
                // 一致するメッセージのisReadを更新
                _messages[index].isRead = isRead ?? false; // デフォルトでfalseを設定
                print('Message with ID $id updated to isRead: ${isRead ?? false}');
              } else {
                print('Message with ID $id not found in _messages');
              }
            } else {
              print('Update data has no valid ID');
            }
          } else {
            print('Invalid update format: $update');
          }
        }
      }
      if (decodedMessage['type'] == 'message_unread_websocket') {
        final messageData = decodedMessage['message'];
        final int messageId = messageData['id'];
        final bool isRead = messageData['is_read'];
        // 対象メッセージを探し、isRead を更新
        final int index = _messages.indexWhere((msg) => msg.id == messageId);
        if (index != -1) {
          setState(() {
            _messages[index].isRead = isRead;
          });
          print('Message ID $messageId updated to isRead: $isRead');
        } else {
          print('Message ID $messageId not found in the message list.');
        }
      }
    });
  }


  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      //Postリクエストを送信するエンドポイントのURL
      var uri = Uri.parse('${httpUrl}private_messages/${widget.privateChatroomId}');


      final request = http.MultipartRequest('POST', uri);


      Map<String, String> headers = {"Content-type": "multipart/form-data"};


      final file = http.MultipartFile.fromBytes('file', [], filename: '');
      request.files.add(file);
      request.headers.addAll(headers);


      request.fields.addAll({
        'user_id': widget.myData.id,
        'message_type': 'text',
        'sent_at': DateTime.now().toIso8601String(),
        'is_read': false.toString(),
        'content': _messageController.text,
      });


      final stream = await request.send();


      return await http.Response.fromStream(stream).then(
              (response) {
            if (response.statusCode == 200) {
              _scrollToBottom();
              return response;
            }
            else {
              return Future.error(response);
            }
          });


    }
  }


  Future<void> _updateChatRoomDateTime() async {
    var uri = Uri.parse('${httpUrl}update_datetime_private_chat_room/${widget.privateChatroomId}');


    // 送信するデータを作成
    Map<String, dynamic> data = {
      'updated_at': DateTime.now().toIso8601String(),
    };


    // リクエストヘッダーを設定
    Map<String, String> headers = {
      'Content-Type': 'application/json', // JSON形式のデータを送信する場合
      // 他のヘッダーを必要に応じて追加
    };


    try {
      // HTTP POSTリクエストを送信
      final response = await http.patch(
        uri,
        headers: headers,
        body: json.encode(data), // データをJSON形式にエンコード
      );


      // レスポンスをログに出力（デバッグ用）
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');


    } catch (e) {
      // エラーハンドリング
      print('Error: $e');
    }
  }


  void _showImageDialog(BuildContext context, String imageURL) {
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
                    child: Image.network(
                      imageURL,
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
                    //保存
                    await SaveImage().saveImage(imageURL);
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


  void _downloadFile(String url) async {
    if (await canLaunch(url)) {
      await launch(url); // 外部リンクを使用してダウンロードを実行
    } else {
      throw 'ダウンロードできません: $url';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    _channel.sink.close();
    _scrollController.dispose();
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
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) {
                      return PrivateChatRoomInfo(privateChatroomId: widget.privateChatroomId, userData: widget.userData, myData: widget.myData);
                    }
                ),
              );


            },
            icon: const Icon(Icons.info),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) {
                    return const Footer(pageNumber: 2);
                  }
              ),
            );
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
              child: Scrollbar(
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length + 1,
                  reverse: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  cacheExtent: 1000,
                  itemBuilder: (context, index) {
                    if (index < _messages.length) {
                      return MessageListItem(
                        message: _messages[index],
                        isMyMessage: _messages[index].userId == widget.myData.id,
                        myData: widget.myData,
                        userData: widget.userData,
                        onImageTap: _showImageDialog,
                        onFileTap: (url, filename) async {
                          // 拡張子を取得
                          String extension = filename.split('.').last.toLowerCase();


                          if (extension == 'pdf') {
                            // 拡張子がpdfの場合はPdfViewScreenへ遷移
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PdfViewScreen(
                                  pdfURL: url,
                                  fileName: filename,
                                ),
                              ),
                            );
                          } else {
                            // 拡張子がpdfでない場合はダウンロード確認のポップアップを表示
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('ファイルのダウンロード'),
                                  content: Text('$filename をダウンロードしますか？'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('キャンセル'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _downloadFile(url); // ファイルのダウンロード処理
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('ダウンロード'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: _hasMore ? const SizedBox()
                              : const Text('No more data to load'),
                        ),
                      );
                    }
                  },
                ),
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
                                  final fileSent = await _getFileFromGallery();
                                  if (fileSent) {
                                    await _updateChatRoomDateTime();
                                    _messageController.clear();
                                    const snackBar = SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text('ファイルの送信をしました。'),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  }
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
                                  final imageSent = await _getImageFromGallery();
                                  if (imageSent) {
                                    await _updateChatRoomDateTime();
                                    _messageController.clear();
                                    const snackBar = SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text('画像の送信をしました。'),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  }
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
                    onPressed: () async {
                      await _sendMessage();
                      await _updateChatRoomDateTime();
                      setState(() {
                        _messageController.clear();
                      });
                    },
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




}




/*


*/

















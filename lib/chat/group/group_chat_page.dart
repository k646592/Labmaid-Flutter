import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:labmaidfastapi/chat/group/group_chat_room_info_page.dart';

import 'package:labmaidfastapi/domain/chat_data.dart';
import 'package:labmaidfastapi/domain/user_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../../header_footer_drawer/footer.dart';
import '../../network/url.dart';
import '../../pick_export/pick_image_export.dart';
import '../../save_export/save_image.dart';
import '../pdf_viewer.dart';
import 'group_chat_message_list.dart';


class GroupChatPage extends StatefulWidget {
  final GroupChatRoomData groupChatRoomData;
  final GroupChatUserData myData;
  final List<GroupChatUserData> groupUsers;
  const GroupChatPage({
    Key? key,
    required this.groupChatRoomData,
    required this.myData,
    required this.groupUsers,
  }) : super(key: key);

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  int _page = 1; // 現在のページ番号
  bool _isLoading = false; // データを読み込んでいるか
  bool _hasMore = true; // もっとデータがあるかどうか

  static const _scrollValueThreshold = 0.8;

  final TextEditingController _messageController = TextEditingController();
  late WebSocketChannel _channel;
  final List<GroupMessageData> _messages = [];

  List<GroupChatUserData> groupChatUsers = [];

  Future getGroupChatUsers(int groupChatRoomId) async {
    var uri = Uri.parse('${httpUrl}group_chat_room_users/$groupChatRoomId');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);
      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      // 必要なデータを取得
      groupChatUsers = body.map((dynamic json) => GroupChatUserData.fromJson(json)).toList();

    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }
  }

  Future<bool> _getImageFromGallery() async {
    DateTime sentAt = DateTime.now();
    try {
      // PickImageクラスから画像を取得
      final pickedImage = await PickImage().pickImage();

      if (pickedImage == null) {
        return false; // 画像が選択されなかった場合
      }

      // POSTリクエストを送信するエンドポイントのURL
      var uri = Uri.parse('${httpUrl}group_messages/${widget.groupChatRoomData.id}');
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
        'sent_at': sentAt.toIso8601String(),
        'content': ' ',
      });

      // リクエストを送信
      final stream = await request.send();
      final response = await http.Response.fromStream(stream);

      if (response.statusCode == 200) {
        _scrollToBottom();
        final responseData = jsonDecode(response.body); // レスポンスを JSON としてパース
        final GroupWebsocketMessageData fetchedMessage = GroupWebsocketMessageData.fromJson(responseData);

        final id = responseData['id'] as int;
        await _createUnreadMessages(id, sentAt);
        await _websocketMessage(fetchedMessage);
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

  Future<void> _websocketMessage(GroupWebsocketMessageData message) async {
    final url = Uri.parse('${httpUrl}websocket_messages');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': message.id,
        'group_chat_room_id': message.groupChatRoomId,
        'user_id': message.userId,
        'message_type': message.messageType,
        'sent_at': message.sentAt.toIso8601String(),
        'content': message.content,
        'image_name': message.imageName,
        'image_url': message.imageURL,
        'file_name': message.fileName,
        'file_url': message.fileURL,
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

  Future<bool> _getFileFromGallery() async {
    DateTime sentAt = DateTime.now();
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
      var uri = Uri.parse('${httpUrl}group_messages/${widget.groupChatRoomData.id}');

      final request = http.MultipartRequest('POST', uri);

      Map<String, String> headers = {"Content-type": "multipart/form-data"};

      final filePost = http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name);
      request.files.add(filePost);
      request.headers.addAll(headers);

      request.fields.addAll({
        'user_id': widget.myData.id,
        'message_type': 'file',
        'sent_at': sentAt.toIso8601String(),
        'content': ' ',
      });

      // リクエストを送信
      final stream = await request.send();
      final response = await http.Response.fromStream(stream);

      if (response.statusCode == 200) {
        _scrollToBottom();
        final responseData = jsonDecode(response.body); // レスポンスを JSON としてパース
        final GroupWebsocketMessageData fetchedMessage = GroupWebsocketMessageData.fromJson(responseData);

        final id = responseData['id'] as int;
        await _createUnreadMessages(id, sentAt);
        await _websocketMessage(fetchedMessage);
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
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isExpanded = _focusNode.hasFocus;
      });
    });
    _fetchInitialMessageHistory();
    _connectWebSocket();

    // スクロール位置のリスナーを設定
    _scrollController.addListener(_onScroll);
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

  void _onScroll() async {
    final scrollValue = _scrollController.offset / _scrollController.position.maxScrollExtent;
    if (scrollValue > _scrollValueThreshold) {
      await _fetchMoreMessageHistory();
    }
  }

  Future<void> _fetchInitialMessageHistory() async {
    if (_isLoading) return; // 読み込み中であれば処理を中断
    setState(() {
      _isLoading = true; // ローディング状態に設定
    });


    try {
      final response = await http.get(
        Uri.parse('${httpUrl}group_messages/${widget.groupChatRoomData.id}/?page=1'),
      );


      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> body = jsonDecode(responseBody);
        final List<GroupMessageData> fetchedMessages = body.map((message) => GroupMessageData.fromJson(message)).toList();


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
        Uri.parse('${httpUrl}group_messages/${widget.groupChatRoomData.id}/?page=$_page'),
      );


      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> body = jsonDecode(responseBody);
        final List<GroupMessageData> fetchedMessages =
        body.map((message) => GroupMessageData.fromJson(message)).toList();


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
      Uri.parse('${wsUrl}ws_group_message/${widget.groupChatRoomData.id}/${widget.myData.id}'),
    );
    _channel.stream.listen((message) async {
      final decodedMessage = json.decode(message);
      if (decodedMessage['type'] == 'broadcast') {
        final newMessage = GroupMessageData.fromJson(json.decode(decodedMessage['message']));
        if (newMessage.userId != widget.myData.id) {
          //Postリクエストを送信するエンドポイントのURL
          var uri = Uri.parse('${httpUrl}group_message_unread_update_websocket/${widget.groupChatRoomData.id}/${newMessage.id}/${widget.myData.id}');

          final response = await http.post(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'group_chat_room_id': widget.groupChatRoomData.id,
              'group_message_id': newMessage.id,
              'user_id': widget.myData.id,
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
            final int? id = update['group_message_id'];

            // IDがnullでない場合のみ処理
            if (id != null) {
              // 一致するメッセージを検索
              int index = _messages.indexWhere((msg) => msg.id == id);


              if (index != -1) {
                // 一致するメッセージのisReadを更新
                setState(() {
                  _messages[index].unreadCount--;
                });
                print('Message with ID $id updated to isRead: ${_messages[index].unreadCount}');
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
        // 対象メッセージを探し、isRead を更新
        final int index = _messages.indexWhere((msg) => msg.id == messageId);
        if (index != -1) {
          setState(() {
            _messages[index].unreadCount--;
          });
          print('Message ID $messageId updated to isRead: ${_messages[index].unreadCount}');
        } else {
          print('Message ID $messageId not found in the message list.');
        }

      }
    });
  }

  Future<void> _sendMessage() async {
    DateTime sentAt = DateTime.now();
    if (_messageController.text.isNotEmpty) {
      //Postリクエストを送信するエンドポイントのURL
      var uri = Uri.parse('${httpUrl}group_messages/${widget.groupChatRoomData.id}');


      final request = http.MultipartRequest('POST', uri);


      Map<String, String> headers = {"Content-type": "multipart/form-data"};


      final file = http.MultipartFile.fromBytes('file', [], filename: '');
      request.files.add(file);
      request.headers.addAll(headers);


      request.fields.addAll({
        'user_id': widget.myData.id,
        'message_type': 'text',
        'sent_at': sentAt.toIso8601String(),
        'content': _messageController.text,
      });

      final stream = await request.send();

      return await http.Response.fromStream(stream).then(
              (response) async {
            if (response.statusCode == 200) {
              _scrollToBottom();
              final responseData = jsonDecode(response.body); // レスポンスを JSON としてパース
              final GroupWebsocketMessageData fetchedMessage = GroupWebsocketMessageData.fromJson(responseData);

              final id = responseData['id'] as int;
              await _createUnreadMessages(id, sentAt);
              await _websocketMessage(fetchedMessage);
            }
            else {
              return Future.error(response);
            }
          });
    }
  }

  Future<void> _createUnreadMessages(int messageId, DateTime update) async {
    final url = Uri.parse('${httpUrl}create_unread_messages');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'group_chat_room_id': widget.groupChatRoomData.id,
        'group_message_id': messageId,
        'user_id': widget.myData.id,
        'updated_at': update.toIso8601String(),
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
                    // 保存
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0.0,
        title: Text(widget.groupChatRoomData.name,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await getGroupChatUsers(widget.groupChatRoomData.id);
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) {
                      return GroupChatRoomInfo(groupChatRoomData: widget.groupChatRoomData, groupChatUsers: groupChatUsers, myData: widget.myData);
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
                      final userData = widget.groupUsers.firstWhere((user) => user.id == _messages[index].userId);
                      return GroupMessageListItem(
                        message: _messages[index],
                        isMyMessage: _messages[index].userId == widget.myData.id,
                        myData: widget.myData,
                        userData: userData,
                        groupMemberLength: widget.groupUsers.length - 1,
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
                      setState(() {
                        _messageController.clear();
                      });
                    },
                    icon: const Icon(Icons.send,color: Colors.blue),
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


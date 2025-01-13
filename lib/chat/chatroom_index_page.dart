import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labmaidfastapi/chat/group/delete_group_chat_room_page.dart';
import 'package:labmaidfastapi/chat/group/group_chat_page.dart';
import 'package:labmaidfastapi/chat/private/private_chat_page.dart';
import '../domain/chat_data.dart';
import '../domain/user_data.dart';
import '../door_status/door_status_appbar.dart';
import '../header_footer_drawer/drawer.dart';
import '../network/url.dart';
import 'group/create_group_chat_room_page.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class ChatRoomListPage extends StatefulWidget {
  const ChatRoomListPage({Key? key}) : super(key: key);

  @override
  State<ChatRoomListPage> createState() => _ChatRoomListPage();
}

class _ChatRoomListPage extends State<ChatRoomListPage> {
  List<GetGroupChatRoomData> groupChatRoomList = [];
  List<UserPrivateChatData> userData = [];
  List<GroupChatUserData> groupChatUsers = [];
  List<GroupChatRoomData> groupChatData = [];
  List<GroupChatRoomData> notGroupChatData = [];
  late int privateChatroomId;
  UserData? myData;
  GroupChatUserData? groupMyData;

  late WebSocketChannel _channel;

  @override
  void initState() {
    fetchChatRoomList();
    _connectWebSocket();
    _connectGroupWebSocket();
    super.initState();
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  Future<void> getGroupChatRoomList() async {
    var uri = Uri.parse('${httpUrl}get_group_chat_rooms');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);
      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      // 必要なデータを取得
      if (mounted) {
        setState(() {
          groupChatRoomList = body.map((dynamic json) => GetGroupChatRoomData.fromJson(json)).toList();
        });
      }

    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }
  }

  Future<void> fetchChatRoomList() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    // MyUser情報を取得
    var uri = Uri.parse('${httpUrl}users/${currentUser!.uid}');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      var responseData = jsonDecode(responseBody);

      // 必要なデータを取得
      if (mounted) {
        setState(() {
          myData = UserData.fromJson(responseData);
        });
      }

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }

    // 個人チャットのユーザを取得する
    var url = Uri.parse('${httpUrl}chat_users/${currentUser.uid}');

    // GETリクエストを送信
    var responseGet = await http.get(url);

    // レスポンスのステータスコードを確認
    if (responseGet.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(responseGet.bodyBytes);

      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      // 必要なデータを取得
      if (mounted) {
        setState(() {
          userData = body.map((dynamic json) => UserPrivateChatData.fromJson(json)).toList();
        });
      }

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${responseGet.statusCode}');
    }

    if (myData != null) {
      // 参加中のグループチャットの一覧を取得
      var uriEntryGroup = Uri.parse('${httpUrl}get_entry_group_chat_room/${myData!.id}');
      // GETリクエストを送信
      var responseEntryGroup = await http.get(uriEntryGroup);

      // レスポンスのステータスコードを確認
      if (responseEntryGroup.statusCode == 200) {
        // レスポンスボディをUTF-8でデコード
        var responseBody = utf8.decode(responseEntryGroup.bodyBytes);

        // JSONデータをデコード
        final List<dynamic> body = jsonDecode(responseBody);

        //　必要なデータを取得
        if (mounted) {
          setState(() {
            groupChatData = body.map((dynamic json) => GroupChatRoomData.fromJson(json)).toList();
          });
        }

      } else {
        // リクエストが失敗した場合の処理
        print('リクエストが失敗しました: ${responseEntryGroup.statusCode}');
      }

      // 参加していないグループチャット一覧を取得する
      var uriNotEntryGroup = Uri.parse('${httpUrl}get_not_entry_group_chat_room/${myData!.id}');
      // GETリクエストを送信
      var responseNotEntryGroup = await http.get(uriNotEntryGroup);

      // レスポンスのステータスコードを確認
      if (responseNotEntryGroup.statusCode == 200) {
        // レスポンスボディをUTF-8でデコード
        var responseBody = utf8.decode(responseNotEntryGroup.bodyBytes);
        // JSONデータをデコード
        final List<dynamic> body = jsonDecode(responseBody);

        // 必要なデータを取得
        if (mounted) {
          setState(() {
            notGroupChatData = body.map((dynamic json) => GroupChatRoomData.fromJson(json)).toList();
          });
        }

      } else {
        // リクエストが失敗した場合の処理
        print('リクエストが失敗しました: ${responseNotEntryGroup.statusCode}');
      }
    }

  }

  void _connectWebSocket() {
    final currentUser = FirebaseAuth.instance.currentUser;
    _channel = WebSocketChannel.connect(
      Uri.parse('${wsUrl}ws_private_userlist/${currentUser!.uid}'),
    );
    _channel.stream.listen((message) async {
      if (!mounted) return;
      final decodedMessage = json.decode(message);
      if (decodedMessage['type'] == 'broadcast') {
        final messageData = decodedMessage['message'];
        final String userId = messageData['user_id'];
        final DateTime updatedAt = DateTime.parse(messageData['updated_at'] as String);
        // 対象メッセージを探し、isRead を更新
        final int index = userData.indexWhere((user) => user.id == userId);
        if (index != -1) {
          final user = userData[index];
          user.updatedAt = updatedAt;
          user.unreadCount ++;
          setState(() {
            userData.removeAt(index);
            userData.insert(0, user);
          });
          print('成功');
        } else {
          print('失敗');
        }
      }
    });
  }

  void _connectGroupWebSocket() {
    final currentUser = FirebaseAuth.instance.currentUser;
    _channel = WebSocketChannel.connect(
      Uri.parse('${wsUrl}ws_group_chat_list/${currentUser!.uid}'),
    );
    _channel.stream.listen((message) async {
      if (!mounted) return;
      final decodedMessage = json.decode(message);
      if (decodedMessage['type'] == 'broadcast') {
        final messageData = decodedMessage['message'];
        final int groupChatRoomId = messageData['group_chat_room_id'];
        final DateTime updatedAt = DateTime.parse(messageData['updated_at'] as String);
        // 対象メッセージを探し、isRead を更新
        final int index = groupChatData.indexWhere((group) => group.id == groupChatRoomId);
        if (index != -1) {
          final group = groupChatData[index];
          group.updatedAt = updatedAt;
          group.unreadCount ++;
          setState(() {
            groupChatData.removeAt(index);
            groupChatData.insert(0, group);
          });
          print('成功');
        } else {
          print('失敗');
        }
      }
    });
  }

  Future<void> getGroupChatUserMyData(int groupChatRoomId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    // MyUser情報を取得
    var uri = Uri.parse('${httpUrl}get_group_chat_room_user/$groupChatRoomId/${currentUser!.uid}');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      var responseData = jsonDecode(responseBody);

      // 必要なデータを取得
      if (mounted) {
        setState(() {
          groupMyData = GroupChatUserData.fromJson(responseData);
        });
      }

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    //グループチャット削除ページへ遷移
                    await getGroupChatRoomList();
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) {
                            return GroupChatRoomDeletePage(groupChatRoomList: groupChatRoomList);
                          }
                      ),
                    );
                  }
              ),
            ),
          ],
          backgroundColor: Colors.orange,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          centerTitle: false,
          elevation: 0.0,
          title: const DoorStatusAppbar(),
          bottom: const TabBar(
            tabs: <Tab>[
              Tab(text: '個人',),
              Tab(text: '参加中',),
              Tab(text: '未参加',),
            ],
          ),
        ),
        drawer: const UserDrawer(),
        body: TabBarView(
          children: [
            userData.isNotEmpty ? Scrollbar(
              child: ListView.builder(
                itemCount: userData.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return GestureDetector(
                    onTap: () async {
                      //個人チャットルーム遷移
                      await createOrGetPrivateChatRoom(userData[index].id);
                      await updateUnreadPrivateMessage(privateChatroomId, userData[index].id);
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) {
                              return PrivateChatPage(
                                  privateChatroomId: privateChatroomId,
                                  userData: UserData(
                                      id: userData[index].id,
                                      email: userData[index].email,
                                      group: userData[index].group,
                                      grade: userData[index].grade,
                                      name: userData[index].name,
                                      status: userData[index].status,
                                      imageURL: userData[index].imageURL,
                                      imageName: userData[index].imageName,
                                      location: userData[index].location,
                                      flag: userData[index].flag
                                  ),
                                  myData: myData!,
                              );
                            }
                        ),
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 50,
                          backgroundImage: userData[index].imageURL != '' ? Image.network(
                            userData[index].imageURL,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) {
                              return const Icon(
                                Icons.error,
                                color: Colors.red,
                              );
                            },
                          ).image
                              : const AssetImage('assets/images/default.png'),
                        ),
                        title: Text(userData[index].name),
                        subtitle: userData[index].group == 'Network班' ?
                        Text('Net班　${userData[index].grade}　${userData[index].status}')
                        : Text('${userData[index].group}　${userData[index].grade}　${userData[index].status}'),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            userData[index].updatedAt != null
                                ? Builder(
                              builder: (context) {
                                DateTime updated = userData[index].updatedAt!;
                                DateTime now = DateTime.now();

                                // 日付を比較するために、時刻情報を削除
                                DateTime updatedDate = DateTime(updated.year, updated.month, updated.day);
                                DateTime nowDate = DateTime(now.year, now.month, now.day);

                                String timeText;
                                int dayDifference = nowDate.difference(updatedDate).inDays;

                                if (dayDifference == 0) {
                                  // 今日
                                  timeText = DateFormat.Hm('ja').format(updated);
                                } else if (dayDifference == 1) {
                                  // 昨日
                                  timeText = '昨日';
                                } else if (dayDifference == 2) {
                                  // 一昨日
                                  timeText = '一昨日';
                                } else if (dayDifference <= 6) {
                                  // 1週間以内
                                  timeText = '${DateFormat.E('ja').format(updated)}曜日';
                                } else {
                                  // それ以前
                                  timeText = DateFormat.yMd('ja').format(updated);
                                }

                                return Text(
                                  timeText,
                                  style: TextStyle(color: Colors.grey[600]),
                                );
                              },
                            )
                                : Text('チャットなし', style: TextStyle(color: Colors.grey[600])),
                            if (userData[index].unreadCount > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${userData[index].unreadCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      ),
                    ),
                  );
                },
              ),
            )
            : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
            groupChatData.isNotEmpty ? Scrollbar(
              child: ListView.builder(
                itemCount: groupChatData.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return GestureDetector(
                    onTap: () async {
                      //グループチャットルーム遷移
                      await getGroupChatUsers(groupChatData[index].id);
                      await getGroupChatUserMyData(groupChatData[index].id);
                      await updateUnreadGroupMessage(groupChatData[index].id, myData!.id);
                      if (groupMyData != null) {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) {
                                return GroupChatPage(groupChatRoomData: groupChatData[index], myData: groupMyData!, groupUsers: groupChatUsers);
                              }
                          ),
                        );
                      }

                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 50,
                          backgroundImage: groupChatData[index].imageURL != '' ? Image.network(
                            groupChatData[index].imageURL,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) {
                              return const Icon(
                                Icons.error,
                                color: Colors.red,
                              );
                            },
                          ).image
                              : const AssetImage('assets/images/group_default.jpg'),
                        ),
                        title: Text(groupChatData[index].name),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Builder(
                              builder: (context) {
                                DateTime updated = groupChatData[index].updatedAt;
                                DateTime now = DateTime.now();

                                // 日付を比較するために、時刻情報を削除
                                DateTime updatedDate = DateTime(updated.year, updated.month, updated.day);
                                DateTime nowDate = DateTime(now.year, now.month, now.day);

                                String timeText;
                                int dayDifference = nowDate.difference(updatedDate).inDays;

                                if (dayDifference == 0) {
                                  // 今日
                                  timeText = DateFormat.Hm('ja').format(updated);
                                } else if (dayDifference == 1) {
                                  // 昨日
                                  timeText = '昨日';
                                } else if (dayDifference == 2) {
                                  // 一昨日
                                  timeText = '一昨日';
                                } else if (dayDifference <= 6) {
                                  // 1週間以内
                                  timeText = '${DateFormat.E('ja').format(updated)}曜日';
                                } else {
                                  // それ以前
                                  timeText = DateFormat.yMd('ja').format(updated);
                                }

                                return Text(
                                  timeText,
                                  style: TextStyle(color: Colors.grey[600]),
                                );
                              },
                            ),
                            if (groupChatData[index].unreadCount > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${groupChatData[index].unreadCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
            : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
            notGroupChatData.isNotEmpty ? Scrollbar(
              child: ListView.builder(
                itemCount: notGroupChatData.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return GestureDetector(
                    onTap: () async {
                      //グループチャットルーム遷移

                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 50,
                          backgroundImage: notGroupChatData[index].imageURL != '' ? Image.network(
                            notGroupChatData[index].imageURL,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) {
                              return const Icon(
                                Icons.error,
                                color: Colors.red,
                              );
                            },
                          ).image
                              : const AssetImage('assets/images/group_default.jpg'),
                        ),
                        title: Text(notGroupChatData[index].name),

                      ),
                    ),
                  );
                },
              ),
            )
            : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            //ルーム追加
            await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) {
                    return const AddRoomPage();
                  }),
            );
          },
        ),
      ),
    );
  }

  Future createOrGetPrivateChatRoom(String userId) async {
    var uri = Uri.parse('${httpUrl}private_chat_room/${myData!.id}/$userId');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      var responseData = jsonDecode(responseBody);

      // 必要なデータを取得

      privateChatroomId = responseData['id'];

      print(privateChatroomId);

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }
  }

  Future updateUnreadPrivateMessage(int roomId, String userId) async {
    var url = Uri.parse('${httpUrl}private_message_unread_update/$roomId/$userId');

    // 送信するデータを作成
    Map<String, dynamic> data = {
      'private_chat_room_id': roomId,
      'user_id': userId,
      // 他のキーと値を追加
    };

    // リクエストヘッダーを設定
    Map<String, String> headers = {
      'Content-Type': 'application/json', // JSON形式のデータを送信する場合
      // 他のヘッダーを必要に応じて追加
    };

    try {
      // HTTP POSTリクエストを送信
      final request = await http.patch(
        url,
        headers: headers,
        body: json.encode(data), // データをJSON形式にエンコード
      );

      // レスポンスをログに出力（デバッグ用）
      print('Response status: ${request.statusCode}');
      print('Response body: ${request.body}');

    } catch (e) {
      // エラーハンドリング
      print('Error: $e');
    }
  }

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

  Future updateUnreadGroupMessage(int roomId, String userId) async {
    var url = Uri.parse('${httpUrl}group_message_unread_update/$roomId/$userId');

    // 送信するデータを作成
    Map<String, dynamic> data = {
      'group_chat_room_id': roomId,
      'user_id': userId,
      // 他のキーと値を追加
    };

    // リクエストヘッダーを設定
    Map<String, String> headers = {
      'Content-Type': 'application/json', // JSON形式のデータを送信する場合
      // 他のヘッダーを必要に応じて追加
    };

    try {
      // HTTP POSTリクエストを送信
      final request = await http.patch(
        url,
        headers: headers,
        body: json.encode(data), // データをJSON形式にエンコード
      );

      // レスポンスをログに出力（デバッグ用）
      print('Response status: ${request.statusCode}');
      print('Response body: ${request.body}');

    } catch (e) {
      // エラーハンドリング
      print('Error: $e');
    }
  }


}



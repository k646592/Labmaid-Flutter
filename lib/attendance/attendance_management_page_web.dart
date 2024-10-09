import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import '../domain/user_data.dart';

class AttendanceManagementPageWeb extends StatefulWidget {
  const AttendanceManagementPageWeb({Key? key}) : super(key: key);

  @override
  State<AttendanceManagementPageWeb> createState() => _AttendanceManagementPageWeb();
}

class _AttendanceManagementPageWeb extends State<AttendanceManagementPageWeb> {
  late WebSocketChannel _channel;
  final user = FirebaseAuth.instance.currentUser;

  List<UserAttendanceData> users = [];

  late String firebaseUserId;
  late int userId;

  @override
  void initState() {
    firebaseUserId = user!.uid;
    _fetchAttendanceUserList();
    _fetchMyUserData();
    _connectWebSocket();
    super.initState();
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  Future<void> _fetchAttendanceUserList() async {
    var uri = Uri.parse('http://sui.al.kansai-u.ac.jp/api/users_attendance');

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
          users = body.map((dynamic json) => UserAttendanceData.fromJson(json)).toList();
        });
      }

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }
  }

  Future<void> _fetchMyUserData() async {
    var uriUser = Uri.parse('http://sui.al.kansai-u.ac.jp/api/user_id/$firebaseUserId');
    var responseUser = await http.get(uriUser);

    // レスポンスのステータスコードを確認
    if (responseUser.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(responseUser.bodyBytes);

      // JSONデータをデコード
      var responseData = jsonDecode(responseBody);

      // 必要なデータを取得
      if (mounted) {
        setState(() {
          userId = responseData['id'];
        });
      }

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${responseUser.statusCode}');
    }
  }

  Future attendanceUpdate(String updateStatus) async {
    var uri = Uri.parse('http://sui.al.kansai-u.ac.jp/api/update_user_status/$userId');

    // 送信するデータを作成
    Map<String, dynamic> data = {
      'status': updateStatus,
      // 他のキーと値を追加
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

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://sui.al.kansai-u.ac.jp/api/ws_user_status'),
    );
    _channel.stream.listen((message) {
      final Map<String, dynamic> data = jsonDecode(message);
      final int id = data['user_id'];
      final String status = data['status'];
      for(int i=0; i<users.length; i++) {
        if(users[i].id == id) {
          setState(() {
            users[i].status = status;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(4.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await attendanceUpdate('出席');
                        const snackBar = SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(
                            "出席しました",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        );
                        //model.fetchAttendanceList();状態の更新 websocketで更新する
                        ScaffoldMessenger.of(context).
                        showSnackBar(snackBar);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green[400],
                      ),
                      child: const FittedBox(
                        child: Text(
                          '出席',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await attendanceUpdate('一時退席');
                        const snackBar = SnackBar(
                          backgroundColor: Colors.yellow,
                          content: Text(
                            "一時退席しました",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        );
                        //model.fetchAttendanceList();
                        ScaffoldMessenger.of(context).
                        showSnackBar(snackBar);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.yellow,
                      ),
                      child: const FittedBox(
                        child: Text(
                          '一時退席',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await attendanceUpdate('帰宅');
                        const snackBar = SnackBar(
                          backgroundColor: Colors.grey,
                          content: Text(
                            "帰宅しました",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        );
                        //model.fetchAttendanceList();
                        ScaffoldMessenger.of(context).
                        showSnackBar(snackBar);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.grey,
                      ),
                      child: const FittedBox(
                        child: Text(
                          '帰宅',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(4.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await attendanceUpdate('欠席');
                        const snackBar = SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            "欠席しました",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        );
                        //model.fetchAttendanceList();
                        ScaffoldMessenger.of(context).
                        showSnackBar(snackBar);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.red,
                      ),
                      child: const FittedBox(
                        child: Text(
                          '欠席',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await attendanceUpdate('未出席');
                        const snackBar = SnackBar(
                          backgroundColor: Colors.blue,
                          content: Text(
                            "未出席になりました",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        );
                        //model.fetchAttendanceList();
                        ScaffoldMessenger.of(context).
                        showSnackBar(snackBar);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.blue,
                      ),
                      child: const FittedBox(
                        child: Text(
                          '未出席',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await attendanceUpdate('授業中');
                        const snackBar = SnackBar(
                          backgroundColor: Colors.purple,
                          content: Text(
                            "授業中になりました",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        );
                        //model.fetchAttendanceList();
                        ScaffoldMessenger.of(context).
                        showSnackBar(snackBar);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.purple,
                      ),
                      child: const FittedBox(
                        child: Text(
                          '授業中',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2.0),
                  child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black45,
                            ),
                          ),
                          child: const Text('Net班'),  //グループ名
                        ),
                        SizedBox(
                          child: Column(
                            children: groupAttendanceUser(users, 'Network班'),
                          ),
                        ),
                      ]
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2.0),
                  child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black45,
                            ),
                          ),
                          child: const Text('Grid班'),  //グループ名
                        ),
                        SizedBox(
                          child: Column(
                            children: groupAttendanceUser(users, 'Grid班'),
                          ),
                        ),
                      ]
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2.0),
                  child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black45,
                            ),
                          ),
                          child: const Text('Web班'),  //グループ名
                        ),
                        SizedBox(
                          child: Column(
                            children: groupAttendanceUser(users, 'Web班'),
                          ),
                        ),
                      ]
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2.0),
                  child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black45,
                            ),
                          ),
                          child: const Text('教員'),  //グループ名
                        ),
                        SizedBox(
                          child: Column(
                            children: groupAttendanceUser(users, '教員'),
                          ),
                        ),
                      ]
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  List<Widget> groupAttendanceUser(List<UserAttendanceData> users, String group) {
    List<Widget> index = users
        .where((user) => user.group.contains(group))  // フィルタリング
        .map(
          (user) => Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _attendanceColor(user.status),
              border: Border.all(
                color: Colors.black45,
              ),
            ),
            child: FittedBox(child: Text(user.name)),
          ),
    ).toList();
    return index;
  }

  Color _attendanceColor(String text){
    if (text == '一時退席'){
      return Colors.yellow;
    }
    else if (text == '出席'){
      return Colors.green;
    }
    else if(text == '欠席'){
      return Colors.red;
    }
    else if(text == '帰宅'){
      return Colors.grey;
    } else if (text == '授業中') {
      return Colors.purple;
    } else {
      return Colors.blue;
    }
  }

}


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../network/url.dart';

class SendReportPage extends StatefulWidget {
  const SendReportPage({Key? key}) : super(key: key);

  @override
  State<SendReportPage> createState() => _SendReportPage();
}

class _SendReportPage extends State<SendReportPage> {
  late TextEditingController _contentController;
  final user = FirebaseAuth.instance.currentUser;

  late String firebaseUserId;

  String? _recipientId; // 選択した受信者のID
  List<Map<String, String>> _users = []; // ユーザーリスト: {name, id, status}
  final int _maxLength = 1000;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();

    firebaseUserId = user!.uid;

    // ユーザーリストを取得
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final url = Uri.parse('${httpUrl}users');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(responseBody);

      setState(() {
        _users = data
            .where((user) =>
        user['grade'] == 'M1' ||
            user['grade'] == 'M2' ||
            user['grade'] == 'D1' ||
            user['grade'] == 'D2' ||
            user['grade'] == 'D3' ||
            user['grade'] == '教授')
            .map<Map<String, String>>((user) {
          return {
            'name': user['name'] as String,
            'id': user['id'] as String,
            'status': user['status'] as String,
          };
        }).toList();

        if (_users.isNotEmpty) {
          _recipientId = _users.first['id'];
        }
      });
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '出席':
        return Colors.green;
      case '欠席':
        return Colors.red;
      case '未出席':
        return Colors.blue;
      case '一時退席':
        return Colors.yellow;
      case '授業中':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.98,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                maxLength: _maxLength,
                controller: _contentController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: "研究進捗を入力してください",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: _recipientId,
                  items: _users.map<DropdownMenuItem<String>>((user) {
                    return DropdownMenuItem<String>(
                      value: user['id'],
                      child: Text(
                        user['name']!,
                        style: TextStyle(
                          color: _getStatusColor(user['status']!),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _recipientId = newValue!;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_contentController.text.length > _maxLength) {
                      const snackBar = SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('研究進捗は1000文字以内で入力してください。'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      return;
                    }

                    try {
                      await sendReport(
                        _contentController.text,
                        _recipientId!,
                        firebaseUserId,
                      );

                      _contentController.clear();

                      const snackBar = SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('研究報告を投稿しました。'),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "送信",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendReport(
      String content, String recipientId, String userId) async {
    if (content.isEmpty) {
      throw '内容が入力されていません。';
    }

    final now = DateTime.now();
    final url = Uri.parse('${httpUrl}reports');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        'created_at': now.toIso8601String(),
        'user_id': userId,
        'user_name': user!.displayName ?? 'Unknown', // 追加
        'recipient_user_id': recipientId,
        'recipient_user_name':
        _users.firstWhere((user) => user['id'] == recipientId)['name'] ??
            'Unknown', // 追加
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['detail'] ?? 'Unknown error';
      throw 'Request failed with status: ${response.statusCode}, error: $error';
    }

    final responseData = jsonDecode(response.body);
    print('Response data: $responseData');
  }
}
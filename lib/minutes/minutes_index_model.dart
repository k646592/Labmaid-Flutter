import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:labmaidfastapi/domain/memo_data.dart';

import 'package:labmaidfastapi/domain/user_data.dart';
import '../network/url.dart';


class MemoListModel extends ChangeNotifier {

  List<MemoData> memoList = [];
  UserData? myData;

  void fetchMemoList() async {

    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser!.uid;

    var uri = Uri.parse('${httpUrl}users/$uid');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      var responseData = jsonDecode(responseBody);

      // 必要なデータを取得
      myData = UserData.fromJson(responseData);
      
      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }

    notifyListeners();
  }

  Future<void> memoGetList(String team, String kinds) async {
    memoList.clear();

    var uri = Uri.parse('${httpUrl}meetings?team=$team&kinds=$kinds');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      memoList.addAll(body.map((dynamic json) => MemoData.fromJson(json)).toList());

    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');

    }
  }
}
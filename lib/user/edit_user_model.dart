import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditMyPageModel extends ChangeNotifier {
  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  void fetchUser() async {


    notifyListeners();
  }

  //ユーザ情報更新
  Future update(String name, String group, String grade, int id) async {

    if(name == ''){
      throw '名前が入力されていません。';
    }
    if(group == ''){
      throw 'グループが選択されていません。';
    }
    if(grade == ''){
      throw '学年が選択されていません。';
    }

    var uri = Uri.parse('http://localhost:8000/users/$id');

    // 送信するデータを作成
    Map<String, dynamic> data = {
      'name': name,
      'group': group,
      'grade': grade,
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

    notifyListeners();
  }

  Future updateImage(Uint8List? userImage, int id) async {

    var uri = Uri.parse('http://localhost:8000/users/image/$id');
    final request = http.MultipartRequest('PATCH', uri);
    Map<String, String> headers = {"Content-type": "multipart/form-data"};
    final file = http.MultipartFile.fromBytes('file', userImage!, filename: 'update.png');
    request.files.add(file);
    request.headers.addAll(headers);
    final stream = await request.send();

    return await http.Response.fromStream(stream).then(
            (response) {
          if (response.statusCode == 200) {
            return response;
          }
          return Future.error(response);
        });

  }

}
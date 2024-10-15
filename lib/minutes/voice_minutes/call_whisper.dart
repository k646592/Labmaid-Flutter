import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'apikey_openai.dart';

//変更点
//音声ファイルのパスを渡して、Whisperに文字起こしを行わせる関数
//返り値は文字起こしされたテキスト

Future<String> convertSpeechToText(String filePath) async {
  const apiKey = openaiApiKey;
  var url = Uri.https("api.openai.com", "v1/audio/transcriptions");
  var request = http.MultipartRequest('POST', url);
  request.headers.addAll(({"Authorization": "Bearer $apiKey"}));
  request.fields["model"] = 'whisper-1';
  request.fields["language"] = "ja";
  request.files.add(await http.MultipartFile.fromPath('file', filePath));
  var response = await request.send();
  var newResponse = await http.Response.fromStream(response);
  final responseData = jsonDecode(utf8.decode(newResponse.body.codeUnits));

  if (response.statusCode == 200) {
    return responseData['text'];
  } else if (response.statusCode == 413) {
    debugPrint('Payload Too Large error: Whisperにおいてリクエストが大きすぎる');
    return 'whisperで音声ファイルが大きすぎるため、文字起こしされませんでした';
  } else {
    debugPrint('error: Whisperにおいて謎のエラーが起きました');
    return 'whisperで謎のエラーが起き、文字起こしされませんでした';
  }
}
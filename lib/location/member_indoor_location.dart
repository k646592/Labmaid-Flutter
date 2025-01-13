import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:labmaidfastapi/domain/seat_data.dart';
import 'package:labmaidfastapi/header_footer_drawer/drawer.dart';


import '../door_status/door_status_appbar.dart';
import '../gemini/gemini_chat_page.dart';
import '../geo_location/location_member_index.dart';
import '../network/url.dart';
import 'package:http/http.dart' as http;

//作成した研究室の地図UIです

class MemberLocation extends StatefulWidget {


  const MemberLocation({super.key, });

  @override
  _MemberLocationState createState() => _MemberLocationState();
}

class _MemberLocationState extends State<MemberLocation> {
  late Timer _timer;
  List<SeatData> seats = [];

  @override
  void initState() {
    _startFetching();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startFetching() {
    // 5分（300秒）ごとにデータを取得
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _fetchSeat();
    });

    // 初回のデータ取得を即座に実行
    _fetchSeat();
  }

  Future<void> _fetchSeat() async {
    var uri = Uri.parse('${httpUrl}seats');

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
          seats = body.map((dynamic json) => SeatData.fromJson(json)).toList();
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
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.teal,
        centerTitle: false,
        elevation: 0.0,
        title: const DoorStatusAppbar(),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GeoLocationIndexPage()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              icon: const Icon(Icons.psychology_alt),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GeminiChatPage()),
                );
              },
            ),
          ),
        ],
      ),
      drawer: const UserDrawer(),
      body: Center(
        child: AspectRatio(
          aspectRatio: 15 / 9, // 画像のアスペクト比を設定
          child: LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth;
              double height = constraints.maxHeight;
              return Container(
                color: Colors.black12,
                child: Stack(
                  children: [
                    // テレビ
                    Positioned(
                      left: width * 0.13,
                      top: height * 0,
                      child: Container(
                        width: width * 0.15,
                        height: height * 0.05,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Center(child: FittedBox(child: Text('プロジェクター'))),
                      ),
                    ),
                    // 流し
                    Positioned(
                      left: width * 0,
                      top: height * 0.15,
                      child: Container(
                        width: width * 0.05,
                        height: height * 0.15,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Center(child: Text('流し')),
                      ),
                    ),
                    // 棚
                    Positioned(
                      left: width * 0,
                      top: height * 0.3,
                      child: Container(
                        width: width * 0.05,
                        height: height * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Center(child: Text('棚')),
                      ),
                    ),
                    // 冷蔵庫
                    Positioned(
                      left: width * 0,
                      top: height * 0.4,
                      child: Container(
                        width: width * 0.05,
                        height: height * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Center(child: Text('冷蔵庫')),
                      ),
                    ),
                    // プリンター
                    Positioned(
                      left: width * 0,
                      top: height * 0.5,
                      child: Container(
                        width: width * 0.05,
                        height: height * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Center(child: Text('プリンター')),
                      ),
                    ),
                    Positioned(
                      left: width * 0,
                      top: height * 0.6,
                      child: Container(
                        width: width * 0.05,
                        height: height * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Center(child: Text('プリンター')),
                      ),
                    ),
                    // 長机
                    Positioned(
                      left: width * 0.13,
                      top: height * 0.15,
                      child: Container(
                        width: width * 0.15,
                        height: height * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: const BorderRadius.all(
                            Radius.elliptical(100, 200),
                          ),
                        ),
                        child: const Center(child: Text('長机')),
                      ),
                    ),
                    // 本棚
                    Positioned(
                      left: width * 0.45,
                      top: height * 0,
                      child: Container(
                        width: width * 0.55,
                        height: height * 0.07,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Center(child: Text('本棚')),
                      ),
                    ),
                    // 機材置場
                    Positioned(
                      left: width * 0.35,
                      top: height * 0.9,
                      child: Container(
                        width: width * 0.05,
                        height: height * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Center(child: Text('プリンター')),
                      ),
                    ),
                    Positioned(
                      left: width * 0.4,
                      top: height * 0.9,
                      child: Container(
                        width: width * 0.5,
                        height: height * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Center(child: Text('機材置場')),
                      ),
                    ),
                    // サーバー
                    Positioned(
                      left: width * 0.9,
                      top: height * 0.9,
                      child: Container(
                        width: width * 0.05,
                        height: height * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Center(child: Text('サーバー')),
                      ),
                    ),
                    //棚
                    Positioned(
                      left: width * 0.47,
                      top: height * 0.2,
                      child: Container(
                        width: width * 0.07,
                        height: height * 0.15,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: Text('棚')),
                      ),
                    ),

                    // 右上の座席群
                    // 座席番号18
                    Positioned(
                      left: width * 0.9,
                      top: height * 0.2,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(18),),
                      ),
                    ),
                    // 座席番号17
                    Positioned(
                      left: width * 0.8,
                      top: height * 0.2,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(17),),
                      ),
                    ),
                    // 座席番号14
                    Positioned(
                      left: width * 0.9,
                      top: height * 0.28,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(14),),
                      ),
                    ),
                    // 座席番号13
                    Positioned(
                      left: width * 0.8,
                      top: height * 0.28,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(13),),
                      ),
                    ),

                    //　右下の座席群
                    // 座席番号10
                    Positioned(
                      left: width * 0.9,
                      top: height * 0.55,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(10),),
                      ),
                    ),
                    // 座席番号5
                    Positioned(
                      left: width * 0.9,
                      top: height * 0.63,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(5),),
                      ),
                    ),
                    // 座席番号9
                    Positioned(
                      left: width * 0.8,
                      top: height * 0.55,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(9),),
                      ),
                    ),
                    // 座席番号4
                    Positioned(
                      left: width * 0.8,
                      top: height * 0.63,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(4),),
                      ),
                    ),

                    //左上の座席群
                    // 座席番号16
                    Positioned(
                      left: width * 0.64,
                      top: height * 0.2,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(16),),
                      ),
                    ),
                    // 座席番号15
                    Positioned(
                      left: width * 0.54,
                      top: height * 0.2,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(15),),
                      ),
                    ),
                    // 座席番号12
                    Positioned(
                      left: width * 0.64,
                      top: height * 0.28,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(12),),
                      ),
                    ),
                    // 座席番号11
                    Positioned(
                      left: width * 0.54,
                      top: height * 0.28,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(11),),
                      ),
                    ),

                    // 左下の座席群
                    // 座席番号8
                    Positioned(
                      left: width * 0.64,
                      top: height * 0.55,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(8),),
                      ),
                    ),
                    // 座席番号3
                    Positioned(
                      left: width * 0.64,
                      top: height * 0.63,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(3),),
                      ),
                    ),
                    // 座席番号7
                    Positioned(
                      left: width * 0.54,
                      top: height * 0.55,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(7),),
                      ),
                    ),
                    // 座席番号2
                    Positioned(
                      left: width * 0.54,
                      top: height * 0.63,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(2),),
                      ),
                    ),
                    // 座席番号1
                    Positioned(
                      left: width * 0.44,
                      top: height * 0.63,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(1),),
                      ),
                    ),
                    // 座席番号6
                    Positioned(
                      left: width * 0.44,
                      top: height * 0.55,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(child: seatDisplay(6),),
                      ),
                    ),



                    //使用していない机群
                    Positioned(
                      left: width * 0.34,
                      top: height * 0.63,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Center(child: Text('PC'),),
                      ),
                    ),
                    Positioned(
                      left: width * 0.34,
                      top: height * 0.55,
                      child: Container(
                        width: width * 0.1,
                        height: height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Center(child: Text('PC'),),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget seatDisplay(int number) {
    // `seats` リストの中から、`id` が `number` と一致する `SeatData` を探す
    final seat = seats.firstWhere((seat) => seat.id == number, orElse: () => SeatData(id: -1, status: 'Not Found'));

    // `status` を表示するウィジェットを返す
    return seat.status == 'empty' ?
    const Text('空', style: TextStyle(color: Colors.blue),)
        : seat.status == 'occupied'
        ? const Text('満', style: TextStyle(color: Colors.red),)
        : const Text('');
  }
}
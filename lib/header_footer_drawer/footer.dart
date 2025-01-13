import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:labmaidfastapi/chat/chatroom_index_page.dart';
import 'package:labmaidfastapi/location/member_indoor_location.dart';
import 'package:labmaidfastapi/minutes/minutes_index_page.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../attendance/attendance_page_responsive.dart';
import '../event/event_responsive_page.dart';
import '../network/url.dart';
import '../user/my_page.dart';

import 'package:http/http.dart' as http;

class Footer extends StatefulWidget {

  final int pageNumber;
  const Footer({super.key, required this.pageNumber});

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  late int _selectedIndex;
  final _bottomNavigationBarItems = <BottomNavigationBarItem>[];
  late WebSocketChannel _channel;

  // 未読メッセージ数
  int? _totalUnreadCount; // 初期値をnullに設定

  //アイコン情報
  static const _footerIcons = [
    Icons.calendar_month,
    Icons.groups,
    Icons.chat,
    Icons.edit_note,
    Icons.location_pin,
    Icons.account_circle,
  ];

  //アイコン文字列
  static const _footerItemNames = [
    'イベント',
    '出席管理',
    'チャット',
    '議事録',
    '位置情報',
    'マイページ',
  ];

  //アイコンや文字列のカラー
  final List<Color?> _footerItemColor = [
    Colors.purple[200],
    Colors.pink.shade200,
    Colors.orange,
    Colors.blue.shade800,
    Colors.teal,
    Colors.lightGreen.shade700,
  ];

  final _routes = [
    const EventPageTop(),
    const AttendancePageTop(),
    const ChatRoomListPage(),
    const MemoListPage(),
    const MemberLocation(),
    const MyPage(),
  ];

  Future<void> _fetchUnreadCount() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    int total = 0;

    if (currentUser == null) {
      print('No user is currently logged in.');
      return;
    }


    try {
      final response = await http.get(
        Uri.parse('${httpUrl}get_private_unread_count/${currentUser.uid}'),
      );

      if (response.statusCode == 200) {
        // レスポンスボディをデコード
        var responseBody = utf8.decode(response.bodyBytes);
        // 未読メッセージ数を整数に変換
        int unreadCount = int.parse(responseBody);
        total = total + unreadCount;

      } else {
        // エラーハンドリング
        print('Failed to load unread count: ${response.statusCode}');
      }
    } catch (e) {
      // 例外ハンドリング
      print('Error fetching unread count: $e');
    }
    try {
      final response = await http.get(
        Uri.parse('${httpUrl}get_group_unread_count/${currentUser.uid}'),
      );

      if (response.statusCode == 200) {
        // レスポンスボディをデコード
        var responseBody = utf8.decode(response.bodyBytes);
        // 未読メッセージ数を整数に変換
        int unreadCount = int.parse(responseBody);

        total = total + unreadCount;

        // UIを更新
        if (mounted) {
          setState(() {
            _totalUnreadCount = total;
          });
        }

      } else {
        // エラーハンドリング
        print('Failed to load unread count: ${response.statusCode}');
      }
    } catch (e) {
      // 例外ハンドリング
      print('Error fetching unread count: $e');
    }
  }

  void _connectWebSocket() {
    final currentUser = FirebaseAuth.instance.currentUser;
    _channel = WebSocketChannel.connect(
      Uri.parse('${wsUrl}ws_chat_list_unread_total/${currentUser!.uid}'),
    );

    _channel.stream.listen((message){
      if (!mounted) return;
      final decodedMessage = json.decode(message);
      if (decodedMessage['type'] == 'broadcast') {
        if (_totalUnreadCount != null) {
          int i = _totalUnreadCount!;
          i ++;
          if (mounted) {
            setState(() {
              _totalUnreadCount = i;
            });
          }
        }
      }

    });
  }

  @override
  void initState() {
    _fetchUnreadCount();
    _connectWebSocket();
    _selectedIndex = widget.pageNumber;
    super.initState();
    for ( var i =0; i < _footerItemNames.length; i++) {
      if(_selectedIndex != i) {
        _bottomNavigationBarItems.add(_UpdateDeactiveState(i));
      }
      else {
        _bottomNavigationBarItems.add(_UpdateActiveState(_selectedIndex));
      }
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  // バッジ付きのチャットアイコンを作成
  Widget _buildChatIcon(int index, String activate) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          _footerIcons[index],
          color: activate == 'activate' ? _footerItemColor[index] : Colors.black26,
          size: 30,
        ),
        if (_totalUnreadCount != null) // 値が取得された場合のみバッジを表示
          if (_totalUnreadCount! > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '${_totalUnreadCount!}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        if (_totalUnreadCount == null) // 値がnullの場合のプレースホルダー
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: const Text(
                '...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  // インデックスのアイテムをアクティベートする
  BottomNavigationBarItem _UpdateActiveState(int index) {
    return BottomNavigationBarItem(
      icon: index == 2 ?
      _buildChatIcon(2, 'activate')
          : Icon(
        _footerIcons[index],
        color: _footerItemColor[index],
      ),
      label: _footerItemNames[index],

    );
  }

  // インデックスのアイテムをディアクティベートする
  BottomNavigationBarItem _UpdateDeactiveState(int index) {
    return BottomNavigationBarItem(
      icon: index == 2 ?
          _buildChatIcon(2, 'deactivate')
          : Icon(
        _footerIcons[index],
        color: Colors.black26,
      ),
      label: _footerItemNames[index],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _bottomNavigationBarItems[_selectedIndex] = _UpdateDeactiveState(_selectedIndex);
      _bottomNavigationBarItems[index] = _UpdateActiveState(index);
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: _routes.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,  //これを書かないと３つまでしか表示されない
          items: _bottomNavigationBarItems,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
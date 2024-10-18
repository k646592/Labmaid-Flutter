import 'package:flutter/material.dart';
import 'package:labmaidfastapi/door_status/door_status_appbar.dart';
import 'package:labmaidfastapi/event/event_create_page.dart';
import '../attendance/attendance_management_page_web.dart';
import '../gemini/gemini_chat_page.dart';
import '../geo_location/location_member_index.dart';
import '../header_footer_drawer/drawer.dart';
import 'event_index_page_web.dart';

//変更点
//新規作成
//Web用のイベント管理ページのUI

class EventPageWeb extends StatelessWidget {
  const EventPageWeb({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple[200],
        centerTitle: false,
        title: const DoorStatusAppbar(),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber
        ,
        onPressed: () async {
          //画面遷移
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEventPage(),
              fullscreenDialog: true,
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: Row(
        children: [
          //Web用のカレンダーUI
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: const EventIndexPageWeb(),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 1.0,
              child: const Column(
                children: [
                  Expanded(child: AttendanceManagementPageWeb()),
                ],
              )
          ),
        ],
      ),
    );
  }
}
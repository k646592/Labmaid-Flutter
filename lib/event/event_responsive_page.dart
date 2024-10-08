import 'package:flutter/material.dart';

import '../widget/responsive_widget.dart';
import 'event_index_page.dart';
import 'event_page_web.dart';

//変更点
//新規作成
//イベント管理ページのレスポンシブ

class EventPageTop extends StatelessWidget {
  const EventPageTop({super.key});
  @override
  Widget build(BuildContext context) {
    return const ResponsiveWidget(
      //従来通りのUI
      mobileWidget: EventIndexPage(),
      //Web用のUI
      webWidget: EventPageWeb(),
    );
  }
}
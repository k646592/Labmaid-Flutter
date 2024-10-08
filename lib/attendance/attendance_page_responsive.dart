import 'package:flutter/material.dart';
import '../widget/responsive_widget.dart';
import 'attendance_home_page.dart';
import 'attendance_page_web.dart';

//変更点
//新規作成
//出席管理ページのレスポンシブ

class AttendancePageTop extends StatelessWidget {
  const AttendancePageTop({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const ResponsiveWidget(
      //従来通りのUI
      mobileWidget: AttendanceHomePage(),
      //Web用のUI
      webWidget: AttendancePageWeb(),
    );
  }
}
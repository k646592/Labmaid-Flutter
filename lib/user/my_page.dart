import 'package:flutter/material.dart';
import 'package:labmaidfastapi/geo_location/location_member_index.dart';
import 'package:labmaidfastapi/user/my_model.dart';
import 'package:provider/provider.dart';
import '../door_status/door_status_appbar.dart';
import '../gemini/gemini_chat_page.dart';
import '../report/board_report.dart';
import '../report/board_report_send.dart';
import '../header_footer_drawer/drawer.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true, // Material 3 を有効化
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.green), //イベントページのテーマカラーを設定（purple）
      ),
      child: ChangeNotifierProvider<MyModel>(
        create: (_) => MyModel()..fetchMyModel(),
        child: Scaffold(
          appBar: AppBar(
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
            backgroundColor: Colors.green[300],
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            centerTitle: false,
            elevation: 0.0,
            title: const DoorStatusAppbar(),
          ),
          drawer: const UserDrawer(),
          body: Consumer<MyModel>(builder: (context, model, child) {
            return model.myData != null
                ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FittedBox(
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 50,
                              backgroundImage: model.myData!.imageURL != ''
                                  ? Image.network(
                                model.myData!.imageURL,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) {
                                  return const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  );
                                },
                              ).image
                                  : const AssetImage(
                                  'assets/images/default.png'),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              child: Text(model.myData!.name
                                //'吉岡', // ダミーユーザ名
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            FittedBox(
                              child: Text(model.myData!.email
                                //'yoshioka782@outlook.jp', // ダミーEmail
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: 100,
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                    color: groupColor(model.myData!.group),
                                  ),
                                  child: Text(
                                    model.myData!.group,
                                    //'M1',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                    color: gradeColor(model.myData!.grade),
                                  ),
                                  child: Text(
                                    model.myData!.grade,
                                    //'Web',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                    color:
                                    statusColor(model.myData!.status),
                                  ),
                                  child: Text(
                                    model.myData!.status,
                                    //'出席',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                // B4 の場合はすべて表示、それ以外は担当学生の報告のみ表示
                if (model.myData!.grade == 'B4') ...[
                  Expanded(child: ReportPage()),
                  SendReportPage(),
                ] else ...[
                  Expanded(child: ReportPage()),
                ],
              ],
            )
                : const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.green),
              ),
            );
          }),
        ),
      ),
    );
  }

  Color groupColor(String group) {
    if (group == 'Web班') {
      return Colors.cyan;
    } else if (group == 'Network班') {
      return Colors.yellow;
    } else if (group == '教員') {
      return Colors.pinkAccent;
    } else {
      return Colors.greenAccent;
    }
  }

  Color gradeColor(String grade) {
    if (grade == 'B4') {
      return Colors.lightGreenAccent;
    } else if (grade == 'M1') {
      return Colors.purple;
    } else if (grade == 'M2') {
      return Colors.orange;
    } else if (grade == '教授') {
      return Colors.redAccent;
    } else {
      return Colors.teal;
    }
  }

  Color statusColor(String status) {
    if (status == '出席') {
      return Colors.green;
    } else if (status == '欠席') {
      return Colors.red;
    } else if (status == '未出席') {
      return Colors.blue;
    } else if (status == '帰宅') {
      return Colors.grey;
    } else if (status == '授業中') {
      return Colors.purple;
    } else {
      return Colors.yellow;
    }
  }
}
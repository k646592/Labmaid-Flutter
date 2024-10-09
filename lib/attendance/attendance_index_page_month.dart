import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../domain/attendance_data.dart';
import 'attendance_update_page.dart';

class AttendanceIndexPageMonth extends StatefulWidget {

  const AttendanceIndexPageMonth({Key? key}) : super(key: key);


  @override
  _AttendanceIndexPageMonthState createState() => _AttendanceIndexPageMonthState();
}


class _AttendanceIndexPageMonthState extends State<AttendanceIndexPageMonth> {
  final CalendarController _controllerMonth = CalendarController();
  late CalendarHeaderStyle _headerStyle;

  late WebSocketChannel _channel;

  List<AttendanceData> attendances = [];
  int? id;

  bool _isDisposed = false;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  DateTime today = DateTime.now();

  CalendarHeaderStyle headerStyle(DateTime date) {
    if(date.month == 1) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.blue,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 2) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.cyan,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 3) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.teal,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 4) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.green,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if(date.month == 5) {
      return CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.lightGreenAccent.shade700,
        textStyle: const TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if(date.month == 6) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.amber,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if(date.month == 7) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.orange,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 8) {
      return CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.deepOrange.shade600,
        textStyle: const TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 9) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.pinkAccent,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 10) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.purpleAccent,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 11) {
      return const CalendarHeaderStyle(
          textAlign: TextAlign.center,
          backgroundColor: Colors.purple,
          textStyle: TextStyle(
            fontSize: 25,
            fontStyle: FontStyle.normal,
            letterSpacing: 5,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          )
      );
    } else {
      return const CalendarHeaderStyle(
          textAlign: TextAlign.center,
          backgroundColor: Colors.indigo,
          textStyle: TextStyle(
            fontSize: 25,
            fontStyle: FontStyle.normal,
            letterSpacing: 5,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          )
      );
    }
  }

  void _goToToday() {
    _controllerMonth.displayDate = DateTime(today.year, today.month, 1,);
  }

  void _goToSelectedYearMonth(int year, int month) {
    _controllerMonth.displayDate = DateTime(year, month, 1);
  }

  @override
  void initState() {
    _controllerMonth.displayDate = DateTime(today.year, today.month, 1, 0,0,0,0,0);
    _headerStyle = headerStyle(DateTime.now());
    _fetchAttendance();
    _fetchMyUserData();
    _connectWebSocket();
    super.initState();
  }

  @override
  void dispose() {
    _isDisposed = true; // disposeが呼ばれたことを示すフラグを設定
    _channel.sink.close();
    super.dispose();
  }

  Future<void> _fetchAttendance() async {
    var uri = Uri.parse('http://sui.al.kansai-u.ac.jp/api/attendances');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      // 必要なデータを取得
      setState(() {
        attendances = body.map((dynamic json) => AttendanceData.fromJson(json)).toList();
      });

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }
  }

  Future<void> _fetchMyUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    var uriUser = Uri.parse('http://sui.al.kansai-u.ac.jp/api/user_id/$userId');
    var responseUser = await http.get(uriUser);

    // レスポンスのステータスコードを確認
    if (responseUser.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(responseUser.bodyBytes);

      // JSONデータをデコード
      var responseData = jsonDecode(responseBody);

      // 必要なデータを取得
      setState(() {
        id = responseData['id'];
      });

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${responseUser.statusCode}');
    }
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    SchedulerBinding.instance.addPersistentFrameCallback((duration) {
      if (!mounted) return; // ウィジェットがマウントされているか確認
      if (_isDisposed) return; // フラグをチェック
      var midDate = viewChangedDetails.visibleDates[viewChangedDetails.visibleDates.length ~/ 2];
      setState(() {
        _headerStyle = headerStyle(midDate);
      });
    });
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://sui.al.kansai-u.ac.jp/api/ws_attendance_list'),
    );
    _channel.stream.listen((message) {

      // JSONデータをデコード
      var messageData = jsonDecode(message);
      if (messageData['action'] == 'create') {
        final attendance = AttendanceData.fromJson(messageData);
        setState(() {
          attendances.add(attendance);
        });
      } else if (messageData['action'] == 'delete') {
        setState(() {
          attendances.removeWhere((attendance) => attendance.id == messageData['id']);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _goToToday();
                          },
                          child: const Text('今日'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: DropdownButton(
                            value: selectedYear,
                            items: const [
                              DropdownMenuItem(
                                value: 2020,
                                child: Text('2020年'),
                              ),
                              DropdownMenuItem(
                                value: 2021,
                                child: Text('2021年'),
                              ),
                              DropdownMenuItem(
                                value: 2022,
                                child: Text('2022年'),
                              ),
                              DropdownMenuItem(
                                value: 2023,
                                child: Text('2023年'),
                              ),
                              DropdownMenuItem(
                                value: 2024,
                                child: Text('2024年'),
                              ),
                              DropdownMenuItem(
                                value: 2025,
                                child: Text('2025年'),
                              ),
                              DropdownMenuItem(
                                value: 2026,
                                child: Text('2026年'),
                              ),
                              DropdownMenuItem(
                                value: 2027,
                                child: Text('2027年'),
                              ),
                              DropdownMenuItem(
                                value: 2028,
                                child: Text('2028年'),
                              ),
                              DropdownMenuItem(
                                value: 2029,
                                child: Text('2029年'),
                              ),
                              DropdownMenuItem(
                                value: 2030,
                                child: Text('2030年'),
                              ),
                            ],
                            onChanged: (text) {
                              setState(() {
                                selectedYear = text!;
                              });
                            }
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: DropdownButton(
                            value: selectedMonth,
                            items: const [
                              DropdownMenuItem(
                                value: 1,
                                child: Text('1月'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('2月'),
                              ),
                              DropdownMenuItem(
                                value: 3,
                                child: Text('3月'),
                              ),
                              DropdownMenuItem(
                                value: 4,
                                child: Text('4月'),
                              ),
                              DropdownMenuItem(
                                value: 5,
                                child: Text('5月'),
                              ),
                              DropdownMenuItem(
                                value: 6,
                                child: Text('6月'),
                              ),
                              DropdownMenuItem(
                                value: 7,
                                child: Text('7月'),
                              ),
                              DropdownMenuItem(
                                value: 8,
                                child: Text('8月'),
                              ),
                              DropdownMenuItem(
                                value: 9,
                                child: Text('9月'),
                              ),
                              DropdownMenuItem(
                                value: 10,
                                child: Text('10月'),
                              ),
                              DropdownMenuItem(
                                value: 11,
                                child: Text('11月'),
                              ),
                              DropdownMenuItem(
                                value: 12,
                                child: Text('12月'),
                              ),
                            ],
                            onChanged: (text) {
                              setState(() {
                                selectedMonth = text!;
                              });
                            }
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _goToSelectedYearMonth(selectedYear, selectedMonth);
                          },
                          child: const Text('移動'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 1800,
              child: SfCalendar(
                onLongPress: (CalendarLongPressDetails details) {

                },
                onTap: (CalendarTapDetails details) {

                },
                dataSource: AttendanceDataSource(attendances),
                view: CalendarView.month,
                controller: _controllerMonth,
                cellEndPadding: 0,
                headerDateFormat: 'yyyy年MM月',
                showNavigationArrow: true,
                onViewChanged: viewChanged,
                headerStyle: _headerStyle,
                viewHeaderStyle: ViewHeaderStyle(
                  backgroundColor: _headerStyle.backgroundColor,
                  dayTextStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                todayHighlightColor: Colors.white,
                appointmentBuilder: (BuildContext context,
                    CalendarAppointmentDetails details) {
                  final AttendanceData appointment = details.appointments.first;
                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdateAttendancePage(attendance: appointment, currentUserId: id!,),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isTitleToColorBox(appointment.title),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: _isTitleToColorBorder(appointment.title),
                          width: 1.0,
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: Text('${appointment.userName}：${appointment.title}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                  return Container(
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                        color: _getCellColor(details.date),
                        border: Border.all(color: Colors.grey, width: 0.2)
                    ),
                    child: DateTime(details.date.year, details.date.month, details.date.day) == DateTime(today.year, today.month, today.day)
                        ? Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.indigo,
                      ),
                      height: 25,
                      width: 25,
                      alignment: Alignment.center,
                      child: Text(
                        details.date.day.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                        : Text(
                      details.date.day.toString(),
                      style: TextStyle(color: _getTextColor(details.date)),
                    ),
                  );
                },
                monthViewSettings: const MonthViewSettings(
                  numberOfWeeksInView: 6, // 表示する週の数
                  agendaItemHeight: 40,
                  appointmentDisplayCount: 7,
                  showAgenda: true,
                  appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                  monthCellStyle: MonthCellStyle(
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget calendarChange (CalendarView view) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _goToToday();
                        },
                        child: const Text('今日'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: DropdownButton(
                          value: selectedYear,
                          items: const [
                            DropdownMenuItem(
                              value: 2020,
                              child: Text('2020年'),
                            ),
                            DropdownMenuItem(
                              value: 2021,
                              child: Text('2021年'),
                            ),
                            DropdownMenuItem(
                              value: 2022,
                              child: Text('2022年'),
                            ),
                            DropdownMenuItem(
                              value: 2023,
                              child: Text('2023年'),
                            ),
                            DropdownMenuItem(
                              value: 2024,
                              child: Text('2024年'),
                            ),
                            DropdownMenuItem(
                              value: 2025,
                              child: Text('2025年'),
                            ),
                            DropdownMenuItem(
                              value: 2026,
                              child: Text('2026年'),
                            ),
                            DropdownMenuItem(
                              value: 2027,
                              child: Text('2027年'),
                            ),
                            DropdownMenuItem(
                              value: 2028,
                              child: Text('2028年'),
                            ),
                            DropdownMenuItem(
                              value: 2029,
                              child: Text('2029年'),
                            ),
                            DropdownMenuItem(
                              value: 2030,
                              child: Text('2030年'),
                            ),
                          ],
                          onChanged: (text) {
                            setState(() {
                              selectedYear = text!;
                            });
                          }
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: DropdownButton(
                          value: selectedMonth,
                          items: const [
                            DropdownMenuItem(
                              value: 1,
                              child: Text('1月'),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text('2月'),
                            ),
                            DropdownMenuItem(
                              value: 3,
                              child: Text('3月'),
                            ),
                            DropdownMenuItem(
                              value: 4,
                              child: Text('4月'),
                            ),
                            DropdownMenuItem(
                              value: 5,
                              child: Text('5月'),
                            ),
                            DropdownMenuItem(
                              value: 6,
                              child: Text('6月'),
                            ),
                            DropdownMenuItem(
                              value: 7,
                              child: Text('7月'),
                            ),
                            DropdownMenuItem(
                              value: 8,
                              child: Text('8月'),
                            ),
                            DropdownMenuItem(
                              value: 9,
                              child: Text('9月'),
                            ),
                            DropdownMenuItem(
                              value: 10,
                              child: Text('10月'),
                            ),
                            DropdownMenuItem(
                              value: 11,
                              child: Text('11月'),
                            ),
                            DropdownMenuItem(
                              value: 12,
                              child: Text('12月'),
                            ),
                          ],
                          onChanged: (text) {
                            setState(() {
                              selectedMonth = text!;
                            });
                          }
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _goToSelectedYearMonth(selectedYear, selectedMonth);
                        },
                        child: const Text('移動'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 1000,
            child: SfCalendar(
              dataSource: AttendanceDataSource(attendances),
              view: view,
              controller: _controllerMonth,
              cellEndPadding: 0,
              headerDateFormat: 'yyyy年　MM月',
              showNavigationArrow: true,
              onViewChanged: viewChanged,
              headerStyle: _headerStyle,
              viewHeaderStyle: ViewHeaderStyle(
                backgroundColor: _headerStyle.backgroundColor,
                dayTextStyle: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              todayHighlightColor: Colors.white,
              /*allowedViews: const <CalendarView>[
                                     CalendarView.day,
                                     CalendarView.week,
                                     CalendarView.month,
                               ],

                                    */
              appointmentBuilder: (BuildContext context,
                  CalendarAppointmentDetails details) {
                final AttendanceData appointment = details.appointments.first;
                final bool isTimeslotAppointment = _isTimeslotAppointmentView(
                    appointment, _controllerMonth.view);
                final bool isStartAppointment = !isTimeslotAppointment &&
                    _isStartOfAppointmentView(appointment, details.date);
                final bool isEndAppointment = !isTimeslotAppointment &&
                    _isEndOfAppointmentView(
                        appointment, details.date, _controllerMonth.view);
                return Container(
                  margin: EdgeInsets.fromLTRB(isStartAppointment ? 0 : 0, 0,
                      isEndAppointment ? 0 : 0, 0),
                  decoration: BoxDecoration(
                    color: _isTitleToColorBox(appointment.title),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _isTitleToColorBorder(appointment.title),
                      width: 1.0,
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: Text('${appointment.userName}：${appointment.title}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
              monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                return Container(
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                      color: _getCellColor(details.date),
                      border: Border.all(color: Colors.grey, width: 0.2)
                  ),
                  child: DateTime(details.date.year, details.date.month, details.date.day) == DateTime(today.year, today.month, today.day)
                      ? Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.indigo,
                    ),
                    height: 25,
                    width: 25,
                    alignment: Alignment.center,
                    child: Text(
                      details.date.day.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                      : Text(
                    details.date.day.toString(),
                    style: TextStyle(color: _getTextColor(details.date)),
                  ),
                );
              },
              monthViewSettings: const MonthViewSettings(
                numberOfWeeksInView: 6, // 表示する週の数
                agendaItemHeight: 10,
                appointmentDisplayCount: 5, // 表示するアポイントメントの最大数
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                monthCellStyle: MonthCellStyle(
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///祝日(手打ち)
  List<DateTime> holidays = [
    DateTime(2022,01,01),
    DateTime(2022,01,10),
    DateTime(2022,02,11),
    DateTime(2022,02,23),
    DateTime(2022,03,21),
    DateTime(2022,04,29),
    DateTime(2022,05,03),
    DateTime(2022,05,04),
    DateTime(2022,05,05),
    DateTime(2022,07,18),
    DateTime(2022,08,11),
    DateTime(2022,09,19),
    DateTime(2022,09,23),
    DateTime(2022,10,10),
    DateTime(2022,11,03),
    DateTime(2022,11,23),
    DateTime(2023,01,01),
    DateTime(2023,01,02),
    DateTime(2023,01,09),
    DateTime(2023,02,11),
    DateTime(2023,02,23),
    DateTime(2023,03,21),
    DateTime(2023,04,29),
    DateTime(2023,05,03),
    DateTime(2023,05,04),
    DateTime(2023,05,05),
    DateTime(2023,07,17),
    DateTime(2023,08,11),
    DateTime(2023,09,18),
    DateTime(2023,09,23),
    DateTime(2023,10,09),
    DateTime(2023,11,03),
    DateTime(2023,11,23),
    DateTime(2024,01,01),
    DateTime(2024,01,08),
    DateTime(2024,02,11),
    DateTime(2024,02,12),
    DateTime(2024,02,23),
    DateTime(2024,03,20),
    DateTime(2024,04,29),
    DateTime(2024,05,03),
    DateTime(2024,05,04),
    DateTime(2024,05,05),
    DateTime(2024,05,06),
    DateTime(2024,07,15),
    DateTime(2024,08,11),
    DateTime(2024,09,16),
    DateTime(2024,09,22),
    DateTime(2024,09,23),
    DateTime(2024,10,14),
    DateTime(2024,11,03),
    DateTime(2024,11,23),
    DateTime(2025,01,01),
    DateTime(2025,01,13),
    DateTime(2025,02,11),
    DateTime(2025,02,23),
    DateTime(2025,03,20),
    DateTime(2025,04,29),
    DateTime(2025,05,03),
    DateTime(2025,05,04),
    DateTime(2025,05,05),
    DateTime(2025,05,06),
    DateTime(2025,07,21),
    DateTime(2025,08,11),
    DateTime(2025,09,15),
    DateTime(2025,09,23),
    DateTime(2025,10,13),
    DateTime(2025,11,03),
    DateTime(2025,11,23),
    DateTime(2025,11,24),
    DateTime(2026,01,01),
    DateTime(2026,01,12),
    DateTime(2026,02,11),
    DateTime(2026,02,23),
    DateTime(2026,03,20),
    DateTime(2026,04,29),
    DateTime(2026,05,03),
    DateTime(2026,05,04),
    DateTime(2026,05,05),
    DateTime(2026,05,06),
    DateTime(2026,07,20),
    DateTime(2026,08,11),
    DateTime(2026,09,21),
    DateTime(2026,09,22),
    DateTime(2026,09,23),
    DateTime(2026,10,12),
    DateTime(2026,11,03),
    DateTime(2026,11,23),
    DateTime(2027,01,01),
    DateTime(2027,01,11),
    DateTime(2027,02,11),
    DateTime(2027,02,23),
    DateTime(2027,03,21),
    DateTime(2027,03,22),
    DateTime(2027,04,29),
    DateTime(2027,05,03),
    DateTime(2027,05,04),
    DateTime(2027,05,05),
    DateTime(2027,07,19),
    DateTime(2027,08,11),
    DateTime(2027,09,20),
    DateTime(2027,09,23),
    DateTime(2027,10,11),
    DateTime(2027,11,03),
    DateTime(2027,11,23),
    DateTime(2028, 1, 1),
    DateTime(2028, 1,10),
    DateTime(2028, 2,11),
    DateTime(2028, 2,23),
    DateTime(2028, 3,20),
    DateTime(2028, 4,29),
    DateTime(2028, 5, 3),
    DateTime(2028, 5, 4),
    DateTime(2028, 5, 5),
    DateTime(2028, 7,17),
    DateTime(2028, 8,11),
    DateTime(2028, 9,18),
    DateTime(2028, 9,22),
    DateTime(2028,10, 9),
    DateTime(2028,11, 3),
    DateTime(2028,11,23),
    DateTime(2029, 1, 1),
    DateTime(2029, 1, 8),
    DateTime(2029, 2,11),
    DateTime(2029, 2,12),
    DateTime(2029, 2,23),
    DateTime(2029, 3,20),
    DateTime(2029, 4,29),
    DateTime(2029, 4,30),
    DateTime(2029, 5, 3),
    DateTime(2029, 5, 4),
    DateTime(2029, 5, 5),
    DateTime(2029, 7,16),
    DateTime(2029, 8,11),
    DateTime(2029, 9,17),
    DateTime(2029, 9,23),
    DateTime(2029, 9,24),
    DateTime(2029,10, 8),
    DateTime(2029,11, 3),
    DateTime(2029,11,23),
    DateTime(2030, 1, 1),
    DateTime(2030, 1,14),
    DateTime(2030, 2,11),
    DateTime(2030, 2,23),
    DateTime(2030, 3,20),
    DateTime(2030, 4,29),
    DateTime(2030, 5, 3),
    DateTime(2030, 5, 4),
    DateTime(2030, 5, 5),
    DateTime(2030, 5, 6),
    DateTime(2030, 7,15),
    DateTime(2030, 8,11),
    DateTime(2030, 8,12),
    DateTime(2030, 9,16),
    DateTime(2030, 9,23),
    DateTime(2030,10, 14),
    DateTime(2030,11, 3),
    DateTime(2030,11, 4),
    DateTime(2030,11,23),
  ];

  Color _getCellColor(DateTime date) {
    DateTime displayDate = _controllerMonth.displayDate!;
    if (DateTime(date.year,date.month,1).isBefore(DateTime(displayDate.year,displayDate.month,displayDate.day))) {
      return const Color(0xFFD6D6D6);
    } else if (DateTime(date.year,date.month,1).isAfter(DateTime(displayDate.year,displayDate.month+1,0))){
      return const Color(0xFFD6D6D6);
    } else {
      if (holidays.contains(DateTime(date.year,date.month,date.day))) {
        return Colors.red.shade100;
      } else {
        if (date.weekday == DateTime.sunday) {
          return Colors.red.shade100;
        } else if (date.weekday == DateTime.saturday) {
          return Colors.blue.shade100;
        } else {
          return Colors.white;
        }
      }
    }
  }

  Color _getTextColor(DateTime date) {
    DateTime displayDate = _controllerMonth.displayDate!;
    if (DateTime(date.year,date.month,1).isBefore(DateTime(displayDate.year,displayDate.month,displayDate.day))) {
      return Colors.grey.shade600;
    } else if (DateTime(date.year,date.month,1).isAfter(DateTime(displayDate.year,displayDate.month+1,0))){
      return Colors.grey.shade600;
    } else {
      if (holidays.contains(DateTime(date.year,date.month,date.day))) {
        return Colors.red;
      } else {
        if (date.weekday == DateTime.sunday) {
          return Colors.red;
        } else if (date.weekday == DateTime.saturday) {
          return Colors.blue;
        } else {
          return Colors.black;
        }
      }
    }
  }

  Color _isTitleToColorBox(String title) {
    if (title == '遅刻') {
      return Colors.orange.shade300;
    } else if (title == '欠席') {
      return Colors.red.shade300;
    } else {
      return Colors.grey.shade400;
    }

  }

  Color _isTitleToColorBorder(String title) {
    if (title == '遅刻') {
      return Colors.orange;
    } else if (title == '欠席') {
      return Colors.red;
    } else {
      return Colors.grey;
    }

  }

  /// Check whether the appointment placed inside the timeslot on day, week
  /// and work week views.
  bool _isTimeslotAppointmentView(AttendanceData app, CalendarView? view) {
    return (view == CalendarView.day ||
        view == CalendarView.week ||
        view == CalendarView.workWeek) &&
        app.end.difference(app.start).inDays < 1;
  }
  /// Check the date values are equal based on day, month and year.
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  /// Check the appointment view is start of an appointment.
  bool _isStartOfAppointmentView(AttendanceData app, DateTime date) {
    return _isSameDate(app.start, date);
  }
  /// Check the appointment view is end of an appointment.
  bool _isEndOfAppointmentView(AttendanceData app, DateTime date, CalendarView? view) {
    if (view == CalendarView.month ||
        view == CalendarView.timelineWeek ||
        view == CalendarView.timelineWorkWeek ||
        view == CalendarView.week ||
        view == CalendarView.workWeek) {
      const int firstDayOfWeek = DateTime.sunday; // denotes the sunday weekday.

      /// Calculate the start date of the current week based on the builder
      /// date and first day of week.
      int value = -date.weekday + firstDayOfWeek - DateTime.daysPerWeek;
      if (value.abs() >= DateTime.daysPerWeek) {
        value += DateTime.daysPerWeek;
      }

      /// Current week start date.
      final DateTime weekStartDate = date.add(Duration(days: value));
      DateTime weekEndDate = weekStartDate.add(const Duration(days: DateTime.daysPerWeek - 1));
      weekEndDate = DateTime(weekEndDate.year, weekEndDate.month, weekEndDate.day, 23, 59, 59);

      /// Check the appointment end date is on or before the week end date.
      return weekEndDate.isAfter(app.start) || _isSameDate(app.end, weekEndDate);
    } else if (view == CalendarView.schedule || view == CalendarView.timelineDay || view == CalendarView.day) {
      /// In calendar day, timeline day and schedule views
      /// are rendered based on each day, so we need to check the builder
      /// date value with appointment end date value for identify
      /// the end of the appointment.
      return _isSameDate(app.end, date);
    } else if (view == CalendarView.timelineMonth) {
      /// In calendar timeline month view render based month value so we need
      /// to check the builder date month and year value with appointment end
      /// date month and year value for identify the end of the appointment.
      return app.end.month == date.month && app.end.year == date.year;
    }
    return false;
  }

}


/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class AttendanceDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  AttendanceDataSource(List<AttendanceData> source) {
    appointments = source;
  }

  @override
  int getId(int index) {
    return _getAttendanceData(index).id;
  }


  @override
  DateTime getStartTime(int index) {
    return _getAttendanceData(index).start;
  }


  @override
  DateTime getEndTime(int index) {
    return _getAttendanceData(index).end;
  }


  @override
  String getSubject(int index) {
    return _getAttendanceData(index).title;
  }



  AttendanceData _getAttendanceData(int index) {
    final dynamic attendance = appointments![index];
    late final AttendanceData attendanceData;
    if (attendance is AttendanceData) {
      attendanceData = attendance;
    }
    return attendanceData;
  }
}



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../header_footer_drawer/footer.dart';
import 'attendance_create_model.dart';

class CreateAttendancePage extends StatefulWidget {
  final bool withDuration;

  const CreateAttendancePage({Key? key, this.withDuration = false})
      : super(key: key);

  @override
  _CreateAttendancePageState createState() => _CreateAttendancePageState();
}

class _CreateAttendancePageState extends State<CreateAttendancePage> {

  final GlobalKey<FormState> _form = GlobalKey();

  bool undecided = false;
  bool _mailSend = true;
  DateTime currentDate = DateTime.now();
  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late FocusNode _descriptionNode;

  @override
  void initState() {
    _titleController = TextEditingController();
    _titleController.text = '遅刻';
    _descriptionController = TextEditingController();
    selectedStartDate = currentDate.add(const Duration(minutes: 30));
    selectedEndDate = DateTime(currentDate.year,currentDate.month,currentDate.day,23,00,00);
    _descriptionNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _descriptionNode.dispose();
    super.dispose();
  }

  void reset(String content) {
    if (content == '欠席') {
      setState(() {
        selectedStartDate = DateTime(currentDate.year,currentDate.month,currentDate.day,00,00,00);
        selectedEndDate = DateTime(currentDate.year,currentDate.month,currentDate.day,23,00,00);
      });
    } else {
      setState(() {
        selectedStartDate = currentDate.add(const Duration(minutes: 30));
        selectedEndDate = DateTime(currentDate.year,currentDate.month,currentDate.day,23,00,00);
      });
    }

  }

  void resetUndecided(bool undecided) {
    if (undecided == true) {
      setState(() {
        selectedStartDate = DateTime(selectedStartDate.year,selectedStartDate.month,selectedStartDate.day,00,00,00);
      });
    } else {
      if (DateTime(selectedStartDate.year,selectedStartDate.month,selectedStartDate.day) == DateTime(currentDate.year,currentDate.month,currentDate.day)) {
        selectedStartDate = DateTime(selectedStartDate.year,selectedStartDate.month,selectedStartDate.day,currentDate.hour,currentDate.minute,00);
        setState(() {
          selectedStartDate = selectedStartDate.add(const Duration(minutes: 30));
        });
      }
      else {
        setState(() {
          selectedStartDate = DateTime(selectedStartDate.year,selectedStartDate.month,selectedStartDate.day,12,00,00);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateAttendanceModel>(
      create: (_) => CreateAttendanceModel()..fetchUser(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.pink.shade200,
          centerTitle: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xff626262),
            ),
          ),
          title: const Text(
            "Create New Attendance",
            style: TextStyle(
              color: Color(0xff626262),
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<CreateAttendanceModel>(builder: (context, model, child) {
          return Form(
            key: _form,
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              padding: const EdgeInsets.all(5.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: const Color(0xffb3b9ed),
                                ),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('今日の日付：',
                                    style: TextStyle(
                                      fontSize: 17.0,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(DateFormat.yMMMd('ja').format(currentDate),
                                    style: const TextStyle(
                                      fontSize: 17.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              padding: const EdgeInsets.all(5.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: const Color(0xffb3b9ed),
                                ),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('投稿者：',
                                    style: TextStyle(
                                      fontSize: 17.0,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(model.name,
                                    style: const TextStyle(
                                      fontSize: 17.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              padding: const EdgeInsets.all(5.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: const Color(0xffb3b9ed),
                                ),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('内容：',
                                    style: TextStyle(
                                      fontSize: 17.0,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  DropdownButton(
                                    value: _titleController.text,
                                    items: const [
                                      DropdownMenuItem(
                                        value: '遅刻',
                                        child: Text('遅刻'),
                                      ),
                                      DropdownMenuItem(
                                        value: '欠席',
                                        child: Text('欠席'),
                                      ),
                                      DropdownMenuItem(
                                        value: '早退',
                                        child: Text('早退'),
                                      ),
                                    ],
                                    onChanged: (text) {
                                      setState(() {
                                        _titleController.text = text.toString();
                                      });
                                      reset(_titleController.text);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            _titleDateTime(_titleController.text),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              focusNode: _descriptionNode,
                              controller: _descriptionController,
                              style: const TextStyle(
                                color: Color(0xff626262),
                                fontSize: 17.0,
                              ),
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              selectionControls: MaterialTextSelectionControls(),
                              minLines: 1,
                              maxLines: 10,
                              maxLength: 1000,
                              validator: (value) {
                                if (value == null || value.trim() == "") {
                                  return "Please enter attendance description.";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: const BorderSide(
                                    width: 2,
                                    color: Color(0xffb3b9ed),
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: const BorderSide(
                                    width: 2,
                                    color: Color(0xffb3b9ed),
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: const BorderSide(
                                    width: 2,
                                    color: Color(0xffb3b9ed),
                                  ),
                                ).copyWith(
                                  borderSide: const BorderSide(
                                    width: 2,
                                    color: Color(0xfff96c6c),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: const BorderSide(
                                    width: 2,
                                    color: Color(0xffb3b9ed),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: const BorderSide(
                                    width: 2,
                                    color: Color(0xffb3b9ed),
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: const BorderSide(
                                    width: 2,
                                    color: Color(0xffb3b9ed),
                                  ),
                                ),
                                hintText: "Attendance Title",
                                hintStyle: const TextStyle(
                                  color: Color(0xff626262),
                                  fontSize: 17,
                                ),
                                labelStyle: const TextStyle(
                                  color: Color(0xff626262),
                                  fontSize: 17,
                                ),
                                helperStyle: const TextStyle(
                                  color: Color(0xff626262),
                                  fontSize: 17,
                                ),
                                errorStyle: const TextStyle(
                                  color: Color(0xfff96c6c),
                                  fontSize: 12,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                              ).copyWith(
                                hintText: "Attendance Description",
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(5.0),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                        color: const Color(0xffb3b9ed),
                                      ),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Text('メール送信：',
                                          style: TextStyle(
                                            fontSize: 17.0,
                                          ),
                                        ),
                                        Flexible(
                                          child: ListTile(
                                            trailing: CupertinoSwitch(
                                                value: _mailSend,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _mailSend = value;
                                                  });
                                                }
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            GestureDetector(
                              onTap: () async {

                                try {
                                  //イベント追加
                                  await model.addAttendance(_titleController.text, selectedStartDate, selectedEndDate, _descriptionController.text, _mailSend, undecided);
                                  if (_mailSend == true) {
                                    await model.sendEmail(_titleController.text, selectedStartDate, selectedEndDate, _descriptionController.text, undecided);
                                  }

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Footer(pageNumber: 1)),
                                  );
                                  const snackBar = SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text('イベントの登録をしました。'),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                } catch (e) {
                                  final snackBar = SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(e.toString()),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 40,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xff6471e9),
                                  borderRadius: BorderRadius.circular(7.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xff626262),
                                      offset: Offset(0, 4),
                                      blurRadius: 10,
                                      spreadRadius: -3,
                                    )
                                  ],
                                ),
                                child: const Text(
                                  'Create Attendance',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _titleDateTime(String title) {
    if (title == '遅刻') {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: const Color(0xffb3b9ed),
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.centerLeft,
            child: TextButton(
              child: Text('日付：${DateFormat.yMMMd('ja').format(selectedStartDate).toString()}(${DateFormat.E('ja').format(selectedStartDate)})',
                style: const TextStyle(
                  fontSize: 17.0,
                ),
              ),
              onPressed: () {
                DatePicker.showDatePicker(
                  context,
                  // 現在の日時
                  currentTime: selectedStartDate,
                  // 選択できる日時の範囲
                  minTime: DateTime(currentDate.year,currentDate.month,currentDate.day),
                  maxTime: DateTime(2030, 12, 31),

                  // ドラムロールを変化させたときの処理
                  onChanged: (dateTime) {
                  },

                  // 「完了」を押したときの処理
                  onConfirm: (dateTime) {
                    setState(() {
                      selectedStartDate = DateTime(dateTime.year,dateTime.month,dateTime.day,12,00,00);
                      selectedEndDate = DateTime(dateTime.year,dateTime.month,dateTime.day,23,00,00);
                    });
                  },

                  // 「キャンセル」を押したときの処理
                  onCancel: () {
                  },
                  //言語
                  locale: LocaleType.jp,
                );
              },
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Expanded(
                child: undecided
                    ? Container(
                  padding: const EdgeInsets.all(5.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: const Color(0xffb3b9ed),
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      '到着予定時刻未定',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                )
                    : Container(
                  padding: const EdgeInsets.all(5.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: const Color(0xffb3b9ed),
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    child: Text('到着予定時刻：${DateFormat.Hm('ja').format(selectedStartDate)}',
                      style: const TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                    onPressed: () {
                      DatePicker.showTimePicker(
                        context,
                        // 現在の日時
                        currentTime: selectedStartDate,
                        showSecondsColumn: false,

                        // ドラムロールを変化させたときの処理
                        onChanged: (dateTime) {
                        },

                        // 「完了」を押したときの処理
                        onConfirm: (dateTime) {
                          setState(() {
                            selectedStartDate = dateTime;
                            if (selectedStartDate.isAfter(selectedEndDate)) {
                              selectedEndDate = selectedStartDate;
                            }
                          });
                        },

                        // 「キャンセル」を押したときの処理
                        onCancel: () {
                        },
                        //言語
                        locale: LocaleType.jp,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10,),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                        value: undecided,
                        onChanged: (value) {
                          setState(() {
                            undecided = value!;
                          });
                          resetUndecided(undecided);
                        }
                    ),
                    const Text(
                      '未定',
                      style: TextStyle(fontSize: 17,),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    } else if (title == '早退') {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: const Color(0xffb3b9ed),
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.centerLeft,
            child: TextButton(
              child: Text('日付：${DateFormat.yMMMd('ja').format(selectedStartDate).toString()}(${DateFormat.E('ja').format(selectedStartDate)})',
                style: const TextStyle(
                  fontSize: 17.0,
                ),
              ),
              onPressed: () {
                DatePicker.showDatePicker(
                  context,
                  // 現在の日時
                  currentTime: selectedStartDate,
                  // 選択できる日時の範囲
                  minTime: DateTime(currentDate.year,currentDate.month,currentDate.day),
                  maxTime: DateTime(2030, 12, 31),

                  // ドラムロールを変化させたときの処理
                  onChanged: (dateTime) {
                  },

                  // 「完了」を押したときの処理
                  onConfirm: (dateTime) {
                    setState(() {
                      selectedStartDate = DateTime(dateTime.year,dateTime.month,dateTime.day,12,00,00);
                      selectedEndDate = DateTime(dateTime.year,dateTime.month,dateTime.day,23,00,00);
                    });
                  },

                  // 「キャンセル」を押したときの処理
                  onCancel: () {
                  },
                  //言語
                  locale: LocaleType.jp,
                );
              },
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            padding: const EdgeInsets.all(5.0),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: const Color(0xffb3b9ed),
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.centerLeft,
            child: TextButton(
              child: Text('早退予定時刻：${DateFormat.Hm('ja').format(selectedStartDate)}',
                style: const TextStyle(
                  fontSize: 17.0,
                ),
              ),
              onPressed: () {
                DatePicker.showTimePicker(
                  context,
                  // 現在の日時
                  currentTime: selectedStartDate,

                  showSecondsColumn: false,
                  // 選択できる日時の範囲

                  // ドラムロールを変化させたときの処理
                  onChanged: (dateTime) {
                  },

                  // 「完了」を押したときの処理
                  onConfirm: (dateTime) {
                    setState(() {
                      selectedStartDate = dateTime;
                      if (selectedStartDate.isAfter(selectedEndDate)) {
                        selectedEndDate = selectedStartDate;
                      }
                    });
                  },

                  // 「キャンセル」を押したときの処理
                  onCancel: () {
                  },
                  //言語
                  locale: LocaleType.jp,
                );
              },
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: const Color(0xffb3b9ed),
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.centerLeft,
            child: TextButton(
              child: Text('開始時刻：${DateFormat.yMMMd('ja').format(selectedStartDate).toString()}(${DateFormat.E('ja').format(selectedStartDate)})ー${DateFormat.Hm('ja').format(selectedStartDate)}',
                style: const TextStyle(
                  fontSize: 17.0,
                ),
              ),
              onPressed: () {
                DatePicker.showDateTimePicker(
                  context,
                  // 現在の日時
                  currentTime: selectedStartDate,
                  // 選択できる日時の範囲
                  minTime: DateTime(currentDate.year,currentDate.month,currentDate.day,0,0,0),
                  maxTime: DateTime(2030, 12, 31,23,0,0),

                  // ドラムロールを変化させたときの処理
                  onChanged: (dateTime) {
                  },

                  // 「完了」を押したときの処理
                  onConfirm: (dateTime) {
                    setState(() {
                      selectedStartDate = dateTime;
                      if (selectedStartDate.isAfter(selectedEndDate)) {
                        selectedEndDate = DateTime(selectedStartDate.year,selectedStartDate.month,selectedStartDate.day,23,00,00);
                      }
                    });
                  },

                  // 「キャンセル」を押したときの処理
                  onCancel: () {
                  },
                  //言語
                  locale: LocaleType.jp,
                );
              },
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            padding: const EdgeInsets.all(5.0),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: const Color(0xffb3b9ed),
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.centerLeft,
            child: TextButton(
              child: Text('終了時刻：${DateFormat.yMMMd('ja').format(selectedEndDate).toString()}(${DateFormat.E('ja').format(selectedEndDate)})ー${DateFormat.Hm('ja').format(selectedEndDate)}',
                style: const TextStyle(
                  fontSize: 17.0,
                ),
              ),
              onPressed: () {
                DatePicker.showDateTimePicker(
                  context,
                  // 現在の日時
                  currentTime: selectedEndDate,
                  // 選択できる日時の範囲
                  minTime: selectedStartDate,
                  maxTime: DateTime(2030, 12, 31),

                  // ドラムロールを変化させたときの処理
                  onChanged: (dateTime) {
                  },

                  // 「完了」を押したときの処理
                  onConfirm: (dateTime) {
                    setState(() {
                      selectedEndDate = dateTime;
                    });
                  },

                  // 「キャンセル」を押したときの処理
                  onCancel: () {
                  },
                  //言語
                  locale: LocaleType.jp,
                );
              },
            ),
          ),
        ],
      );
    }
  }
}



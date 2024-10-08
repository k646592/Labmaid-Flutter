import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:labmaidfastapi/domain/event_data.dart';
import 'package:provider/provider.dart';

import 'event_update_model.dart';

class UpdateEventPage extends StatefulWidget {

  final EventData event;
  final String content;
  const UpdateEventPage({Key? key, required this.event, required this.content}) : super(key:key);
  @override
  _UpdateEventPageState createState() => _UpdateEventPageState();
}

class _UpdateEventPageState extends State<UpdateEventPage> {

  final GlobalKey<FormState> _form = GlobalKey();
  late String _unit;
  late String _content;
  late bool _display;
  late bool _mailSend;
  DateTime currentDate = DateTime.now();
  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late FocusNode _descriptionNode;

  @override
  void initState() {
    _content = widget.content;
    if (_content == 'その他') {
      _display = true;
    } else {
      _display = false;
    }
    _unit = widget.event.unit;
    _mailSend = widget.event.mailSend;
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    selectedStartDate = widget.event.start;
    selectedEndDate = widget.event.end;
    _descriptionNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _descriptionNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpdateEventModel>(
        create: (_) => UpdateEventModel()..fetchUser(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.purple[200],
          centerTitle: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xff626262),
            ),
          ),
          title: const Text(
            "Show Event",
            style: TextStyle(
              color: Color(0xff626262),
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<UpdateEventModel>(builder: (context, model, child) {
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
                                    Text(widget.event.userName,
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
                                      value: _content,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'ミーティング',
                                          child: Text('ミーティング'),
                                        ),
                                        DropdownMenuItem(
                                          value: '輪講',
                                          child: Text('輪講'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'その他',
                                          child: Text('その他'),
                                        ),
                                      ],
                                      onChanged: (text) {
                                        setState(() {
                                          _content = text.toString();
                                          if (text.toString() == 'ミーティング') {
                                            _display = false;
                                            _titleController.text = 'ミーティング';
                                          }
                                          if (text.toString() == '輪講') {
                                            _display = false;
                                            _titleController.text = '輪講';
                                          }
                                          if (text.toString() == 'その他') {
                                            _display = true;
                                            _titleController.text = '';
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                controller: _titleController,
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
                                  hintText: "Event Title",
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
                                ).copyWith(),
                                style: const TextStyle(
                                  color: Color(0xff626262),
                                  fontSize: 17.0,
                                ),
                                enabled: _display,

                                validator: (value) {
                                  if (_titleController.text == "") {
                                    return "Please enter event title.";
                                  }

                                  return null;
                                },
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              unitSelector(_content),
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
                                      minTime: DateTime(currentDate.year, currentDate.month, currentDate.day,0,0,0),
                                      maxTime: DateTime(2030, 12, 31,23,0,0),

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
                                    return "Please enter event description.";
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
                                  hintText: "Event Title",
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
                                  hintText: "Event Description",
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
                                          const Text('メール送信',
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: GestureDetector(
                                      onTap: () async {

                                        try {
                                          showDialog(
                                              context: context,
                                              builder: (_) => CupertinoAlertDialog(
                                                title: const Text("削除しますか？"),
                                                actions: [
                                                  CupertinoDialogAction(
                                                      isDestructiveAction: true,
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: const Text('Cancel')),
                                                  CupertinoDialogAction(
                                                    child: const Text('OK'),
                                                    onPressed: () async {
                                                      //イベント削除
                                                      await model.deleteEvent(widget.event.id);
                                                      Navigator.of(context).pop();
                                                      Navigator.of(context).pop();
                                                      const snackBar = SnackBar(
                                                        backgroundColor: Colors.green,
                                                        content: Text('削除しました'),
                                                      );
                                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                    },
                                                  )
                                                ],
                                              ));
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
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(7.0),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.red,
                                              offset: Offset(0, 4),
                                              blurRadius: 10,
                                              spreadRadius: -3,
                                            )
                                          ],
                                        ),
                                        child: const Text(
                                          '削除',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: GestureDetector(
                                      onTap: () async {

                                        try {
                                          //イベント更新
                                          await model.updateEvent(widget.event.id, _titleController.text, selectedStartDate, selectedEndDate, _unit, _descriptionController.text, _mailSend);
                                          if (_mailSend == true) {
                                            await model.sendEmail(_titleController.text, selectedStartDate, selectedEndDate, _unit, _descriptionController.text);
                                          }
                                          Navigator.of(context).pop();
                                          const snackBar = SnackBar(
                                            backgroundColor: Colors.green,
                                            content: Text('イベントの編集をしました。'),
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
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(7.0),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.green,
                                              offset: Offset(0, 4),
                                              blurRadius: 10,
                                              spreadRadius: -3,
                                            )
                                          ],
                                        ),
                                        child: const Text(
                                          '編集',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
          }
          ),
      ),
    );
  }

  Widget unitSelector(String content) {
    if (content == 'ミーティング'){
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
            child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const Text('参加単位：',
                    style: TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  DropdownButton(
                      value: _unit,
                      items: const [
                        DropdownMenuItem(
                          value: '全体',
                          child: Text('全体'),
                        ),
                        DropdownMenuItem(
                          value: '個人',
                          child: Text('個人'),
                        ),
                        DropdownMenuItem(
                          value: 'Net班',
                          child: Text('Net班'),
                        ),
                        DropdownMenuItem(
                          value: 'Grid班',
                          child: Text('Grid班'),
                        ),
                        DropdownMenuItem(
                          value: 'Web班',
                          child: Text('Web班'),
                        ),
                        DropdownMenuItem(
                          value: 'B4',
                          child: Text('B4'),
                        ),
                        DropdownMenuItem(
                          value: 'M1',
                          child: Text('M1'),
                        ),
                        DropdownMenuItem(
                          value: 'M2',
                          child: Text('M2'),
                        ),
                      ],
                      onChanged: (text) {
                        setState(() {
                          _unit = text.toString();
                        });
                      }
                  ),
                ]),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      );
    }
    else {
      return const SizedBox();
    }
  }
}
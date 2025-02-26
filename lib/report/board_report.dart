import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labmaidfastapi/domain/report_data.dart';
import '../network/url.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPage();
}

class _ReportPage extends State<ReportPage> {
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  final user = FirebaseAuth.instance.currentUser;
  String? firebaseUserId;
  List<ReportData> reports = [];

  @override
  void initState() {
    firebaseUserId = user!.uid;
    _fetchReport();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!_isLoading && _hasMore) {
          _fetchReport();
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchReport() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      var uri =
      Uri.parse('${httpUrl}reports?user_id=$firebaseUserId&page=$_page');
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            reports
                .addAll(body.map((json) => ReportData.fromJson(json)).toList());
            _page++;
            _hasMore = body.isNotEmpty;
          });
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // rogerの状態を更新する関数
  Future<void> _updateRoger(int reportId, bool currentRoger) async {
    setState(() {
      final report = reports.firstWhere((report) => report.id == reportId);
      report.roger = !currentRoger;
    });

    try {
      var url = Uri.parse(
          '${httpUrl}reports/$reportId/roger?roger_value=${!currentRoger}');
      var response = await http.put(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        print('Roger updated successfully');
        _fetchReport(); // リストを再取得して表示を更新
      } else {
        print('Failed to update Roger: ${response.body}');
        setState(() {
          final report = reports.firstWhere((report) => report.id == reportId);
          report.roger = currentRoger;
        });
      }
    } catch (e) {
      print('Error updating Roger: $e');
      setState(() {
        final report = reports.firstWhere((report) => report.id == reportId);
        report.roger = currentRoger;
      });
    }
  }

  // 削除処理
  Future<void> _deleteReport(int reportId) async {
    try {
      var url = Uri.parse('${httpUrl}reports/$reportId');
      var response = await http.delete(url);

      if (response.statusCode == 200) {
        setState(() {
          reports.removeWhere((report) => report.id == reportId);
        });
        print('Report deleted successfully');
      } else {
        print('Failed to delete Report: ${response.body}');
      }
    } catch (e) {
      print('Error deleting Report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return firebaseUserId == null
        ? const Center(child: CircularProgressIndicator())
        : SelectionArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height -
            AppBar().preferredSize.height -
            MediaQuery.of(context).padding.top -
            kBottomNavigationBarHeight,
        width: MediaQuery.of(context).size.width * 0.98,
        child: Container(
          margin:
          const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0),
          padding: const EdgeInsets.only(
              left: 8.0, right: 8.0, top: 1.0, bottom: 1.0),
          child: Scrollbar(
            controller: _scrollController,
            child: (_isLoading && reports.isEmpty)
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: reports.length + 1, // ローディング表示分+1
              itemBuilder: (context, index) {
                if (index == reports.length) {
                  return _isLoading
                      ? const Center(
                      child: CircularProgressIndicator())
                      : const SizedBox.shrink();
                }
                final report = reports[index];
                bool isRecipient = report.recipientUserId ==
                    firebaseUserId; // 送信者かどうかを確認
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${report.userName} To ${report.recipientUserName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  DateFormat('yyyy年MM月dd日 HH:mm')
                                      .format(report.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            report.content,
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                report.roger ? "確認済み" : "未確認",
                                style: TextStyle(
                                  color: report.roger
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              if (!report.roger &&
                                  isRecipient) // 送信者で未確認なら確認ボタンを表示
                                ElevatedButton(
                                  onPressed: () => _updateRoger(
                                      report.id, report.roger),
                                  child: const Text('確認'),
                                ),
                              if (!isRecipient) // 送信者には削除ボタンを表示
                                ElevatedButton(
                                  onPressed: () =>
                                      _deleteReport(report.id),
                                  child: const Text('削除',
                                      style: TextStyle(
                                          color: Colors.red)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
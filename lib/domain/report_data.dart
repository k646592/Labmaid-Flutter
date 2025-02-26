class ReportData {
  ReportData({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.userId,
    required this.userName,
    required this.recipientUserId,
    required this.recipientUserName,
    required this.roger,
  });

  final int id;
  final String content;
  final DateTime createdAt;
  final String userId; // 投稿者ID
  final String userName; // 投稿者名
  final String recipientUserId; // 送信先ユーザーID
  final String recipientUserName; // 送信先ユーザー名
  bool roger; // `final`を削除して、`bool`に変更（変更可能なフィールドにする）

  // JSONからオブジェクトを作成するファクトリメソッド
  factory ReportData.fromJson(dynamic json) {
    return ReportData(
      id: json['id'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      recipientUserId: json['recipient_user_id'] as String,
      recipientUserName: json['recipient_user_name'] as String,
      roger: json['roger'] as bool,
    );
  }
}
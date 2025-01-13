class BoardData {
  BoardData({
    required this.id, required this.content, required this.createdAt,
    required this.group, required this.userId, required this.userName,
    required this.isAcknowledged, required this.acknowledgements,
    required this.commentDisplay,
  });
  final int id;
  final String content;
  final DateTime createdAt;
  final String group;
  final String userId;
  final String userName;
  int acknowledgements;
  bool isAcknowledged;
  bool commentDisplay;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory BoardData.fromJson(dynamic json) {
    return BoardData(
      id: json['id'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      group: json['group'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      isAcknowledged: json['is_acknowledged'] as bool,
      acknowledgements: json['acknowledgements'] as int,
      commentDisplay: false
    );
  }
}

class AcknowledgementData {
  AcknowledgementData({
    required this.userId, required this.userName,
    required this.createdAt, required this.imageURL, required this.imageName,
  });

  final String userId;
  final String userName;
  final DateTime createdAt;
  final String imageURL;
  final String imageName;



  //JSONからオブジェクトを作成するファクトリメソッド
  factory AcknowledgementData.fromJson(dynamic json) {
    return AcknowledgementData(
        createdAt: DateTime.parse(json['created_at'] as String),
        userId: json['user_id'] as String,
        userName: json['user_name'] as String,
        imageURL: json['image_url'] as String,
        imageName: json['image_name'] as String,
    );
  }
}
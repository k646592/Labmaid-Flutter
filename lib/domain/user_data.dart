import 'package:path/path.dart' as path;

class UserAttendanceData {
  UserAttendanceData({
    required this.id, required this.group, required this.name, required this.status,
  });

  final String id;
  final String group;
  final String name;
  String status;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory UserAttendanceData.fromJson(dynamic json) {
    return UserAttendanceData(
      id: json['id'] as String,
      name: json['name'] as String,
      group: json['group'] as String,
      status: json['status'] as String,
    );
  }
}

class UserData {
  UserData({
    required this.id, required this.email, required this.group, required this.grade,
    required this.name, required this.status, required this.imageURL,
    required this.imageName, required this.location, required this.flag,
  });

  final String id;
  String email;
  String group;
  String grade;
  String name;
  String status;
  String imageURL;
  String imageName;
  String location;
  bool flag;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory UserData.fromJson(dynamic json) {
    return UserData(
      id: json['id'] as String,
      email: json['email'] as String,
      group: json['group'] as String,
      grade: json['grade'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      imageURL: json['image_url'] as String,
      imageName: path.basename(json['image_name'] as String),
      location: json['now_location'] as String,
      flag: json['location_flag'] as bool,
    );
  }

}

class UserPrivateChatData {
  UserPrivateChatData({
    required this.id, required this.email, required this.group, required this.grade,
    required this.name, required this.status, required this.imageURL,
    required this.imageName, required this.location, required this.flag,
    required this.updatedAt, required this.unreadCount
  });

  final String id;
  String email;
  String group;
  String grade;
  String name;
  String status;
  String imageURL;
  String imageName;
  String location;
  bool flag;
  DateTime? updatedAt;
  int unreadCount;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory UserPrivateChatData.fromJson(dynamic json) {
    return UserPrivateChatData(
      id: json['id'] as String,
      email: json['email'] as String,
      group: json['group'] as String,
      grade: json['grade'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      imageURL: json['image_url'] as String,
      imageName: path.basename(json['image_name'] as String),
      location: json['now_location'] as String,
      flag: json['location_flag'] as bool,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null, // nullの場合はそのまま設定
      unreadCount: json['unread_count'] as int,
    );
  }

}

class GroupChatMemberCreate {
  GroupChatMemberCreate({
    required this.id, required this.group,
    required this.name, required this.join, required this.grade
  });

  final String id;
  final String group;
  final String name;
  final String grade;
  bool join;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory GroupChatMemberCreate.fromJson(dynamic json) {
    return GroupChatMemberCreate(
      id: json['id'] as String,
      group: json['group'] as String,
      grade: json['grade'] as String,
      name: json['name'] as String,
      join: true,
    );
  }

}

class GroupChatUserData {
  GroupChatUserData({
    required this.id, required this.email, required this.group, required this.grade,
    required this.name, required this.status, required this.imageURL, required this.imageName,
    required this.joinedDate, required this.leaveDate, required this.join,
  });

  final String id;
  final String email;
  final String group;
  final String grade;
  final String name;
  final String status;
  final String imageURL;
  final String imageName;
  final DateTime? joinedDate;
  final DateTime? leaveDate;
  final bool join;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory GroupChatUserData.fromJson(dynamic json) {
    return GroupChatUserData(
      id: json['id'] as String,
      email: json['email'] as String,
      group: json['group'] as String,
      grade: json['grade'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      imageName: json['image_name'] as String,
      imageURL: json['image_url'] as String,
      joinedDate: json['joined_date'] != null ? DateTime.parse(json['joined_date'] as String) : null,  // nullの場合はnullを返す
      leaveDate: json['leave_date'] != null
          ? DateTime.parse(json['leave_date'] as String)
          : null,  // nullの場合はnullを返す
      join: json['join'] as bool,
    );
  }

}

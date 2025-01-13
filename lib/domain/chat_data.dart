import 'package:path/path.dart' as path;

class PrivateMessageData {
  PrivateMessageData({
    required this.id, required this.userId, required this.content,
    required this.sentAt, required this. isRead, required this.messageType,
    required this.imageURL, required this.imageName, required this.fileURL,
    required this.fileName,
  });

  final int id;
  final String userId;
  final String content;
  final DateTime sentAt;
  bool isRead;
  final String messageType;
  final String imageURL;
  final String imageName;
  final String fileURL;
  final String fileName;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory PrivateMessageData.fromJson(dynamic json) {
    return PrivateMessageData(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
      isRead: json['is_read'] as bool,
      messageType: json['message_type'] as String,
      imageURL: json['image_url'] as String,
      imageName: path.basename(json['image_name'] as String),
      fileURL: json['file_url'] as String,
      fileName: path.basename(json['file_name'] as String),
     );
  }
}

class PrivateMessageUnreadData {
  PrivateMessageUnreadData({
    required this.id, required this. isRead,
  });

  final int id;
  bool isRead;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory PrivateMessageUnreadData.fromJson(dynamic json) {
    return PrivateMessageUnreadData(
      id: json['id'] as int,
      isRead: json['is_read'] as bool,
    );
  }
}

class PrivateChatRoomData {
  PrivateChatRoomData({
    required this.id, required this.updatedAt,
  });

  final int id;
  final DateTime updatedAt;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory PrivateChatRoomData.fromJson(dynamic json) {
    return PrivateChatRoomData(
      id: json['id'] as int,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class GetGroupChatRoomData {
  GetGroupChatRoomData({
    required this.id, required this.name, required this.updatedAt,
    required this.createdAt, required this.imageURL, required this.imageName,
  });

  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String imageURL;
  final String imageName;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory GetGroupChatRoomData.fromJson(dynamic json) {
    return GetGroupChatRoomData(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      imageURL: json['image_url'] as String,
      imageName: json['image_name'] as String,
    );
  }
}

class GroupChatRoomData {
  GroupChatRoomData({
    required this.id, required this.name, required this.updatedAt,
    required this.createdAt, required this.imageURL, required this.imageName,
    required this.unreadCount
  });

  final int id;
  final String name;
  final DateTime createdAt;
  DateTime updatedAt;
  final String imageURL;
  final String imageName;
  int unreadCount;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory GroupChatRoomData.fromJson(dynamic json) {
    return GroupChatRoomData(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      imageURL: json['image_url'] as String,
      imageName: json['image_name'] as String,
      unreadCount: json['unread_count'] as int,
    );
  }
}

class GroupChatMember {
  GroupChatMember({
    required this.id, required this.email, required this.group, required this.grade,
    required this.name, required this.status, required this.imageURL,
    required this.imageName, required this.join,
  });

  final String id;
  final String email;
  final String group;
  final String grade;
  final String name;
  final String status;
  final String imageURL;
  final String imageName;
  bool join;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory GroupChatMember.fromJson(dynamic json) {
    return GroupChatMember(
      id: json['id'] as String,
      email: json['email'] as String,
      group: json['group'] as String,
      grade: json['grade'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      imageURL: json['image_url'] as String,
      imageName: json['image_name'] as String,
      join: true,
    );
  }

}

class GroupMessageData {
  GroupMessageData({
    required this.id, required this.userId, required this.content,
    required this.sentAt, required this.messageType, required this.imageURL,
    required this.imageName, required this.fileURL, required this.fileName,
    required this.unreadCount
  });

  final int id;
  final String userId;
  final String content;
  final DateTime sentAt;
  final String messageType;
  final String imageURL;
  final String imageName;
  final String fileURL;
  final String fileName;
  int unreadCount;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory GroupMessageData.fromJson(dynamic json) {
    return GroupMessageData(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
      messageType: json['message_type'] as String,
      imageURL: json['image_url'] as String,
      imageName: json['image_name'] as String,
      fileURL: json['file_url'] as String,
      fileName: json['file_name'] as String,
      unreadCount: json['unread_count'] as int
    );
  }
}

class GroupWebsocketMessageData {
  GroupWebsocketMessageData({
    required this.id, required this.userId, required this.content,
    required this.sentAt, required this.messageType, required this.imageURL,
    required this.imageName, required this.fileURL, required this.fileName,
    required this.groupChatRoomId
  });

  final int id;
  final int groupChatRoomId;
  final String userId;
  final String content;
  final DateTime sentAt;
  final String messageType;
  final String imageURL;
  final String imageName;
  final String fileURL;
  final String fileName;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory GroupWebsocketMessageData.fromJson(dynamic json) {
    return GroupWebsocketMessageData(
        id: json['id'] as int,
        groupChatRoomId: json['group_chat_room_id'] as int,
        userId: json['user_id'] as String,
        content: json['content'] as String,
        sentAt: DateTime.parse(json['sent_at'] as String),
        messageType: json['message_type'] as String,
        imageURL: json['image_url'] as String,
        imageName: json['image_name'] as String,
        fileURL: json['file_url'] as String,
        fileName: json['file_name'] as String,
    );
  }
}
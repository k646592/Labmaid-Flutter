// Separate StatelessWidget for message items
import 'package:flutter/material.dart';

import '../../domain/chat_data.dart';
import '../../domain/user_data.dart';
import 'group_chat_message_content.dart';
import 'group_user_avator_widget.dart';

class GroupMessageListItem extends StatelessWidget {
  final GroupMessageData message;
  final bool isMyMessage;
  final GroupChatUserData myData;
  final GroupChatUserData userData;
  final int groupMemberLength;
  final Function(BuildContext, String) onImageTap;
  final Function(String, String) onFileTap;

  const GroupMessageListItem({
    Key? key,
    required this.message,
    required this.isMyMessage,
    required this.myData,
    required this.userData,
    required this.groupMemberLength,
    required this.onImageTap,
    required this.onFileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserData = isMyMessage ? myData : userData;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMyMessage) ...[
            GroupUserAvatar(userData: currentUserData),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GroupMessageContent(
              message: message,
              isMyMessage: isMyMessage,
              userData: currentUserData,
              groupMemberLength: groupMemberLength,
              onImageTap: onImageTap,
              onFileTap: onFileTap,
            ),
          ),
          if (isMyMessage) ...[
            const SizedBox(width: 8),
            GroupUserAvatar(userData: currentUserData),
          ],
        ],
      ),
    );
  }
}
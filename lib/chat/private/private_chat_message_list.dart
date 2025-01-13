// Separate StatelessWidget for message items
import 'package:flutter/material.dart';
import 'package:labmaidfastapi/chat/private/private_chat_message_content.dart';
import 'package:labmaidfastapi/chat/private/private_user_avator_widget.dart';

import '../../domain/chat_data.dart';
import '../../domain/user_data.dart';

class MessageListItem extends StatelessWidget {
  final PrivateMessageData message;
  final bool isMyMessage;
  final UserData myData;
  final UserData userData;
  final Function(BuildContext, String) onImageTap;
  final Function(String, String) onFileTap;

  const MessageListItem({
    Key? key,
    required this.message,
    required this.isMyMessage,
    required this.myData,
    required this.userData,
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
            UserAvatar(userData: currentUserData),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: MessageContent(
              message: message,
              isMyMessage: isMyMessage,
              userData: currentUserData,
              onImageTap: onImageTap,
              onFileTap: onFileTap,
            ),
          ),
          if (isMyMessage) ...[
            const SizedBox(width: 8),
            UserAvatar(userData: currentUserData),
          ],
        ],
      ),
    );
  }
}
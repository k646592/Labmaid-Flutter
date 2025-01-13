// Separate widget for message content type
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/chat_data.dart';
import 'package:path/path.dart' as path;

import '../../domain/user_data.dart';

// Separate widget for message content
class MessageContent extends StatelessWidget {
  final PrivateMessageData message;
  final bool isMyMessage;
  final UserData userData;
  final Function(BuildContext, String) onImageTap;
  final Function(String, String) onFileTap;

  const MessageContent({
    Key? key,
    required this.message,
    required this.isMyMessage,
    required this.userData,
    required this.onImageTap,
    required this.onFileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Column(
        crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMyMessage)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                userData.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: isMyMessage ? Colors.blue[100] : Colors.grey[300],
              border: Border.all(color: isMyMessage ? Colors.blue : Colors.grey),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMyMessage ? 25 : 0),
                topRight: Radius.circular(isMyMessage ? 0 : 25),
                bottomLeft: const Radius.circular(25),
                bottomRight: const Radius.circular(25),
              ),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: MessageContentType(
              message: message,
              onImageTap: onImageTap,
              onFileTap: onFileTap,
            ),
          ),
          if (isMyMessage)
            Padding(
              padding: const EdgeInsets.only(right: 4, top: 2),
              child: Text(
                message.isRead ? '既読' : '未読',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }
}


class MessageContentType extends StatelessWidget {
  final PrivateMessageData message;
  final Function(BuildContext, String) onImageTap;
  final Function(String, String) onFileTap;

  const MessageContentType({
    Key? key,
    required this.message,
    required this.onImageTap,
    required this.onFileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.messageType == 'text')
          Text(message.content)
        else if (message.messageType == 'image')
          GestureDetector(
            onTap: () => onImageTap(context, message.imageURL),
            child: CachedNetworkImage(
                imageUrl: message.imageURL,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          )
        else
          GestureDetector(
            onTap: () => onFileTap(message.fileURL, message.fileName),
            child: ListTile(
              leading: Icon(switchIcon(message.fileName)),
              title: Text(message.fileName),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          '${DateFormat.yMMMd('ja').format(message.sentAt).toString()}(${DateFormat.E('ja').format(message.sentAt)})ー${DateFormat.Hm('ja').format(message.sentAt)}',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  IconData switchIcon(String fileName) {
    IconData icon;
    switch (path.extension(fileName).toLowerCase()) {
    // 画像ファイル
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.bmp':
      case '.gif':
        icon = Icons.image;
        break;


    // PDFファイル
      case '.pdf':
        icon = Icons.picture_as_pdf;
        break;


    // ワードファイル
      case '.doc':
      case '.docx':
        icon = Icons.description;
        break;


    // エクセルファイル
      case '.xls':
      case '.xlsx':
        icon = Icons.table_chart;
        break;


    // パワーポイント
      case '.pptx' :
        icon = Icons.slideshow;
        break;


    // 動画ファイル
      case '.mp4':
      case '.mov':
      case '.avi':
      case '.mkv':
        icon = Icons.movie;
        break;


    // 音声ファイル
      case '.mp3':
      case '.wav':
      case '.aac':
        icon = Icons.audiotrack;
        break;


    // コードファイル
      case '.html':
      case '.xml':
      case '.css':
      case '.js':
      case '.json':
      case '.dart':
        icon = Icons.code;
        break;


    // テキストファイル
      case '.txt':
      case '.log':
      case '.md':
        icon = Icons.text_snippet;
        break;


    // 圧縮ファイル
      case '.zip':
      case '.rar':
      case '.7z':
      case '.tar':
      case '.gz':
        icon = Icons.archive;
        break;


    // その他
      default:
        icon = Icons.help_outline; // その他用の汎用アイコン
    }
    return icon;
  }

}
import 'package:callup247/src/responsive_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final String timestamp;

  const ChatBubble({
    required this.content,
    required this.isUser,
    required this.timestamp,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localDateTime = DateTime.parse(timestamp).toLocal();
    return Container(
      margin: EdgeInsets.only(
        left: isUser ? 40 : 0,
        right: isUser ? 0 : 40,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            color: isUser ? const Color(0xFF039fdc) : const Color(0xFF13CAF1),
            borderRadius: BorderRadius.circular(8),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                content,
                style: responsiveTextStyle(context, 16, Colors.black, null),
              ),
            ),
          ),
          Text(
            DateFormat.yMd().add_Hm().format(localDateTime),
            style: TextStyle(
              color: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }
}

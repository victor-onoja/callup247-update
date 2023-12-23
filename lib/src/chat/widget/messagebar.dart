import 'package:callup247/main.dart';
import 'package:callup247/src/responsive_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Set of widget that contains TextField and Button to submit message

class MessageBar extends StatefulWidget {
  const MessageBar(
      {Key? key,
      required this.senderid,
      required this.receiverid,
      required this.chatid})
      : super(key: key);

  final String senderid, receiverid, chatid;

  @override
  State<MessageBar> createState() => MessageBarState();
}

class MessageBarState extends State<MessageBar> {
  // 01 - use case send message

  void _sendMessage(String senderid, String receiverid, String chatid) async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      return;
    }
    _textController.clear();
    try {
      await supabase.from('chat_messages').insert({
        'senderid': senderid,
        'content': text,
        'receiverid': receiverid,
        'chatid': chatid
      });
    } on PostgrestException catch (error) {
      //
    } catch (e) {
      //
    }
  }

// init

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  // dispose

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // variables

  late final TextEditingController _textController;

// build method

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  style: responsiveTextStyle(context, 16, Colors.black87, null),
                  maxLines: null,
                  autofocus: true,
                  controller: _textController,
                  decoration: InputDecoration(
                    hintStyle:
                        responsiveTextStyle(context, 14, Colors.black87, null),
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.all(8),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _sendMessage(
                      widget.senderid, widget.receiverid, widget.chatid);
                },
                icon: const Icon(Icons.send),
                color: Colors.black87,
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:callup247/main.dart';
import 'package:callup247/src/chat/widget/chatbubble.dart';
import 'package:callup247/src/chat/widget/messagebar.dart';
import 'package:callup247/src/responsive_text_styles.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key, required this.serviceproviderid, required this.userid});

  final String serviceproviderid, userid;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // build method

  @override
  Widget build(BuildContext context) {
    final serviceproviderid = widget.serviceproviderid;
    final userid = widget.userid;
    final chatid = userid + serviceproviderid;
    final stream = supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('chatid', chatid)
        .order('created_at')
        .map((maps) => maps.toList());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF13CAF1),
        title: Text(
          'Chat',
          style:
              responsiveTextStyle(context, 20, Colors.black, FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
          child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFF039fdc),
                    Color(0xFF13CAF1),
                  ],
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  children: [
                    Expanded(
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final messages = snapshot.data!;
                          return ListView.builder(
                              reverse: true,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                return ChatBubble(
                                    content: message['content'],
                                    isUser: message['senderid'] == userid,
                                    timestamp: message['created_at']);
                              });
                        } else {
                          return Center(
                            child: Text(
                              'Start your conversation now :)',
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, null),
                            ),
                          );
                        }
                      },
                    )),
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                    if (supabase.auth.currentUser!.id == userid)
                      MessageBar(
                        receiverid: serviceproviderid,
                        senderid: supabase.auth.currentUser!.id,
                        chatid: chatid,
                      )
                    else
                      MessageBar(
                        receiverid: userid,
                        senderid: supabase.auth.currentUser!.id,
                        chatid: chatid,
                      )
                  ],
                ),
              ))),
    );
  }
}

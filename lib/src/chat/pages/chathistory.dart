import 'package:callup247/main.dart';
import 'package:callup247/src/chat/pages/chat_page.dart';
import 'package:callup247/src/responsive_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class ChatHistory extends StatefulWidget {
  final bool isCustomer;
  const ChatHistory({super.key, required this.isCustomer});

  @override
  State<ChatHistory> createState() => _ChatHistoryState(isCustomer);
}

class _ChatHistoryState extends State<ChatHistory> {
  bool isCustomer;

  _ChatHistoryState(this.isCustomer);
  // 01 - use case get sender's profile

  Future<Map<String, dynamic>> _getSenderProfile(String senderId) async {
    final data =
        await supabase.from('profiles').select().eq('id', senderId).single();
    return data;
  }

// init

  @override
  void initState() {
    super.initState();
  }

  // build method

  @override
  Widget build(BuildContext context) {
// variables

    final userid = supabase.auth.currentUser!.id;
    final stream = supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('receiverid', userid) // Use the receiver ID
        .order('created_at',
            ascending: false) // Order by created_at in descending order
        .map((maps) => maps.toList());
    Map<String, Map<String, dynamic>> latestMessagesMap = {};

// widget tree

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF13CAF1),
        title: Text(
          'Chat History',
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data!;

                  // Iterate through the messages to find the latest for each chatid

                  for (final message in messages) {
                    final chatid = message['chatid'];
                    if (!latestMessagesMap.containsKey(chatid)) {
                      latestMessagesMap[chatid] = message;
                    } else {
                      // If the chatid is already in the map, check if the new message is more recent
                      final latestMessage = latestMessagesMap[chatid]!;
                      final newMessageTimestamp =
                          DateTime.parse(message['created_at']);
                      final latestMessageTimestamp =
                          DateTime.parse(latestMessage['created_at']);
                      if (newMessageTimestamp.isAfter(latestMessageTimestamp)) {
                        // Update the latest message if the new message is more recent
                        latestMessagesMap[chatid] = message;
                      }
                    }
                  }
                  // Extract only the latest messages from the map
                  final latestMessages = latestMessagesMap.values.toList();

                  // chat history

                  return ListView.builder(
                      itemCount: latestMessages.length,
                      itemBuilder: (context, index) {
                        final message = latestMessages[index];
                        final senderId = message['senderid'];

                        return FutureBuilder<Map<String, dynamic>>(
                          future: _getSenderProfile(senderId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SpinKitPianoWave(
                                size: 30,
                                color: Color(0xFF13CAF1),
                                itemCount: 4,
                              );
                            } else if (snapshot.hasError) {
                              return const Text('Error loading sender profile');
                            } else {
                              final senderProfile = snapshot.data!;
                              return Column(
                                children: [
                                  ListTile(
                                    onTap: () {
                                      if (isCustomer) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  ChatPage(
                                                    serviceproviderid:
                                                        senderProfile['id'],
                                                    userid: supabase
                                                        .auth.currentUser!.id,
                                                  )),
                                        );
                                      } else {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  ChatPage(
                                                    serviceproviderid: supabase
                                                        .auth.currentUser!.id,
                                                    userid: senderProfile['id'],
                                                  )),
                                        );
                                      }
                                    },
                                    titleTextStyle: responsiveTextStyle(
                                        context, 18, Colors.black, null),
                                    subtitleTextStyle: responsiveTextStyle(
                                        context, 16, null, null),
                                    leadingAndTrailingTextStyle:
                                        responsiveTextStyle(
                                            context, 12, Colors.black54, null),
                                    title: Text(senderProfile['full_name']),
                                    subtitle: Text(message['content']),
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          senderProfile['avatar_url']),
                                    ),
                                    trailing: Text(DateFormat.yMd()
                                        .add_Hm()
                                        .format(DateTime.parse(
                                                message['created_at'])
                                            .toLocal())),
                                  ),
                                  const Divider(
                                    color: Color(0xFF039fdc),
                                  )
                                ],
                              );
                            }
                          },
                        );
                      });
                } else {
                  return Center(
                    child: Text(
                      'No chat yet :)',
                      style:
                          responsiveTextStyle(context, 16, Colors.black, null),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

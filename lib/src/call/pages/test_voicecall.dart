import 'package:callup247/src/call/pages/voicecall_page.dart';
import 'package:flutter/material.dart';

class TestCall extends StatelessWidget {
  final callidtextctrl = TextEditingController(text: 'testcallid');
  TestCall({super.key, required this.userId, required this.username});
  final String userId, username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextFormField(
                  controller: callidtextctrl,
                  decoration:
                      const InputDecoration(labelText: 'start a call by id'),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return VoiceCallPage(
                          userID: userId,
                          username: username,
                          callId: callidtextctrl.text);
                    }));
                  },
                  child: const Text('call'))
            ],
          ),
        ),
      ),
    );
  }
}

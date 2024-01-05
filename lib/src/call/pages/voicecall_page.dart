import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VoiceCallPage extends StatelessWidget {
  const VoiceCallPage(
      {super.key,
      required this.userID,
      required this.username,
      required this.callId});

  final String userID, username, callId;

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: 1387657630,
      appSign:
          '3ad64942f1d87e41180fe3013a8df56969ff1918a42ad8173b2a334662037a7a',
      callID: callId,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
      userID: userID,
      userName: username,
    );
  }
}

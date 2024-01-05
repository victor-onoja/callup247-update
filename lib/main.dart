import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'src/splash_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // todo: use alternate method to return this
  await Supabase.initialize(
      url: 'https://odlnrfizgyyjnipouhct.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9kbG5yZml6Z3l5am5pcG91aGN0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTc2MjY1OTIsImV4cCI6MjAxMzIwMjU5Mn0.I7J1ijBoasLDeYO7cBk_CTTk9FbKjrJ-yCJQ4erDdKQ');

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService()
        .useSystemCallingUI([ZegoUIKitSignalingPlugin()]);
  });

  runApp(MyApp(
    navigatorKey: navigatorKey,
  ));
}

final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  final GlobalKey navigatorKey;
  const MyApp({super.key, required this.navigatorKey});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF13CAF1),
      ),
    );
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'CallUp247',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      builder: (BuildContext context, Widget? child) {
        return Stack(
          children: [
            if (child != null) child,
            ZegoUIKitPrebuiltCallMiniOverlayPage(
              contextQuery: () {
                return widget.navigatorKey.currentState!.context;
              },
            ),
          ],
        );
      },
    );
  }
}

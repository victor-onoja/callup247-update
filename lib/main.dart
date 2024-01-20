import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // todo: use alternate method to return this
  await Supabase.initialize(
      url: 'https://odlnrfizgyyjnipouhct.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9kbG5yZml6Z3l5am5pcG91aGN0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTc2MjY1OTIsImV4cCI6MjAxMzIwMjU5Mn0.I7J1ijBoasLDeYO7cBk_CTTk9FbKjrJ-yCJQ4erDdKQ');
  runApp(const MyApp());
}

// global variables

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF13CAF1),
      ),
    );
    return const MaterialApp(
      title: 'CallUp247',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

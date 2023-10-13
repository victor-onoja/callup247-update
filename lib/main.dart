import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // use alternate method to return this
  await Supabase.initialize(
      url: 'https://chmtrezjfdbranykodpp.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNobXRyZXpqZmRicmFueWtvZHBwIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY0OTcyODUsImV4cCI6MjAxMjA3MzI4NX0.3LllHtTHpNEe5V6uqk43oTylazVncs9a1Ek1LVzVpaM');
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'CallUp247',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

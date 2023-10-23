import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text('data')),
          FloatingActionButton(onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final userProfileJson = prefs.getString('userprofile');

            if (userProfileJson != null) {
              final userProfileMap = json.decode(userProfileJson);

              // To access specific fields like full name and email address:
              final fullName = userProfileMap['fullname'];
              final emailAddress = userProfileMap['email'];

              print(fullName);
              print(emailAddress);
              // You can now use fullName and emailAddress as needed.
            } else {
              // Handle the case where no user profile data is found in SharedPreferences.
            }
          }),
        ],
      ),
    );
  }
}

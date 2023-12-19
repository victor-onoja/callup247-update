import 'dart:convert';

import 'package:callup247/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../../responsive_text_styles.dart';
import 'user_verification.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  // 01 - use case check network

  Future<bool> _checkInternetConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 02 - use case sign in auth 1

  Future<void> _signInUser() async {
    final emailaddress = _emailaddressController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await supabase.auth
          .signInWithPassword(email: emailaddress, password: password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Welcome back :)',
            style:
                responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ));
        setState(() {
          loading = false;
        });
        isPasswordReset = false;
        _signOut();
        _signInUserOTP();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => VerificationScreen(
              isPasswordReset: isPasswordReset,
              userEmail: _emailaddressController.text.trim(),
            ),
          ),
        );
      }
    } on PostgrestException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Server Error, Please try again in a bit :)',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Invalid Login Credentials :(',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // 03 - use case signin user auth 2

  Future<void> _signInUserOTP() async {
    final emailaddress = _emailaddressController.text.trim();

    try {
      await supabase.auth.signInWithOtp(
        email: emailaddress,
        emailRedirectTo:
            kIsWeb ? null : 'io.supabase.flutter://signin-callback/',
      );
      if (mounted) {}
    } on PostgrestException catch (error) {
      //
    } catch (error) {
      //
    } finally {
      if (mounted) {}
    }
  }

  // 04 - use case sign out

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } on PostgrestException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Server Error, Please try again in a bit :)',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Unexpected Error, Please try again in a bit :)',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  // init

  @override
  void initState() {
    super.initState();
    _acontroller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Adjust the duration as needed
    )..repeat();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString('userprofile');
    if (userProfileJson != null) {
      final userProfileMap = json.decode(userProfileJson);
      final email = userProfileMap['email'];
      setState(() {
        userEmail = email;
      });
    }
  }

  // dispose

  @override
  void dispose() {
    _acontroller.dispose();
    _emailaddressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // variables

  late AnimationController _acontroller;
  final _formKey = GlobalKey<FormState>();
  final _emailaddressController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isPasswordVisible = false;
  var loading = false;
  bool isPasswordReset = false;
  String userEmail = '';

  // build method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF13CAF1),
          title: Text(
            'Login',
            style:
                responsiveTextStyle(context, 20, Colors.black, FontWeight.bold),
          ),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.sizeOf(context).height,
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
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      RotationTransition(
                        turns:
                            Tween(begin: 0.0, end: 1.0).animate(_acontroller),
                        child: Image.asset(
                          'assets/logo_t.png',
                          height: 75,
                        ),
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
                      // email address

                      TextFormField(
                        controller: _emailaddressController,
                        cursorColor: Colors.white,
                        keyboardType: TextInputType.emailAddress,
                        style: responsiveTextStyle(
                            context, 16, Colors.white, null),
                        decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: responsiveTextStyle(
                                context, 14, Colors.black87, null),
                            focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black87))),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email address';
                          }
                          // Email address regex pattern for basic validation
                          const emailPattern =
                              r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
                          final regExp = RegExp(emailPattern);
                          if (!regExp.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          // You can add email validation logic here.
                          return null;
                        },
                      ),
                      SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.08),
                      // Password

                      TextFormField(
                        controller: _passwordController,
                        cursorColor: Colors.white,
                        style: responsiveTextStyle(
                            context, 16, Colors.white, null),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: responsiveTextStyle(
                              context, 14, Colors.black, null),
                          focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black87)),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                            child: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        obscureText: !isPasswordVisible,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a password';
                          }
                          // Password strength validation criteria
                          const lengthCriteria =
                              8; // Minimum length requirement

                          if (value.length < lengthCriteria) {
                            return 'Password must be at least $lengthCriteria characters long';
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),

                      // log in button

                      loading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF039fdc)),
                              onPressed: () async {
                                // Check network connectivity
                                bool isConnected =
                                    await _checkInternetConnectivity();
                                if (!isConnected) {
                                  if (!context.mounted) return;
                                  // Show a snackbar for no network
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      'No internet connection. Please check your network settings.',
                                      style: responsiveTextStyle(context, 16,
                                          Colors.black, FontWeight.bold),
                                    ),
                                    backgroundColor: Colors.red,
                                  ));
                                  return; // Exit the function if there's no network
                                }
                                if (userEmail != _emailaddressController.text &&
                                    userEmail != '') {
                                  if (!context.mounted) return;
                                  // Show a snackbar for no network
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      'Warning: The profile associated with this device is $userEmail\nUninstall the app and reinstall it to use a different profile',
                                      style: responsiveTextStyle(context, 16,
                                          Colors.black, FontWeight.bold),
                                    ),
                                    backgroundColor: Colors.red,
                                  ));
                                  return; // Exit the function if there's no network
                                } else if (userEmail == '') {}
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    loading = true;
                                  });
                                  _signInUser();
                                }
                              },
                              child: Text(
                                'Sign In',
                                style: responsiveTextStyle(
                                    context, 14, Colors.black, FontWeight.bold),
                              ),
                            ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),

                      // forgot password

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                              onPressed: () {
                                if (_emailaddressController.text.trim() == '' ||
                                    _emailaddressController.text.trim().length <
                                        8) {
                                  // Show a snackbar for no user email
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      'Please type in your email address.',
                                      style: responsiveTextStyle(context, 16,
                                          Colors.black, FontWeight.bold),
                                    ),
                                    backgroundColor: Colors.red,
                                  ));
                                  return;
                                }
                                isPasswordReset = true;
                                _signInUserOTP();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        VerificationScreen(
                                      isPasswordReset: isPasswordReset,
                                      userEmail:
                                          _emailaddressController.text.trim(),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.password,
                                color: Colors.black54,
                              ),
                              label: const Text(
                                'Forgot Password ?',
                                style: TextStyle(color: Colors.black45),
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

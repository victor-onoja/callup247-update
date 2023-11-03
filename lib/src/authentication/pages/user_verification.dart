import 'dart:convert';
import 'package:callup247/main.dart';
import 'package:callup247/src/authentication/pages/forgot_password.dart';
import 'package:callup247/src/home/pages/customer_home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../responsive_text_styles.dart';
import 'package:pinput/pinput.dart';

class VerificationScreen extends StatefulWidget {
  final bool isPasswordReset;
  const VerificationScreen({super.key, required this.isPasswordReset});

  @override
  State<VerificationScreen> createState() =>
      _VerificationScreenState(isPasswordReset);
}

class _VerificationScreenState extends State<VerificationScreen>
    with SingleTickerProviderStateMixin {
  bool isPasswordReset;

  _VerificationScreenState(this.isPasswordReset);
  // use case verify user

  Future<void> _verifyUser(BuildContext context) async {
    try {
      setState(() {
        loading = true;
      });
      await supabase.auth.verifyOTP(
          token: token, type: OtpType.magiclink, email: emailaddress);
      if (mounted) {
        // print('verify success');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'You are valid!',
            style:
                responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ));
        // Delay and navigate
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          loading = false;
        });
        if (isPasswordReset) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const ForgotPasswordScreen(),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const CustomerHomePage(),
            ),
          );
        }
      }
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          e.message,
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      // print(e.message);
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'your token is either invalid or expired. Please check again or resend otp :(',
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

  // 0? - use case resend otp

  Future<void> _resendOTP() async {
    final useremailaddress = emailaddress;

    try {
      await supabase.auth.signInWithOtp(
        email: useremailaddress,
        emailRedirectTo:
            kIsWeb ? null : 'io.supabase.flutter://signin-callback/',
      );
      if (mounted) {
        print('resend success');
      }
    } on PostgrestException catch (error) {
      print(error.message);
    } catch (error) {
      print(error);
    } finally {
      if (mounted) {}
    }
  }

  // init
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // use case initialize data
  Future<void> _initializeData() async {
    _acontroller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Adjust the duration as needed
    )..repeat();

    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString('userprofile');
    if (userProfileJson != null) {
      final userProfileMap = json.decode(userProfileJson);
      // To access specific fields like full name and email address:
      final userEmailAddress = userProfileMap['email'];
      setState(() {
        emailaddress = userEmailAddress;
      });
      // You can now use `emailaddress` as needed.
    } else {
      // Handle the case where no user profile data is found in SharedPreferences.
      // For example, show a snackbar.
      print('no data found');
    }
  }

  // dispose
  @override
  void dispose() {
    _acontroller.dispose();
    super.dispose();
  }

  // variables
  late AnimationController _acontroller;
  bool linkTappedResendOTP = false;
  bool loading = false;
  String token = '';
  String emailaddress = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF13CAF1),
          title: Text(
            'Verification',
            style:
                responsiveTextStyle(context, 20, Colors.black, FontWeight.bold),
          ),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
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
              padding: EdgeInsets.only(
                  left: 32,
                  right: 32,
                  top: MediaQuery.of(context).size.height * 0.01,
                  bottom: MediaQuery.of(context).size.height * 0.1),
              child: Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RotationTransition(
                          turns:
                              Tween(begin: 0.0, end: 1.0).animate(_acontroller),
                          child: Image.asset(
                            'assets/logo_t.png',
                            height: 75,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Please, enter the code sent to : ',
                              style: responsiveTextStyle(
                                  context, 18, Colors.black, null),
                            ),
                            Text(
                              emailaddress,
                              style: responsiveTextStyle(
                                  context, 18, Colors.white, null),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Pinput(
                      length: 6,
                      onCompleted: (value) {
                        setState(() {
                          token = value;
                        });
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () {
                              _verifyUser(context);
                            },
                            child: Text(
                              'Verify',
                              style: responsiveTextStyle(
                                  context, 14, Colors.black, FontWeight.bold),
                            ),
                          ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              linkTappedResendOTP = true;
                            });
                            _resendOTP();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'OTP resent. Check your email.',
                                style: responsiveTextStyle(
                                    context, 16, Colors.black, FontWeight.bold),
                              ),
                              backgroundColor: Colors.green,
                            ));
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.black54,
                          ),
                          label: Text('Resend OTP',
                              style: linkTappedResendOTP
                                  ? const TextStyle(color: Colors.black45)
                                  : null),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

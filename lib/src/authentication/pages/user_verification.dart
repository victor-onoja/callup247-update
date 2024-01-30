import 'dart:convert';
import 'package:callup247/main.dart';
import 'package:callup247/src/authentication/pages/forgot_password.dart';
import 'package:callup247/src/home/pages/customer_home.dart';
import 'package:callup247/src/profile/pages/serviceprovider_profile_creation_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../responsive_text_styles.dart';
import 'package:pinput/pinput.dart';

class VerificationScreen extends StatefulWidget {
  final bool isPasswordReset;
  final String userEmail;
  const VerificationScreen(
      {super.key, required this.isPasswordReset, required this.userEmail});

  @override
  State<VerificationScreen> createState() =>
      _VerificationScreenState(isPasswordReset, userEmail);
}

class _VerificationScreenState extends State<VerificationScreen>
    with SingleTickerProviderStateMixin {
  bool isPasswordReset;
  String userEmail;

  _VerificationScreenState(this.isPasswordReset, this.userEmail);
  // 01 - use case verify user

  Future<void> _verifyUser(BuildContext context) async {
    try {
      setState(() {
        loading = true;
      });
      await supabase.auth.verifyOTP(
          token: token, type: OtpType.magiclink, email: emailaddress);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'You are valid!',
            style:
                responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ));
        // Delay and navigate
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          loading = false;
        });
        if (isPasswordReset) {
          if (!context.mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const ForgotPasswordScreen(),
            ),
          );
        } else {
          if (serviceprovider == 'TRUE') {
            if (!context.mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    const ServiceProviderProfileCreation(),
              ),
            );
          } else {
            if (!context.mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) => const CustomerHomePage(),
              ),
            );
          }
        }
      }
    } on PostgrestException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          e.message,
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    } catch (error) {
      if (!context.mounted) return;
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

  // 02 - use case resend otp

  Future<void> _resendOTP() async {
    final useremailaddress = userEmail;

    try {
      await supabase.auth.signInWithOtp(
        email: useremailaddress,
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

  // init

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // 03 - use case initialize data

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
      final serviceProvider = userProfileMap['service_provider'];
      setState(() {
        emailaddress = userEmailAddress;
        serviceprovider = serviceProvider;
      });
      // You can now use `emailaddress` as needed.
    } else {
      //  query database for user information
      try {
        final response = await supabase
            .from('profiles')
            .select()
            .eq('email', userEmail)
            .single();

        if (mounted) {
          setState(() {
            serviceprovider = response['service_provider'];
            emailaddress = response['email'];
            userResponse = response;
          });
          if (serviceprovider == 'TRUE') {
            try {
              final response2 = await supabase
                  .from('serviceproviders_profile')
                  .select()
                  .eq('gmail_link', userEmail)
                  .single();
              if (mounted) {
                setState(() {
                  userResponse2 = response2;
                });
              }
            } catch (e) {
              //
            }

            // save customer data
            _saveProfileLocallyServiceProvider();
            _saveServiceProviderProfilelocally();
            // save serviceprovider data
          } else {
            // save customer data
            _saveProfileLocallyCustomer();
          }
        }
      } on PostgrestException catch (error) {
        if (!context.mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        final tError = error.message;

        messenger.showSnackBar(SnackBar(
          content: Text(
            'Server Error: $tError, Please try again',
            style:
                responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
          ),
          backgroundColor: Colors.red,
        ));
        print(tError);
        Navigator.pop(context);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Unexpected Error, Please check your network settings & try again',
            style:
                responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
          ),
          backgroundColor: Colors.red,
        ));
        Navigator.pop(context);
      }
    }
  }

  // 04 - use case save user information locally

  Future<void> _saveProfileLocallyCustomer() async {
    final fullname = userResponse['full_name'];
    final emailaddress = userResponse['email'];
    final country = userResponse['country'];
    final state = userResponse['state'];
    final city = userResponse['city'];
    final displaypicture = userResponse['avatar_url'];

    // Create a map to represent the user's profile data
    final userProfile = {
      'fullname': fullname,
      'email': emailaddress,
      'country': country,
      'state': state,
      'city': city,
      'displaypicture': displaypicture,
      'service_provider': 'FALSE'
    };

    // Encode the map to JSON and save it as a single string
    final jsonString = json.encode(userProfile);

    // Obtain shared preferences
    final prefs = await SharedPreferences.getInstance();

    // Set the JSON string in SharedPreferences
    await prefs.setString('userprofile', jsonString);
  }

  // 04A - use case save user information locally

  Future<void> _saveProfileLocallyServiceProvider() async {
    final fullname = userResponse['full_name'];
    final emailaddress = userResponse['email'];
    final country = userResponse['country'];
    final state = userResponse['state'];
    final city = userResponse['city'];
    final displaypicture = userResponse['avatar_url'];

    // Create a map to represent the user's profile data
    final userProfile = {
      'fullname': fullname,
      'email': emailaddress,
      'country': country,
      'state': state,
      'city': city,
      'displaypicture': displaypicture,
      'service_provider': 'TRUE'
    };

    // Encode the map to JSON and save it as a single string
    final jsonString = json.encode(userProfile);

    // Obtain shared preferences
    final prefs = await SharedPreferences.getInstance();

    // Set the JSON string in SharedPreferences
    await prefs.setString('userprofile', jsonString);
  }

  // 07 - use save service provider profile locally

  Future<void> _saveServiceProviderProfilelocally() async {
    final serviceprovided = userResponse2['service_provided'];
    final media1 = userResponse2['media_url1'];
    final media2 = userResponse2['media_url2'];
    final media3 = userResponse2['media_url3'];
    final ig = userResponse2['ig_url'];
    final x = userResponse2['x_url'];
    final fb = userResponse2['fb_url'];
    final web = userResponse2['web_link'];
    final gmail = userResponse2['gmail_link'];
    final bio = userResponse2['bio'];
    final experience = userResponse2['experience'];
    final availability = userResponse2['availability'];
    final specialoffers = userResponse2['special_offers'];

    final details = {
      'service_provided': serviceprovided,
      'media_url1': media1,
      'media_url2': media2,
      'media_url3': media3,
      'ig_url': ig,
      'x_url': x,
      'fb_url': fb,
      'web_link': web,
      'gmail_link': gmail,
      'bio': bio,
      'experience': experience,
      'availability': availability,
      'special_offers': specialoffers,
    };

    final jsonString = json.encode(details);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('serviceproviderprofile', jsonString);
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
  String? emailaddress;
  String serviceprovider = '';
  dynamic userResponse = {};
  dynamic userResponse2 = {};

// build method

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
                padding: EdgeInsets.only(
                    left: 32,
                    right: 32,
                    top: MediaQuery.sizeOf(context).height * 0.01,
                    bottom: MediaQuery.sizeOf(context).height * 0.1),
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RotationTransition(
                            turns: Tween(begin: 0.0, end: 1.0)
                                .animate(_acontroller),
                            child: Image.asset(
                              'assets/logo_t.png',
                              height: 75,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
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
                                emailaddress ?? userEmail,
                                style: responsiveTextStyle(
                                    context, 18, Colors.white, null),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
                      Pinput(
                        length: 6,
                        onCompleted: (value) {
                          setState(() {
                            token = value;
                          });
                        },
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
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
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                linkTappedResendOTP = true;
                              });
                              _resendOTP();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  'OTP resent. Check your email.',
                                  style: responsiveTextStyle(context, 16,
                                      Colors.black, FontWeight.bold),
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
          ),
        ));
  }
}

import 'dart:convert';
import 'package:callup247/main.dart';
import 'package:callup247/src/onboarding/pages/onboarding_choice_screen.dart';
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
  bool rememberme = false;

  // build method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(
              image: DecorationImage(
            image: const AssetImage('assets/loginbg.png'),
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          )),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/loginlogo.png'),
                  // email address

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: responsiveTextStyle(context, 14,
                            const Color(0xFFFFFFFF), FontWeight.w500),
                      ),
                      SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.008),
                      TextFormField(
                        controller: _emailaddressController,
                        cursorColor: const Color(0xFFA6A6A6),
                        keyboardType: TextInputType.emailAddress,
                        style: responsiveTextStyle(context, 16,
                            const Color(0xFFA6A6A6), FontWeight.w500),
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(25, 54, 222,
                                  255), // Background color of the square
                              borderRadius: BorderRadius.circular(
                                  8.0), // Border radius of the square
                            ),
                            child: const Icon(
                              Icons.email,
                              color: Color(0xFF36DDFF),
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(
                              0xFFE2E2E5), // Background color of the text field
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          hintText: 'Enter your email here',
                        ),
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
                    ],
                  ),
                  // Password

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: responsiveTextStyle(context, 14,
                            const Color(0xFFFFFFFF), FontWeight.w500),
                      ),
                      SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.008),
                      TextFormField(
                        controller: _passwordController,
                        cursorColor: const Color(0xFFA6A6A6),
                        style: responsiveTextStyle(context, 16,
                            const Color(0xFFA6A6A6), FontWeight.w500),
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(25, 54, 222,
                                  255), // Background color of the square
                              borderRadius: BorderRadius.circular(
                                  8.0), // Border radius of the square
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: Color(0xFF36DDFF),
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(
                              0xFFE2E2E5), // Background color of the text field
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          hintText: 'Password',
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
                              color: const Color(0xFFA6A6A6),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // forgot password
                          TextButton(
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
                              child: Text(
                                'Forgot Password ?',
                                style: responsiveTextStyle(context, 10,
                                    const Color(0xFF36DDFF), FontWeight.w600),
                              )),
                          Row(
                            children: [
                              Text(
                                'Remember Me',
                                style: responsiveTextStyle(context, 10,
                                    const Color(0xFFF3F3F3), FontWeight.w500),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Switch(
                                value: rememberme,
                                onChanged: (_) => setState(() {
                                  rememberme = !rememberme;
                                }),
                                activeColor: const Color(0xFF44C5E1),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),

                  // log in button

                  loading
                      ? const CircularProgressIndicator()
                      : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF36DCFF)),
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
                                  if (userEmail !=
                                          _emailaddressController.text &&
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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: Text(
                                    'Sign In',
                                    style: responsiveTextStyle(
                                        context,
                                        18,
                                        const Color(0xFF000000),
                                        FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF36DCFF)),
                                onPressed: () {},
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Icon(
                                    Icons.fingerprint,
                                    color: Color(0xFF000000),
                                    size: 30,
                                  ),
                                ))
                          ],
                        ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Don\'t have an account ?',
                        style: responsiveTextStyle(
                            context,
                            14,
                            const Color.fromARGB(190, 255, 255, 255),
                            FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const OnboardingChoiceScreen()));
                        },
                        child: Text(
                          'Register here',
                          style: responsiveTextStyle(context, 14,
                              const Color(0xFF36DCFF), FontWeight.w700),
                        ),
                      )
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

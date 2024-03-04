import 'dart:convert';
import 'package:callup247/main.dart';
import 'package:callup247/src/authentication/pages/user_verification.dart';
import 'package:callup247/src/responsive_text_styles.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class ServiceProviderSignUpScreen extends StatefulWidget {
  const ServiceProviderSignUpScreen({super.key});

  @override
  State<ServiceProviderSignUpScreen> createState() =>
      _ServiceProviderSignUpScreenState();
}

class _ServiceProviderSignUpScreenState
    extends State<ServiceProviderSignUpScreen> {
  // 01 - use case pick image

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // 02 - use case upload image

  Future<void> _uploadImage() async {
    final filename = _fullnameController.text.trim();
    try {
      await supabase.storage.from('avatars').upload(
            filename,
            _image!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      if (mounted) {}
    } on PostgrestException catch (error) {
      //
    } catch (error) {
      //
    }
  }

  // 03 - use case create user

  Future<void> _createUser() async {
    final emailaddress = _emailaddressController.text.trim();
    final password = _passwordController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        loading = true;
      });
      await supabase.auth.signUp(password: password, email: emailaddress);
      if (mounted) {}
    } on PostgrestException catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(
          'Server Error, Please try again in a bit :)',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      setState(() {
        loading = false;
      });
    } catch (error) {
      setState(() {
        loading = false;
      });
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(
          'Unexpected Error, Please try again in a bit :)',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {}
    }
  }

  // 04 - use case signin user

  Future<void> _signInUser() async {
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

  // 05 - use case update profiles table

  Future<void> _updateProfile() async {
    final fullname = _fullnameController.text.trim();
    final email = _emailaddressController.text.trim();
    final country = _countryValue.text;
    final state = _stateValue.text;
    final city = _cityValue.text;
    final displaypicture = supabase.storage
        .from('avatars')
        .getPublicUrl(_fullnameController.text.trim());
    final user = supabase.auth.currentUser;
    final details = {
      'id': user!.id,
      'updated_at': DateTime.now().toIso8601String(),
      'full_name': fullname,
      'email': email,
      'country': country,
      'state': state,
      'city': city,
      'avatar_url': displaypicture,
      'service_provider': 'TRUE'
    };
    final messenger = ScaffoldMessenger.of(context);
    try {
      await supabase.from('profiles').upsert(details);
      if (mounted) {
        messenger.showSnackBar(SnackBar(
          content: Text(
            'Welcome to callup247!!',
            style:
                responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ));
      }
    } on PostgrestException catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(
          'Server Error, Please try again in a bit :)',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      setState(() {
        loading = false;
      });
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(
          'Unexpected Error, Please try again in a bit :)',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      setState(() {
        loading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // 06 - use case save user information locally

  Future<void> _saveProfileLocally() async {
    final fullname = _fullnameController.text.trim();
    final emailaddress = _emailaddressController.text.trim();
    final country = _countryValue.text;
    final state = _stateValue.text;
    final city = _cityValue.text;
    final displaypicture = supabase.storage
        .from('avatars')
        .getPublicUrl(_fullnameController.text.trim());

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

  // 07 - use case check network

  Future<bool> _checkInternetConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  //  08 - use case signup logic

  Future<void> _performSignup() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Run _createUser and wait for it to finish
      await _createUser();

      // Only run _uploadImage if _createUser has finished successfully
      if (_image != null) {
        await _uploadImage();
      }

      // Update profile locally and remotely
      await _updateProfile();
      await _saveProfileLocally();
      await _signInUser();
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(
          'An error occurred. Please try again later.',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  // 09 - variables

  bool isPasswordVisible = false;
  bool isPasswordConfirmVisible = false;
  final _countryValue = TextEditingController();
  final _stateValue = TextEditingController();
  final _cityValue = TextEditingController();
  final _fullnameController = TextEditingController();
  final _emailaddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  File? _image;
  var loading = false;
  final _formKey = GlobalKey<FormState>();
  bool isPasswordReset = false;
  bool _isChecked = false;

// 10 - dispose

  @override
  void dispose() {
    _emailaddressController.dispose();
    _fullnameController.dispose();
    _passwordController.dispose();
    _countryValue.dispose();
    _stateValue.dispose();
    _cityValue.dispose();
    super.dispose();
  }

  // 11 - build method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(41, 54, 222, 255),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'User Type',
              style: responsiveTextStyle(
                  context, 14, const Color(0xFF6E6B6B), FontWeight.w500),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: 2,
              height: 25,
              color: const Color(0xFFFFFFFF),
            ),
            Text(
              'Service Provider',
              style: responsiveTextStyle(
                  context, 14, const Color(0xFF6E6B6B), FontWeight.w500),
            ),
          ],
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF6E6B6B)),
      ),
      body: Stack(children: [
        Positioned(
          left: 2,
          bottom: 2,
          child: Image.asset(
            'assets/resetpasset.png',
            fit: BoxFit.contain,
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // full name

                      TextFormField(
                        controller: _fullnameController,
                        cursorColor: const Color(0xFFA6A6A6),
                        textCapitalization: TextCapitalization.words,
                        style: responsiveTextStyle(context, 14,
                            const Color(0xFFA6A6A6), FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: 'First & Last Name',
                          labelStyle: responsiveTextStyle(context, 14,
                              const Color(0xFFA6A6A6), FontWeight.w500),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 1.5),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 1.5),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your first and last name';
                          } else if (value.split(' ').length < 2) {
                            return 'Please enter both your first and last name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.02),

                      // email address

                      TextFormField(
                        controller: _emailaddressController,
                        cursorColor: const Color(0xFFA6A6A6),
                        keyboardType: TextInputType.emailAddress,
                        style: responsiveTextStyle(context, 14,
                            const Color(0xFFA6A6A6), FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: responsiveTextStyle(context, 14,
                              const Color(0xFFA6A6A6), FontWeight.w500),
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
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 1.5),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 1.5),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
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
                      SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.02),

                      // Country Picker

                      CountryStateCityPicker(
                          textFieldDecoration: InputDecoration(
                            hintStyle: responsiveTextStyle(context, 14,
                                const Color(0xFFA6A6A6), FontWeight.w500),
                            isDense: true,
                            suffixIcon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFFE2E2E5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFFE2E2E5), width: 1.5),
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFFE2E2E5), width: 1.5),
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                          country: _countryValue,
                          state: _stateValue,
                          city: _cityValue),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '-- this information is used to share your location with customers :)',
                            style: responsiveTextStyle(
                                context, 8, const Color(0xFFA6A6A6), null),
                          ),
                        ],
                      ),

                      SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.02),

                      // Password

                      TextFormField(
                        controller: _passwordController,
                        cursorColor: const Color(0xFFA6A6A6),
                        style: responsiveTextStyle(context, 14,
                            const Color(0xFFA6A6A6), FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: responsiveTextStyle(context, 14,
                              const Color(0xFFA6A6A6), FontWeight.w500),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 1.5),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 1.5),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
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
                              color: const Color(0xFFE2E2E5),
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
                          // final uppercaseCriteria = RegExp(r'[A-Z]');
                          // final lowercaseCriteria = RegExp(r'[a-z]');
                          // final digitCriteria = RegExp(r'[0-9]');
                          // final specialCharCriteria =
                          //     RegExp(r'[!@#$%^&*(),.?":{}|<>]');
                          if (value.length < lengthCriteria) {
                            return 'Password must be at least $lengthCriteria characters long';
                          }
                          // if (!uppercaseCriteria.hasMatch(value) ||
                          //     !lowercaseCriteria.hasMatch(value) ||
                          //     !digitCriteria.hasMatch(value) ||
                          //     !specialCharCriteria.hasMatch(value)) {
                          //   return 'Password must include uppercase, lowercase, digit, and special characters';
                          // }
                          return null;
                        },
                      ),
                      SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.02),
                      // Confirm Password

                      TextFormField(
                        controller: _confirmpasswordController,
                        cursorColor: const Color(0xFFA6A6A6),
                        style: responsiveTextStyle(context, 14,
                            const Color(0xFFA6A6A6), FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: responsiveTextStyle(context, 14,
                              const Color(0xFFA6A6A6), FontWeight.w500),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 1.5),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 1.5),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                isPasswordConfirmVisible =
                                    !isPasswordConfirmVisible;
                              });
                            },
                            child: Icon(
                              isPasswordConfirmVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFFE2E2E5),
                            ),
                          ),
                        ),
                        obscureText: !isPasswordConfirmVisible,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please re-type your password';
                          }

                          if (value != _passwordController.text) {
                            return 'passwords must match';
                          }

                          return null;
                        },
                      ),
                      SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.01),

                      // display picture

                      GestureDetector(
                        onTap: () {
                          _pickImage();
                        },
                        child: Column(
                          children: <Widget>[
                            if (_image != null)
                              Image.file(
                                _image!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              )
                            else
                              const Icon(
                                Icons.camera_alt,
                                size: 100,
                                color: Color(0xFFA6A6A6),
                              ),
                            Text(
                              'Add a display pictue :)',
                              style: responsiveTextStyle(
                                  context, 14, const Color(0xFFA6A6A6), null),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.02),

                      // todo: add terms and conditions document, agreement

                      Row(
                        children: [
                          Checkbox(
                            value: _isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                _isChecked = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF36DDFF),
                          ),
                          Flexible(
                            child: Text(
                              'I have read and agree to the terms and conditions and privacy policy',
                              style: responsiveTextStyle(context, 14,
                                  const Color(0xFF8C8585), FontWeight.w500),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.02),

                      // sign up button

                      loading
                          ? const CircularProgressIndicator()
                          : Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF36DDFF)),
                                    onPressed: () async {
                                      final messenger =
                                          ScaffoldMessenger.of(context);
                                      try {
                                        // Check network connectivity
                                        bool isConnected =
                                            await _checkInternetConnectivity();
                                        if (!isConnected) {
                                          if (!context.mounted) return;
                                          // Show a snackbar for no network
                                          messenger.showSnackBar(SnackBar(
                                            content: Text(
                                              'No internet connection. Please check your network settings.',
                                              style: responsiveTextStyle(
                                                  context,
                                                  16,
                                                  Colors.black,
                                                  FontWeight.bold),
                                            ),
                                            backgroundColor: Colors.red,
                                          ));
                                          return; // Exit the function if there's no network
                                        }

                                        // Validate form
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          return; // Exit the function if form validation fails
                                        }

                                        if (!_isChecked) {
                                          if (!context.mounted) return;
                                          // Show a snackbar for no network
                                          messenger.showSnackBar(SnackBar(
                                            content: Text(
                                              'Please accept the Terms and Conditions.',
                                              style: responsiveTextStyle(
                                                  context,
                                                  16,
                                                  Colors.black,
                                                  FontWeight.bold),
                                            ),
                                            backgroundColor: Colors.red,
                                          ));
                                          return; // Exit the function if there's no network
                                        }

                                        if (_image == null) {
                                          if (!context.mounted) return;
                                          messenger.showSnackBar(SnackBar(
                                            content: Text(
                                              'Please add a display picture :)',
                                              style: responsiveTextStyle(
                                                  context,
                                                  16,
                                                  Colors.black,
                                                  FontWeight.bold),
                                            ),
                                            backgroundColor: Colors.red,
                                          ));
                                          return;
                                        }

                                        setState(() {
                                          loading = true;
                                        });
                                        await _performSignup().then((_) {
                                          if (!context.mounted) return;
                                          messenger.showSnackBar(SnackBar(
                                            content: Text(
                                              'Welcome to callup247!!',
                                              style: responsiveTextStyle(
                                                  context,
                                                  16,
                                                  Colors.black,
                                                  FontWeight.bold),
                                            ),
                                            backgroundColor: Colors.green,
                                          ));

                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  VerificationScreen(
                                                isPasswordReset:
                                                    isPasswordReset,
                                                userEmail:
                                                    _emailaddressController.text
                                                        .trim(),
                                              ),
                                            ),
                                          );
                                        });
                                      } catch (error) {
                                        if (!context.mounted) return;
                                        messenger.showSnackBar(SnackBar(
                                          content: Text(
                                            'An error occurred. Please try again later.',
                                            style: responsiveTextStyle(
                                                context,
                                                16,
                                                Colors.black,
                                                FontWeight.bold),
                                          ),
                                          backgroundColor: Colors.red,
                                        ));
                                      } finally {
                                        setState(() {
                                          loading = false;
                                        });
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0),
                                      child: Text(
                                        'Sign Up',
                                        style: responsiveTextStyle(
                                            context,
                                            14,
                                            const Color(0xFF140202),
                                            FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

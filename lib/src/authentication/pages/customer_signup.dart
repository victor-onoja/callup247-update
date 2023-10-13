import 'package:callup247/main.dart';
import 'package:callup247/src/responsive_text_styles.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerSignUpScreen extends StatefulWidget {
  const CustomerSignUpScreen({super.key});

  @override
  State<CustomerSignUpScreen> createState() => _CustomerSignUpScreenState();
}

class _CustomerSignUpScreenState extends State<CustomerSignUpScreen> {
  // use case pick image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // use case upload image
  Future<void> _uploadImage() async {
    final filename = _fullnameController.text;
    try {
      await supabase.storage.from('avatars').upload(
            filename,
            _image!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      if (mounted) {
        print('img uploaded');
      }
    } on PostgrestException catch (error) {
      print('postgres error: ${error.message}');
    } catch (error) {
      print('Unexpected error');
    }
  }

  // use case sign up
  Future<void> _signup(BuildContext context) async {
    setState(() {
      loading = true;
    });
    final fullname = _fullnameController.text.trim();
    final phonenumber = _phonenumberController.text.trim();
    final emailaddress = _emailaddressController.text.trim();
    final country = countryValue;
    final state = stateValue;
    final city = cityValue;
    final homeaddress = _homeadressController.text.trim();
    final displaypicture =
        supabase.storage.from('avatars').getPublicUrl(_fullnameController.text);

    final details = {
      'full_name': fullname,
      'phone_number': phonenumber,
      'email_address': emailaddress,
      'country': country,
      'state': state,
      'city': city,
      'home_address': homeaddress,
      'display_picture': displaypicture
    };

    try {
      print(0);
      await supabase.from('customers').insert(details);
      if (mounted) {
        print('1');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Welcome to callup247'),
          backgroundColor: Colors.greenAccent,
        ));
      }
    } on PostgrestException catch (error) {
      print(error.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 5),
        content: Text(error.message),
        backgroundColor: Colors.red,
      ));
    } catch (error) {
      print('3');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Unexpected Error Occured'),
        backgroundColor: Colors.red,
      ));
    } finally {
      print(4);
      if (mounted) {
        print('5');
        setState(() {
          loading = false;
        });
      }
    }
  }

  // variables
  bool isPasswordVisible = false;
  String? countryValue = "";
  String? stateValue = "";
  String? cityValue = "";
  File? _image;
  final _fullnameController = TextEditingController();
  final _phonenumberController = TextEditingController();
  final _emailaddressController = TextEditingController();
  final _homeadressController = TextEditingController();
  var loading = false;
  final _formKey = GlobalKey<FormState>();

// dispose
  @override
  void dispose() {
    _emailaddressController.dispose();
    _fullnameController.dispose();
    _homeadressController.dispose();
    _phonenumberController.dispose();
    super.dispose();
  }

  // build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF13CAF1),
        title: Text(
          'Sign Up',
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
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // full name
                  TextFormField(
                    controller: _fullnameController,
                    cursorColor: Colors.white,
                    textCapitalization: TextCapitalization.words,
                    style: responsiveTextStyle(context, 16, Colors.white, null),
                    decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: responsiveTextStyle(
                            context, 14, Colors.black87, null),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black87))),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  // Phone Number
                  TextFormField(
                    controller: _phonenumberController,
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.phone,
                    style: responsiveTextStyle(context, 16, Colors.white, null),
                    decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: responsiveTextStyle(
                            context, 14, Colors.black87, null),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black87))),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      // Phone number regex pattern (allowing only digits, optional '+' at the beginning)
                      const phonePattern = r'^\+?[0-9]+$';
                      final regExp = RegExp(phonePattern);

                      if (!regExp.hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                      // You can add more specific validation logic here if needed.
                      return null;
                    },
                  ),
                  // email address
                  TextFormField(
                    controller: _emailaddressController,
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.emailAddress,
                    style: responsiveTextStyle(context, 16, Colors.white, null),
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  // Country Picker
                  CSCPicker(
                    flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                    dropdownDecoration: BoxDecoration(
                        color: const Color(0xFF13CAF1),
                        borderRadius: BorderRadius.circular(6)),
                    disabledDropdownDecoration: BoxDecoration(
                        color: const Color(0xFF039fdc),
                        borderRadius: BorderRadius.circular(6)),
                    selectedItemStyle:
                        responsiveTextStyle(context, 14, Colors.black, null),
                    onCountryChanged: (value) {
                      // Handle the selected country value here.
                      setState(() {
                        // Store the selected country value in a variable.
                        countryValue = value;
                      });
                    },
                    onStateChanged: (value) {
                      // Handle the selected state value here.
                      setState(() {
                        // Store the selected state value in a variable.
                        stateValue = value;
                      });
                    },
                    onCityChanged: (value) {
                      // Handle the selected city value here.
                      setState(() {
                        // Store the selected city value in a variable.
                        cityValue = value;
                      });
                    },
                  ),
                  // home address
                  TextFormField(
                    controller: _homeadressController,
                    cursorColor: Colors.white,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.streetAddress,
                    style: responsiveTextStyle(context, 16, Colors.white, null),
                    decoration: InputDecoration(
                        labelText: 'Home Address',
                        labelStyle: responsiveTextStyle(
                            context, 14, Colors.black87, null),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black87))),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your home address';
                      }
                      return null; // Return null to indicate a valid input.
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
                            color: Colors.black54,
                          ),
                        Text(
                          'Add a display pictue :)',
                          style: responsiveTextStyle(
                              context, 14, Colors.black, null),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF039fdc)),
                          onPressed: () {
                            // Add your sign-up logic here.
                            if (_formKey.currentState!.validate()) {
                              _uploadImage();
                              _signup(context);
                            }
                          },
                          child: Text(
                            'Sign Up',
                            style: responsiveTextStyle(
                                context, 14, Colors.black, FontWeight.bold),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

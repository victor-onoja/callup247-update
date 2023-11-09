import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../main.dart';
import '../../responsive_text_styles.dart';

class EditServiceProviderProfile extends StatefulWidget {
  const EditServiceProviderProfile({super.key});

  @override
  State<EditServiceProviderProfile> createState() =>
      _EditServiceProviderProfileState();
}

class _EditServiceProviderProfileState
    extends State<EditServiceProviderProfile> {
  // init

  @override
  void initState() {
    super.initState();
    _initializeData().then((_) {
      _instagramController.text = iglink;
      _xController.text = xlink;
      _facebookController.text = fblink;
      _websiteController.text = weblink;
      _bioController.text = bio;
      _experienceController.text = experience;
      _availabilityController.text = availability;
      _specialOffersController.text = specialoffers;
      _homeServiceController.text = homeservice;
      _languagesSpokenController.text = languagesspoken;
    });
  }

  // use case initialize data

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString('userprofile');
    final serviceProviderProfileJson =
        prefs.getString('serviceproviderprofile');
    if (userProfileJson != null) {
      final userProfileMap = json.decode(userProfileJson);
      final fullName = userProfileMap['fullname'];
      setState(() {
        fullname = fullName;
      });
    }
    if (serviceProviderProfileJson != null) {
      final serviceProviderMap = json.decode(serviceProviderProfileJson);

      final userMedia1 = serviceProviderMap['media_url1'];
      final userMedia2 = serviceProviderMap['media_url2'];
      final userMedia3 = serviceProviderMap['media_url3'];
      final userMedia4 = serviceProviderMap['media_url4'];
      final userMedia5 = serviceProviderMap['media_url5'];

      final useriglink = serviceProviderMap['ig_url'];
      final userxlink = serviceProviderMap['x_url'];
      final userfblink = serviceProviderMap['fb_url'];
      final userweblink = serviceProviderMap['web_link'];

      final userExperience = serviceProviderMap['experience'];
      final userBio = serviceProviderMap['bio'];
      final userAvailability = serviceProviderMap['availability'];
      final userSpecialOffers = serviceProviderMap['special_offers'];
      final userhomeService = serviceProviderMap['home_service'];
      final userLanguagesSpoken = serviceProviderMap['languages_spoken'];

      setState(() {
        media1 = userMedia1;
        media2 = userMedia2;
        media3 = userMedia3;
        media4 = userMedia4;
        media5 = userMedia5;
        iglink = useriglink;
        xlink = userxlink;
        fblink = userfblink;
        weblink = userweblink;
        bio = userBio;
        experience = userExperience;
        availability = userAvailability;
        specialoffers = userSpecialOffers;
        homeservice = userhomeService;
        languagesspoken = userLanguagesSpoken;
      });
    } else {}
  }

  // 05 - use case check valid image

  Future<bool> _checkImageValidity(String img) async {
    try {
      final response = await http.get(Uri.parse(img));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // use case display image

  Future<ImageProvider?> _imageProvider(String img) async {
    // Check if the image URL is valid
    bool isImageValid = await _checkImageValidity(img);

    if (isImageValid) {
      // Image URL is valid, return the NetworkImage
      return NetworkImage(img);
    } else {
      // if (img == pfp) {
      //   // Image URL is not valid, return a placeholder image using AssetImage
      //   return const AssetImage('assets/guest_dp.png');
      // } else {
      //   return null;
      // }
    }
    return null;
  }

  // use case display media

  FutureBuilder<ImageProvider<Object>?> _buildImageWidget(String imageUrl) {
    return FutureBuilder<ImageProvider<Object>?>(
      future: _imageProvider(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image(
                image: snapshot.data!,
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              ),
            );
          } else {
            return const Icon(
              Icons.camera_alt,
              size: 250,
            );
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  // 01 - use case pick image1

  Future<void> _pickImage1() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image1 = File(pickedFile.path);
        // print(_image1);
      });
    }
  }

  // 01 - use case pick image1

  Future<void> _pickImage2() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image2 = File(pickedFile.path);
        // print(_image2);
      });
    }
  }

  // 01 - use case pick image1

  Future<void> _pickImage3() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image3 = File(pickedFile.path);
        // print(_image3);
      });
    }
  }

  // 01 - use case pick image1

  Future<void> _pickImage4() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image4 = File(pickedFile.path);
        // print(_image4);
      });
    }
  }

  // 01 - use case pick image1

  Future<void> _pickImage5() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image5 = File(pickedFile.path);
        // print(_image5);
      });
    }
  }

  // 05 - use case check network

  Future<bool> _checkInternetConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 02 - use case upload image

  Future<void> _uploadImage1() async {
    bool isImage1Valid = await _checkImageValidity(media1);
    if (isImage1Valid) {
      try {
        // print('upload image start');
        await supabase.storage.from('media1').update(
              fullname,
              _image1!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: true),
            );
        if (mounted) {
          // print('img uploaded');
        }
      } on PostgrestException catch (error) {
        print('postgres error media 1: ${error.message}');
      } catch (error) {
        print('media1 ${error}');
      }
    } else {
      try {
        // print('upload image start');
        await supabase.storage.from('media1').upload(
              fullname,
              _image1!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );
        if (mounted) {
          // print('img uploaded');
        }
      } on PostgrestException catch (error) {
        print('postgres error media 1: ${error.message}');
      } catch (error) {
        print('media1 ${error}');
      }
    }
  }

  // 02 - use case upload image

  Future<void> _uploadImage2() async {
    bool isImage2Valid = await _checkImageValidity(media2);
    if (isImage2Valid) {
      try {
        // print('upload image start');
        await supabase.storage.from('media2').update(
              fullname,
              _image2!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: true),
            );
        if (mounted) {
          // print('img uploaded');
        }
      } on PostgrestException catch (error) {
        print('postgres error media 2: ${error.message}');
      } catch (error) {
        print('media2 ${error}');
      }
    } else {
      try {
        // print('upload image start');
        await supabase.storage.from('media2').upload(
              fullname,
              _image2!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );
        if (mounted) {
          // print('img uploaded');
        }
      } on PostgrestException catch (error) {
        print('postgres error media 2: ${error.message}');
      } catch (error) {
        print('media2 ${error}');
      }
    }
  }

  // 02 - use case upload image

  Future<void> _uploadImage3() async {
    bool isImage3Valid = await _checkImageValidity(media3);
    if (isImage3Valid) {
      try {
        // print('upload image start');
        await supabase.storage.from('media3').update(
              fullname,
              _image3!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: true),
            );
        if (mounted) {
          // print('img uploaded');
        }
      } on PostgrestException catch (error) {
        print('postgres error media 3: ${error.message}');
      } catch (error) {
        print('media3 ${error}');
      }
    } else {
      try {
        // print('upload image start');
        await supabase.storage.from('media3').upload(
              fullname,
              _image3!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );
        if (mounted) {
          // print('img uploaded');
        }
      } on PostgrestException catch (error) {
        print('postgres error media 3: ${error.message}');
      } catch (error) {
        print('media3 ${error}');
      }
    }
  }

  // 02 - use case upload image

  Future<void> _uploadImage4() async {
    bool isImage4Valid = await _checkImageValidity(media4);
    if (isImage4Valid) {
      try {
        // print('upload image start');
        await supabase.storage.from('media4').update(
              fullname,
              _image4!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: true),
            );
        if (mounted) {
          // print('img uploaded');
        }
      } on PostgrestException catch (error) {
        print('postgres error media 4: ${error.message}');
      } catch (error) {
        print('media4 ${error}');
      }
    } else {
      try {
        // print('upload image start');
        await supabase.storage.from('media4').upload(
              fullname,
              _image4!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );
        if (mounted) {
          // print('img uploaded');
        }
      } on PostgrestException catch (error) {
        print('postgres error media 4: ${error.message}');
      } catch (error) {
        print('media4 ${error}');
      }
    }
  }

  // 02 - use case upload image

  Future<void> _uploadImage5() async {
    bool isImage5Valid = await _checkImageValidity(media5);
    if (isImage5Valid) {
      try {
        // print('upload image start');
        await supabase.storage.from('media5').update(
              fullname,
              _image5!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: true),
            );
        if (mounted) {
          // print('img uploaded');
        }
      } on PostgrestException catch (error) {
        print('postgres error media 5: ${error.message}');
      } catch (error) {
        print('media5 ${error}');
      }
    } else {
      try {
        // print('upload image start');
        await supabase.storage.from('media5').upload(
              fullname,
              _image5!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );
        if (mounted) {
          // print('img uploaded');
        }
      } on PostgrestException catch (error) {
        print('postgres error media 5: ${error.message}');
      } catch (error) {
        print('media5 ${error}');
      }
    }
  }

  // create service provider profile

  Future<void> _updateServiceProviderProfile() async {
    final ig = _instagramController.text.trim();
    final x = _xController.text.trim();
    final fb = _facebookController.text.trim();
    final web = _websiteController.text.trim();
    final bio = _bioController.text.trim();
    final experience = _experienceController.text.trim();
    final availability = _availabilityController.text.trim();
    final specialoffers = _specialOffersController.text.trim();
    final homeservice = _homeServiceController.text.trim();
    final languagesspoken = _languagesSpokenController.text.trim();
    final user = supabase.auth.currentUser;

    final details = {
      'id': user!.id,
      'created_at': DateTime.now().toIso8601String(),
      'ig_url': ig,
      'x_url': x,
      'fb_url': fb,
      'web_link': web,
      'bio': bio,
      'experience': experience,
      'availability': availability,
      'special_offers': specialoffers,
      'home_service': homeservice,
      'languages_spoken': languagesspoken
    };

    try {
      await supabase.from('serviceproviders_profile').upsert(details);
      if (mounted) {
        // print('update profile successful');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Profile Updated Successfully!!',
            style:
                responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ));
      }
    } on PostgrestException catch (error) {
      print(error.message + 'update serviceproviderprofile');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
      print('serviceproviderprofile ${error}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
        print('update profile finished');
        setState(() {
          loading = false;
        });
      }
    }
  }

  // create service provider profile

  Future<void> _saveServiceProviderProfilelocally() async {
    final prefs = await SharedPreferences.getInstance();
    final serviceProviderJson = prefs.getString('serviceproviderprofile');
    if (serviceProviderJson != null) {
      final serviceProviderMap = json.decode(serviceProviderJson);
      serviceProviderMap['ig_url'] = _instagramController.text.trim();
      serviceProviderMap['x_url'] = _xController.text.trim();
      serviceProviderMap['fb_url'] = _facebookController.text.trim();
      serviceProviderMap['web_link'] = _websiteController.text.trim();
      serviceProviderMap['bio'] = _bioController.text.trim();
      serviceProviderMap['experience'] = _experienceController.text.trim();
      serviceProviderMap['availability'] = _availabilityController.text.trim();
      serviceProviderMap['special_offers'] =
          _specialOffersController.text.trim();
      serviceProviderMap['home_service'] = _homeServiceController.text.trim();
      serviceProviderMap['languages_spoken'] =
          _languagesSpokenController.text.trim();

      final updatedServiceProviderJson = json.encode(serviceProviderMap);

      await prefs.setString(
          'serviceproviderprofile', updatedServiceProviderJson);
    } else {}
  }

  // variables

  String media1 = '';
  String media2 = '';
  String media3 = '';
  String media4 = '';
  String media5 = '';
  File? _image1;
  File? _image2;
  File? _image3;
  File? _image4;
  File? _image5;
  String iglink = '';
  String xlink = '';
  String fblink = '';
  String weblink = '';
  String bio = '';
  String experience = '';
  String homeservice = '';
  String availability = '';
  String languagesspoken = '';
  String specialoffers = '';
  String fullname = '';
  var loading = false;
  late final TextEditingController _instagramController =
      TextEditingController();
  late final TextEditingController _xController = TextEditingController();
  late final TextEditingController _facebookController =
      TextEditingController();
  late final TextEditingController _websiteController = TextEditingController();
  late final TextEditingController _bioController = TextEditingController();
  late final TextEditingController _experienceController =
      TextEditingController();
  late final TextEditingController _availabilityController =
      TextEditingController();
  late final TextEditingController _specialOffersController =
      TextEditingController();
  late final TextEditingController _homeServiceController =
      TextEditingController();
  late final TextEditingController _languagesSpokenController =
      TextEditingController();

  // dispose

  @override
  void dispose() {
    _instagramController.dispose();
    _xController.dispose();
    _facebookController.dispose();
    _websiteController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _availabilityController.dispose();
    _specialOffersController.dispose();
    _homeServiceController.dispose();
    _languagesSpokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF13CAF1),
        title: Text(
          'Edit your Profile',
          style:
              responsiveTextStyle(context, 20, Colors.black, FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // edit media

                Text(
                  'Edit your Media :',
                  style: responsiveTextStyle(context, 20, Colors.black, null),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // image 1
                      GestureDetector(
                          onTap: () {
                            _pickImage1();
                          },
                          child: Column(
                            children: <Widget>[
                              if (_image1 != null)
                                Image.file(
                                  _image1!,
                                  height: 250,
                                  width: 250,
                                  fit: BoxFit.cover,
                                )
                              else
                                _buildImageWidget(media1),
                            ],
                          )),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.025),
                      // image 2
                      GestureDetector(
                          onTap: () {
                            _pickImage2();
                          },
                          child: Column(
                            children: <Widget>[
                              if (_image2 != null)
                                Image.file(
                                  _image2!,
                                  height: 250,
                                  width: 250,
                                  fit: BoxFit.cover,
                                )
                              else
                                _buildImageWidget(media2),
                            ],
                          )),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.025),
                      // image 3
                      GestureDetector(
                          onTap: () {
                            _pickImage3();
                          },
                          child: Column(
                            children: <Widget>[
                              if (_image3 != null)
                                Image.file(
                                  _image3!,
                                  height: 250,
                                  width: 250,
                                  fit: BoxFit.cover,
                                )
                              else
                                _buildImageWidget(media3),
                            ],
                          )),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.025),
                      // image 4
                      GestureDetector(
                          onTap: () {
                            _pickImage4();
                          },
                          child: Column(
                            children: <Widget>[
                              if (_image4 != null)
                                Image.file(
                                  _image4!,
                                  height: 250,
                                  width: 250,
                                  fit: BoxFit.cover,
                                )
                              else
                                _buildImageWidget(media4),
                            ],
                          )),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.025),
                      // image 5
                      GestureDetector(
                          onTap: () {
                            _pickImage5();
                          },
                          child: Column(
                            children: <Widget>[
                              if (_image5 != null)
                                Image.file(
                                  _image5!,
                                  height: 250,
                                  width: 250,
                                  fit: BoxFit.cover,
                                )
                              else
                                _buildImageWidget(media5),
                            ],
                          ))
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.06),

                // edit social links

                Text(
                  'Edit Your Social links :',
                  style: responsiveTextStyle(context, 20, Colors.black, null),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/ig-icon.png',
                          width: 25,
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        Text('Instagram :',
                            style: responsiveTextStyle(
                                context, 16, Colors.black, null)),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        Flexible(
                          child: TextField(
                            controller: _instagramController,
                            style: responsiveTextStyle(
                                context, 16, Colors.white, null),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/x-icon.webp',
                          width: 25,
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        Text('X :',
                            style: responsiveTextStyle(
                                context, 16, Colors.black, null)),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        Flexible(
                          child: TextField(
                            controller: _xController,
                            style: responsiveTextStyle(
                                context, 16, Colors.white, null),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/facebook.png',
                          width: 25,
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        Text('Facebook :',
                            style: responsiveTextStyle(
                                context, 16, Colors.black, null)),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        Flexible(
                          child: TextField(
                            controller: _facebookController,
                            style: responsiveTextStyle(
                                context, 16, Colors.white, null),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/web-icon.png',
                          width: 25,
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        Text('Website :',
                            style: responsiveTextStyle(
                                context, 16, Colors.black, null)),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        Flexible(
                          child: TextField(
                            controller: _websiteController,
                            style: responsiveTextStyle(
                                context, 16, Colors.white, null),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.06),

                // edit details

                Text(
                  'Edit Your Details :',
                  style: responsiveTextStyle(context, 20, Colors.black, null),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  children: [
                    Text('Bio :',
                        style: responsiveTextStyle(
                            context, 16, Colors.black, null)),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Flexible(
                      child: TextField(
                        controller: _bioController,
                        style: responsiveTextStyle(
                            context, 16, Colors.white, null),
                        decoration: const InputDecoration(
                          hintText:
                              'E.g Experienced plumber with 5+ years of experience in fixing pipes.',
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('Experience :',
                        style: responsiveTextStyle(
                            context, 16, Colors.black, null)),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Flexible(
                      child: TextField(
                        controller: _experienceController,
                        style: responsiveTextStyle(
                            context, 16, Colors.white, null),
                        decoration: const InputDecoration(
                          hintText: 'E.g 5+ years',
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('Availability :',
                        style: responsiveTextStyle(
                            context, 16, Colors.black, null)),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Flexible(
                      child: TextField(
                        controller: _availabilityController,
                        style: responsiveTextStyle(
                            context, 16, Colors.white, null),
                        decoration: const InputDecoration(
                          hintText: 'E.g 9am - 5pm, Mon - Sat',
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('Special Offers :',
                        style: responsiveTextStyle(
                            context, 16, Colors.black, null)),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Flexible(
                      child: TextField(
                        controller: _specialOffersController,
                        style: responsiveTextStyle(
                            context, 16, Colors.white, null),
                        decoration: const InputDecoration(
                          hintText: 'E.g 20% off till Jan 2024',
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('Home Service :',
                        style: responsiveTextStyle(
                            context, 16, Colors.black, null)),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Flexible(
                      child: TextField(
                        controller: _homeServiceController,
                        style: responsiveTextStyle(
                            context, 16, Colors.white, null),
                        decoration: const InputDecoration(
                          hintText: 'E.g Yes, Citywide, Statewide, Countrywide',
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('Languages Spoken :',
                        style: responsiveTextStyle(
                            context, 16, Colors.black, null)),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Flexible(
                      child: TextField(
                        controller: _languagesSpokenController,
                        style: responsiveTextStyle(
                            context, 16, Colors.white, null),
                        decoration: const InputDecoration(
                          hintText: 'E.g English, Yoruba, Idoma',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.06),

                // submit button

                Center(
                  child: loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              loading = true;
                            });
                            // Check network connectivity
                            bool isConnected =
                                await _checkInternetConnectivity();
                            if (!isConnected) {
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
                              setState(() {
                                loading = false;
                              });
                              return; // Exit the function if there's no network
                            }

                            try {
                              if (_image1 != null) {
                                await _uploadImage1();
                              }
                              if (_image2 != null) {
                                await _uploadImage2();
                              }
                              if (_image3 != null) {
                                await _uploadImage3();
                              }
                              if (_image4 != null) {
                                await _uploadImage4();
                              }
                              if (_image5 != null) {
                                await _uploadImage5();
                              }

                              await _updateServiceProviderProfile();
                              await _saveServiceProviderProfilelocally();

                              await Future.delayed(const Duration(seconds: 2));
                              Navigator.of(context).pop();
                            } catch (error) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  'An error occurred. Please try again later.',
                                  style: responsiveTextStyle(context, 16,
                                      Colors.black, FontWeight.bold),
                                ),
                                backgroundColor: Colors.red,
                              ));
                            } finally {
                              setState(() {
                                loading = false;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF13CAF1),
                            minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.5,
                                MediaQuery.of(context).size.height *
                                    0.06), // Set the button's width and height
                          ),
                          child: Text(
                            'Submit',
                            style: responsiveTextStyle(
                                context, 14, Colors.black, FontWeight.bold),
                          ),
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

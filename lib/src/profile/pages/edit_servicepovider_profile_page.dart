import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
    });
  }

  // 01 - use case initialize data

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

      final useriglink = serviceProviderMap['ig_url'];
      final userxlink = serviceProviderMap['x_url'];
      final userfblink = serviceProviderMap['fb_url'];
      final userweblink = serviceProviderMap['web_link'];

      final userExperience = serviceProviderMap['experience'];
      final userBio = serviceProviderMap['bio'];
      final userAvailability = serviceProviderMap['availability'];
      final userSpecialOffers = serviceProviderMap['special_offers'];

      setState(() {
        media1 = userMedia1;
        media2 = userMedia2;
        media3 = userMedia3;

        iglink = useriglink;
        xlink = userxlink;
        fblink = userfblink;
        weblink = userweblink;
        bio = userBio;
        experience = userExperience;
        availability = userAvailability;
        specialoffers = userSpecialOffers;
      });
    } else {}
  }

  // 02 - use case check valid image

  Future<bool> _checkImageValidity(String img) async {
    try {
      final response = await http.get(Uri.parse(img));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 03 -  use case display image

  Future<ImageProvider?> _imageProvider(String img) async {
    // Check if the image URL is valid
    bool isImageValid = await _checkImageValidity(img);

    if (isImageValid) {
      // Image URL is valid, return the NetworkImage
      return NetworkImage(img);
    } else {
      return null;
    }
  }

  // 04 - use case display media

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
          return const SpinKitPianoWave(
            size: 30,
            color: Color(0xFF13CAF1),
            itemCount: 4,
          );
        }
      },
    );
  }

  // 06A - use case pick image1

  Future<void> _pickImage1() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image1 = File(pickedFile.path);
      });
    }
  }

  // 06B - use case pick image2

  Future<void> _pickImage2() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image2 = File(pickedFile.path);
      });
    }
  }

  // 06C - use case pick image3

  Future<void> _pickImage3() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image3 = File(pickedFile.path);
      });
    }
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

  // 08A - use case upload image1

  Future<void> _uploadImage1() async {
    bool isImage1Valid = await _checkImageValidity(media1);
    if (isImage1Valid) {
      try {
        await supabase.storage.from('media1').update(
              fullname,
              _image1!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: true),
            );
        if (mounted) {}
      } on PostgrestException catch (error) {
        //
      } catch (error) {
        //
      }
    } else {
      try {
        await supabase.storage.from('media1').upload(
              fullname,
              _image1!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );
        if (mounted) {}
      } on PostgrestException catch (error) {
        //
      } catch (error) {
        //
      }
    }
  }

  // 08B - use case upload image2

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
        if (mounted) {}
      } on PostgrestException catch (error) {
        //
      } catch (error) {
        //
      }
    } else {
      try {
        await supabase.storage.from('media2').upload(
              fullname,
              _image2!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );
        if (mounted) {}
      } on PostgrestException catch (error) {
        //
      } catch (error) {
        //
      }
    }
  }

  // 08C - use case upload image3

  Future<void> _uploadImage3() async {
    bool isImage3Valid = await _checkImageValidity(media3);
    if (isImage3Valid) {
      try {
        await supabase.storage.from('media3').update(
              fullname,
              _image3!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: true),
            );
        if (mounted) {}
      } on PostgrestException catch (error) {
        //
      } catch (error) {
        //
      }
    } else {
      try {
        await supabase.storage.from('media3').upload(
              fullname,
              _image3!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );
        if (mounted) {}
      } on PostgrestException catch (error) {
        //
      } catch (error) {
        //
      }
    }
  }

  // 09 - use case create service provider profile

  Future<void> _updateServiceProviderProfile() async {
    final ig = _instagramController.text.trim();
    final x = _xController.text.trim();
    final fb = _facebookController.text.trim();
    final web = _websiteController.text.trim();
    final bio = _bioController.text.trim();
    final experience = _experienceController.text.trim();
    final availability = _availabilityController.text.trim();
    final specialoffers = _specialOffersController.text.trim();
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
    };

    try {
      await supabase.from('serviceproviders_profile').upsert(details);
      if (mounted) {
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
      if (!context.mounted) return;
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
      if (!context.mounted) return;
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
        setState(() {
          loading = false;
        });
      }
    }
  }

  // 10 - use case create service provider profile

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

      final updatedServiceProviderJson = json.encode(serviceProviderMap);

      await prefs.setString(
          'serviceproviderprofile', updatedServiceProviderJson);
    } else {}
  }

  // variables

  String media1 = '';
  String media2 = '';
  String media3 = '';

  File? _image1;
  File? _image2;
  File? _image3;

  String iglink = '';
  String xlink = '';
  String fblink = '';
  String weblink = '';
  String bio = '';
  String experience = '';

  String availability = '';

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

    super.dispose();
  }

// build method

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
      body: SafeArea(
        child: SingleChildScrollView(
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
                  Text(
                      'hint: if you wish to change the service you\'re providing, reach out to customer care on your homepage :)',
                      style: responsiveTextStyle(
                          context, 12, Colors.black45, null)),

                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),

                  // edit media

                  Text(
                    'Edit your Media :',
                    style: responsiveTextStyle(context, 20, Colors.black, null),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
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
                            width: MediaQuery.sizeOf(context).width * 0.025),
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
                            width: MediaQuery.sizeOf(context).width * 0.025),
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
                            width: MediaQuery.sizeOf(context).width * 0.025),
                      ],
                    ),
                  ),

                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),

                  // edit social links

                  Text(
                    'Edit Your Social links :',
                    style: responsiveTextStyle(context, 20, Colors.black, null),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                  Text(
                      'hint: click on the app icons for easy navigation to share your proile :)',
                      style: responsiveTextStyle(
                          context, 12, Colors.black45, null)),
                  Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final Uri url =
                                  Uri.parse('https://www.instagram.com/');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {}
                            },
                            child: Image.asset(
                              'assets/ig-icon.png',
                              width: 25,
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
                          Text('Instagram :',
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, null)),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
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
                          GestureDetector(
                            onTap: () async {
                              final Uri url = Uri.parse('https://twitter.com/');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {}
                            },
                            child: Image.asset(
                              'assets/x-icon.webp',
                              width: 25,
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
                          Text('X :',
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, null)),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
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
                          GestureDetector(
                            onTap: () async {
                              final Uri url = Uri.parse(
                                  'https://web.facebook.com/?_rdc=1&_rdr');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {}
                            },
                            child: Image.asset(
                              'assets/facebook.png',
                              width: 25,
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
                          Text('Facebook :',
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, null)),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
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
                          GestureDetector(
                            onTap: () async {
                              final Uri url =
                                  Uri.parse('https://www.google.com/');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {}
                            },
                            child: Image.asset(
                              'assets/web-icon.png',
                              width: 25,
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
                          Text('Website :',
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, null)),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
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

                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),

                  // edit details

                  Text(
                    'Edit Your Details :',
                    style: responsiveTextStyle(context, 20, Colors.black, null),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                  Row(
                    children: [
                      Text('Bio :',
                          style: responsiveTextStyle(
                              context, 16, Colors.black, null)),
                      SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
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
                      SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
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
                      SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
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
                      SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
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

                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),

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

                                await _updateServiceProviderProfile();
                                await _saveServiceProviderProfilelocally();

                                await Future.delayed(
                                    const Duration(seconds: 2));
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                              } catch (error) {
                                if (!context.mounted) return;
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
                                  MediaQuery.sizeOf(context).width * 0.5,
                                  MediaQuery.sizeOf(context).height *
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
      ),
    );
  }
}

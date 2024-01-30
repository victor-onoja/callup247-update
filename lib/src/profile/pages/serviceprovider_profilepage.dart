import 'dart:async';
import 'dart:convert';
import 'package:callup247/main.dart';
import 'package:callup247/src/chat/pages/chathistory.dart';
import 'package:callup247/src/profile/widgets/availability_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../responsive_text_styles.dart';
import '../widgets/profile_page_action_button.dart';
import 'package:http/http.dart' as http;

class ServiceProviderProfile extends StatefulWidget {
  const ServiceProviderProfile({super.key});

  @override
  State<ServiceProviderProfile> createState() => _ServiceProviderProfileState();
}

class _ServiceProviderProfileState extends State<ServiceProviderProfile> {
  // init

  @override
  void initState() {
    super.initState();
    _initavailability();
    _initializeData();
  }

  Future<void> _initavailability() async {
    final prefs = await SharedPreferences.getInstance();
    final availablecurrent = prefs.getBool('isAvailable');
    if (availablecurrent != null) {
      setState(() {
        isAvailable = availablecurrent;
      });
    } else {
      setState(() {
        isAvailable = false;
      });
    }
  }

  // 01 - use case initialize data

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString('userprofile');
    final serviceProviderProfileJson =
        prefs.getString('serviceproviderprofile');
    if (userProfileJson != null && serviceProviderProfileJson != null) {
      final userProfileMap = json.decode(userProfileJson);
      final serviceProviderMap = json.decode(serviceProviderProfileJson);

      final userPfp = userProfileMap['displaypicture'];
      final userFullname = userProfileMap['fullname'];
      final userEmail = userProfileMap['email'];

      final userMedia1 = serviceProviderMap['media_url1'];
      final userMedia2 = serviceProviderMap['media_url2'];
      final userMedia3 = serviceProviderMap['media_url3'];

      final useriglink = serviceProviderMap['ig_url'];
      final userxlink = serviceProviderMap['x_url'];
      final userfblink = serviceProviderMap['fb_url'];
      final userweblink = serviceProviderMap['web_link'];

      final userExperience = serviceProviderMap['experience'];
      final userAvailability = serviceProviderMap['availability'];
      final userSpecialOffers = serviceProviderMap['special_offers'];

      setState(() {
        pfp = userPfp;
        fullname = userFullname;
        maillink = userEmail;
        media1 = userMedia1;
        media2 = userMedia2;
        media3 = userMedia3;
        iglink = useriglink;
        xlink = userxlink;
        fblink = userfblink;
        weblink = userweblink;
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

  // 03 - use case display image

  Future<ImageProvider?> _imageProvider(String img) async {
    // Check if the image URL is valid
    bool isImageValid = await _checkImageValidity(img);

    if (isImageValid && img == pfp) {
      // Image URL is valid, return the NetworkImage
      return NetworkImage(img);
    } else if (isImageValid && img != pfp) {
      return NetworkImage(img);
    } else if (!isImageValid && img == pfp) {
      return const AssetImage('assets/guest_dp.png');
    } else if (!isImageValid && img != pfp) {
      return null;
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
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            );
          } else {
            return Container();
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

  // 05 - use case toggle availability

  void _toggleAvailability() {
    setState(() {
      isAvailable = !isAvailable;
      storeAvailabilityStatus(isAvailable);
      _available(isAvailable);
    });
  }

// store availability locally

  Future<void> storeAvailabilityStatus(bool isAvailable) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isAvailable', isAvailable);
  }

// 06 - use case online

  Future<void> _available(bool isAvailable) async {
    try {
      await supabase.from('online').upsert({
        'user_id': supabase.auth.currentUser!.id,
        'last_seen': DateTime.now().toString(),
        'availability': isAvailable.toString(),
      });
      if (mounted) {
        print('profile_online');
      }
    } on PostgrestException catch (error) {
      //
    } catch (error) {
      //
    }
  }

  // variables

  bool isOnline = true;
  String pfp = '';
  String media1 = '';
  String media2 = '';
  String media3 = '';
  String iglink = '';
  String xlink = '';
  String fblink = '';
  String weblink = '';
  String maillink = '';
  String fullname = '';
  String experience = '';
  String availability = '';
  String specialoffers = '';
  bool isCustomer = false;
  bool isAvailable = false;

  // build method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 16.0,
                        right: 16,
                        bottom: 16,
                        top: MediaQuery.sizeOf(context).height * 0.01),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AvailabilitySwitch(
                                isAvailable: isAvailable,
                                onToggle: _toggleAvailability),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back),
                            ),
                            Row(
                              children: [
                                // service provider pfp
                                FutureBuilder<ImageProvider<Object>?>(
                                    future: _imageProvider(pfp),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            child: Image(
                                              image: snapshot.data!,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        } else {
                                          return Container();
                                        }
                                      } else {
                                        return const SpinKitPianoWave(
                                          size: 30,
                                          color: Color(0xFF13CAF1),
                                          itemCount: 4,
                                        );
                                      }
                                    })
                                // end of service provider pfp
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.08),
                        Text(
                          'Media:',
                          style: responsiveTextStyle(
                              context, 20, null, FontWeight.bold),
                        ),
                        SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.01),

                        // service provider media territory
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildImageWidget(media1),
                              SizedBox(
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.025),
                              _buildImageWidget(media2),
                              SizedBox(
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.025),
                              _buildImageWidget(media3),
                            ],
                          ),
                        ),

                        // end of service provider media territory
                        SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.08),
                        Text(
                          'Social Links:',
                          style: responsiveTextStyle(
                              context, 20, null, FontWeight.bold),
                        ),
                        SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.01),

                        // service provider social links
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  final ig = iglink;
                                  if (ig.isNotEmpty) {
                                    final Uri url = Uri.parse(ig);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      if (!context.mounted) return;
                                      // If the URL can't be launched, show a dialog
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                const Text('Cannot Open Link'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                    'The Instagram link could not be opened :('),
                                                const Text(
                                                    'but you can copy the link and open it in your browser:'),
                                                SelectableText(ig),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Copy Link'),
                                                onPressed: () {
                                                  Clipboard.setData(
                                                      ClipboardData(text: ig));
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Close'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    // Handle the case where iglink is an empty string (no link provided)
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                              'No Instagram Link Provided'),
                                          content: const Text(
                                              'The user did not provide an Instagram link.'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Close'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Image.asset(
                                  'assets/ig-icon.png',
                                  width: 45,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  final x = xlink;
                                  if (x.isNotEmpty) {
                                    final Uri url = Uri.parse(x);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      if (!context.mounted) return;
                                      // If the URL can't be launched, show a dialog
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                const Text('Cannot Open Link'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                    'The X link could not be opened :('),
                                                const Text(
                                                    'but you can copy the link and open it in your browser:'),
                                                SelectableText(x),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Copy Link'),
                                                onPressed: () {
                                                  Clipboard.setData(
                                                      ClipboardData(text: x));
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Close'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    // Handle the case where iglink is an empty string (no link provided)
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              const Text('No X Link Provided'),
                                          content: const Text(
                                              'The user did not provide an X link.'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Close'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Image.asset(
                                  'assets/x-icon.webp',
                                  width: 45,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  final fb = fblink;
                                  if (fb.isNotEmpty) {
                                    final Uri url = Uri.parse(fb);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      if (!context.mounted) return;
                                      // If the URL can't be launched, show a dialog
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                const Text('Cannot Open Link'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                    'The Facebook link could not be opened :('),
                                                const Text(
                                                    'but you can copy the link and open it in your browser:'),
                                                SelectableText(fb),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Copy Link'),
                                                onPressed: () {
                                                  Clipboard.setData(
                                                      ClipboardData(text: fb));
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Close'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    // Handle the case where iglink is an empty string (no link provided)
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                              'No Facebook Link Provided'),
                                          content: const Text(
                                              'The user did not provide a Facebook link.'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Close'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Image.asset(
                                  'assets/facebook.png',
                                  width: 45,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  final web = weblink;
                                  if (web.isNotEmpty) {
                                    final Uri url = Uri.parse(web);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      if (!context.mounted) return;
                                      // If the URL can't be launched, show a dialog
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                const Text('Cannot Open Link'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                    'The web link could not be opened :('),
                                                const Text(
                                                    'but you can copy the link and open it in your browser:'),
                                                SelectableText(web),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Copy Link'),
                                                onPressed: () {
                                                  Clipboard.setData(
                                                      ClipboardData(text: web));
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Close'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    // Handle the case where iglink is an empty string (no link provided)
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                              'No Web Link Provided'),
                                          content: const Text(
                                              'The user did not provide a website link.'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Close'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Image.asset(
                                  'assets/web-icon.png',
                                  width: 45,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Mail'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                                'You can send a mail to'),
                                            SelectableText(maillink)
                                          ],
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Copy Mail'),
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(
                                                  text: maillink));
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Close'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Image.asset(
                                  'assets/Gmail.png',
                                  width: 45,
                                ),
                              ),
                            )
                          ],
                        ),
                        // end of service provider social links
                        SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.08),
                        Text(
                          'Details:',
                          style: responsiveTextStyle(
                              context, 20, null, FontWeight.bold),
                        ),
                        SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.01),

                        // service provider details
                        Row(
                          children: [
                            Text('Name :- ', // Label
                                style: responsiveTextStyle(context, 16,
                                    Colors.black, FontWeight.bold)),
                            Flexible(
                              child: Text(fullname, // Information
                                  style: responsiveTextStyle(context, 16,
                                      Colors.white, FontWeight.bold)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Experience :- ', // Label
                                style: responsiveTextStyle(context, 16,
                                    Colors.black, FontWeight.bold)),
                            Flexible(
                              child: Text(experience, // Information
                                  style: responsiveTextStyle(context, 16,
                                      Colors.white, FontWeight.bold)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Availability :- ', // Label
                                style: responsiveTextStyle(context, 16,
                                    Colors.black, FontWeight.bold)),
                            Flexible(
                              child: Text(availability, // Information
                                  style: responsiveTextStyle(context, 16,
                                      Colors.white, FontWeight.bold)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Special Offers :- ', // Label
                                style: responsiveTextStyle(context, 16,
                                    Colors.black, FontWeight.bold)),
                            Flexible(
                              child: Text(specialoffers, // Information
                                  style: responsiveTextStyle(context, 16,
                                      Colors.white, FontWeight.bold)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Customers Review :- ', // Label
                                style: responsiveTextStyle(context, 16,
                                    Colors.black, FontWeight.bold)),
                            Row(
                              children: [
                                Text(' none ', // Information
                                    style: responsiveTextStyle(context, 16,
                                        Colors.white, FontWeight.bold)),
                                // const Icon(
                                //   Icons.star,
                                //   color: Colors.yellowAccent,
                                // )
                              ],
                            ),
                          ],
                        ),
                        // end of service provider details
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                  height: 100, // Adjust the height as needed
                  decoration: BoxDecoration(
                    color: const Color(0xFF13CAF1),
                    border: Border.all(width: 2, color: Colors.black),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ActionButton(
                          text: 'Call History',
                          onPressed: () {},
                          icon: const Icon(
                            Icons.call,
                            size: 50,
                          )),
                      ActionButton(
                        text: 'Transaction History',
                        onPressed: () {},
                        icon: const Icon(
                          Icons.payment,
                          size: 50,
                        ),
                      ),
                      ActionButton(
                        text: 'Chat History',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (BuildContext context) => ChatHistory(
                                      isCustomer: isCustomer,
                                    )),
                          );
                        },
                        icon: const Icon(
                          Icons.chat,
                          size: 50,
                        ),
                      ),
                      ActionButton(
                        text: 'Review History',
                        onPressed: () {},
                        icon: const Icon(
                          Icons.reviews,
                          size: 50,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

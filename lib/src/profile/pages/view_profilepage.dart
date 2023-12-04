import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/profile_page_action_button.dart';
import '../../responsive_text_styles.dart';
import 'package:http/http.dart' as http;

class ViewProfilePage extends StatefulWidget {
  const ViewProfilePage(
      {super.key,
      required this.pfp,
      required this.media1,
      required this.media2,
      required this.media3,
      required this.igLink,
      required this.xLink,
      required this.fbLink,
      required this.webLink,
      required this.mailLink,
      required this.fullname,
      required this.experience,
      required this.homeservice,
      required this.availability,
      required this.languagesspoken,
      required this.specialoffers});

  final String pfp,
      media1,
      media2,
      media3,
      igLink,
      xLink,
      fbLink,
      webLink,
      mailLink,
      fullname,
      experience,
      homeservice,
      availability,
      languagesspoken,
      specialoffers;

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  // init

  @override
  void initState() {
    super.initState();
  }

  // 01 - use case check valid image

  Future<bool> _checkImageValidity(String img) async {
    try {
      final response = await http.get(Uri.parse(img));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 02 - use case display image

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

  // 03 - use case display media

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
                height: 180,
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

  // variable

  bool isOnline = true;

  // build method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                      top: MediaQuery.of(context).size.height * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
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
                              Column(
                                children: [
                                  isOnline
                                      ? Text(
                                          'online',
                                          style: responsiveTextStyle(
                                              context,
                                              12,
                                              Colors.white,
                                              FontWeight.bold),
                                        )
                                      : Text(
                                          'offline',
                                          style: responsiveTextStyle(
                                              context,
                                              12,
                                              Colors.white,
                                              FontWeight.bold),
                                        ),
                                  Icon(
                                    Icons.circle,
                                    color:
                                        isOnline ? Colors.green : Colors.black,
                                    size: 12,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),

                              // service provider pfp
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    16.0), // Adjust the radius as needed
                                child: Image.network(
                                  widget.pfp,
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    return const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 50,
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    final totalBytes =
                                        loadingProgress?.expectedTotalBytes;
                                    final bytesLoaded =
                                        loadingProgress?.cumulativeBytesLoaded;
                                    if (totalBytes != null &&
                                        bytesLoaded != null) {
                                      return CircularProgressIndicator(
                                        backgroundColor: Colors.white70,
                                        value: bytesLoaded / totalBytes,
                                        color: Colors.blue[900],
                                        strokeWidth: 5.0,
                                      );
                                    } else {
                                      return child;
                                    }
                                  },
                                  frameBuilder: (context, child, frame,
                                      wasSynchronouslyLoaded) {
                                    if (wasSynchronouslyLoaded) {
                                      return child;
                                    }
                                    return AnimatedOpacity(
                                      opacity: frame == null ? 0 : 1,
                                      duration: const Duration(seconds: 1),
                                      curve: Curves.easeOut,
                                      child: child,
                                    );
                                  },

                                  width:
                                      100, // Adjust the width to fit within the container
                                  height:
                                      100, // Adjust the height to fit within the container
                                  fit: BoxFit
                                      .cover, // You can adjust the BoxFit as needed
                                ),
                              ),
                              // end of service provider pfp
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08),
                      Text(
                        'Media:',
                        style: responsiveTextStyle(
                            context, 20, null, FontWeight.bold),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),

                      // service provider media territory
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildImageWidget(widget.media1),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.025),
                            _buildImageWidget(widget.media2),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.025),
                            _buildImageWidget(widget.media3),
                          ],
                        ),
                      ),
                      // end of service provider media territory
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08),
                      Text(
                        'Social Links:',
                        style: responsiveTextStyle(
                            context, 20, null, FontWeight.bold),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),

                      // service provider social links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () async {
                                final ig = widget.igLink;
                                if (ig.isNotEmpty) {
                                  final Uri url = Uri.parse(ig);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    // If the URL can't be launched, show a dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Cannot Open Link'),
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
                                final x = widget.xLink;
                                if (x.isNotEmpty) {
                                  final Uri url = Uri.parse(x);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    // If the URL can't be launched, show a dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Cannot Open Link'),
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
                                        title: const Text('No X Link Provided'),
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
                                final fb = widget.fbLink;
                                if (fb.isNotEmpty) {
                                  final Uri url = Uri.parse(fb);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    // If the URL can't be launched, show a dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Cannot Open Link'),
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
                                final web = widget.webLink;
                                if (web.isNotEmpty) {
                                  final Uri url = Uri.parse(web);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    // If the URL can't be launched, show a dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Cannot Open Link'),
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
                                        title:
                                            const Text('No Web Link Provided'),
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
                                          const Text('You can send a mail to'),
                                          SelectableText(widget.mailLink)
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Copy Mail'),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                text: widget.mailLink));
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
                          height: MediaQuery.of(context).size.height * 0.08),
                      Text(
                        'Details:',
                        style: responsiveTextStyle(
                            context, 20, null, FontWeight.bold),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),

                      // service provider details
                      Row(
                        children: [
                          Text('Name :- ', // Label
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, FontWeight.bold)),
                          Flexible(
                            child: Text(widget.fullname, // Information
                                style: responsiveTextStyle(context, 16,
                                    Colors.white, FontWeight.bold)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Experience :- ', // Label
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, FontWeight.bold)),
                          Flexible(
                            child: Text(widget.experience, // Information
                                style: responsiveTextStyle(context, 16,
                                    Colors.white, FontWeight.bold)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Home Service :- ', // Label
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, FontWeight.bold)),
                          Flexible(
                            child: Text(widget.homeservice, // Information
                                style: responsiveTextStyle(context, 16,
                                    Colors.white, FontWeight.bold)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Availability :- ', // Label
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, FontWeight.bold)),
                          Flexible(
                            child: Text(widget.availability, // Information
                                style: responsiveTextStyle(context, 16,
                                    Colors.white, FontWeight.bold)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Languages Spoken :- ', // Label
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, FontWeight.bold)),
                          Flexible(
                            child: Text(widget.languagesspoken, // Information
                                style: responsiveTextStyle(context, 16,
                                    Colors.white, FontWeight.bold)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Special Offers :- ', // Label
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, FontWeight.bold)),
                          Flexible(
                            child: Text(widget.specialoffers, // Information
                                style: responsiveTextStyle(context, 16,
                                    Colors.white, FontWeight.bold)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Customers Review :- ', // Label
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, FontWeight.bold)),
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
                      text: 'Call',
                      onPressed: () {},
                      icon: const Icon(
                        Icons.video_call,
                        size: 50,
                      ),
                    ),
                    ActionButton(
                        text: 'Call',
                        onPressed: () {},
                        icon: const Icon(
                          Icons.call,
                          size: 50,
                        )),
                    ActionButton(
                      text: 'Pay',
                      onPressed: () {},
                      icon: const Icon(
                        Icons.payment,
                        size: 50,
                      ),
                    ),
                    ActionButton(
                      text: 'Chat',
                      onPressed: () {},
                      icon: const Icon(
                        Icons.chat,
                        size: 50,
                      ),
                    ),
                    ActionButton(
                      text: 'Review',
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
    );
  }
}

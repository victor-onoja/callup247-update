import 'package:flutter/material.dart';

import '../widgets/profile_page_action_button.dart';

import '../../responsive_text_styles.dart';

class GuestProfilePage extends StatefulWidget {
  const GuestProfilePage({super.key});

  @override
  State<GuestProfilePage> createState() => _GuestProfilePageState();
}

class _GuestProfilePageState extends State<GuestProfilePage> {
  bool isOnline = true;
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
                        top: MediaQuery.sizeOf(context).height * 0.05),
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
                                      color: isOnline
                                          ? Colors.green
                                          : Colors.black,
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
                                  child: Image.asset(
                                    'assets/pfp.jpg',
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
                              Image.asset('assets/no_media.png'),
                              Text(
                                'No media yet :(\nStart an online chat?',
                                style: responsiveTextStyle(
                                    context, 16, Colors.black, null),
                                textAlign: TextAlign.center,
                              )
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
                              child: Image.asset(
                                'assets/ig-icon.png',
                                width: 45,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/x-icon.webp',
                                width: 45,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/facebook.png',
                                width: 45,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/web-icon.png',
                                width: 45,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/Gmail.png',
                                width: 45,
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
                            Text('Name:', // Label
                                style: responsiveTextStyle(context, 16,
                                    Colors.black, FontWeight.bold)),
                            Text(' John Doe', // Information
                                style: responsiveTextStyle(context, 16,
                                    Colors.white, FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Experience:', // Label
                                style: responsiveTextStyle(context, 16,
                                    Colors.black, FontWeight.bold)),
                            Text(' 2 years', // Information
                                style: responsiveTextStyle(context, 16,
                                    Colors.white, FontWeight.bold)),
                          ],
                        ),

                        Row(
                          children: [
                            Text('Availability:', // Label
                                style: responsiveTextStyle(context, 16,
                                    Colors.black, FontWeight.bold)),
                            Text(' 10am - 7pm, Mon - Sat', // Information
                                style: responsiveTextStyle(context, 16,
                                    Colors.white, FontWeight.bold)),
                          ],
                        ),

                        Row(
                          children: [
                            Text('Special Offers:', // Label
                                style: responsiveTextStyle(context, 16,
                                    Colors.black, FontWeight.bold)),
                            Text(' None', // Information
                                style: responsiveTextStyle(context, 16,
                                    Colors.white, FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Customers Review:', // Label
                                style: responsiveTextStyle(context, 16,
                                    Colors.black, FontWeight.bold)),
                            Row(
                              children: [
                                Text(' 2 ', // Information
                                    style: responsiveTextStyle(context, 16,
                                        Colors.white, FontWeight.bold)),
                                const Icon(
                                  Icons.star,
                                  color: Colors.yellowAccent,
                                )
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
      ),
    );
  }
}

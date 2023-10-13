import 'package:flutter/material.dart';

import '../../responsive_text_styles.dart';

class ServiceProviderCard extends StatelessWidget {
  final String name;
  final String bio;
  final String image;
  final Function() onPressedButton1;
  final Function()? onPressedButton2;
  final bool isOnline;
  final bool saved;

  const ServiceProviderCard({
    super.key,
    required this.name,
    required this.bio,
    required this.image,
    required this.onPressedButton1,
    this.onPressedButton2,
    required this.isOnline,
    required this.saved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.black, width: 2),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF039fdc), Color(0xFF13CAF1)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name,
                    style:
                        responsiveTextStyle(context, 18, Colors.white, null)),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: isOnline ? Colors.green : Colors.black,
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 2),
            Center(
              child: Image.asset(
                image,
              ),
            ),
            const SizedBox(height: 2),
            Text(bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: responsiveTextStyle(context, 14, Colors.white, null)),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF039fdc)),
                  onPressed: onPressedButton1,
                  child: const Text('View Profile'),
                ),
                saved
                    ? PopupMenuButton(
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFF039fdc),
                              borderRadius: BorderRadius.circular(5)),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text('Contact',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              textStyle: responsiveTextStyle(
                                  context, 16, Colors.black, FontWeight.bold),
                              value: 'videoCall',
                              child: const Text(
                                'Video Call',
                              ),
                            ),
                            PopupMenuItem(
                              textStyle: responsiveTextStyle(
                                  context, 16, Colors.black, FontWeight.bold),
                              value: 'voiceCall',
                              child: const Text(
                                'Voice Call',
                              ),
                            ),
                            PopupMenuItem(
                              textStyle: responsiveTextStyle(
                                  context, 16, Colors.black, FontWeight.bold),
                              value: 'chat',
                              child: const Text('Chat'),
                            ),
                          ];
                        },
                        onSelected: (value) {
                          // Handle the selected menu item (navigate to the corresponding screen)
                          if (value == 'videoCall') {
                            // Navigate to the edit profile screen
                          } else if (value == 'voiceCall') {
                            // Navigate to the theme screen
                          } else if (value ==
                              'chat') {} // Add more cases for other menu items
                        },
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF039fdc)),
                        onPressed: onPressedButton2,
                        child: const Text('Add to Saved'))
              ],
            ),
          ],
        ),
      ),
    );
  }
}

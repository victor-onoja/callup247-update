import 'package:flutter/material.dart';

import '../../responsive_text_styles.dart';

class ServiceProviderCard extends StatelessWidget {
  final String name;
  final String bio;
  final Image image;
  final Function() onPressedButton1;
  final Function() onPressedButton2;
  final bool isOnline;
  final bool saved;

  const ServiceProviderCard({
    super.key,
    required this.name,
    required this.bio,
    required this.image,
    required this.onPressedButton1,
    required this.onPressedButton2,
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
                // saved
                //     ? Row(
                //         children: [
                //           Row(
                //             children: [
                //               Icon(
                //                 Icons.circle,
                //                 color: isOnline ? Colors.green : Colors.black,
                //                 size: 12,
                //               ),
                //             ],
                //           ),
                //           const SizedBox(
                //             width: 5,
                //           ),
                //           GestureDetector(
                //             onTap: () {
                //               showDialog(
                //                 context: context,
                //                 builder: (BuildContext context) {
                //                   return AlertDialog(
                //                     title: const Text('Confirm Action'),
                //                     content: const Text(
                //                         'Are you sure you want to remove this service provider from your saved searches?'),
                //                     actions: <Widget>[
                //                       TextButton(
                //                         onPressed: () {
                //                           Navigator.of(context)
                //                               .pop(); // Close the dialog
                //                         },
                //                         child: const Text('Cancel'),
                //                       ),
                //                       TextButton(
                //                         onPressed: delete,
                //                         child: const Text('Proceed'),
                //                       ),
                //                     ],
                //                   );
                //                 },
                //               );
                //             },
                //             child: const Icon(
                //               Icons.remove_circle,
                //               color: Colors.redAccent,
                //             ),
                //           ),
                //         ],
                //       )
                //     :
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
            Center(child: image),
            const SizedBox(height: 2),
            Text(bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: responsiveTextStyle(context, 16, Colors.white, null)),
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
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF039fdc)),
                        onPressed: onPressedButton2,
                        child: const Text('Remove Saved'))
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

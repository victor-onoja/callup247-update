import 'package:flutter/material.dart';

import '../../responsive_text_styles.dart';

class GradientContainer extends StatelessWidget {
  final String title;
  final String text;
  final String imagePath;

  const GradientContainer(
      {super.key,
      required this.title,
      required this.text,
      required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF13CAF1), Color(0xFF039fdc)],
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: responsiveTextStyle(
                        context, 20, null, FontWeight.bold)),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.025),
                Text(text, style: responsiveTextStyle(context, 16, null, null)),
              ],
            ),
          ),
          Image.asset(
            imagePath,
            width: 100.0,
            height: 100.0,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}

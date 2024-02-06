import 'package:flutter/material.dart';

import '../../responsive_text_styles.dart';

class GradientContainer extends StatelessWidget {
  final String title;

  const GradientContainer({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF36DDFF),
        borderRadius: BorderRadius.circular(10.0),
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
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward,
            size: 25,
            color: Color(0xFF000000),
          )
        ],
      ),
    );
  }
}

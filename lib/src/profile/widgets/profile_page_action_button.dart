import 'package:flutter/material.dart';

import '../../responsive_text_styles.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final Icon icon;

  const ActionButton(
      {super.key,
      required this.text,
      required this.onPressed,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.lightGreenAccent,
      onTap: onPressed,
      child: Container(
          margin: const EdgeInsets.all(2.0),
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: const Color(0xFF039fdc),
            border: Border.all(width: 2, color: Colors.black),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              Text(
                text,
                textAlign: TextAlign.center,
                style: responsiveTextStyle(
                    context, 10, Colors.white, FontWeight.bold),
              )
            ],
          )),
    );
  }
}

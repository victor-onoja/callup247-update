import 'package:callup247/src/responsive_text_styles.dart';
import 'package:flutter/material.dart';

class AvailabilitySwitch extends StatelessWidget {
  final bool isAvailable;
  final VoidCallback onToggle;

  const AvailabilitySwitch({
    required this.isAvailable,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        isAvailable
            ? Text(
                'I\'m Available!',
                style: responsiveTextStyle(
                    context, 16, Colors.green, FontWeight.bold),
              )
            : Text(
                'I\'m Not Available :(',
                style: responsiveTextStyle(
                    context, 16, const Color(0xFF039fdc), FontWeight.bold),
              ),
        Switch(
          value: isAvailable,
          onChanged: (_) => onToggle(),
        ),
      ],
    );
  }
}

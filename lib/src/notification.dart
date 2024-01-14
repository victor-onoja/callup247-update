import 'package:flutter/material.dart';

class NewMessageNotification extends StatefulWidget {
  final VoidCallback onTap;

  const NewMessageNotification({Key? key, required this.onTap})
      : super(key: key);

  @override
  _NewMessageNotificationState createState() => _NewMessageNotificationState();
}

class _NewMessageNotificationState extends State<NewMessageNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Adjust duration as needed
    );

    _animation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SlideTransition(
        position: _animation,
        child: Container(
          color: Colors.blue,
          padding: const EdgeInsets.all(8.0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.message),
              SizedBox(width: 8.0),
              Text(
                'You have a new message! Tap to open.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

import 'package:callup247/src/onboarding/pages/onboarding_animation_screen.dart';
import 'package:flutter/material.dart';

class SplashScreenX extends StatefulWidget {
  @override
  _SplashScreenXState createState() => _SplashScreenXState();
}

class _SplashScreenXState extends State<SplashScreenX> {
  bool _showGreyLogo = true;
  bool _showBlueLogo = false;
  double _blueLogoSize = 1.0;
  Color _backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    // After 2 seconds, switch to blue logo
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showGreyLogo = false;
        _showBlueLogo = true;
        _startBlueLogoAnimation();
      });
    });
  }

  void _startBlueLogoAnimation() {
    // Continuously increase the size of the blue logo until the whole background is blue
    Future.delayed(const Duration(milliseconds: 1), () {
      setState(() {
        _blueLogoSize += 0.08;
      });
      if (_blueLogoSize < 10.0) {
        // Adjust the maximum size as needed
        _startBlueLogoAnimation();
      } else {
        // Start changing the background color to blue
        _changeBackgroundColor();
      }
    });
  }

  void _changeBackgroundColor() {
    // Change the background color gradually to blue
    setState(() {
      _backgroundColor =
          const Color(0xFF36DDFF); // Set the final background color
    });
    // After the background color is changed, hide the blue logo
    Future.delayed(const Duration(milliseconds: 1), () {
      setState(() {
        _showBlueLogo = false;
      });
      // After a short delay, navigate to the next screen
      Future.delayed(const Duration(milliseconds: 1600), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingAnimationScreen(),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor, // Set background color dynamically
      body: Center(
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: _showGreyLogo ? 1.0 : 0.0,
              duration:
                  const Duration(seconds: 2), // Adjust the duration as needed
              child: Image.asset(
                'assets/splashlogo1.png', // Replace 'assets/grey_logo.png' with your grey logo asset path
                fit: BoxFit.contain,
              ),
            ),
            AnimatedOpacity(
              opacity: _showBlueLogo ? 1.0 : 0.0,
              duration:
                  const Duration(seconds: 2), // Adjust the duration as needed
              child: Transform.scale(
                scale: _blueLogoSize,
                child: Image.asset(
                  'assets/splashlogo.png', // Replace 'assets/blue_logo.png' with your blue logo asset path
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

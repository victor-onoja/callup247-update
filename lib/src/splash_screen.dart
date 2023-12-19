import 'dart:convert';

import 'package:callup247/main.dart';
import 'package:callup247/src/home/pages/customer_home.dart';
import 'package:callup247/src/home/pages/serviceprovider_homepage.dart';
import 'package:callup247/src/responsive_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding/pages/onboarding_animation_screen.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Define the scale animation
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Define the opacity animation
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animations
    _animationController.forward();

    // After the animations, navigate to the next screen
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _redirect();
      }
    });
  }

  // 05 - use case check network

  Future<bool> checkInternetConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // use case splash navigation

  Future<void> _redirect() async {
    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString('userprofile');
    if (userProfileJson != null) {
      final userProfileMap = json.decode(userProfileJson);
      // To access specific fields like full name and email address:

      final serviceProvider = userProfileMap['service_provider'];
      setState(() {
        serviceprovider = serviceProvider;
      });
      // You can now use `emailaddress` as needed.
    } else {
      // Handle the case where no user profile data is found in SharedPreferences.
      // For example, show a snackbar.
    }
    bool isConnected = await checkInternetConnectivity();
    if (!isConnected) {
      if (!context.mounted) return;
      // Show a snackbar for no network
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 10),
        content: Text(
          'No internet connection. Please check your network settings.',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      return; // Exit the function if there's no network
    }
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    final session = supabase.auth.currentSession;
    if (session != null) {
      // navigate to customer or service provider homepage
      if (serviceprovider == 'FALSE') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => const CustomerHomePage(),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) =>
                const ServiceProviderHomePage()));
      }
    } else {
      // todo: navigate to login if onboarding animation has been displayed previously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => const OnboardingAnimationScreen(),
        ),
      );
    }
  }

// variables

  String serviceprovider = '';

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
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 0.2,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: Image.asset(
                    'assets/logo_t.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

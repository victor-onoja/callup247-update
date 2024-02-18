import 'dart:convert';

import 'package:callup247/main.dart';
import 'package:callup247/src/home/pages/customer_home.dart';
import 'package:callup247/src/home/pages/serviceprovider_homepage.dart';
import 'package:callup247/src/location.dart';
import 'package:callup247/src/responsive_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'onboarding/pages/onboarding_animation_screen.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // init

  @override
  void initState() {
    super.initState();
    _locationService = LocationService(context);
    _fetchUserLocation();
    // After 2 seconds, switch to blue logo
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showGreyLogo = false;
        _showBlueLogo = true;
        _startBlueLogoAnimation();
      });
    });
  }

  // use case fetch user's position

  Future<void> _fetchUserLocation() async {
    try {
      final Position position = await _locationService.getLocation();
      // Store user's location in SharedPreferences
      await _storeUserLocationInSharedPreferences(position);
      // Store user's location in Supabase table
      await _storeUserLocationInSupabase(position);
      print(position.latitude);
      print(position.longitude);
    } catch (e) {
      // Handle location fetching error
      print('Error fetching user location: $e');
    }
  }

// store user location in shared prefs

  Future<void> _storeUserLocationInSharedPreferences(Position position) async {
    // Store user's location in SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('userLatitude', position.latitude);
    prefs.setDouble('userLongitude', position.longitude);
  }

  // store user location in supabase

  Future<void> _storeUserLocationInSupabase(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString('userprofile');
    if (userProfileJson != null) {
      final userProfileMap = json.decode(userProfileJson);

      final serviceProvider = userProfileMap['service_provider'];

      if (serviceProvider == 'TRUE') {
        // Store user's location in Supabase table
        final double userLatitude = position.latitude;
        final double userLongitude = position.longitude;

        try {
          await supabase.from('serviceproviders_profile').upsert({
            'id': supabase.auth.currentUser!.id,
            'longitude': userLongitude,
            'latitude': userLatitude,
          });
        } on PostgrestException catch (error) {
          print(error);
        } catch (e) {
          print(e);
        }
      }
    }
  }

// 01 - use case animation a

  void _startBlueLogoAnimation() {
    // Continuously increase the size of the blue logo until the whole background is blue
    Future.delayed(const Duration(milliseconds: 2), () {
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

  // 02 - use case animation b

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
      Future.delayed(const Duration(milliseconds: 1200), () {
        _redirect();
      });
    });
  }

  // 03 - use case check network

  Future<bool> checkInternetConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 04 - use case splash navigation

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
        duration: const Duration(seconds: 30),
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
  bool _showGreyLogo = true;
  bool _showBlueLogo = false;
  double _blueLogoSize = 1.0;
  Color _backgroundColor = Colors.white;
  late final LocationService _locationService;

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

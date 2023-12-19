import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async'; // Import the dart:async library

import 'onboarding_choice_screen.dart';

import '../../responsive_text_styles.dart';

class OnboardingAnimationScreen extends StatefulWidget {
  const OnboardingAnimationScreen({super.key});

  @override
  State<OnboardingAnimationScreen> createState() =>
      _OnboardingAnimationScreenState();
}

class _OnboardingAnimationScreenState extends State<OnboardingAnimationScreen>
    with TickerProviderStateMixin {
  // variables
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  late Timer _timer; // Declare a Timer object

  // init state
  @override
  void initState() {
    super.initState();

    // Start the timer to automatically move to the next page after 5 seconds
    _timer = Timer(const Duration(seconds: 5), () {
      _moveToNextPage();
    });

    _pageController.addListener(() {
      // Cancel the timer if the user interacts with the page
      _timer.cancel();
    });
  }

  // dispose
  @override
  void dispose() {
    // Dispose of the timer when the screen is disposed
    _timer.cancel();
    super.dispose();
  }

// use case: move to next page
// todo: when on page 2 move to next page should be fired again
  void _moveToNextPage() {
    if (_currentPage < 2) {
      // Check if it's not the last page
      _pageController.animateToPage(
        _currentPage + 2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      // Navigate to the next screen when on the last page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => const OnboardingChoiceScreen(),
        ),
      );
    }
  }

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
          child: PageView(
            controller: _pageController,
            children: <Widget>[
              _buildOnboardingPage('assets/wide_services.svg',
                  'Comprehensive Service Selection', 0),
              _buildOnboardingPage('assets/available.svg',
                  'Real-Time Service Provider Availability', 1),
              _buildOnboardingPage('assets/payments.svg',
                  'Secure Payment and First-Time Seller Approval', 2),
            ],
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(
      String svgPath, String description, int pageIndex) {
    final isLastPage = pageIndex == 2;

    final circles = List<Widget>.generate(
      3,
      (index) {
        return Container(
          margin: const EdgeInsets.all(16.0),
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == pageIndex ? Colors.black : Colors.white,
          ),
        );
      },
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset(
          svgPath,
          width: 220,
          height: 220,
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(description,
              textAlign: TextAlign.center,
              style: responsiveTextStyle(context, 28.0, null, FontWeight.bold)),
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.025),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: circles,
        ),
        if (isLastPage)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: InkWell(
              splashColor: Colors.greenAccent,
              radius: 50.0,
              onTap: _moveToNextPage, // Use the method to navigate
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Done',
                      style: responsiveTextStyle(
                          context, 20.0, null, FontWeight.bold)),
                  const Icon(Icons.arrow_forward)
                ],
              ),
            ),
          ),
      ],
    );
  }
}

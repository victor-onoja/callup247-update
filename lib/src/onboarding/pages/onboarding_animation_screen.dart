import 'package:callup247/src/authentication/pages/user_login.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Import the dart:async library
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

    // Start the timer to automatically move to the next page after 4 seconds
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _moveToNextPage();
    });
  }

  // dispose

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

// 01 - use case move to next page

  void _moveToNextPage() {
    if (_currentPage < 2) {
      // Check if it's not the last page
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      // Navigate to the next screen when on the last page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => const SignIn(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            _timer.cancel();
          },
          child: PageView(
            controller: _pageController,
            children: <Widget>[
              _buildOnboardingPage('Real-Time Service Provider Availability', 0,
                  'assets/onboardbg1.png'),
              _buildOnboardingPage(
                  'Secure Payment and First-Time Seller Approval',
                  1,
                  'assets/onboardbg2.png'),
              _buildOnboardingPage('Comprehensive Service Selection', 2,
                  'assets/onboardbg3.png'),
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
    String description,
    int pageIndex,
    String backgroundImage,
  ) {
    final circles = List<Widget>.generate(
      3,
      (index) {
        return Container(
          margin: const EdgeInsets.all(16.0),
          width: 14.0,
          height: 14.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == pageIndex
                ? const Color(0xFFD9D9D9)
                : const Color(0xFFD9D9D9),
            border: index == pageIndex
                ? Border.all(
                    color: const Color(0xFF36DCFF),
                    width: 2.0) // Blue border when index matches
                : null, // No border for other circles
          ),
        );
      },
    );

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.fill,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Image.asset('assets/onboardlogo.png'),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(description,
                    textAlign: TextAlign.center,
                    style: responsiveTextStyle(context, 25.0,
                        const Color(0xFFffffff), FontWeight.w500)),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.025),
              ElevatedButton(
                onPressed: _moveToNextPage,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFF36DDFF)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: MediaQuery.sizeOf(context).width * 0.2),
                  child: Text(
                    'Continue',
                    style: responsiveTextStyle(
                        context, 20, const Color(0xFF0C0505), FontWeight.w500),
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: circles,
          ),
        ],
      ),
    );
  }
}

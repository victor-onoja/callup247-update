import 'package:callup247/src/authentication/pages/customer_signup.dart';
import 'package:callup247/src/authentication/pages/serviceprovider_signup.dart';
import 'package:callup247/src/onboarding/widgets/onboarding_choice_gradient_container.dart';
import 'package:callup247/src/home/pages/guest_home_page.dart';
import 'package:callup247/src/responsive_text_styles.dart';
import 'package:flutter/material.dart';

class OnboardingChoiceScreen extends StatefulWidget {
  const OnboardingChoiceScreen({super.key});

  @override
  State<OnboardingChoiceScreen> createState() => _OnboardingChoiceScreenState();
}

class _OnboardingChoiceScreenState extends State<OnboardingChoiceScreen>
    with TickerProviderStateMixin {
  // 01 - use case animations

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController1.forward(); // Start the first fade-in animation
    await Future.delayed(const Duration(milliseconds: 1000));
    _fadeController2.forward(); // Start the second fade-in animation
    await Future.delayed(const Duration(milliseconds: 1400));
    _fadeController3.forward(); // Start the third fade-in animation
  }

  // init

  @override
  void initState() {
    super.initState();
    _acontroller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _fadeController1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeController3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController1, curve: Curves.easeIn),
    );

    _fadeAnimation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController2, curve: Curves.easeIn),
    );

    _fadeAnimation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController3, curve: Curves.easeIn),
    );

    _startAnimations();
  }

  // dispose

  @override
  void dispose() {
    _acontroller.dispose();
    _fadeController1.dispose();
    _fadeController2.dispose();
    _fadeController3.dispose();
    super.dispose();
  }
  // variables

  late AnimationController _acontroller;
  late AnimationController _fadeController1;
  late Animation<double> _fadeAnimation1;
  late AnimationController _fadeController2;
  late Animation<double> _fadeAnimation2;
  late AnimationController _fadeController3;
  late Animation<double> _fadeAnimation3;

  // widget build animated container

  Widget _buildAnimatedContainer(AnimationController fadeController,
      Animation<double> fadeAnimation, String title, Widget child) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => child,
            ),
          );
        },
        radius: 350,
        splashColor: Colors.greenAccent,
        child: GradientContainer(
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Positioned(
          left: 2,
          bottom: 2,
          child: Image.asset(
            'assets/resetpasset.png',
            fit: BoxFit.contain,
          ),
        ),
        SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: MediaQuery.sizeOf(context).height * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0).animate(_acontroller),
                      child: Image.asset(
                        'assets/logo_t.png',
                        height: 75,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.01,
                    ),
                    Text(
                      'Select User Type',
                      style: responsiveTextStyle(context, 24,
                          const Color(0xFF333333), FontWeight.w600),
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.1,
                    ),
                    _buildAnimatedContainer(
                      _fadeController1,
                      _fadeAnimation1,
                      'Customer',
                      const CustomerSignUpScreen(),
                    ),
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.025),
                    _buildAnimatedContainer(
                      _fadeController2,
                      _fadeAnimation2,
                      'Service Provider',
                      const ServiceProviderSignUpScreen(),
                    ),
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.025),
                    _buildAnimatedContainer(
                      _fadeController3,
                      _fadeAnimation3,
                      'Guest',
                      const GuestHomePage(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

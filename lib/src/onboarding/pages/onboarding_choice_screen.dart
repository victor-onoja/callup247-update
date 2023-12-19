import 'package:callup247/src/authentication/pages/customer_signup.dart';
import 'package:callup247/src/authentication/pages/serviceprovider_signup.dart';
import 'package:callup247/src/authentication/pages/user_login.dart';
import 'package:callup247/src/onboarding/widgets/onboarding_choice_gradient_container.dart';
import 'package:callup247/src/home/pages/guest_home_page.dart';
import 'package:callup247/src/responsive_text_styles.dart';
import 'package:flutter/material.dart';

class OnboardingChoiceScreen extends StatelessWidget {
  const OnboardingChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.sizeOf(context).height,
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
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: MediaQuery.sizeOf(context).height * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(
                          Icons.login,
                          color: Colors.black54,
                        ),
                        label:
                            const Text('Already have an account? Login here'),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const SignIn()));
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.025),
                  Text(
                    'Use this app as a:',
                    style: responsiveTextStyle(context, 28, null, null),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.025),
                  InkWell(
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const CustomerSignUpScreen(),
                          ),
                        );
                      });
                    },
                    radius: 350,
                    splashColor: Colors.greenAccent,
                    child: const GradientContainer(
                      imagePath: 'assets/customer_icon.png',
                      text:
                          'find and access a wide range of services, from home repairs to beauty treatments',
                      title: 'Customer',
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.025),
                  InkWell(
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ServiceProviderSignUpScreen(),
                          ),
                        );
                      });
                    },
                    splashColor: Colors.greenAccent,
                    radius: 50,
                    child: const GradientContainer(
                        title: 'Service Provider',
                        text:
                            'showcase your skills, connect with local customers, manage your availability, and grow your business',
                        imagePath: 'assets/service_provider.png'),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.025),
                  InkWell(
                      splashColor: Colors.greenAccent,
                      radius: 50.0,
                      onTap: () {
                        // Delay navigation by 300 milliseconds (adjust as needed)
                        Future.delayed(const Duration(milliseconds: 300), () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const GuestHomePage(),
                            ),
                          );
                        });
                      },
                      child: const GradientContainer(
                          title: 'Guest',
                          text:
                              "discover available services, gain a preview of the app's offerings and functionality without the need for account creation",
                          imagePath: 'assets/guest_icon.png'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

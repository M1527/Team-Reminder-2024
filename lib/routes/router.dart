import 'package:abc/screens/home/home_screen.dart';
import 'package:abc/screens/profile/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/admin/admin_screen.dart';
import '../screens/home/addboard_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/signup/signup_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case "/":
      return MaterialPageRoute(
        builder: (context) => const OnboardingScreen(),
      );
    case "/login":
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case "/signup":
      return MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      );
    case "/home":
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );
    case "/addboard":
      return CupertinoPageRoute(
        builder: (context) => const AddboardScreen(),
      );
    case '/profile':
      return CupertinoPageRoute(
        builder: (context) => const ProfileScreen(),
      );
    case '/admin':
      return MaterialPageRoute(
        builder: (context) => const AdminScreen(),
      );
    default:
      return MaterialPageRoute(
        // Make a screen for undefine
        builder: (context) => const OnboardingScreen(),
      );
  }
}

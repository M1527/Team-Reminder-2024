import 'dart:async';
import 'dart:developer';

import 'package:abc/api/apis.dart';
import 'package:abc/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final APIs api = APIs();

  @override
  void initState() {
    Timer(const Duration(seconds: 3), () async {
      User? user = api.getCurrentUser();
      if (user != null) {
        String getRole = await api.getRole();
        log('role: $getRole');
        if (getRole == 'admin') {
          Navigator.pushReplacementNamed(navigatorKey.currentContext!, "/admin");
        } else {
          Navigator.pushReplacementNamed(navigatorKey.currentContext!, "/home");
        }
      } else {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset("assets/images/logo.png"),
      ),
    );
  }
}

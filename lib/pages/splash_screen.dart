import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modis/pages/beranda.dart';
import 'package:modis/pages/login.dart';
import 'package:modis/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool logged = false;

  @override
  void initState() {
    super.initState();
    checkLocalData();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anitamtion, secondaryAnimation) =>
              logged ? const Beranda() : const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      );
    });
  }

  void checkLocalData() async {
    SharedPreferences data = await SharedPreferences.getInstance();
    if (data.containsKey('userData')) {
      Provider.of<User>(context, listen: false).setUserData(
        data.getString('userData'),
      );

      setState(() {
        logged = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.fromRGBO(1, 92, 104, 1),
              Color.fromRGBO(1, 135, 76, 1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'images/logo.png',
                  height: 200,
                ),
              ),
              const Text(
                'MoDis',
                style: TextStyle(
                    fontSize: 70,
                    fontFamily: 'italianno',
                    fontWeight: FontWeight.w200,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

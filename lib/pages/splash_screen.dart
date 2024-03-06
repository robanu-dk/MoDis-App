import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:modis/pages/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _start = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    checkInternetConnection(context);

    try {
      Connectivity().onConnectivityChanged.listen((event) {
        if (event == ConnectivityResult.wifi ||
            event == ConnectivityResult.mobile) {
          if (!_start) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Center(child: Text('Terhubung Internet')),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 8),
              ),
            );
          }

          _timer = Timer(const Duration(seconds: 10), () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, anitamtion, secondaryAnimation) =>
                    const LoginPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
            );
          });
        } else {
          _timer.cancel();
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(child: Text('Tidak Terhubung Internet')),
              backgroundColor: Colors.redAccent,
              duration: Duration(minutes: 5),
            ),
          );
          if (_start) {
            setState(() {
              _start = false;
            });
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> checkInternetConnection(context) async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.wifi &&
          connectivityResult != ConnectivityResult.mobile) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text('Tidak Terhubung Internet')),
            backgroundColor: Colors.redAccent,
            duration: Duration(minutes: 5),
          ),
        );
        if (_start) {
          setState(() {
            _start = false;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/logo.png',
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            const Text(
              'MoDis',
              style: TextStyle(
                fontSize: 50,
                fontFamily: 'italianno',
                fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

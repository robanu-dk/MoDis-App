import 'package:flutter/material.dart';
import 'package:modis/pages/splash_screen.dart';
import 'package:modis/providers/user.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MoDis());
}

class MoDis extends StatelessWidget {
  const MoDis({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => User(),
        )
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

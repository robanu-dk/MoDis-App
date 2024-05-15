import 'package:flutter/material.dart';
import 'package:modis/pages/splash_screen.dart';
import 'package:modis/providers/activity.dart';
import 'package:modis/providers/chats.dart';
import 'package:modis/providers/child.dart';
import 'package:modis/providers/events.dart';
import 'package:modis/providers/motivation.dart';
import 'package:modis/providers/user.dart';
import 'package:modis/providers/weight.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        ),
        ChangeNotifierProxyProvider<User, Child>(
          create: (_) => Child(),
          update: (_, user, listAccount) =>
              listAccount!..updateUser(user.userEmail, user.userToken),
        ),
        ChangeNotifierProxyProvider<User, Activity>(
          create: (_) => Activity(),
          update: (_, user, event) =>
              event!..updateEmailToken(user.userEmail, user.userToken),
        ),
        ChangeNotifierProxyProvider<User, Weight>(
          create: (_) => Weight(),
          update: (context, user, weight) =>
              weight!..updateEmailToken(user.userEmail, user.userToken),
        ),
        ChangeNotifierProxyProvider<User, MotivationVideo>(
          create: (_) => MotivationVideo(),
          update: (context, user, motivation) =>
              motivation!..updateEmailToken(user.userEmail, user.userToken),
        ),
        ChangeNotifierProxyProvider<User, Chats>(
          create: (context) => Chats(),
          update: (context, user, chat) =>
              chat!..updateEmailToken(user.userEmail, user.userToken),
        ),
        ChangeNotifierProxyProvider<User, EventsForDilans>(
          create: (_) => EventsForDilans(),
          update: (context, user, event) =>
              event!..setUserEmailToken(user.userEmail, user.userToken),
        ),
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

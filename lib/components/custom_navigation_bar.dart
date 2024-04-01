import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:modis/pages/beranda.dart';
import 'package:modis/pages/chat.dart';
import 'package:modis/pages/list_account.dart';
import 'package:modis/pages/profile.dart';
import 'package:modis/pages/video.dart';
import 'package:modis/providers/child.dart';
import 'package:modis/providers/user.dart';
import 'package:provider/provider.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    List<Widget> superMenu = [
      BottomNavigationItem(
        index: 0,
        currentIndex: currentIndex,
        icon: Icons.dataset_outlined,
        label: 'Beranda',
        action: () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          pushReplacement(context, const Beranda());
        },
      ),
      BottomNavigationItem(
        index: 1,
        currentIndex: currentIndex,
        icon: Icons.supervised_user_circle_rounded,
        label: 'List Akun',
        action: () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          pushReplacement(context, const ListAccount());
          Provider.of<Child>(context, listen: false)
              .getListData()
              .then((response) {
            if (response['status'] == 'error') {
              snackbarMessenger(
                context,
                MediaQuery.of(context).size.width * 0.4,
                Colors.red,
                'Gagal terhubung server',
              );
            }
          }).catchError((error) {
            snackbarMessenger(
              context,
              MediaQuery.of(context).size.width * 0.4,
              Colors.red,
              'Gagal terhubung server',
            );
          });
        },
      ),
      BottomNavigationItem(
        index: 2,
        currentIndex: currentIndex,
        icon: Icons.play_circle_outline,
        label: 'Video',
        action: () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          pushReplacement(context, const Video());
        },
      ),
      BottomNavigationItem(
        index: 3,
        currentIndex: currentIndex,
        icon: Ionicons.ios_chatbubbles,
        label: 'Chat',
        action: () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          pushReplacement(context, const Chat());
        },
      ),
      BottomNavigationItem(
        index: 4,
        currentIndex: currentIndex,
        icon: Icons.account_circle,
        label: 'Profil',
        action: () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          pushReplacement(context, const Profile());
        },
      ),
    ];

    if (Provider.of<User>(context).getUserRole() == 0) {
      superMenu.removeAt(1);
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0, -1),
            blurRadius: BorderSide.strokeAlignOutside,
          ),
        ],
      ),
      height: 61,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: superMenu,
      ),
    );
  }

  pushReplacement(BuildContext context, destination) async {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250), // Durasi animasi
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return destination;
        },
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void snackbarMessenger(BuildContext context, double leftPadding,
      Color backgroundColor, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          left: leftPadding,
          right: 9,
          bottom: MediaQuery.of(context).size.height * 0.65,
        ),
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class BottomNavigationItem extends StatelessWidget {
  const BottomNavigationItem({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.action,
  });

  final int currentIndex, index;
  final Function() action;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: action,
      icon: currentIndex == index
          ? Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(1, 98, 104, 1),
                    Color.fromRGBO(1, 135, 76, 1)
                  ],
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                  ),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          : Icon(
              icon,
              color: const Color.fromARGB(255, 105, 105, 105),
            ),
    );
  }
}

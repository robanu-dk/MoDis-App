import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/alert_input_implement.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/custom_navigation_bar.dart';
import 'package:modis/components/input_implement.dart';
import 'package:modis/components/logo.dart';
import 'package:modis/components/outline_button_implement.dart';
import 'package:modis/pages/edit_profile.dart';
import 'package:modis/pages/login.dart';
import 'package:modis/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _password = TextEditingController(),
      _confirmPassword = TextEditingController();

  bool _showPassword = false, _showConfirmPassword = false;
  final FocusNode _fPassword = FocusNode(), _fConfirmPassword = FocusNode();

  void resetValueUbahPassword() {
    _password.text = '';
    _confirmPassword.text = '';
    _fPassword.unfocus();
    _fConfirmPassword.unfocus();
    setState(() {
      _showPassword = false;
      _showConfirmPassword = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModisAppBar(
        title: const Logo(
          fontSize: 26,
          imageSize: 50,
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        action: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications,
            size: 27,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 8.0, bottom: 6.0),
            child: Card(
              shape: const RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: Color.fromARGB(255, 140, 140, 140),
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              color: Colors.white,
              surfaceTintColor: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: MediaQuery.of(context).size.width * 0.35,
                      decoration: const BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          offset: Offset(0.5, 0.5),
                          spreadRadius: BorderSide.strokeAlignOutside,
                          blurRadius: 0.3,
                        )
                      ], borderRadius: BorderRadius.all(Radius.circular(15.0))),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15.0)),
                        child: Consumer<User>(
                          builder: (context, user, child) =>
                              user.getUserProfileImage() != ''
                                  ? Image.network(
                                      'http://192.168.42.60:8080/API/Modis/public/${user.getUserProfileImage()}',
                                      alignment: Alignment.topCenter,
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    )
                                  : Image.asset(
                                      'images/default_profile_image.jpg',
                                      fit: BoxFit.cover,
                                    ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Consumer<User>(
                        builder: (context, user, child) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: user.getUserRole() == 0
                              ? [
                                  Text(
                                    user.userFullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      overflow: TextOverflow.clip,
                                    ),
                                    maxLines: 2,
                                  ),
                                  accountInformation(
                                    'Nama Pengguna:',
                                    user.userName,
                                  ),
                                  accountInformation(
                                    'Email:',
                                    user.userEmail,
                                  ),
                                  accountInformation(
                                    'Pendamping:',
                                    user.userGuide,
                                  ),
                                ]
                              : [
                                  Text(
                                    user.userFullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      overflow: TextOverflow.clip,
                                    ),
                                    maxLines: 2,
                                  ),
                                  accountInformation(
                                    'Nama Pengguna:',
                                    user.userName,
                                  ),
                                  accountInformation(
                                    'Email:',
                                    user.userEmail,
                                  ),
                                ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
                left: 13.0, right: 13.0, top: 6.0, bottom: 6.0),
            child: const Text(
              'Informasi Akun',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          OutlinedButtonModis(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration:
                      const Duration(milliseconds: 300), // Durasi animasi
                  pageBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation) {
                    return const EditProfile();
                  },
                  transitionsBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                      Widget child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
            childrens: const [
              Icon(
                Icons.account_circle_rounded,
                color: Colors.black,
              ),
              Text(
                ' Ubah Akun',
                style: TextStyle(color: Colors.black),
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.only(
                left: 13.0, right: 13.0, top: 6.0, bottom: 6.0),
            child: const Text(
              'Keamanan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          OutlinedButtonModis(
            onPressed: () {
              resetValueUbahPassword();
              showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setState) => AlertInput(
                    height: 275,
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ubah Kata Sandi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Ionicons.md_close),
                        )
                      ],
                    ),
                    headerPadding: const EdgeInsets.only(left: 8.0),
                    contents: [
                      Input(
                        border: const OutlineInputBorder(),
                        textController: _password,
                        label: 'Kata Sandi Baru',
                        focusNode: _fPassword,
                        isPassword: !_showPassword,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      Input(
                        border: const OutlineInputBorder(),
                        textController: _confirmPassword,
                        label: 'Konfirmasi Kata Sandi Baru',
                        focusNode: _fConfirmPassword,
                        isPassword: !_showConfirmPassword,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showConfirmPassword = !_showConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _showConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ],
                    contentAligment: 'vertical',
                    contentPadding: EdgeInsets.zero,
                    actionAligment: 'horizontal',
                    actions: [
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Colors.red),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          _fPassword.unfocus();
                          _fConfirmPassword.unfocus();
                          if (_password.text == _confirmPassword.text) {
                            loadingIndicator(context);
                            Provider.of<User>(context, listen: false)
                                .changePassword(_password.text)
                                .then((response) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              snackbarMessenger(
                                context,
                                MediaQuery.of(context).size.width * 0.4,
                                response['status'] == 'success'
                                    ? const Color.fromARGB(255, 0, 120, 18)
                                    : Colors.red,
                                response['message'],
                              );
                            }).catchError((error) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              snackbarMessenger(
                                context,
                                MediaQuery.of(context).size.width * 0.4,
                                Colors.red,
                                'Gagal terhubung server',
                              );
                            });
                          } else {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            snackbarMessenger(
                              context,
                              MediaQuery.of(context).size.width * 0.4,
                              Colors.red,
                              'Konfirmasi sandi salah',
                            );
                          }
                        },
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                            Color.fromRGBO(248, 198, 48, 1),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    actionPadding: const EdgeInsets.only(top: 25.0),
                  ),
                ),
              );
            },
            childrens: const [
              Icon(
                Icons.lock,
                color: Colors.black,
              ),
              Text(
                ' Ubah Kata Sandi',
                style: TextStyle(color: Colors.black),
              )
            ],
          ),
          OutlinedButtonModis(
            onPressed: () async {
              SharedPreferences pref = await SharedPreferences.getInstance();
              if (pref.containsKey('userData')) {
                pref.clear();
              }

              Provider.of<User>(context, listen: false).resetData();
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  transitionDuration:
                      const Duration(milliseconds: 500), // Durasi animasi
                  pageBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation) {
                    return const LoginPage();
                  },
                  transitionsBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                      Widget child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
            childrens: const [
              Icon(
                Icons.logout,
                color: Colors.black,
              ),
              Text(
                ' Keluar',
                style: TextStyle(color: Colors.black),
              )
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 4),
    );
  }

  Padding accountInformation(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color.fromARGB(255, 123, 123, 123),
              overflow: TextOverflow.clip,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color.fromARGB(255, 123, 123, 123),
              overflow: TextOverflow.clip,
            ),
            maxLines: 2,
          ),
        ],
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
          bottom: MediaQuery.of(context).size.height * 0.75,
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

  void loadingIndicator(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(154, 0, 0, 0),
          insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.3),
          content: const LoadingIndicator(
            indicatorType: Indicator.ballSpinFadeLoader,
            colors: [Colors.white],
          ),
        ),
      ),
    );
  }
}

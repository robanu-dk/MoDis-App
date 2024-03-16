import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modis/components/card_implement.dart';
import 'package:modis/components/input_implement.dart';
import 'package:modis/components/logo.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:modis/pages/regist.dart';
import 'package:modis/providers/user.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _start = true,
      _showInternetModal = false,
      _showPassword = false,
      _rememberMe = false;
  late Timer _timerInternet;
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void initState() {
    super.initState();

    checkInternetConnection(context);

    try {
      Connectivity().onConnectivityChanged.listen((event) {
        if (event == ConnectivityResult.wifi ||
            event == ConnectivityResult.mobile) {
          if (!_start) {
            Navigator.pop(context);

            setState(() {
              _showInternetModal = true;
            });

            showCheckInternetConnectivityModal(
              'images/icons/internet.png',
              'Terhubung Internet',
            );

            _timerInternet = Timer(const Duration(seconds: 3), () {
              Navigator.pop(context);
              setState(() {
                _showInternetModal = false;
              });
            });
          }
        } else {
          if (_showInternetModal) {
            _timerInternet.cancel();

            Navigator.pop(context);

            setState(() {
              _showInternetModal = false;
            });
          }
          showCheckInternetConnectivityModal(
            'images/icons/no internet.png',
            'Tidak Terhubung Internet',
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
        showCheckInternetConnectivityModal(
          'images/icons/no internet.png',
          'Tidak Terhubung Internet',
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

  showCheckInternetConnectivityModal(String iconPath, String content) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(115, 0, 0, 0),
        content: SizedBox(
          width: 130,
          height: 130,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                color: Colors.white,
                width: 70,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Text(
                  content,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Logo(
                  fontSize: 50,
                  imageSize: 130,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 20),
                child: CardImplement(
                  componentAligment: 'vertical',
                  height: 435,
                  opacity: 0.35,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 30),
                      child: const Text(
                        'MASUK',
                        style: TextStyle(
                          fontFamily: 'crimson',
                          color: Colors.white,
                          fontSize: 45,
                        ),
                      ),
                    ),
                    Input(
                      label: 'Nama Pengguna/ Email',
                      textController: _username,
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color.fromRGBO(120, 120, 120, 1),
                      ),
                    ),
                    Input(
                      label: 'Kata Sandi',
                      textController: _password,
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color.fromRGBO(120, 120, 120, 1),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                        icon: _showPassword
                            ? const Icon(
                                Icons.visibility,
                                color: Color.fromRGBO(120, 120, 120, 1),
                              )
                            : const Icon(
                                Icons.visibility_off,
                                color: Color.fromRGBO(120, 120, 120, 1),
                              ),
                      ),
                      isPassword: !_showPassword,
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(top: 8),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: InkWell(
                        onTap: () {},
                        child: const Text(
                          'Lupa Sandi',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Row(
                        children: [
                          Checkbox(
                            side: const BorderSide(
                              color: Colors.white,
                            ),
                            value: _rememberMe,
                            onChanged: (check) {
                              setState(() {
                                _rememberMe = check ?? false;
                              });
                            },
                          ),
                          const Text(
                            'Ingat Saya',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 18),
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: OutlinedButton(
                        onPressed: () {
                          Provider.of<User>(context, listen: false)
                              .login(
                            _username.text,
                            _password.text,
                            _rememberMe,
                          )
                              .then(
                            (value) {
                              print(value);
                            },
                          ).catchError(
                            (error) {
                              // message : unable to connect server
                              print(error);
                            },
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            const Color.fromRGBO(248, 198, 48, 1),
                          ),
                          shadowColor: MaterialStateProperty.all(Colors.black),
                          elevation: MaterialStateProperty.all(10),
                          side: MaterialStateProperty.all(BorderSide.none),
                        ),
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Belum punya akun? ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegistPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Buat Akun',
                              style: TextStyle(
                                color: Color.fromRGBO(248, 198, 48, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

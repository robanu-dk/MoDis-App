import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/card_implement.dart';
import 'package:modis/components/dropdown_implement.dart';
import 'package:modis/components/input_implement.dart';
import 'package:modis/components/logo.dart';
import 'package:modis/pages/login.dart';
import 'package:modis/providers/user.dart';
import 'package:provider/provider.dart';

class RegistPage extends StatefulWidget {
  const RegistPage({super.key});

  @override
  State<RegistPage> createState() => _RegistPageState();
}

class _RegistPageState extends State<RegistPage> {
  bool _showPassword = false,
      _showConfirmPassword = false,
      _start = true,
      _showInternetModal = false;
  late Timer _timerInternet;
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();
  dynamic _peran, _jenisKelamin;

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
                  height: 720,
                  opacity: 0.35,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 30),
                      child: const Text(
                        'BUAT AKUN',
                        style: TextStyle(
                          fontFamily: 'crimson',
                          color: Colors.white,
                          fontSize: 45,
                        ),
                      ),
                    ),
                    Input(
                      label: 'Nama Lengkap',
                      textController: _fullName,
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color.fromRGBO(120, 120, 120, 1),
                      ),
                    ),
                    Input(
                      label: 'Nama Pengguna',
                      textController: _username,
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color.fromRGBO(120, 120, 120, 1),
                      ),
                    ),
                    Input(
                      label: 'Email',
                      textController: _email,
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Color.fromRGBO(120, 120, 120, 1),
                      ),
                    ),
                    Dropdown(
                      value: _peran,
                      hint: 'Peran',
                      prefixIcon: const Icon(
                        Icons.group,
                        color: Color.fromRGBO(120, 120, 120, 1),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(
                                Icons.supervised_user_circle,
                                color: Color.fromRGBO(120, 120, 120, 1),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 14),
                                child: Text(
                                  'Pendamping',
                                  style: TextStyle(
                                    color: Color.fromRGBO(120, 120, 120, 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 0,
                          child: Row(
                            children: [
                              Icon(
                                Icons.accessible,
                                color: Color.fromRGBO(120, 120, 120, 1),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 14),
                                child: Text(
                                  'Penyandang disabilitas',
                                  style: TextStyle(
                                    color: Color.fromRGBO(120, 120, 120, 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onChange: (value) {
                        setState(() {
                          _peran = value;
                        });
                      },
                    ),
                    Dropdown(
                      value: _jenisKelamin,
                      hint: 'Jenis Kelamin',
                      prefixIcon: const Icon(
                        Icons.attribution,
                        color: Color.fromRGBO(120, 120, 120, 1),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(
                                Icons.female,
                                color: Color.fromRGBO(120, 120, 120, 1),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 14),
                                child: Text(
                                  'Perempuan',
                                  style: TextStyle(
                                    color: Color.fromRGBO(120, 120, 120, 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 0,
                          child: Row(
                            children: [
                              Icon(
                                Icons.male,
                                color: Color.fromRGBO(120, 120, 120, 1),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 14),
                                child: Text(
                                  'Laki-Laki',
                                  style: TextStyle(
                                    color: Color.fromRGBO(120, 120, 120, 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onChange: (value) {
                        setState(() {
                          _jenisKelamin = value;
                        });
                      },
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
                    Input(
                      label: 'Konfirmasi Kata Sandi',
                      textController: _passwordConfirm,
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color.fromRGBO(120, 120, 120, 1),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                        icon: _showConfirmPassword
                            ? const Icon(
                                Icons.visibility,
                                color: Color.fromRGBO(120, 120, 120, 1),
                              )
                            : const Icon(
                                Icons.visibility_off,
                                color: Color.fromRGBO(120, 120, 120, 1),
                              ),
                      ),
                      isPassword: !_showConfirmPassword,
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 35.0),
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: OutlinedButton(
                        onPressed: () {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => PopScope(
                                    canPop: false,
                                    child: AlertDialog(
                                      backgroundColor:
                                          const Color.fromARGB(154, 0, 0, 0),
                                      insetPadding: EdgeInsets.all(
                                          MediaQuery.of(context).size.width *
                                              0.3),
                                      content: const LoadingIndicator(
                                        indicatorType:
                                            Indicator.ballSpinFadeLoader,
                                        colors: [Colors.white],
                                      ),
                                    ),
                                  ));
                          Provider.of<User>(context, listen: false)
                              .regist(
                            _fullName.text,
                            _username.text,
                            _email.text,
                            _peran,
                            _jenisKelamin,
                            _password.text,
                            _passwordConfirm.text,
                          )
                              .then((response) {
                            Navigator.pop(context);
                            if (response['status'] == 'success') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                              snackbarMessenger(
                                context,
                                MediaQuery.of(context).size.width * 0.5,
                                const Color.fromARGB(255, 0, 120, 18),
                                'Berhasil membuat akun',
                              );
                            } else {
                              snackbarMessenger(
                                context,
                                MediaQuery.of(context).size.width * 0.4,
                                Colors.red,
                                response['message'],
                              );
                            }
                          }).catchError((error) {
                            snackbarMessenger(
                              context,
                              MediaQuery.of(context).size.width * 0.5,
                              Colors.red,
                              'Gagal terhubung server',
                            );
                          });
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
                          'Buat',
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
                            'Sudah punya akun? ',
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
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Masuk',
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

  void snackbarMessenger(BuildContext context, double leftPadding,
      Color backgroundColor, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          left: leftPadding,
          right: 9,
          bottom: MediaQuery.of(context).size.height * 0.9,
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

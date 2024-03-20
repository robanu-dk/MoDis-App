import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/alert_input_implement.dart';
import 'package:modis/components/card_implement.dart';
import 'package:modis/components/input_implement.dart';
import 'package:modis/components/logo.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:modis/pages/beranda.dart';
import 'package:modis/pages/regist.dart';
import 'package:modis/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController _username = TextEditingController(),
      _email = TextEditingController(),
      _password = TextEditingController(),
      _otp1 = TextEditingController(),
      _otp2 = TextEditingController(),
      _otp3 = TextEditingController(),
      _otp4 = TextEditingController();
  final FocusNode _focusNode1 = FocusNode(),
      _focusNode2 = FocusNode(),
      _focusNode3 = FocusNode(),
      _focusNode4 = FocusNode(),
      _resetNode = FocusNode();
  late String _kodeOtp;

  @override
  void initState() {
    super.initState();

    otp(_otp1, _focusNode2, true);
    otp(_otp2, _focusNode3, true);
    otp(_otp3, _focusNode4, true);
    otp(_otp4, _focusNode4, false);

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

  otp(TextEditingController controller, FocusNode focusNode, bool next) {
    controller.addListener(() {
      if (controller.text.isNotEmpty) {
        if (controller.text.length > 1) {
          controller.text = controller.text[1];
        }
        if (next) {
          focusNode.requestFocus();
        }
      }
    });
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

  saveLocalData(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = {
      'userFullName': data['name'],
      'userName': data['username'],
      'userToken': data['token'],
      'userProfileImage': data['profile_image'] ?? '',
      'userRole': data['role'].toString(),
    };

    prefs.setString('userData', jsonEncode(userData));
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
                        onTap: () {
                          forgetPassword(context);
                        },
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
                          loadingIndicator(context);
                          Provider.of<User>(context, listen: false)
                              .login(
                            _username.text,
                            _password.text,
                          )
                              .then(
                            (response) {
                              Navigator.pop(context);
                              if (response['status'] == 'success') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Beranda(),
                                  ),
                                );
                                snackbarMessenger(
                                  context,
                                  MediaQuery.of(context).size.width * 0.5,
                                  const Color.fromARGB(255, 0, 120, 18),
                                  'berhasil login',
                                  bottomPadding:
                                      MediaQuery.of(context).size.height * 0.75,
                                );
                                if (_rememberMe) {
                                  saveLocalData(response['data']);
                                }
                              } else {
                                snackbarMessenger(
                                  context,
                                  MediaQuery.of(context).size.width * 0.4,
                                  Colors.red,
                                  response['message'],
                                );
                              }
                            },
                          ).catchError(
                            (error) {
                              Navigator.pop(context);
                              snackbarMessenger(
                                context,
                                MediaQuery.of(context).size.width * 0.5,
                                Colors.red,
                                'Gagal terhubung server',
                              );
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

  void forgetPassword(BuildContext context) {
    _email.text = '';
    showDialog(
      context: context,
      builder: (context) => AlertInput(
        height: 200,
        header: const Text(
          'Lupa Sandi',
          style: TextStyle(
            fontFamily: 'crimson',
            fontSize: 30,
          ),
        ),
        headerPadding: const EdgeInsets.only(top: 8.0),
        contents: [
          Input(
            textController: _email,
            label: "Email",
            focusNode: _resetNode,
            prefixIcon: const Icon(Icons.email),
          )
        ],
        contentAligment: 'vertical',
        contentPadding: const EdgeInsets.only(top: 8.0),
        actionAligment: 'horizontal',
        actions: [
          OutlinedButton(
            onPressed: () {
              _resetNode.unfocus();
              if (_email.text != '') {
                loadingIndicator(context);
                Provider.of<User>(context, listen: false)
                    .forgetPassword(_email.text)
                    .then((response) {
                  Navigator.pop(context);

                  if (response['status'] == 'success') {
                    _otp1.text = '';
                    _otp2.text = '';
                    _otp3.text = '';
                    _otp4.text = '';

                    setState(() {
                      _kodeOtp = response['otp'];
                    });

                    showOtpInput(context);
                  } else {
                    snackbarMessenger(
                      context,
                      MediaQuery.of(context).size.width * 0.5,
                      Colors.red,
                      response['message'],
                    );
                  }
                }).catchError((error) {
                  Navigator.pop(context);
                  snackbarMessenger(
                    context,
                    MediaQuery.of(context).size.width * 0.5,
                    Colors.red,
                    "Gagal terhubung server",
                  );
                });
              } else {
                snackbarMessenger(
                  context,
                  MediaQuery.of(context).size.width * 0.5,
                  Colors.red,
                  "email harus diisi",
                );
              }
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
              'Reset',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ],
        actionPadding: const EdgeInsets.only(top: 20.0),
      ),
    );
  }

  void showOtpInput(BuildContext context) {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertInput(
        height: 250,
        header: Column(
          children: [
            const Text(
              'Kode OTP',
              style: TextStyle(
                fontFamily: 'crimson',
                fontSize: 30,
              ),
            ),
            Text(
              'Masukkan Kode OTP yang telah dikirim pada email ${_email.text}',
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);

                  forgetPassword(context);
                },
                child: const Text(
                  'ubah email',
                  style: TextStyle(
                    color: Color.fromRGBO(248, 198, 48, 1),
                  ),
                ),
              ),
            ),
          ],
        ),
        headerPadding: const EdgeInsets.only(top: 8.0),
        contents: [
          otpField(EdgeInsets.zero, _otp1, _focusNode1),
          otpField(const EdgeInsets.only(left: 10.0), _otp2, _focusNode2),
          otpField(const EdgeInsets.only(left: 10.0), _otp3, _focusNode3),
          otpField(const EdgeInsets.only(left: 10.0), _otp4, _focusNode4),
        ],
        contentAligment: 'horizontal',
        contentPadding: const EdgeInsets.only(top: 8.0),
        actionAligment: 'horizontal',
        actions: [
          OutlinedButton(
            onPressed: () {
              _focusNode1.unfocus();
              _focusNode2.unfocus();
              _focusNode3.unfocus();
              _focusNode4.unfocus();

              if (_kodeOtp ==
                  "${_otp1.text}${_otp2.text}${_otp3.text}${_otp4.text}") {
                loadingIndicator(context);
                Provider.of<User>(context, listen: false)
                    .resetPassword(_email.text, _kodeOtp)
                    .then((response) {
                  Navigator.pop(context);

                  if (response['status'] == 'success') {
                    Navigator.pop(context);

                    showDialog(
                      context: context,
                      builder: (context) => AlertInput(
                        height: 225,
                        header: const Text(
                          'Password Baru',
                          style: TextStyle(
                            fontFamily: 'crimson',
                            fontSize: 30,
                          ),
                        ),
                        headerPadding: const EdgeInsets.only(top: 8.0),
                        contents: [
                          Text(
                            'Berikut adalah password baru untuk ${_email.text}',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                const Text(
                                  'Password: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  response['password'],
                                  style: const TextStyle(
                                    color: Color.fromRGBO(248, 198, 48, 1),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        contentAligment: 'vertical',
                        contentPadding: const EdgeInsets.only(top: 20.0),
                        actionAligment: 'horizontal',
                        actions: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                const Color.fromRGBO(248, 198, 48, 1),
                              ),
                              shadowColor:
                                  MaterialStateProperty.all(Colors.black),
                              elevation: MaterialStateProperty.all(10),
                              side: MaterialStateProperty.all(BorderSide.none),
                            ),
                            child: const Text(
                              'Tutup',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          )
                        ],
                        actionPadding: const EdgeInsets.only(top: 20.0),
                      ),
                    );
                  } else {
                    snackbarMessenger(
                      context,
                      MediaQuery.of(context).size.width * 0.5,
                      Colors.red,
                      response['message'],
                    );
                  }
                }).catchError((error) {
                  Navigator.pop(context);
                  snackbarMessenger(
                    context,
                    MediaQuery.of(context).size.width * 0.5,
                    Colors.red,
                    "Gagal terhubung server",
                  );
                });
              } else {
                snackbarMessenger(
                  context,
                  MediaQuery.of(context).size.width * 0.5,
                  Colors.red,
                  "Kode OTP salah",
                );
              }
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
              'Kirim',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          )
        ],
        actionPadding: const EdgeInsets.only(top: 20.0),
      ),
    );
  }

  Container otpField(EdgeInsetsGeometry margin,
      TextEditingController controller, FocusNode focusNode) {
    return Container(
      margin: margin,
      width: 40.0,
      child: TextField(
        onTap: () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
        },
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.next,
        focusNode: focusNode,
      ),
    );
  }

  void snackbarMessenger(BuildContext context, double leftPadding,
      Color backgroundColor, String message,
      {double bottomPadding = 0}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          left: leftPadding,
          right: 9,
          bottom: bottomPadding == 0
              ? MediaQuery.of(context).size.height * 0.85
              : bottomPadding,
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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/alert_input_implement.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/circle_button.dart';
import 'package:modis/components/custom_navigation_bar.dart';
import 'package:modis/components/dropdown_implement.dart';
import 'package:modis/components/input_implement.dart';
import 'package:modis/components/logo.dart';
import 'package:modis/components/outline_button_implement.dart';
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
      _confirmPassword = TextEditingController(),
      _fullName = TextEditingController(),
      _userName = TextEditingController(),
      _email = TextEditingController();
  bool _showPassword = false, _showConfirmPassword = false, _preview = false;
  final FocusNode _fPassword = FocusNode(), _fConfirmPassword = FocusNode();
  final ImagePicker _picker = ImagePicker();
  dynamic _profileImage;
  late int _jenisKelamin;

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

  void resetValueAkun() {
    _fullName.text = Provider.of<User>(context, listen: false).userFullName;
    _userName.text = Provider.of<User>(context, listen: false).userName;
    _email.text = Provider.of<User>(context, listen: false).userEmail;
    setState(() {
      _jenisKelamin = Provider.of<User>(context, listen: false).userGender;
    });
  }

  void saveToLocal(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      var userData = {
        'userFullName': data['name'],
        'userName': data['username'],
        'userEmail': data['email'],
        'userToken': data['token'],
        'userProfileImage': data['profile_image'] ?? '',
        'userRole': data['role'].toString(),
        'userGender': data['jenis_kelamin'].toString(),
        'userGuide': data['guide'] ?? '',
      };

      prefs.setString('userData', jsonEncode(userData));
    }
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    _fullName.text = Provider.of<User>(context, listen: false).userFullName;
    _userName.text = Provider.of<User>(context, listen: false).userName;
    _email.text = Provider.of<User>(context, listen: false).userEmail;
    setState(() {
      _jenisKelamin = Provider.of<User>(context, listen: false).userGender;
    });
    // });
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
                left: 10.0, right: 10.0, top: 6.0, bottom: 6.0),
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
                        )
                      ], borderRadius: BorderRadius.all(Radius.circular(15.0))),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15.0)),
                        child: Consumer<User>(
                          builder: (context, user, child) =>
                              user.getUserProfileImage() != ''
                                  ? Image.network(
                                      'http://10.0.2.2:8080/API/Modis/public/${user.getUserProfileImage()}',
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
                          children: [
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
              resetValueAkun();
              setState(() {
                _preview = false;
              });
              showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setState) => AlertInput(
                    height: 550,
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ubah Akun',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Ionicons.md_close,
                          ),
                        ),
                      ],
                    ),
                    headerPadding: EdgeInsets.zero,
                    contents: [
                      Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(1.0, 1.0),
                            )
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        width: 110,
                        height: 110,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10.0)),
                          child: _preview
                              ? _profileImage == 'delete'
                                  ? Image.asset(
                                      'images/default_profile_image.jpg',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_profileImage.path),
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    )
                              : Consumer<User>(
                                  builder: (context, user, child) =>
                                      user.userProfileImage != ''
                                          ? Image.network(
                                              'http://10.0.2.2:8080/API/Modis/public/${user.userProfileImage}',
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
                      SizedBox(
                        width: 155,
                        child: FilledButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  height: 100,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    children: [
                                      CircleButtonModis(
                                        onPressed: () {
                                          _picker
                                              .pickImage(
                                                  source: ImageSource.camera)
                                              .then((value) {
                                            setState(() {
                                              _profileImage = value!;
                                              _preview = true;
                                            });
                                          });
                                          Navigator.pop(context);
                                        },
                                        icon: Ionicons.md_camera,
                                        label: 'Kamera',
                                        colors: const [
                                          Color.fromARGB(255, 180, 196, 255),
                                          Color.fromARGB(255, 0, 32, 147),
                                        ],
                                        margin:
                                            const EdgeInsets.only(left: 25.0),
                                      ),
                                      CircleButtonModis(
                                        onPressed: () {
                                          _picker
                                              .pickImage(
                                                  source: ImageSource.gallery)
                                              .then((value) {
                                            setState(() {
                                              _profileImage = value!;
                                              _preview = true;
                                            });
                                          });
                                          Navigator.pop(context);
                                        },
                                        icon: Icons.photo_library,
                                        label: 'Galeri',
                                        colors: const [
                                          Color.fromARGB(255, 200, 169, 255),
                                          Color.fromARGB(255, 82, 34, 165),
                                        ],
                                        margin:
                                            const EdgeInsets.only(left: 30.0),
                                      ),
                                      CircleButtonModis(
                                        onPressed: () {
                                          setState(() {
                                            _profileImage = 'delete';
                                            _preview = true;
                                          });
                                          Navigator.pop(context);
                                        },
                                        icon: Icons.delete,
                                        label: 'Hapus',
                                        colors: const [
                                          Color.fromARGB(255, 250, 148, 146),
                                          Color.fromARGB(255, 183, 28, 28),
                                        ],
                                        margin:
                                            const EdgeInsets.only(left: 30.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          style: const ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                            backgroundColor: MaterialStatePropertyAll(
                              Color.fromRGBO(248, 198, 48, 1),
                            ),
                          ),
                          child: const Text(
                            'Ubah Foto Profil',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Input(textController: _fullName, label: 'Nama Lengkap'),
                      Input(textController: _userName, label: 'Nama Pengguna'),
                      Input(textController: _email, label: 'Email'),
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
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.red),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(color: Colors.white),
                          )),
                      FilledButton(
                          onPressed: () {
                            loadingIndicator(context);
                            Provider.of<User>(context, listen: false)
                                .updateData(
                              _profileImage,
                              _fullName.text,
                              _userName.text,
                              _email.text,
                              _jenisKelamin,
                              _preview,
                            )
                                .then((response) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              if (response['status'] == 'success') {
                                saveToLocal(response['data']);
                                snackbarMessenger(
                                  context,
                                  MediaQuery.of(context).size.width * 0.4,
                                  const Color.fromARGB(255, 0, 120, 18),
                                  'data berhasil diperbarui',
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
                              Navigator.pop(context);
                              Navigator.pop(context);
                              snackbarMessenger(
                                context,
                                MediaQuery.of(context).size.width * 0.4,
                                Colors.red,
                                '$error Gagal terhubung server',
                              );
                            });
                          },
                          style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                              Color.fromRGBO(248, 198, 48, 1),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white),
                          )),
                    ],
                    actionPadding: const EdgeInsets.only(top: 20.0),
                  ),
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
                          'Ubah Password',
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
                        textController: _password,
                        label: 'Sandi Baru',
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
                        textController: _confirmPassword,
                        label: 'Konfirmasi Sandi Baru',
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
                ' Ubah Password',
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

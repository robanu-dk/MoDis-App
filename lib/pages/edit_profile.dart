import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/circle_button.dart';
import 'package:modis/components/input_implement.dart';
import 'package:modis/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _fullName = TextEditingController(),
      _userName = TextEditingController(),
      _email = TextEditingController();
  bool _preview = false;
  dynamic _profileImage;
  late int _jenisKelamin;

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
        'userGender': data['gender'].toString(),
        'userGuide': data['guide'] ?? '',
      };

      prefs.setString('userData', jsonEncode(userData));
    }
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

  @override
  void initState() {
    super.initState();
    _fullName.text = Provider.of<User>(context, listen: false).userFullName;
    _userName.text = Provider.of<User>(context, listen: false).userName;
    _email.text = Provider.of<User>(context, listen: false).userEmail;
    setState(() {
      _jenisKelamin = Provider.of<User>(context, listen: false).userGender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ModisAppBar(
        action: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications,
            size: 27,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.keyboard_backspace_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const Text(
              'Ubah Data',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
        paddingHeader: 1.5,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    children: [
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
                        width: 150,
                        height: 150,
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
                                              'https://modis.techcreator.my.id/${user.userProfileImage}',
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
                        margin: const EdgeInsets.only(top: 5.0),
                        child: FilledButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.white,
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  height: 100,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        margin: EdgeInsets.zero,
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
                                        margin: EdgeInsets.zero,
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
                                        margin: EdgeInsets.zero,
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
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: 200,
            child: Column(
              children: [
                Input(
                  textController: _fullName,
                  label: 'Nama Lengkap',
                  border: const OutlineInputBorder(),
                ),
                Input(
                    textController: _userName,
                    label: 'Nama Pengguna',
                    border: const OutlineInputBorder()),
                Input(
                    textController: _email,
                    label: 'Email',
                    border: const OutlineInputBorder()),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  margin: const EdgeInsets.only(top: 20.0),
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    border: Border.all(
                      strokeAlign: BorderSide.strokeAlignInside,
                      color: Colors.black,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: DropdownButtonFormField(
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      value: _jenisKelamin,
                      hint: const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.attribution,
                              color: Color.fromRGBO(120, 120, 120, 1),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text('Jenis Kelamin'),
                          ),
                        ],
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(
                                  Icons.female,
                                  color: Color.fromRGBO(120, 120, 120, 1),
                                ),
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
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(
                                  Icons.male,
                                  color: Color.fromRGBO(120, 120, 120, 1),
                                ),
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
                      onChanged: (value) {
                        setState(() {
                          _jenisKelamin = value!;
                        });
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: FilledButton(
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
                            'Gagal terhubung server',
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

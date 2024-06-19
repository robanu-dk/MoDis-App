import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/alert_input_implement.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/flex_row_information.dart';
import 'package:modis/components/input_implement.dart';
import 'package:modis/components/search_input.dart';
import 'package:modis/components/tab_button.dart';
import 'package:modis/components/tile_information_implement.dart';
import 'package:modis/providers/child.dart';
import 'package:provider/provider.dart';

class AddChildAccount extends StatefulWidget {
  const AddChildAccount({super.key});

  @override
  State<AddChildAccount> createState() => _AddChildAccountState();
}

class _AddChildAccountState extends State<AddChildAccount> {
  String _searchAvailableChild = '';
  final FocusNode _fSearchAvailableChild = FocusNode();
  bool _listAccount = true, isLoad = true;

  void snackbarMessenger(BuildContext context, double leftPadding,
      Color backgroundColor, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          left: leftPadding,
          right: 9,
          bottom: MediaQuery.of(context).size.height * 0.7,
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

  @override
  void initState() {
    super.initState();
    Provider.of<Child>(context, listen: false)
        .getListAvailableChild()
        .then((response) {
      setState(() {
        isLoad = false;
      });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ModisAppBar(
        paddingHeader: _listAccount ? 3.3 : 2.5,
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
              'Tambah Akun',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
        header: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            children: _listAccount
                ? [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TabButton(
                          isActive: _listAccount,
                          onPressed: () {
                            setState(() {
                              _listAccount = true;
                              _searchAvailableChild = '';
                            });
                          },
                          label: 'Daftar Akun',
                        ),
                        TabButton(
                          isActive: !_listAccount,
                          onPressed: () {
                            setState(() {
                              _listAccount = false;
                            });
                          },
                          label: 'Tambah Akun',
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        left: 15.0,
                        right: 15.0,
                      ),
                      child: SearchModis(
                        onSubmitted: (value) {
                          _fSearchAvailableChild.unfocus();
                          setState(() {
                            _searchAvailableChild = value;
                          });
                        },
                        focusNode: _fSearchAvailableChild,
                      ),
                    ),
                  ]
                : [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TabButton(
                          isActive: _listAccount,
                          onPressed: () {
                            setState(() {
                              _listAccount = true;
                              _searchAvailableChild = '';
                            });
                          },
                          label: 'Daftar Akun',
                        ),
                        TabButton(
                          isActive: !_listAccount,
                          onPressed: () {
                            setState(() {
                              _listAccount = false;
                            });
                          },
                          label: 'Tambah Akun',
                        ),
                      ],
                    ),
                  ],
          ),
        ),
      ),
      body: ListView(
        children: [
          _listAccount
              ? (isLoad
                  ? Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.3),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 30,
                            child: LoadingIndicator(
                              indicatorType: Indicator.ballSpinFadeLoader,
                            ),
                          ),
                          Text('loading'),
                        ],
                      ),
                    )
                  : ListAvailableChild(
                      searchAvailableChild: _searchAvailableChild,
                    ))
              : const FormCreateAccount(),
        ],
      ),
    );
  }
}

class ListAvailableChild extends StatelessWidget {
  const ListAvailableChild({
    super.key,
    required String searchAvailableChild,
  }) : _searchAvailableChild = searchAvailableChild;

  final String _searchAvailableChild;

  void snackbarMessenger(BuildContext context, double leftPadding,
      Color backgroundColor, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          left: leftPadding,
          right: 9,
          bottom: MediaQuery.of(context).size.height * 0.6,
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<Child>(
          builder: (context, provider, child) => provider.search(
                          data: provider.allAvailableChild,
                          filter: _searchAvailableChild) !=
                      null &&
                  provider
                          .search(
                              data: provider.allAvailableChild,
                              filter: _searchAvailableChild)
                          .length !=
                      0
              ? Column(
                  children: provider
                      .search(
                          data: provider.allAvailableChild,
                          filter: _searchAvailableChild)
                      .map<Widget>(
                        (element) => TileButton(
                          paddingLeft: 15.0,
                          paddingRight: 15.0,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertInput(
                                header: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Informasi Akun',
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
                                headerPadding: EdgeInsets.zero,
                                contents: [
                                  Container(
                                    height: 150,
                                    width: 150,
                                    decoration: const BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black,
                                          offset: Offset(0, 2),
                                          blurRadius: 1.0,
                                        ),
                                      ],
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20.0)),
                                      child: element['profile_image'] == null ||
                                              element['profile_image'] == ''
                                          ? Image.asset(
                                              'images/default_profile_image.jpg')
                                          : Image.network(
                                              'https://modis.techcreator.my.id/${element["profile_image"]}?timestamp=${DateTime.fromMillisecondsSinceEpoch(100)}',
                                              filterQuality: FilterQuality.high,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 20.0,
                                      left: 4.0,
                                      right: 4.0,
                                    ),
                                    child: Column(
                                      children: [
                                        FlexRowInformation(
                                          label: 'Nama Lengkap',
                                          value: element['name'],
                                        ),
                                        FlexRowInformation(
                                          label: 'Nama Pengguna',
                                          value: element['username'],
                                        ),
                                        FlexRowInformation(
                                          label: 'Email',
                                          value: element['email'],
                                        ),
                                        FlexRowInformation(
                                          label: 'Jenis Kelamin',
                                          value: element['gender'] == 1
                                              ? 'Perempuan'
                                              : 'Laki-Laki',
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                                contentAligment: 'vertical',
                                contentPadding:
                                    const EdgeInsets.only(top: 10.0),
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      loadingIndicator(context);
                                      Provider.of<Child>(context, listen: false)
                                          .addChildAccount(element['email'])
                                          .then((response) {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        if (response['status'] == 'success') {
                                          Navigator.pop(context);
                                          snackbarMessenger(
                                            context,
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                            const Color.fromARGB(
                                                255, 0, 120, 18),
                                            'berhasil memilih akun',
                                          );
                                        } else {
                                          snackbarMessenger(
                                            context,
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                            Colors.red,
                                            response['message'],
                                          );
                                        }
                                      }).catchError((error) {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        snackbarMessenger(
                                          context,
                                          MediaQuery.of(context).size.width *
                                              0.4,
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
                                      'Tambah',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                                actionPadding: const EdgeInsets.only(top: 20.0),
                              ),
                            );
                          },
                          height: 55,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20.0)),
                                child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: element['profile_image'] == null
                                      ? Image.asset(
                                          'images/default_profile_image.jpg')
                                      : Image.network(
                                          'https://modis.techcreator.my.id/${element["profile_image"]}?timestamp=${DateTime.fromMillisecondsSinceEpoch(100)}',
                                          filterQuality: FilterQuality.high,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Container(
                                width:
                                    MediaQuery.of(context).size.width - 100.0,
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  element['username'],
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                )
              : Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.25),
                  child: const Text('data tidak ditemukan'),
                ),
        )
      ],
    );
  }
}

class FormCreateAccount extends StatefulWidget {
  const FormCreateAccount({
    super.key,
  });

  @override
  State<FormCreateAccount> createState() => _FormCreateAccountState();
}

class _FormCreateAccountState extends State<FormCreateAccount> {
  final TextEditingController _name = TextEditingController(),
      _username = TextEditingController(),
      _email = TextEditingController(),
      _password = TextEditingController(),
      _confirmPassword = TextEditingController();
  final FocusNode _fName = FocusNode(),
      _fUsername = FocusNode(),
      _fEmail = FocusNode(),
      _fPassword = FocusNode(),
      _fConfirmPassword = FocusNode();
  int? _gender;
  bool _showPassword = false, _showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Input(
          label: 'Nama Lengkap',
          textController: _name,
          focusNode: _fName,
          prefixIcon: const Icon(
            Icons.person,
            color: Color.fromRGBO(120, 120, 120, 1),
          ),
          border: const OutlineInputBorder(),
        ),
        Input(
          label: 'Nama Pengguna',
          textController: _username,
          focusNode: _fUsername,
          prefixIcon: const Icon(
            Icons.person,
            color: Color.fromRGBO(120, 120, 120, 1),
          ),
          border: const OutlineInputBorder(),
        ),
        Input(
          label: 'Email',
          textController: _email,
          focusNode: _fEmail,
          prefixIcon: const Icon(
            Icons.email,
            color: Color.fromRGBO(120, 120, 120, 1),
          ),
          border: const OutlineInputBorder(),
        ),
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
              decoration: const InputDecoration(border: InputBorder.none),
              value: _gender,
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
                  _gender = value!;
                });
              }),
        ),
        Input(
          label: 'Kata Sandi',
          textController: _password,
          focusNode: _fPassword,
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
          border: const OutlineInputBorder(),
          isPassword: !_showPassword,
        ),
        Input(
          label: 'Konfirmasi Kata Sandi',
          textController: _confirmPassword,
          focusNode: _fConfirmPassword,
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
          border: const OutlineInputBorder(),
          isPassword: !_showConfirmPassword,
        ),
        Container(
          padding: const EdgeInsets.only(top: 25.0),
          width: MediaQuery.of(context).size.width * 0.6,
          child: OutlinedButton(
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => PopScope(
                  canPop: false,
                  child: AlertDialog(
                    backgroundColor: const Color.fromARGB(154, 0, 0, 0),
                    insetPadding:
                        EdgeInsets.all(MediaQuery.of(context).size.width * 0.3),
                    content: const LoadingIndicator(
                      indicatorType: Indicator.ballSpinFadeLoader,
                      colors: [Colors.white],
                    ),
                  ),
                ),
              );
              if (_gender == null ||
                  _name.text == '' ||
                  _username.text == '' ||
                  _email.text == '' ||
                  _password.text == '') {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                snackbarMessenger(
                  context,
                  MediaQuery.of(context).size.width * 0.4,
                  Colors.red,
                  'terdapat data yang kosong',
                );
              } else {
                if (_password.text == _confirmPassword.text) {
                  Provider.of<Child>(context, listen: false)
                      .createNewChildAccount(
                    _name.text,
                    _username.text,
                    _email.text,
                    _gender,
                    _password.text,
                  )
                      .then((response) {
                    Navigator.pop(context);
                    if (response['status'] == 'success') {
                      Navigator.pop(context);
                      snackbarMessenger(
                        context,
                        MediaQuery.of(context).size.width * 0.5,
                        const Color.fromARGB(255, 0, 120, 18),
                        'Berhasil menambahkan akun',
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
                    snackbarMessenger(
                      context,
                      MediaQuery.of(context).size.width * 0.5,
                      Colors.red,
                      'Gagal terhubung server',
                    );
                  });
                } else {
                  Navigator.pop(context);
                  snackbarMessenger(
                    context,
                    MediaQuery.of(context).size.width * 0.4,
                    Colors.red,
                    'kata sandi berbeda dengan konfirmasi kata sandi',
                  );
                }
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
              'Tambah',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void snackbarMessenger(BuildContext context, double leftPadding,
      Color backgroundColor, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          left: leftPadding,
          right: 9,
          bottom: MediaQuery.of(context).size.height * 0.6,
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

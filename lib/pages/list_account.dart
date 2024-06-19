import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/custom_navigation_bar.dart';
import 'package:modis/components/floating_action_button_modis.dart';
import 'package:modis/components/logo.dart';
import 'package:modis/components/search_input.dart';
import 'package:modis/components/tile_information_implement.dart';
import 'package:modis/pages/add_child_account.dart';
import 'package:modis/pages/child_account_information.dart';
import 'package:modis/providers/activity.dart';
import 'package:modis/providers/child.dart';
import 'package:modis/providers/weight.dart';
import 'package:provider/provider.dart';

class ListAccount extends StatefulWidget {
  const ListAccount({super.key});

  @override
  State<ListAccount> createState() => _ListAccountState();
}

class _ListAccountState extends State<ListAccount> {
  String _searchChildBasedAccount = '';
  final FocusNode _fSearchChildBasedAccount = FocusNode();
  bool isLoad = true;

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

  @override
  void initState() {
    super.initState();
    Provider.of<Child>(context, listen: false).getListData().then((response) {
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
        paddingHeader: 3.1,
        header: Container(
          padding: const EdgeInsets.only(top: 11.0, left: 12.0, right: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Akun Terhubung',
                style: TextStyle(
                  fontFamily: 'crimson',
                  fontSize: 25,
                ),
              ),
              SearchModis(
                focusNode: _fSearchChildBasedAccount,
                onSubmitted: (value) {
                  setState(() {
                    _searchChildBasedAccount = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: isLoad
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
          : Consumer<Child>(
              builder: (context, provider, child) => provider.search(
                              data: provider.listChild,
                              filter: _searchChildBasedAccount) !=
                          null &&
                      provider.listChild.length != 0
                  ? accountButton(provider: provider)
                  : const Center(
                      child: Text('Tidak ada data'),
                    ),
            ),
      floatingActionButton: FloatingActionButtonModis(
        onPressed: () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration:
                  const Duration(milliseconds: 300), // Durasi animasi
              pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return const AddChildAccount();
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
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  accountButton({required Child provider}) {
    return ListView(
      children: provider
          .search(data: provider.listChild, filter: _searchChildBasedAccount)
          .map<Widget>(
            (element) => TileButton(
              onPressed: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                _fSearchChildBasedAccount.unfocus();
                Provider.of<Activity>(context, listen: false)
                    .getListTodayActivityBasedGuide(
                  element['email'],
                )
                    .then((response) {
                  if (response['status'] == 'success') {
                    Provider.of<Weight>(context, listen: false)
                        .getUserWeight(element['email'], true)
                        .then((response) {
                      if (response['status'] == 'success') {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                                milliseconds: 300), // Durasi animasi
                            pageBuilder: (BuildContext context,
                                Animation<double> animation,
                                Animation<double> secondaryAnimation) {
                              return ChildAccountInformation(
                                data: element,
                              );
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
                      } else {
                        snackbarMessenger(
                          context,
                          MediaQuery.of(context).size.width * 0.4,
                          Colors.red,
                          'Gagal terhubung ke server',
                        );
                      }
                    }).catchError((error) {
                      snackbarMessenger(
                        context,
                        MediaQuery.of(context).size.width * 0.4,
                        Colors.red,
                        'Gagal terhubung ke server',
                      );
                    });
                  } else {
                    snackbarMessenger(
                      context,
                      MediaQuery.of(context).size.width * 0.4,
                      Colors.red,
                      'Gagal terhubung ke server',
                    );
                  }
                }).catchError((error) {
                  snackbarMessenger(
                    context,
                    MediaQuery.of(context).size.width * 0.4,
                    Colors.red,
                    'Gagal terhubung ke server',
                  );
                });
              },
              height: 55,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    child: element['profile_image'] == null
                        ? Image.asset('images/default_profile_image.jpg')
                        : Image.network(
                            'https://modis.techcreator.my.id/${element["profile_image"]}?timestamp=${DateTime.fromMillisecondsSinceEpoch(100)}',
                          ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 85.0,
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/custom_navigation_bar.dart';
import 'package:modis/components/logo.dart';
import 'package:modis/components/search_input.dart';
import 'package:modis/components/tile_information_implement.dart';
import 'package:modis/pages/add_child_account.dart';
import 'package:modis/providers/child.dart';
import 'package:provider/provider.dart';

class ListAccount extends StatefulWidget {
  const ListAccount({super.key});

  @override
  State<ListAccount> createState() => _ListAccountState();
}

class _ListAccountState extends State<ListAccount> {
  String _searchChildBasedAccount = '';
  final FocusNode _fSearchChildBasedAccount = FocusNode();

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
      body: Consumer<Child>(
        builder: (context, provider, child) => provider.search(
                    data: provider.listChild,
                    filter: _searchChildBasedAccount) !=
                null
            ? accountButton(provider: provider)
            : const Center(
                child: Text('Tidak ada data'),
              ),
      ),
      floatingActionButton: IconButton(
        onPressed: () {
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
        style: const ButtonStyle(
          fixedSize: MaterialStatePropertyAll(
            Size.fromRadius(kRadialReactionRadius * 1.5),
          ),
          backgroundColor: MaterialStatePropertyAll(
            Color.fromRGBO(1, 98, 104, 1.0),
          ),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
          size: 45.0,
        ),
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
                _fSearchChildBasedAccount.unfocus();
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: Text('wkwk'),
                  ),
                );
              },
              height: 55,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    child: element['profile_image'] == null
                        ? Image.asset('images/default_profile_image.jpg')
                        : Image.network(
                            'http://10.0.2.2:8080/API/Modis/public/${element["profile_image"]}',
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      element['username'],
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

class TabButton extends StatelessWidget {
  const TabButton({
    super.key,
    required this.listAccount,
    required this.onPressed,
    required this.label,
  });

  final bool listAccount;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      height: 50.0,
      child: listAccount
          ? FilledButton(
              onPressed: onPressed,
              style: const ButtonStyle(
                padding: MaterialStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 10.0)),
                backgroundColor: MaterialStatePropertyAll(
                  Color.fromRGBO(248, 198, 48, 1),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: const ButtonStyle(
                padding: MaterialStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 10.0),
                ),
              ),
              child: Text(
                label,
              ),
            ),
    );
  }
}

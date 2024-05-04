import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/custom_navigation_bar.dart';
import 'package:modis/components/logo.dart';
import 'package:modis/providers/chats.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final ScrollController _scollChat = ScrollController();
  final TextEditingController _keyboard = TextEditingController();
  late SharedPreferences _pref;
  final FocusNode _keyboardFocus = FocusNode();
  final double height = 70;
  int scale = 1;
  final Map<String, String> month = {
    '01': 'Januari',
    '02': 'Febuari',
    '03': 'Maret',
    '04': 'April',
    '05': 'Mei',
    '06': 'Juni',
    '07': 'Juli',
    '08': 'Agustus',
    '09': 'September',
    '10': 'Oktober',
    '11': 'November',
    '12': 'Desember',
  };

  scrollPosition() async {
    _pref = await SharedPreferences.getInstance();
    if (_pref.containsKey('scrollChatPosition')) {
      _scollChat.jumpTo(
        double.parse(
          _pref.getString('scrollChatPosition').toString(),
        ),
      );
    } else {
      _scollChat.jumpTo(0);
    }
    _pref.setString(
      'scrollChatPosition',
      _scollChat.position.maxScrollExtent.toString(),
    );
  }

  checkKeyboardMessage() async {
    _pref = await SharedPreferences.getInstance();
    if (_pref.containsKey('messageHistory')) {
      _keyboard.text = _pref.getString('messageHistory')!;
    }
  }

  @override
  void initState() {
    super.initState();
    try {
      Provider.of<Chats>(context, listen: false).getAllMessage().then((value) {
        scrollPosition();
      });
      checkKeyboardMessage();
    } catch (error) {
      print('error: $error');
    }
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

  String convertDateToString(String date) {
    List<String> dates = date.split('-');
    return '${dates[2]} ${month[dates[1]]} ${dates[0]}';
  }

  Widget inputMessage(double size) {
    return Container(
      height: size,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: const Color.fromARGB(255, 240, 240, 240),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.01),
            width: MediaQuery.of(context).size.width * 0.84,
            child: TextField(
              onChanged: (value) async {
                _pref = await SharedPreferences.getInstance();
                _pref.setString('messageHistory', value);
                if (_keyboard.text.split('\n').isNotEmpty) {
                  setState(() {
                    scale = _keyboard.text.split('\n').length;
                  });
                }
              },
              focusNode: _keyboardFocus,
              controller: _keyboard,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 35, vertical: 8),
                hintText: 'Ketik pesan',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(
                    Radius.circular(40),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              if (_keyboard.text != '') {
                Provider.of<Chats>(context, listen: false)
                    .sendMessage(_keyboard.text);
                _keyboard.text = '';
                _pref = await SharedPreferences.getInstance();
                _pref.remove('messageHistory');
                _keyboardFocus.unfocus();
              }
            },
            style: const ButtonStyle(
              padding: MaterialStatePropertyAll(EdgeInsets.zero),
            ),
            icon: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(1, 98, 104, 1.0),
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    MediaQuery.of(context).size.width * 0.12,
                  ),
                ),
              ),
              height: MediaQuery.of(context).size.width * 0.1,
              width: MediaQuery.of(context).size.width * 0.1,
              child: Icon(
                Ionicons.md_send,
                color: Colors.white,
                size: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          )
        ],
      ),
    );
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
        colorFreeSpace: const Color.fromARGB(255, 240, 240, 240),
      ),
      body: CustomScrollView(
        reverse: true,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedWidgetDelegate(
              child: inputMessage(scale > 8 ? 150 : height + (scale - 1) * 10),
              height: scale > 8 ? 150 : height + (scale - 1) * 10,
            ),
          ),
          Consumer<Chats>(
            builder: (context, chat, child) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  String today = DateTime.now().toString().split(' ')[0];
                  String dayChatCreated = chat.listMessage != null
                      ? chat.listMessage[index]['created_at'].split(' ')[0]
                      : '';
                  String timeChatCreated = chat.listMessage != null
                      ? chat.listMessage[index]['created_at'].split(' ')[1]
                      : '';
                  String timeChatCreatedInHoursMinutes = timeChatCreated != ''
                      ? '${timeChatCreated.split(":")[0]}:${timeChatCreated.split(":")[1]}'
                      : '';
                  dynamic chatMessage = chat.listMessage != null
                      ? [
                          chat.listMessage.length == index + 1
                              ? (chat.listMessage[index]['email'] != chat.email
                                  ? showProfile(context, chat, index)
                                  : Container())
                              : (chat.listMessage[index]['email'] !=
                                          chat.listMessage[index + 1]
                                              ['email'] ||
                                      chat.listMessage[index]['created_at']
                                              .split(' ')[0] !=
                                          chat.listMessage[index + 1]
                                                  ['created_at']
                                              .split(' ')[0]
                                  ? showProfile(context, chat, index)
                                  : Container(
                                      padding: const EdgeInsets.only(left: 30),
                                    )),
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  chat.listMessage[index]['email'] != chat.email
                                      ? Colors.white
                                      : const Color.fromRGBO(1, 98, 104, 1.0),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8.0)),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: chat.listMessage[index]['email'] !=
                                      chat.email
                                  ? [
                                      chat.listMessage.length == index + 1
                                          ? Text(
                                              chat.listMessage[index]['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : (chat.listMessage[index]['email'] !=
                                                      chat.listMessage[
                                                          index + 1]['email'] ||
                                                  chat.listMessage[index]
                                                              ['created_at']
                                                          .split(' ')[0] !=
                                                      chat.listMessage[index +
                                                              1]['created_at']
                                                          .split(' ')[0]
                                              ? Text(
                                                  chat.listMessage[index]
                                                      ['name'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : Container()),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 4.0),
                                            width: chat
                                                                .listMessage[index]
                                                                    ['message']
                                                                .length *
                                                            8.0 >
                                                        200 ||
                                                    chat.listMessage[index]['name'].length * 6.0 >
                                                        200.0
                                                ? 200.0
                                                : (chat
                                                            .listMessage[index]
                                                                ['message']
                                                            .length >
                                                        chat
                                                            .listMessage[index]
                                                                ['name']
                                                            .length
                                                    ? chat
                                                            .listMessage[index]
                                                                ['message']
                                                            .length *
                                                        8.0
                                                    : chat
                                                            .listMessage[index]
                                                                ['name']
                                                            .length *
                                                        6.0),
                                            child: Text(chat.listMessage[index]
                                                ['message']),
                                          ),
                                          Text(
                                            timeChatCreatedInHoursMinutes,
                                            style:
                                                const TextStyle(fontSize: 10.0),
                                          ),
                                        ],
                                      ),
                                    ]
                                  : [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 4.0),
                                            width: chat
                                                            .listMessage[index]
                                                                ['message']
                                                            .length *
                                                        8.0 >
                                                    200
                                                ? 200.0
                                                : chat
                                                        .listMessage[index]
                                                            ['message']
                                                        .length *
                                                    8.0,
                                            child: Text(
                                              chat.listMessage[index]
                                                  ['message'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            timeChatCreatedInHoursMinutes,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                            ),
                          )
                        ]
                      : [];
                  return chat.listMessage != null
                      ? Container(
                          margin: const EdgeInsets.only(
                              bottom: 8.0, left: 8.0, right: 8.0),
                          child: Column(
                            children: [
                              index == chat.listMessage.length - 1
                                  ? Container(
                                      decoration: const BoxDecoration(
                                          color: Color.fromRGBO(0, 0, 0, 0.7),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0))),
                                      padding: const EdgeInsets.all(8.0),
                                      margin:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        dayChatCreated == today
                                            ? 'Hari ini'
                                            : convertDateToString(
                                                dayChatCreated),
                                        style: const TextStyle(
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : (chat.listMessage[index]['created_at']
                                              .toString()
                                              .split(' ')[0] !=
                                          chat.listMessage[index + 1]
                                                  ['created_at']
                                              .toString()
                                              .split(' ')[0]
                                      ? Container(
                                          decoration: const BoxDecoration(
                                            color: Color.fromRGBO(0, 0, 0, 0.7),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          margin: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Text(
                                            dayChatCreated == today
                                                ? 'Hari ini'
                                                : convertDateToString(
                                                    dayChatCreated),
                                            style: const TextStyle(
                                                color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ))
                                      : Container()),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: chat.listMessage[index]
                                            ['email'] ==
                                        chat.email
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: chat.listMessage[index]['email'] ==
                                        chat.email
                                    ? chatMessage.reversed.toList()
                                    : chatMessage.toList(),
                              ),
                            ],
                          ),
                        )
                      : Container();
                },
                childCount:
                    chat.listMessage != null ? chat.listMessage.length : 1,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }

  SizedBox showProfile(BuildContext context, Chats chat, int index) {
    return SizedBox(
      width: 30,
      height: 30,
      child: IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: LayoutBuilder(
                builder: (context, constraint) =>
                    chat.listMessage[index]['profile_image'] == null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(24),
                            ),
                            child: Image.asset(
                              'images/default_profile_image.jpg',
                              fit: BoxFit.cover,
                              width: constraint.maxWidth,
                              height: constraint.maxWidth,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(24),
                            ),
                            child: Image.network(
                              'http://192.168.42.60:8080/API/Modis/public/${chat.listMessage[index]["profile_image"]}?timestamp=${DateTime.fromMillisecondsSinceEpoch(100)}',
                              fit: BoxFit.cover,
                              width: constraint.maxWidth,
                              height: constraint.maxWidth,
                            ),
                          ),
              ),
            ),
          );
        },
        style: const ButtonStyle(
          padding: MaterialStatePropertyAll(EdgeInsets.zero),
        ),
        icon: chat.listMessage[index]['profile_image'] == null
            ? ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(36),
                ),
                child: Image.asset(
                  'images/default_profile_image.jpg',
                  fit: BoxFit.cover,
                ),
              )
            : ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(36),
                ),
                child: Image.network(
                  'http://192.168.42.60:8080/API/Modis/public/${chat.listMessage[index]["profile_image"]}?timestamp=${DateTime.fromMillisecondsSinceEpoch(100)}',
                  fit: BoxFit.cover,
                  width: 30,
                  height: 30,
                ),
              ),
      ),
    );
  }
}

class PinnedWidgetDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  PinnedWidgetDelegate({required this.child, required this.height});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

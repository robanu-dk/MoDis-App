import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chats extends ChangeNotifier {
  String email = '', token = '';
  String apiDomain = 'https://modis.techcreator.my.id/api/chats';
  List<dynamic> listMessage = [];

  updateEmailToken(email, token) {
    this.email = email;
    this.token = token;
    notifyListeners();
  }

  Future<dynamic> getAllMessage() async {
    try {
      Uri url = Uri.parse('$apiDomain/get-all-chat');

      var allMessage = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(
          {
            'email': email,
            'offset': listMessage.length,
          },
        ),
      );

      var response = jsonDecode(allMessage.body);
      if (response['status'] == 'success') {
        if (response['data'].length != 0) {
          listMessage =
              [...listMessage.reversed, ...response['data']].reversed.toList();
          notifyListeners();
        }
      }

      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> sendMessage(String message) async {
    try {
      Uri url = Uri.parse('$apiDomain/send-message');

      var post = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(
          {
            'email': email,
            'message': message,
          },
        ),
      );

      var response = jsonDecode(post.body);

      return response;
    } catch (error) {
      throw error.toString();
    }
  }
}

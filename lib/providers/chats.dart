import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chats extends ChangeNotifier {
  String email = '', token = '';
  String apiDomain = 'http://192.168.42.60:8080/API/Modis/public/api/chats';
  dynamic listMessage;

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
          },
        ),
      );

      var response = jsonDecode(allMessage.body);
      if (response['status'] == 'success') {
        listMessage = response['data'];
        notifyListeners();
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
      if (response['status'] == 'success') {
        listMessage = response['data'];
        notifyListeners();
      }

      return response;
    } catch (error) {
      throw error.toString();
    }
  }
}

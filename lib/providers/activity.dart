import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Activity extends ChangeNotifier {
  String email = '',
      token = '',
      apiDomain = 'http://192.168.42.60:8080/API/Modis/public/api/event';
  dynamic listTodayActivity;

  updateEmailToken(String userEmail, String userToken) {
    email = userEmail;
    token = userToken;
    notifyListeners();
  }

  Future<dynamic> getListTodayActivityBasedGuide(String childEmail) async {
    try {
      listTodayActivity = null;

      Uri url = Uri.parse('$apiDomain/all-today-event-child-user-based-id');

      var post = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(
          {
            'guide_email': email,
            'user_email': childEmail,
          },
        ),
      );

      var response = jsonDecode(post.body);
      if (response['status'] == 'success') {
        listTodayActivity = response['data'];
        notifyListeners();
      }

      return response;
    } catch (error) {
      throw error.toString();
    }
  }
}

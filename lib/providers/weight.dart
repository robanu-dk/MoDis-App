import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Weight extends ChangeNotifier {
  String email = '',
      token = '',
      apiDomain = 'http://10.0.2.2:8080/API/Modis/public/api/weight';

  dynamic listWeightBasedGuide;

  updateEmailToken(String userEmail, String userToken) {
    email = userEmail;
    token = userToken;
    notifyListeners();
  }

  Future<dynamic> getUserWeightBasedGuide(String userEmail) async {
    listWeightBasedGuide = null;

    try {
      Uri url = Uri.parse('$apiDomain/weight-based-guide');

      var post = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(
          {
            'guide_email': email,
            'user_email': userEmail,
          },
        ),
      );

      var response = jsonDecode(post.body);

      if (response['status'] == 'success') {
        listWeightBasedGuide = response['data'];
      }
      notifyListeners();

      return response;
    } catch (error) {
      throw error.toString();
    }
  }
}

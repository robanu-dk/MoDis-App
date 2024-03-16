import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class User with ChangeNotifier {
  final String apiDomain = 'http://10.0.2.2:8080/API/Modis/public';

  Future<dynamic> login(String email, String password, bool remember) async {
    try {
      Uri url = Uri.parse('$apiDomain/api/user/login');

      var post = await http.post(
        url,
        body: jsonEncode(
          {
            'email': email,
            'password': password,
          },
        ),
      );

      var response = jsonDecode(post.body);
      if (response['status'] == 'success') {}

      return jsonDecode(post.body);
    } catch (error) {
      throw error.toString();
    }
  }
}

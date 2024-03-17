import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class User with ChangeNotifier {
  final String apiDomain = 'http://10.0.2.2:8080/API/Modis/public/api/user';

  Future<dynamic> login(String email, String password, bool remember) async {
    try {
      Uri url = Uri.parse('$apiDomain/login');

      var post = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
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

  Future<dynamic> regist(
      String fullName,
      String username,
      String email,
      dynamic peran,
      dynamic gender,
      String password,
      String confirmPassword) async {
    // validate nullable data
    if (fullName == '' ||
        username == '' ||
        email == '' ||
        peran == null ||
        gender == null) {
      return {
        'status': 'error',
        'message': 'Terdapat data yang belum terisi',
      };
    }

    // validate email
    final regex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!regex.hasMatch(email)) {
      return {
        'status': 'error',
        'message': 'Email yang digunakan salah',
      };
    }

    // validate password
    if (password != confirmPassword) {
      return {
        'status': 'error',
        'message': 'Konfirmasi kata sandi salah',
      };
    }

    // post data
    try {
      Uri url = Uri.parse('$apiDomain/registrasi');

      var post = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': fullName,
          'username': username,
          'email': email,
          'role': peran,
          'jenis_kelamin': gender,
          'password': password,
        }),
      );

      var response = jsonDecode(post.body);
      return response;
    } catch (error) {
      throw error.toString();
    }
  }
}

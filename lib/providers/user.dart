import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class User with ChangeNotifier {
  final String apiDomain = 'http://10.0.2.2:8080/API/Modis/public/api/user';
  String userFullName = '',
      userName = '',
      userToken = '',
      userProfileImage = '',
      userGuide = '';
  int userRole = 0;

  getUserRole() {
    return userRole;
  }

  setUserData(String? localData) {
    Map<String, dynamic> data =
        jsonDecode(localData.toString()) as Map<String, dynamic>;
    userFullName = data['userFullName'];
    userName = data['userName'];
    userToken = data['userToken'];
    userProfileImage = data['userProfileImage'];
    userRole = int.parse(data['userRole']);
    userGuide = data['userGuide'];
  }

  Future<dynamic> login(String email, String password) async {
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
      if (response['status'] == 'success') {
        userFullName = response['data']['name'];
        userName = response['data']['username'];
        userToken = response['data']['token'];
        userProfileImage = response['data']['profile_image'] ?? '';
        userGuide = response['data']['guide'] ?? '';
        userRole = response['data']['role'];
      }

      return response;
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

  Future<dynamic> forgetPassword(String email) async {
    try {
      Uri url = Uri.parse('$apiDomain/forget-password');
      var post = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
        }),
      );

      var response = jsonDecode(post.body);
      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> resetPassword(String email, String token) async {
    try {
      Uri url = Uri.parse('$apiDomain/generate-password');

      var post = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "token": token,
        }),
      );

      var response = jsonDecode(post.body);
      return response;
    } catch (error) {
      throw error.toString();
    }
  }
}

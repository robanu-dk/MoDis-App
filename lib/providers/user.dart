import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class User with ChangeNotifier {
  final String apiDomain =
      'http://192.168.42.60:8080/API/Modis/public/api/user';
  String userFullName = '',
      userName = '',
      userToken = '',
      userProfileImage = '',
      userEmail = '',
      userGuide = '';
  int userRole = 0, userGender = 0;

  getUserRole() {
    return userRole;
  }

  getUserProfileImage() {
    return userProfileImage;
  }

  setUserData(String? localData) {
    Map<String, dynamic> data =
        jsonDecode(localData.toString()) as Map<String, dynamic>;
    userFullName = data['userFullName'];
    userName = data['userName'];
    userEmail = data['userEmail'];
    userToken = data['userToken'];
    userProfileImage = data['userProfileImage'];
    userRole = int.parse(data['userRole']);
    userGender = int.parse(data['userGender']);
    userGuide = data['userGuide'];
    notifyListeners();
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
        userEmail = response['data']['email'];
        userToken = response['data']['token'];
        userProfileImage = response['data']['profile_image'] ?? '';
        userGuide = response['data']['guide'] ?? '';
        userGender = response['data']['gender'];
        userRole = response['data']['role'];
        notifyListeners();
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
          'gender': gender,
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

  Future<dynamic> updateData(
    dynamic profileImage,
    String name,
    String username,
    String email,
    int gender,
    bool upImage,
  ) async {
    try {
      Uri url = Uri.parse('$apiDomain/update');
      var request = http.MultipartRequest('POST', url);

      request.headers['authorization'] = 'Bearer $userToken';

      if (upImage) {
        if (profileImage == 'delete') {
          request.fields['reset_profile_image'] = '1';
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'profile_image',
              profileImage.path,
            ),
          );
        }
      }

      request.fields['name'] = name;
      request.fields['username'] = username;
      request.fields['old_email'] = userEmail;
      request.fields['new_email'] = email;
      request.fields['gender'] = gender.toString();

      var post = await request.send();
      var response = await http.Response.fromStream(post);

      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        userFullName = data['data']['name'];
        userName = data['data']['username'];
        userEmail = data['data']['email'];
        userProfileImage = data["data"]["profile_image"] != null
            ? '${data["data"]["profile_image"]}?timestamp=${DateTime.fromMillisecondsSinceEpoch(100)}'
            : '';
        userGender = int.parse(data['data']['gender']);
        notifyListeners();
      }

      return data;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> changePassword(String password) async {
    try {
      Uri url = Uri.parse('$apiDomain/change-password');

      var post = await http.put(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $userToken',
          },
          body: jsonEncode({
            'email': userEmail,
            'password': password,
          }));

      var response = jsonDecode(post.body);
      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> resetData() async {
    try {
      Uri url = Uri.parse('$apiDomain/logout');

      var logout = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'email': userEmail,
          },
        ),
      );

      var response = jsonDecode(logout.body);

      if (response['status'] == 'success') {
        userFullName = '';
        userName = '';
        userEmail = '';
        userToken = '';
        userProfileImage = '';
        userGuide = '';
        userRole = 0;
        notifyListeners();
      }

      return response;
    } catch (error) {
      throw error.toString();
    }
  }
}

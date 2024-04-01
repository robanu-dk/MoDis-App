import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Child extends ChangeNotifier {
  String email = '', token = '';
  dynamic listChild, allAvailableChild;
  String apiDomain = 'http://10.0.2.2:8080/API/Modis/public/api/guide';

  void updateUser(String email, String token) {
    this.email = email;
    this.token = token;
    notifyListeners();
  }

  search({dynamic data, String? filter}) {
    if (filter != '') {
      return data
          .where((element) =>
              element['username'].toString().contains(filter.toString()))
          .toList();
    } else {
      return data;
    }
  }

  Future<dynamic> getListData() async {
    try {
      Uri url = Uri.parse('$apiDomain/all-user-based-guide');

      var get = await http.post(
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

      var response = jsonDecode(get.body);
      if (response['status'] == 'success') {
        listChild = response['data'];
        notifyListeners();
      }

      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  getListAvailableChild() async {
    try {
      Uri url = Uri.parse('$apiDomain/all-user');

      var post = await http.post(
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

      var response = jsonDecode(post.body);

      if (response['status'] == 'success') {
        allAvailableChild = response['data'];
        notifyListeners();
      }
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> createNewChildAccount(
    String name,
    String username,
    String userEmail,
    int? gender,
    String password,
  ) async {
    try {
      Uri url = Uri.parse('$apiDomain/create-user');

      var post = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'guide_email': email,
            'user_email': userEmail,
            'name': name,
            'username': username,
            'gender': gender,
            'password': password,
          }));

      var response = jsonDecode(post.body);

      if (response['status'] == 'success') {
        getListData();
      }

      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> addChildAccount(String userEmail) async {
    try {
      Uri url = Uri.parse('$apiDomain/choose-user');

      var post = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(
          {
            'user_email': userEmail,
            'guide_email': email,
          },
        ),
      );

      var response = jsonDecode(post.body);
      if (response['status'] == 'success') {
        getListData();
        allAvailableChild = allAvailableChild
            .where((element) => element['email'] != userEmail)
            .toList();
      }

      return response;
    } catch (error) {
      throw error.toString();
    }
  }
}

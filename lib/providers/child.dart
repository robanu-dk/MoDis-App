import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Child extends ChangeNotifier {
  String email = '', token = '';
  dynamic listChild;
  String apiDomain = 'http://10.0.2.2:8080/API/Modis/public/api/guide';

  void updateUser(String email, String token) {
    this.email = email;
    this.token = token;
    notifyListeners();
  }

  getListChild({String? filter}) {
    if (filter != '') {
      return listChild
          .where((element) =>
              element['username'].toString().contains(filter.toString()))
          .toList();
    } else {
      return listChild;
    }
  }

  Future<dynamic> getListData() async {
    try {
      listChild = null;

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
}

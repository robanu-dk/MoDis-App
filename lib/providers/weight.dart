import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Weight extends ChangeNotifier {
  String email = '',
      token = '',
      apiDomain = 'http://10.0.2.2:8080/API/Modis/public/api/weight';

  dynamic listWeightUser;

  updateEmailToken(String userEmail, String userToken) {
    email = userEmail;
    token = userToken;
    notifyListeners();
  }

  dynamic filter(dynamic data, int? filter) {
    if (filter != null) {
      return data.where((element) {
        List<String> date = element['date'].toString().split('-');
        List<String> now = DateTime.now().toString().split(' ')[0].split('-');

        int diffYears = int.parse(now[0]) - int.parse(date[0]);
        int diffMonths = int.parse(now[1]) - int.parse(date[1]);

        int diff = diffYears * 12 + diffMonths;

        if (diff <= filter) {
          return true;
        }

        return false;
      }).toList();
    }

    return data;
  }

  Future<dynamic> getUserWeight(String userEmail, bool isGuide) async {
    listWeightUser = null;

    try {
      Uri url = Uri.parse(isGuide
          ? '$apiDomain/weight-based-guide'
          : '$apiDomain/weight-based-user');

      Map<String, dynamic> body;
      if (isGuide) {
        body = {
          'guide_email': email,
          'user_email': userEmail,
        };
      } else {
        body = {
          'email': email,
        };
      }

      var post = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(
          body,
        ),
      );

      var response = jsonDecode(post.body);

      if (response['status'] == 'success') {
        listWeightUser = response['data'];
      }
      notifyListeners();

      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> deleteWeight(
    String weightId,
    String? email,
    bool isGuide,
  ) async {
    try {
      Uri url = Uri.parse('$apiDomain/delete');

      Map<String, String> body = {};
      if (isGuide) {
        body = {
          'guide_email': this.email,
          'user_email': email!,
          'weight_id': weightId,
        };
      } else {
        body = {
          'email': this.email,
          'weight_id': weightId,
        };
      }

      var delete = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      var response = jsonDecode(delete.body);
      if (response['status'] == 'success') {
        listWeightUser = listWeightUser
            .where((element) => element['id'].toString() != weightId)
            .toList();
        notifyListeners();
      }

      return response;
    } catch (error) {
      throw error.toString();
    }
  }
}

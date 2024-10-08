import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Weight extends ChangeNotifier {
  String email = '',
      token = '',
      apiDomain = 'https://modis.techcreator.my.id/api/weight';

  dynamic listWeightUser;

  updateEmailToken(String userEmail, String userToken) {
    email = userEmail;
    token = userToken;
    notifyListeners();
  }

  dynamic filter(dynamic data, int filter, String unit) {
    if (filter != 0) {
      return data.where((element) {
        DateTime today = DateTime.now();
        DateTime dateFilter = DateTime(
            unit == 'tahun' ? today.year - filter : today.year,
            unit == 'bulan' ? today.month - filter : today.month,
            unit == 'minggu' ? today.day - (filter * 7) : today.day);
        DateTime date =
            DateTime.parse(element['date'].toString().split(' ')[0]);

        return date.isAfter(dateFilter);
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

  Future<dynamic> addWeight(
      String? userEmail, String weight, String date, bool isGuide) async {
    try {
      Uri url = Uri.parse('$apiDomain/store');

      Map<String, String> body;
      if (isGuide) {
        body = {
          'guide_email': email,
          'user_email': userEmail!,
          'weight': weight,
          'date': date,
        };
      } else {
        body = {
          'email': email,
          'weight': weight,
          'date': date,
        };
      }

      var post = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      var response = jsonDecode(post.body);

      if (response['status'] == 'success') {
        listWeightUser = response['data'];
        notifyListeners();
      }

      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> updateWeight(String weightId, String? userEmail,
      String weight, String date, bool isGuide) async {
    try {
      Uri url = Uri.parse('$apiDomain/update');

      Map<String, String> body = {};

      if (isGuide) {
        body = {
          'guide_email': email,
          'user_email': userEmail!,
          'weight_id': weightId,
          'weight': weight,
          'date': date,
        };
      } else {
        body = {
          'email': email,
          'weight_id': weightId,
          'weight': weight,
          'date': date,
        };
      }

      var update = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      var response = jsonDecode(update.body);

      if (response['status'] == 'success') {
        listWeightUser = response['data'];
        notifyListeners();
      }

      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> deleteWeight({
    required String weightId,
    String? email,
    required bool isGuide,
  }) async {
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

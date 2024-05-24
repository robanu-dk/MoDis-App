import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Activity extends ChangeNotifier {
  String email = '',
      token = '',
      apiDomain = 'https://modis.techcreator.my.id/api/activity';
  dynamic listTodayActivity, listMyActivities, userCoordinates;
  List<String> dateActivities = [];
  bool loadingGetData = true;

  updateEmailToken(String userEmail, String userToken) {
    email = userEmail;
    token = userToken;
    notifyListeners();
  }

  setLoadingGetData() {
    loadingGetData = true;
    notifyListeners();
  }

  Future<dynamic> getListTodayActivityBasedGuide(String childEmail) async {
    try {
      listTodayActivity = null;

      Uri url = Uri.parse('$apiDomain/all-today-activity-child-user-based-id');

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

  Future<dynamic> getListActivities() async {
    try {
      dateActivities = [];

      Uri url = Uri.parse('$apiDomain/get-all-my-activities');

      var get = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      var response = jsonDecode(get.body);
      if (response['status'] == 'success') {
        listMyActivities = response['data'];

        for (var activity in listMyActivities) {
          if (!dateActivities.contains(activity['date'])) {
            dateActivities.add(activity['date']);
          }
        }
        loadingGetData = false;
        notifyListeners();
      }

      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> getDetailActivities(String activityId) async {
    try {
      Uri url = Uri.parse('$apiDomain/get-detail-activity');

      var get = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(
          {
            'email': email,
            'activity_id': activityId,
          },
        ),
      );

      var response = jsonDecode(get.body);

      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> getUserCoordinates() async {
    try {
      Uri url = Uri.parse('$apiDomain/get-user-activity-coordinates');
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> saveActivity(
    String name,
    String date,
    String startTime,
    String endTime,
    String note,
    List<dynamic> participantId,
  ) async {
    try {
      Uri url = Uri.parse('$apiDomain/create-activity');

      Map<String, dynamic> data = {
        'email': email,
        'activity_name': name,
        'activity_date': date,
        'activity_start_time': startTime,
        'activity_end_time': endTime,
        'activity_note': note,
      };

      if (participantId.isNotEmpty) {
        data['list_child_account_id'] = participantId;
      }

      var post = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      var response = jsonDecode(post.body);

      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> updateActivity(
    int activityId,
    String name,
    String date,
    String startTime,
    String endTime,
    String note,
    List<dynamic> participantId,
  ) async {
    try {
      Uri url = Uri.parse('$apiDomain/update-activity');

      Map<String, dynamic> data = {
        'activity_id': activityId,
        'email': email,
        'activity_name': name,
        'activity_date': date,
        'activity_start_time': startTime,
        'activity_end_time': endTime,
        'activity_note': note,
        'list_child_account_id': participantId,
      };

      var update = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      var response = jsonDecode(update.body);

      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> deleteActivity(String activityId) async {
    try {
      Uri url = Uri.parse('$apiDomain/delete-activity');

      var delete = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
          'activity_id': activityId,
        }),
      );

      var response = jsonDecode(delete.body);

      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> startActivity() async {
    try {} catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> finishActivity() async {
    try {
      Uri url = Uri.parse('$apiDomain/finish-activity');
    } catch (error) {
      throw error.toString();
    }
  }
}

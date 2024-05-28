import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class Activity extends ChangeNotifier {
  String email = '',
      token = '',
      apiDomain = 'https://modis.techcreator.my.id/api/activity';
  dynamic listTodayActivity, listMyActivities, userCoordinates;
  List<String> dateActivities = [];
  bool loadingGetData = true;
  int seconds = 0, minutes = 0, hours = 0;
  List<LatLng> coordinates = [];
  Position? lastPosition;

  updateEmailToken(String userEmail, String userToken) {
    email = userEmail;
    token = userToken;
    notifyListeners();
  }

  setLoadingGetData() {
    loadingGetData = true;
    notifyListeners();
  }

  resetDuration() {
    seconds = 0;
    minutes = 0;
    hours = 0;
  }

  resetCoordinates() {
    coordinates = [];
  }

  bool countingDuration() {
    bool updateLocation = false;
    seconds++;

    if (seconds == 1 || seconds % 10 == 0) {
      trackingLocation();
    }

    if (seconds % 30 == 0) {
      updateLocation = true;
    }

    if (seconds >= 60) {
      minutes++;
      if (minutes >= 60) {
        hours++;
        minutes = 0;
      }
      seconds = 0;
    }
    notifyListeners();

    return updateLocation;
  }

  Future<List> setCoordinatesData(dynamic data, String email) async {
    coordinates = [];
    List<LatLng> latlong = [];

    try {
      dynamic filteredData =
          data.where((item) => item['email'] == email).toList()[0];

      if (filteredData['coordinates'] != null) {
        filteredData['coordinates'].toString().split(';').forEach((element) {
          List splitCoordinate = element.toString().split(' ');
          if (splitCoordinate.length == 2) {
            double lat = double.parse(splitCoordinate[0]);
            double lng = double.parse(splitCoordinate[1]);
            latlong.add(LatLng(lat, lng));
          }
        });
      }

      coordinates.addAll(latlong);

      return coordinates;
    } catch (error) {
      throw error.toString();
    }
  }

  trackingLocation() async {
    Position coordinate = await Geolocator.getCurrentPosition();
    if (coordinates.isNotEmpty) {
      if (Geolocator.distanceBetween(
              lastPosition!.latitude,
              lastPosition!.longitude,
              coordinate.latitude,
              coordinate.longitude) >
          5.0) {
        lastPosition = coordinate;
        coordinates.add(LatLng(coordinate.latitude, coordinate.longitude));
        notifyListeners();
      }
    } else {
      lastPosition = coordinate;
      coordinates.add(LatLng(coordinate.latitude, coordinate.longitude));
      notifyListeners();
    }
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
      loadingGetData = true;
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

  Future<dynamic> finishActivity(
      String activityId,
      String startTime,
      String finishingTime,
      List<LatLng> coordinates,
      List<dynamic> participants) async {
    try {
      Uri url = Uri.parse('$apiDomain/finish-activity');

      String coordinate = '';
      List participantId = [];

      for (var item in coordinates) {
        coordinate += '${item.latitude} ${item.longitude};';
      }

      for (var participant in participants) {
        participantId.add(participant['user_id']);
      }

      var post = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
          'activity_id': activityId,
          'list_child_account_id': participantId,
          'start_time': startTime,
          'finishing_time': finishingTime,
          'track_coordinates': coordinate,
        }),
      );

      var response = jsonDecode(post.body);

      return response;
    } catch (error) {
      throw error.toString();
    }
  }
}

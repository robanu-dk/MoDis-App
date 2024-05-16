import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventsForDilans extends ChangeNotifier {
  String email = '',
      token = '',
      apiDomain = 'https://modis.techcreator.my.id/api/event';
  dynamic listEvent;

  setUserEmailToken(email, token) {
    this.email = email;
    this.token = token;
    notifyListeners();
  }

  Future<dynamic> getAllEvents(String keyword) async {
    try {
      Uri url = Uri.parse('$apiDomain/get-all-event');

      var getData = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
          'search': keyword,
        }),
      );

      var response = jsonDecode(getData.body);

      if (response['status'] == 'success') {
        listEvent = response['data'];
        notifyListeners();
      }

      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> addEvent(
    String eventName,
    File? eventPoster,
    String eventType,
    String eventDate,
    String eventStartTime,
    String eventEndTime,
    String contactPerson,
    String location,
    String coordinateLocation,
  ) async {
    try {
      Uri url = Uri.parse('$apiDomain/create-event');

      Map<String, String> data = {
        'email': email,
        'event_name': eventName,
        'event_type': eventType,
        'event_date': eventDate,
        'start_time': eventStartTime,
        'end_time': eventEndTime,
        'location': location,
        'coordinate_location': coordinateLocation,
        'contact_person': contactPerson,
      };

      if (eventPoster == null) {
        var post = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $token',
          },
          body: jsonEncode(
            data,
          ),
        );
        var response = jsonDecode(post.body);
        return response;
      } else {
        var post = http.MultipartRequest('POST', url);

        post.headers['authorization'] = 'Bearer $token';

        post.fields.addAll(data);

        post.files.add(
          await http.MultipartFile.fromPath('event_poster', eventPoster.path),
        );

        var send = await post.send();

        var streamResponse = await http.Response.fromStream(send);
        var response = jsonDecode(streamResponse.body);
        return response;
      }
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> updateEvent(
    String eventName,
    String idEvent,
    File? eventPoster,
    String eventType,
    String eventDate,
    String eventStartTime,
    String eventEndTime,
    String contactPerson,
    String location,
    String coordinateLocation,
  ) async {
    try {
      Uri url = Uri.parse('$apiDomain/update-event');

      late Map<String, String> data;

      if (eventPoster != null) {
        data = {
          'email': email,
          'id_event': idEvent,
          'event_name': eventName,
          'event_type': eventType,
          'event_date': eventDate,
          'start_time': eventStartTime,
          'end_time': eventEndTime,
          'location': location,
          'coordinate_location': coordinateLocation,
          'contact_person': contactPerson,
          'update_poster': 'true',
        };
      } else {
        data = {
          'email': email,
          'id_event': idEvent,
          'event_name': eventName,
          'event_type': eventType,
          'event_date': eventDate,
          'start_time': eventStartTime,
          'end_time': eventEndTime,
          'location': location,
          'coordinate_location': coordinateLocation,
          'contact_person': contactPerson,
        };
      }

      if (eventPoster == null) {
        var post = await http.post(url,
            headers: {
              'Content-Type': 'application/json',
              'authorization': 'Bearer $token',
            },
            body: jsonEncode(data));

        var response = jsonDecode(post.body);
        return response;
      } else {
        var request = http.MultipartRequest('POST', url);

        request.headers['authorization'] = 'Bearer $token';

        request.fields.addAll(data);

        request.files.add(
          await http.MultipartFile.fromPath('event_poster', eventPoster.path),
        );

        var post = await request.send();

        var streamResponse = await http.Response.fromStream(post);

        var response = jsonDecode(streamResponse.body);

        return response;
      }
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> deleteEvent(String idEvent) async {
    try {
      Uri url = Uri.parse('$apiDomain/delete-event');

      var delete = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(
          {
            'email': email,
            'id_event': idEvent,
          },
        ),
      );

      var response = jsonDecode(delete.body);
      return response;
    } catch (error) {
      throw error.toString();
    }
  }
}

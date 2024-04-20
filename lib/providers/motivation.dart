import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MotivationVideo extends ChangeNotifier {
  String apiDomain = 'http://10.0.2.2:8080/API/Modis/public/api/video';
  String apiVideoCategories =
      'http://10.0.2.2:8080/API/Modis/public/api/video-categories';
  String token = '', email = '';
  dynamic listVideo, videoCategories;
  int lengthResponseData = 0;
  bool canScroll = true;

  updateEmailToken(String email, String token) {
    this.email = email;
    this.token = token;
    notifyListeners();
  }

  Future<dynamic> getAllVideo(
      int limit, int start, dynamic categoryId, String search) async {
    if (start == 0) {
      listVideo = null;
      canScroll = true;
    }

    try {
      Uri url = Uri.parse('$apiDomain/get-video');

      var getContent = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'limit': limit,
          'start': start,
          'category_id': categoryId,
          'search': search,
          'all_video': true,
        }),
      );

      var getCategories = await http.get(Uri.parse('$apiVideoCategories/get'));

      var response = jsonDecode(getContent.body);
      videoCategories = jsonDecode(getCategories.body)['data'];

      if (response['status'] == 'success') {
        lengthResponseData = response['data'].length = response['data'].length;

        if (start == 0) {
          listVideo = response['data'];
        } else {
          listVideo.addAll(response['data']);
        }

        if (response['data'].length == 0) {
          canScroll = false;
        }

        notifyListeners();
      }

      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> getVideoBasedGuide(
      int limit, int start, dynamic categoryId, String search) async {
    if (start == 0) {
      listVideo = null;
      canScroll = true;
    }

    try {
      Uri url = Uri.parse('$apiDomain/get-video');

      var getContent = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(
          {
            'email': email,
            'limit': limit,
            'start': start,
            'category_id': categoryId,
            'search': search,
            'all_video': false,
          },
        ),
      );

      var response = jsonDecode(getContent.body);

      if (response['status'] == 'success') {
        lengthResponseData = response['data'].length;

        if (start == 0) {
          listVideo = response['data'];
        } else {
          listVideo.addAll(response['data']);
        }

        if (response['data'].length == 0) {
          canScroll = false;
        }

        notifyListeners();
      }

      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> uploadVideo() async {
    try {} catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> updateVideo() async {
    try {} catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> deleteVideo() async {
    try {} catch (error) {
      throw error.toString();
    }
  }
}

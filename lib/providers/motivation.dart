import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MotivationVideo extends ChangeNotifier {
  String apiDomain = 'http://192.168.42.60:8080/API/Modis/public/api/video';
  String apiVideoCategories =
      'http://192.168.42.60:8080/API/Modis/public/api/video-categories';
  String token = '', email = '';
  dynamic listVideo, videoCategories;
  int lengthResponseData = 0;
  bool canScroll = true;

  updateEmailToken(String email, String token) {
    this.email = email;
    this.token = token;
    notifyListeners();
  }

  Future<dynamic> getCategories() async {
    try {
      var getCategories = await http.get(Uri.parse('$apiVideoCategories/get'));
      videoCategories = jsonDecode(getCategories.body)['data'];
      notifyListeners();
    } catch (error) {
      throw error.toString();
    }
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

  Future<dynamic> uploadVideo({
    required String title,
    required int category,
    required String description,
    required File thumbnail,
    required File video,
  }) async {
    try {
      Uri url = Uri.parse('$apiDomain/upload-video');

      var upload = http.MultipartRequest('POST', url);
      upload.headers['authorization'] = 'Bearer $token';
      upload.fields['email'] = email;
      upload.fields['title'] = title;
      upload.fields['category'] = category.toString();
      upload.fields['description'] = description;
      upload.files.add(
        await http.MultipartFile.fromPath('thumbnail', thumbnail.path),
      );
      upload.files.add(
        await http.MultipartFile.fromPath('video', video.path),
      );

      var post = await upload.send();
      var response = await http.Response.fromStream(post);

      var responseBody = jsonDecode(response.body);
      if (responseBody['status'] == 'success') {
        listVideo = responseBody['data'];
        notifyListeners();
      }

      return responseBody;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> updateVideo({
    required String videoId,
    required String title,
    required int category,
    required String description,
    required bool updateThumbnail,
    required bool updateVideo,
    File? thumbnail,
    File? video,
  }) async {
    try {
      Uri url = Uri.parse('$apiDomain/update-video');

      var request = http.MultipartRequest('POST', url);
      request.headers['authorization'] = 'Bearer $token';

      request.fields['video_id'] = videoId;
      request.fields['email'] = email;
      request.fields['title'] = title;
      request.fields['category'] = category.toString();
      request.fields['description'] = description;

      if (updateThumbnail) {
        request.files.add(
          await http.MultipartFile.fromPath('thumbnail', thumbnail!.path),
        );
      }

      if (updateVideo) {
        request.files.add(
          await http.MultipartFile.fromPath('video', video!.path),
        );
      }

      var update = await request.send();
      var response = await http.Response.fromStream(update);

      var responseBody = jsonDecode(response.body);
      if (responseBody['status'] == 'success') {
        listVideo = responseBody['data'];
        notifyListeners();
      }

      return responseBody;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<dynamic> deleteVideo(String videoId, int limit, int start,
      dynamic categoryId, String search) async {
    try {
      Uri url = Uri.parse('$apiDomain/delete-video');

      var deleteVideo = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(
          {
            'email': email,
            'video_id': videoId,
          },
        ),
      );

      var response = jsonDecode(deleteVideo.body);
      if (response['status'] == 'success') {
        getVideoBasedGuide(limit, start, categoryId ?? '', search);
      }

      return response;
    } catch (error) {
      throw error.toString();
    }
  }
}

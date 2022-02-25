import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:dio/adapter.dart';
import 'dart:io';

class Network {
  final String _url = 'https://koobits.iailab.net/api/fake';

  Map<String, Object>? result;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: 10000,
      receiveTimeout: 10000,
    ),
  );

  Future<dynamic> getData(apiUrl) async {
    _checkSSl();
    debugPrint('get date from: $apiUrl');
    var fullUrl = _url + apiUrl;
    try {
      final response = await _dio.get(fullUrl);
      debugPrint(response.toString());
      return json.decode(response.toString());
    } on DioError catch (e) {
      result = {
        'success': false,
        'message': e.message,
      };

      if (e.type == DioErrorType.connectTimeout) {
        EasyLoading.showError('網路有些不穩喔，請稍後再試！',
            duration: const Duration(seconds: 2), dismissOnTap: true);
        result = {
          'success': false,
          'message': {
            'error': ['網路有些不穩喔，請稍後再試！']
          },
        };
      }
      if (e.type == DioErrorType.other) {
        EasyLoading.showError('目前沒有您的環境沒有網路，請連結網路後再試看看！',
            duration: const Duration(seconds: 4), dismissOnTap: true);
        result = {
          'success': false,
          'message': {
            'error': ['網路有些不穩喔，請稍後再試！']
          },
        };
      }
      return result;
    }
  }

  Future<dynamic> postData(data, apiUrl) async {
    _checkSSl();
    var fullUrl = _url + apiUrl;
    debugPrint('post date from: $apiUrl');
    try {
      EasyLoading.show(status: '請稍候...');
      final response = await _dio.post(fullUrl, data: jsonEncode(data));
      inspect(response);
      EasyLoading.dismiss();
      return json.decode(response.toString());
    } on DioError catch (e) {
      EasyLoading.dismiss();
      result = {
        'success': false,
        'message': e.message,
      };
      if (e.type == DioErrorType.connectTimeout) {
        EasyLoading.showError('網路有些不穩喔，請稍後再試！',
            duration: const Duration(seconds: 2), dismissOnTap: true);
        result = {
          'success': false,
          'message': {
            'error': ['網路有些不穩喔，請稍後再試！']
          },
        };
      }
      if (e.type == DioErrorType.other) {
        EasyLoading.showError('目前沒有您的環境沒有網路，請連結網路後再試看看！',
            duration: const Duration(seconds: 4), dismissOnTap: true);
        result = {
          'success': false,
          'message': {
            'error': ['網路有些不穩喔，請稍後再試！']
          },
        };
      }

      return result;
    }
  }

  _checkSSl() {
    if (_url == 'https://koobits_backend.test/api/fake') {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
        return null;
      };
    }
  }
}

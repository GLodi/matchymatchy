import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

class NetUtils {
  final client = Dio(BaseOptions(connectTimeout: 5000));

  Future<dynamic> get(String url) {
    return client.get(url).then((Response response) {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw Exception();
      }

      return response.data;
    });
  }

  Future<dynamic> post(String url, FormData data) {
    return client.post(url, data: data).then((Response response) {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw Exception();
      }

      return response.data;
    });
  }

}
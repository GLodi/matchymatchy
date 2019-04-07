import 'dart:async';
import 'package:dio/dio.dart';

class NetUtils {
  final client = Dio();

  Future<dynamic> get(String url) {
    return client.get(url).catchError((e) => throw e).then((Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        throw Exception();
      }
      return response.data;
    });
  }

  Future<dynamic> post(String url, FormData data) {
    return client
        .post(url, data: data)
        .catchError((e) => throw e)
        .then((Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        throw Exception();
      }
      return response.data;
    });
  }
}

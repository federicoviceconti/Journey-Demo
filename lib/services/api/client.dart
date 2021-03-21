import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:journey_demo/services/api/base_response.dart';

class Client {
  final Map<String, String> headers = {};
  final String basePath;
  final Dio dio = Dio();

  Client({
    @required this.basePath,
  }) {
    _initInterceptors();
  }

  Future<T> makeGet<T extends BaseResponse>(
    endPath, {
    Map<String, dynamic> queryParameters,
    T Function(ResponseData) converter,
  }) async {
    Response<dynamic> response;

    try {
      response = await dio.get(
        basePath + endPath,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );
    } on DioError catch (e) {
      response = e.response;
    }

    final responseData = ResponseData(
        statusCode: response?.statusCode ?? 500,
        body: response.data.isNotEmpty ? response.data : null);
    return converter(responseData);
  }

  setCustomHeaders(String key, String value) {
    headers[key] = value;
  }

  setInterceptors(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }

  void _initInterceptors() {
    setInterceptors(
      InterceptorsWrapper(
        onRequest: (RequestOptions options) async {
          return options;
        },
        onResponse: (Response response) async {
          _printResponse(response);
          return response; // continue
        },
        onError: (DioError e) async {
          _printResponse(e.response);
          return e; //continue
        },
      ),
    );
  }

  void _printResponse(Response<dynamic> response) {
    debugPrint("| URL: ${response.request.uri}");
    debugPrint("|____________________________");
    debugPrint("| RESPONSE:");
    debugPrint("|____________________________");
    debugPrint("| ${response.data?.toString()?.substring(0, 5000)}");
    debugPrint("|____________________________");
  }
}

class ResponseData {
  final int statusCode;
  final dynamic body;

  ResponseData({this.statusCode, this.body});
}

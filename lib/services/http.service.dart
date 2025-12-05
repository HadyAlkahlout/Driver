import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:fuodz/constants/api.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth.service.dart';
import 'local_storage.service.dart';

class HttpService {
  String host = Api.baseUrl;
  late BaseOptions baseOptions;
  late Dio dio;
  late SharedPreferences prefs;

  Future<Map<String, String>> getHeaders({bool isRegister = false}) async {
    final userToken = await AuthServices.getAuthBearerToken();
    return isRegister ? {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: "$userToken",
      "lang": translator.activeLocale.languageCode,
    } : {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $userToken",
      "lang": translator.activeLocale.languageCode,
    };
  }

  HttpService() {
    LocalStorageService.getPrefs();

    baseOptions = new BaseOptions(
      baseUrl: host,
      validateStatus: (status) {
        return status != null && status <= 500;
      },
      // connectTimeout: 300,
    );
    dio = new Dio(baseOptions);
    dio.interceptors.add(getCacheManager().interceptor);
  }

  DioCacheManager getCacheManager() {
    return DioCacheManager(
      CacheConfig(baseUrl: host, defaultMaxAge: Duration(hours: 1)),
    );
  }

  //for get api calls
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    bool includeHeaders = true,
  }) async {
    //preparing the api uri/url
    String uri = "$host$url";

    //preparing the post options if header is required
    final mOptions =
        !includeHeaders ? null : Options(headers: await getHeaders());

    print("GET Request to: $uri");
    print("GET Query Parameters: $queryParameters");

    try {
      final response = await dio.get(uri, options: mOptions, queryParameters: queryParameters);
      print("GET Response Status: ${response.statusCode}");
      print("GET Response Data: ${response.data}");
      return response;
    } catch (error) {
      print("GET Error: $error");
      rethrow;
    }
  }

  //for post api calls
  Future<Response> post(String url, body, {bool includeHeaders = true, bool isRegister = false}) async {
    //preparing the api uri/url
    String uri = "$host$url";

    //preparing the post options if header is required
    final mOptions =
        !includeHeaders ? null : Options(headers: await getHeaders(isRegister: isRegister));

    print("POST Request to: $uri");
    print("POST Body: $body");
    print("POST Headers: ${mOptions?.headers}");

    try {
      final response = await dio.post(uri, data: body, options: mOptions);
      print("POST Response Status: ${response.statusCode}");
      print("POST Response Data: ${response.data}");
      return response;
    } catch (error) {
      print("POST Error: $error");
      rethrow;
    }
  }

  //for post api calls with file upload
  Future<Response> postWithFiles(
    String url,
    body, {
    bool includeHeaders = true,
  }) async {
    //preparing the api uri/url
    String uri = "$host$url";
    //preparing the post options if header is required
    final mOptions =
        !includeHeaders ? null : Options(headers: await getHeaders());

    Response response;

    try {
      response = await dio.post(
        uri,
        data: FormData.fromMap(body),
        options: mOptions,
      );
    } on DioException catch (error) {
      response = formatDioExecption(error);
    }

    return response;
  }

  Future<Response> postCustomFiles(
    String url,
    body, {
    FormData? formData,
    bool includeHeaders = true,
    bool isRegister = false,
  }) async {
    //preparing the api uri/url
    String uri = "$host$url";
    //preparing the post options if header is required
    final mOptions =
        !includeHeaders ? null : Options(headers: await getHeaders(isRegister: isRegister));

    Response response;

    try {
      response = await dio.post(
        uri,
        data: formData != null ? formData : FormData.fromMap(body),
        options: mOptions,
      );
    } on DioException catch (error) {
      response = formatDioExecption(error);
    }

    return response;
  }

  //for patch api calls
  Future<Response> patch(String url, Map<String, dynamic> body) async {
    String uri = "$host$url";
    return dio.patch(
      uri,
      data: body,
      options: Options(headers: await getHeaders()),
    );
  }

  //for delete api calls
  Future<Response> delete(String url) async {
    String uri = "$host$url";
    return dio.delete(uri, options: Options(headers: await getHeaders()));
  }

  Response formatDioExecption(DioException ex) {
    var response = Response(requestOptions: ex.requestOptions);
    response.statusCode = 400;
    try {
      if (ex.type == DioExceptionType.connectionTimeout) {
        response.data = {
          "message":
              "Connection timeout. Please check your internet connection and try again",
        };
      } else {
        response.data = {
          "message": "Please check your internet connection and try again",
        };
      }
    } catch (error) {
      response.statusCode = 400;
      response.data = {
        "message":
            (error is Map && error.containsKey("message"))
                ? "${error["message"]}"
                : "Please check your internet connection and try again",
      };
    }

    return response;
  }
}

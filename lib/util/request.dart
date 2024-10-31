import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:map/entity/token_response.dart';
import 'package:map/main.dart';
import 'package:map/repository/token_repository.dart';
import 'package:map/util/url.dart';

class NetworkService {
  static final TokenRepo _tokenRepo = getIt<TokenRepo>();
  static const String _baseUrl = Url.BASE_URL;

  static Future<dynamic> refreshToken() async {
    TokenResponse tokenResponse = await _getToken();
    var response = await http.post(Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'X-Refresh-Token': 'Bearer ${tokenResponse.refreshToken}'});
    if (response.statusCode == 200) {
      var responseData = json.decode(utf8.decode(response.bodyBytes));
      tokenResponse.accessToken = responseData['data']['accessToken'];
      tokenResponse.refreshToken = responseData['data']['refreshToken'];
      await _tokenRepo.updateToken(tokenResponse);
      return tokenResponse;
    } else {
      throw Exception('Failed to refresh token');
    }
  }

  static Future<dynamic> get(
      {required String url, Map<String, String>? headers}) async {
    try {
      TokenResponse tokenResponse = await _getToken();
      headers ??= {};
      headers.addAll({'Authorization': 'Bearer ${tokenResponse.accessToken}'});

      var response = await http.get(Uri.parse(url), headers: headers);
      // Nếu mã trạng thái là 401, tức là token hết hạn sẽ dùng refresh token để lấy token mới
      switch (response.statusCode) {
        case 401:
          await refreshToken();
          return await NetworkService.get(url: url, headers: headers);
        case 200:
          var responseData = json.decode(utf8.decode(response.bodyBytes));
          if (responseData['status'] == 200) {
            return responseData['data'];
          }
          throw Exception("${responseData['message']}");
        default:
          var errorData = json.decode(utf8.decode(response.bodyBytes));
          String errorMessage = errorData['message'] ?? 'Unknown error occurred';
          throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> post(
      {required String url,
      required Map<String, String>? headers,
      required Map<String, dynamic>? body}) async {
    try {
      TokenResponse tokenResponse = await _getToken();
      headers ??= {};
      headers.addAll({'Authorization': 'Bearer ${tokenResponse.accessToken}'});
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      switch (response.statusCode) {
        case 401:
          await refreshToken();
          return await NetworkService.post(
              url: url, headers: headers, body: body);
        case 200:
        case 201:
          var responseData = json.decode(utf8.decode(response.bodyBytes));
          if (responseData['status'] == 200 || responseData['status'] == 201) {
            return responseData['data'];
          }
          throw Exception("${responseData['message']}");
        default:
          var errorData = json.decode(utf8.decode(response.bodyBytes));
          String errorMessage = errorData['message'] ?? 'Unknown error occurred';
          throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> put(
      {required String url,
      required Map<String, String>? headers,
      required Map<String, dynamic>? body}) async {
    try {
      TokenResponse tokenResponse = await _getToken();
      headers ??= {};
      headers.addAll({'Authorization': 'Bearer ${tokenResponse.accessToken}'});
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      switch (response.statusCode) {
        case 401:
          await refreshToken();
          return await NetworkService.put(
              url: url, headers: headers, body: body);
        case 200:
        case 201:
        case 204:
          var responseData = json.decode(utf8.decode(response.bodyBytes));
          if (responseData['status'] == 204 || responseData['status'] == 200) {
            return responseData['data'];
          }
          throw Exception("${responseData['message']}");
        default:
          var errorData = json.decode(utf8.decode(response.bodyBytes));
          String errorMessage = errorData['message'] ?? 'Unknown error occurred';
          throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> patch(
      {required String url,
      required Map<String, String>? headers,
      required Map<String, dynamic>? body}) async {
    try {
      TokenResponse tokenResponse = await _getToken();
      headers ??= {};
      headers.addAll({'Authorization': 'Bearer ${tokenResponse.accessToken}'});

      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      switch (response.statusCode) {
        case 401:
          await refreshToken();
          return await NetworkService.patch(
              url: url, headers: headers, body: body);
        case 200:
        case 201:
        case 204:
          var responseData = json.decode(utf8.decode(response.bodyBytes));
          if (responseData['status'] == 204 || responseData['status'] == 200) {
            return responseData['data'];
          }
          throw Exception("${responseData['message']}");
        default:
          var errorData = json.decode(utf8.decode(response.bodyBytes));
          String errorMessage = errorData['message'] ?? 'Unknown error occurred';
          throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> delete(
      {required String url,
      required Map<String, String>? headers,
      required Map<String, dynamic>? body}) async {
    try {
      TokenResponse tokenResponse = await _getToken();
      headers ??= {};
      headers.addAll({'Authorization': 'Bearer ${tokenResponse.accessToken}'});
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      switch (response.statusCode) {
        case 401:
          await refreshToken();
          return await NetworkService.delete(
              url: url, headers: headers, body: body);
        case 200:
        case 201:
        case 204:
          var responseData = json.decode(utf8.decode(response.bodyBytes));
          if (responseData['status'] == 204 || responseData['status'] == 200) {
            return responseData['data'];
          }
          throw Exception("${responseData['message']}");
        default:
          var errorData = json.decode(utf8.decode(response.bodyBytes));
          String errorMessage = errorData['message'] ?? 'Unknown error occurred';
          throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<TokenResponse> _getToken() async {
    TokenResponse? tokenResponse = await _tokenRepo.getToken();
    if (tokenResponse == null) {
      return TokenResponse('', '', '');
    }
    return tokenResponse;
  }
}

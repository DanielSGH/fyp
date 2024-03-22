import 'dart:convert';
import 'dart:io';
import 'package:fyp/classes/flashcards/models/flashcard_model.dart';
import 'package:fyp/classes/users/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiWrapper {
  static final Future<SharedPreferences> apiPreferences = SharedPreferences.getInstance();

  static Future<Response> sendPostReq(String endpoint, Map<String, dynamic> body) async {
    String url = '${dotenv.get('API_BASE_URL')}$endpoint';
    String token = await apiPreferences.then((prefs) => prefs.getString('accessToken') ?? '');
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      var body = jsonDecode(response.body);
      throw Exception(body['error']);
    }

    return response;
  }

  static Future<Response> sendGetReq(String endpoint) async {
    String url = '${dotenv.get('API_BASE_URL')}$endpoint';
    var prefs = await apiPreferences;
    var accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      throw Exception('No access token found in local shared preferences');
    }

    var response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      var body = jsonDecode(response.body);
      throw Exception(body['error']);
    }

    return response;
  }

  static Future<User> getUserInfo() async {
    var response = await sendGetReq('/user/info');
    if (!isOk(response.statusCode)) {
      throw HttpException('${response.statusCode} ${response.reasonPhrase}');
    }

    var userInfo = jsonDecode(response.body);

    return User.fromJson(userInfo);
  }

  static Future<void> authUser(String username, String password, String selectedLanguage, [String? email]) async {
    Response response;

    if (email == null) {
      response = await sendPostReq('/auth/signin', {
        'username': username,
        'password': password,
      });
    } else {
      response = await sendPostReq('/auth/signup', {
        'username': username,
        'password': password,
        'email': email,
        'selectedLanguage': selectedLanguage,
      });
    }

    if (!isOk(response.statusCode)) {
      String? errorMsg = jsonDecode(response.body)?['error'];
      throw Exception(errorMsg ?? 'Invalid crendetials');
    }

    var tokens = jsonDecode(response.body);
    storeTokensInPrefs(tokens);
  }

  static Future<bool> refreshAccessToken() async {
    var prefs = await apiPreferences;
    var refreshToken = prefs.getString('refreshToken');
    var lastAccessToken = prefs.getString('accessToken');

    if (refreshToken == null) {
      throw Exception('No refresh token found in local shared preferences');
    }

    var response = await sendPostReq('/auth/refresh', {
      'token': refreshToken,
    });

    if (!isOk(response.statusCode)) {
      throw Exception('Invalid refresh token');
    }

    var tokens = jsonDecode(response.body);

    if (tokens['accessToken'] == lastAccessToken) {
      return false;
    }

    storeTokensInPrefs(tokens);

    return true;
  }

  static void storeTokensInPrefs(Map tokens) async {
    var prefs = await apiPreferences;

    for (var token in tokens.entries) {
      prefs.setString(token.key, token.value);
    }
  }

  static bool isOk(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static void updateFlashcard(FlashCard oldCard, FlashCard dueCard, String selectedLanguage) {
    sendPostReq('/user/updateFlashcard', {
      'oldCard': oldCard.id.oid,
      'newCard': dueCard.toJson(),
      'selectedLanguage': selectedLanguage
    });
  }
}
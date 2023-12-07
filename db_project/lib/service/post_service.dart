import 'dart:convert';
import 'package:http/http.dart' as http;

class PostServices {
  static Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static const baseUrl = "http://192.168.219.100:3000";
  static const String postTestUrl = "/api/test";
  static const String postinsertTestUrl = "/api/insertTest";

  static Future<bool> postTest(Map<String, dynamic> postData) async {
    print('/api/test 호출됨');
    String jsonData = jsonEncode(postData);

    try {
      return await http
          .post(
        Uri.parse(baseUrl + postTestUrl),
        headers: headers,
        body: jsonData,
      )
          .then((response) {
        if (response.statusCode == 200) {
          return true;
        } else {
          throw Exception();
        }
      });
    } catch (error) {
      return false;
    }
  }

  static Future<bool> postinsertTest(Map<String, dynamic> postData) async {
    print('/api/test 호출됨');
    String jsonData = jsonEncode(postData);

    try {
      return await http
          .post(
        Uri.parse(baseUrl + postinsertTestUrl),
        headers: headers,
        body: jsonData,
      )
          .then((response) {
        if (response.statusCode == 200) {
          return true;
        } else {
          throw Exception();
        }
      });
    } catch (error) {
      return false;
    }
  }
}

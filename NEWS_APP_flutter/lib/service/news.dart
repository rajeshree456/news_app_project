import 'package:flutter_application_3/config/backend_baseurl.dart'; 
import 'dart:convert';
import 'package:flutter_application_3/models/article_model.dart';
import 'package:http/http.dart' as http;


class News {
  List<ArticleModel> news = [];

  Future<void> getNews({int page = 1}) async {
    final String backendUrl = "$backendBaseUrl/news/basic";
    try {
      final response = await http.get(Uri.parse(backendUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == "success") {
          List<dynamic> articlesJson = data["articles"];
          news = articlesJson
              .map((json) => ArticleModel.fromJson(json))
              .toList();
        }
      } else {
        print("Error fetching news: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception fetching news: $e");
    }
  }
}

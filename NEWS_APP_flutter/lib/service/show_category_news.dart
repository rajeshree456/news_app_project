import 'dart:convert';
import 'package:flutter_application_3/config/api_key.dart';
import 'package:flutter_application_3/models/show_category.dart';
import 'package:http/http.dart' as http;

class ShowCategoryNews {
  List<ShowCategoryModel> categories = [];

  Future<void> getCategoriesNews(String category) async {
    String url;
    final String apiKey = ApiKey.newsApiKey;
    if (category.toLowerCase() == "india") {
      url = "https://newsapi.org/v2/everything?sortBy=publishedAt&sources=the-times-of-india&pageSize=20&language=en&apiKey=$apiKey";
    } else {
      url = "https://newsapi.org/v2/top-headlines?category=$category&language=en&pageSize=20&apiKey=$apiKey";
    }
    
    var response = await http.get(Uri.parse(url));
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    var jsonData = jsonDecode(response.body);
    if (jsonData['status'] == 'ok') {
      jsonData['articles'].forEach((element) {
        if (element["urlToImage"] != null && element['description'] != null) {
          ShowCategoryModel categoryModel = ShowCategoryModel(
            title: element["title"],
            description: element["description"],
            content: element["content"],
            author: element["author"],
            url: element["url"],
            urlToImage: element["urlToImage"],
          );
          categories.add(categoryModel);
        }
      });
    }
  }
}

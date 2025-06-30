import 'dart:convert';
import 'package:flutter_application_3/config/api_key.dart';
import 'package:flutter_application_3/models/slider_model.dart';
import 'package:http/http.dart' as http;

class Sliders {
  List<SliderModel> sliders = [];
  Future<void> getSlider() async {
    final String apiKey = ApiKey.newsApiKey;
    final String url =
        "https://newsapi.org/v2/top-headlines?sources=abc-news&pageSize=10&sortBy=publishedAt&apiKey=$apiKey";
    var response = await http.get(Uri.parse(url));
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    var jsonData = jsonDecode(response.body);
    if (jsonData['status'] == 'ok') {
      jsonData['articles'].forEach((element) {
        if (element["urlToImage"] != null && element['description'] != null) {
          SliderModel sliderModel = SliderModel(
            title: element["title"],
            description: element["description"],
            content: element["content"],
            author: element["author"],
            url: element["url"],
            urlToImage: element["urlToImage"],
          );
          sliders.add(sliderModel);
        }
      });
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleModel {
  final String title;
  final String summary;
  final String imageUrl;
  final String articleUrl;
  final String? fullText; 
  final Timestamp? timestamp;

  ArticleModel(
      {required this.title,
      required this.summary,
      required this.imageUrl,
      required this.articleUrl,
      this.fullText,
      this.timestamp});

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] ?? "No Title",
      summary: json['summary'] ?? "",
      imageUrl: json['image_url'] ?? "",
      articleUrl: json['article_url'] ?? "",
      fullText: json['full_text'] ?? "",
      timestamp: json['timestamp'] as Timestamp?, 
    );
  }
}

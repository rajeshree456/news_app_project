import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/article_model.dart';

class MyArticleWidget extends StatelessWidget {
  final String articleId;
  final ArticleModel article;

  const MyArticleWidget(
      {super.key, required this.articleId, required this.article});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("My Articles", style: TextStyle(color: Colors.deepPurple[900], fontSize: 26, fontWeight: FontWeight.bold),),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          article.imageUrl.isNotEmpty
              ? Image.network(
                  article.imageUrl,
                  height: screenHeight / 3,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'assets/images/customnews_4.png', 
                  height: screenHeight / 3,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  (article.fullText ?? "").isNotEmpty
                      ? article.fullText!
                      : article.summary,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

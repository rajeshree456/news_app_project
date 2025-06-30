
import 'package:flutter/material.dart';
import 'package:flutter_application_3/components/article_widget.dart';
import 'package:flutter_application_3/models/article_model.dart';
import 'package:flutter_application_3/pages/homepage.dart';
import 'package:flutter_application_3/service/news.dart';
import 'package:flutter_application_3/utils.dart'; 

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  NewsScreenState createState() => NewsScreenState();
}

class NewsScreenState extends State<NewsScreen> {
  List<ArticleModel> articles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadAllNews();
  }

  Future<void> loadAllNews() async {
    News newsService = News();
    await newsService.getNews();
    setState(() {
      articles = newsService.news;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("M Y  F E E D", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: screenHeight * 0.7,
                  child: ArticleWidget(
                    articleId: generateArticleId(
                      articles[index].articleUrl.isNotEmpty
                          ? articles[index].articleUrl
                          : "article_${index}",
                    ),
                    article: articles[index],
                  ),
                );
              },
            ),
    );
  }
}

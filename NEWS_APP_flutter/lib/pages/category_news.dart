
import 'package:flutter/material.dart';
import 'package:flutter_application_3/components/article_widget.dart';
import 'package:flutter_application_3/models/article_model.dart';
import 'package:flutter_application_3/models/show_category.dart';
import 'package:flutter_application_3/pages/article_web_view.dart';
import 'package:flutter_application_3/service/show_category_news.dart';
import 'package:flutter_application_3/utils.dart';

class CategoryNews extends StatefulWidget {
  final String name;
  const CategoryNews({super.key, required this.name});

  @override
  State<CategoryNews> createState() => _CategoryNewsState();
}

class _CategoryNewsState extends State<CategoryNews> {
  List<ShowCategoryModel> categories = [];
  bool _loading = true;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    getNews();
  }

  getNews() async {
    ShowCategoryNews showCategoryNews = ShowCategoryNews();
    await showCategoryNews.getCategoriesNews(widget.name.toLowerCase());
    categories = showCategoryNews.categories;
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(centerTitle: true,
        title: Text(widget.name, style: TextStyle(color: Colors.deepPurple[900], fontWeight: FontWeight.bold, fontSize: 27)),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: screenHeight * 0.7,
                  child: ArticleWidget(
                    articleId: generateArticleId(
                        categories[index].url ?? "article_${index}"),
                    article: ArticleModel(
                      title: categories[index].title ?? "No Title",
                      summary: categories[index].description ?? "No Summary Available",
                      imageUrl: categories[index].urlToImage ?? "",
                      articleUrl: categories[index].url ?? "",
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ShowCategory extends StatelessWidget {
  final String image;
  final String desc;
  final String title;
  final String url;

  const ShowCategory({
    super.key,
    required this.image,
    required this.desc,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              image,
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 3,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        desc,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (url.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ArticleWebView(blogUrl: url),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("No URL available for this article")),
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "Tap to read full article",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.thumb_up, color: Colors.blue),
                          Icon(Icons.comment, color: Colors.blue),
                          Icon(Icons.bookmark, color: Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

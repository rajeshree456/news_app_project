import 'package:flutter/material.dart';
import 'package:flutter_application_3/config/api_key.dart';
import 'package:flutter_application_3/pages/article_web_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List articles = [];
  bool isLoading = false;
  int page = 1;
  int pageSize = 5;
  bool hasMore = true;
  Map<String, List> _cache = {};
  Timer? _debounce;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchNews(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 800), () {
      _fetchNews(query, reset: true);
    });
  }

  Future<void> _fetchNews(String query, {bool reset = false}) async {
    if (query.isEmpty || (!hasMore && !reset)) return;

    if (reset) {
      setState(() {
        articles.clear();
        page = 1;
        hasMore = true;
      });
    }

    if (_cache.containsKey(query) && reset) {
      setState(() {
        articles = _cache[query]!;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });
    final String apiKey = ApiKey.newsApiKey;
    final String url = "https://newsapi.org/v2/everything?qInTitle=$query&language=en&page=$page&pageSize=$pageSize&sortBy=publishedAt&apiKey=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List newArticles = data["articles"];

      setState(() {
        articles.addAll(newArticles);
        _cache[query] = articles;
        hasMore = newArticles.length == pageSize;
        page++;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching news"), backgroundColor: Colors.red,),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search news...",
            border: InputBorder.none,
          ),
          onChanged: onSearchChanged,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading && articles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : articles.isEmpty
              ? Center(child: Text("No news found"))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: articles.length + 1,
                  itemBuilder: (context, index) {
                    if (index == articles.length) {
                      return hasMore
                          ? Center(child: CircularProgressIndicator())
                          : SizedBox();
                    }
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                      child: InkWell(
                        onTap: () {
                          String url = articles[index]["url"];
                          if (url.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ArticleWebView(blogUrl: url),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  articles[index]["urlToImage"] ?? "https://via.placeholder.com/150",
                                  width: 120,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      articles[index]["title"],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      articles[index]["description"] ?? "No description available",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "Published: ${articles[index]["publishedAt"].substring(0, 10)}",
                                      style: TextStyle(
                                          color: Colors.blueGrey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

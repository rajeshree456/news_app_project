import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/config/backend_baseurl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_3/components/comments_page.dart';
import 'package:flutter_application_3/models/article_model.dart';
import 'package:flutter_application_3/pages/article_web_view.dart';
import 'dart:ui';


class ArticleWidget extends StatefulWidget {
  final String articleId;
  final ArticleModel article;

  const ArticleWidget(
      {Key? key, required this.articleId, required this.article})
      : super(key: key);

  @override
  _ArticleWidgetState createState() => _ArticleWidgetState();
}

class _ArticleWidgetState extends State<ArticleWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoadingSummary = false;
  String _summaryText = "";

  static final Map<String, String> _summaryCache = {};

  final String _summarizeEndpoint = "$backendBaseUrl/summarize";

  Future<void> _fetchSummary() async {
    final textForSummary = widget.article.title;
    if (textForSummary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No content available for summarization.")),
      );
      return;
    }
    if (_summaryCache.containsKey(widget.article.articleUrl)) {
      setState(() {
        _summaryText = _summaryCache[widget.article.articleUrl]!;
      });
      return;
    }
    setState(() {
      _isLoadingSummary = true;
    });
    try {
      final uri = Uri.parse(
          "$_summarizeEndpoint?text=${Uri.encodeComponent(textForSummary)}");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final summary = data["summary"] as String? ?? "";
        if (summary.isNotEmpty &&
            summary != "Error generating summary." &&
            summary != "Summary not available.") {
          _summaryCache[widget.article.articleUrl] = summary;
          setState(() {
            _summaryText = summary;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Summary not available.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error fetching summary: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Exception: $e")));
    }
    setState(() {
      _isLoadingSummary = false;
    });
  }

  Future<void> toggleLike() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    final likeRef = _db
        .collection("articles")
        .doc(widget.articleId)
        .collection("likes")
        .doc(currentUser.uid);
    final likeDoc = await likeRef.get();
    if (likeDoc.exists) {
      await likeRef.delete();
    } else {
      await likeRef.set({'timestamp': FieldValue.serverTimestamp()});
    }
  }

  Future<void> toggleBookmark() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    final bookmarkRef = _db
        .collection("Users")
        .doc(currentUser.uid)
        .collection("bookmarks")
        .doc(widget.articleId);
    final bookmarkDoc = await bookmarkRef.get();
    if (bookmarkDoc.exists) {
      await bookmarkRef.delete();
    } else {
      await bookmarkRef.set({
        'articleId': widget.articleId,
        'timestamp': FieldValue.serverTimestamp()
      });
      final articleRef = _db.collection("articles").doc(widget.articleId);
      final articleDoc = await articleRef.get();
      if (!articleDoc.exists) {
        await articleRef.set({
          'title': widget.article.title,
          'summary': widget.article.summary,
          'article_url': widget.article.articleUrl,
          'image_url': widget.article.imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    

    return Card(
      margin: const EdgeInsets.all(4),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              widget.article.imageUrl,
              height: MediaQuery.of(context).size.height / 3,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return Image.asset(
                  'assets/images/customnews_4.png',
                  height: MediaQuery.of(context).size.height / 3,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.article.title,
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _summaryText.isNotEmpty
                        ? Text(
                            _summaryText,
                            style: const TextStyle(fontSize: 16),
                          )
                        : _isLoadingSummary
                            ? const Center(child: CircularProgressIndicator())
                            : Stack(
                                alignment: Alignment.center,
                                children: [
                                  ImageFiltered(
                                    imageFilter:
                                        ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                    child: Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: const Color.fromARGB(
                                          255, 250, 250, 250),
                                      child: const Center(
                                        child: Text(
                                          "In the quiet morning light, shimmering dew adorns emerald leaves and delicate petals. A gentle breeze whispers through ancient trees while birds sing joyful melodies, welcoming dawn’s warmth and peace, awakening nature with golden grace.",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black45),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _fetchSummary,
                                    child: const Text("Show Summary"),
                                  ),
                                ],
                              ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(6),
            ),
            child: GestureDetector(
              onTap: () {
                if (widget.article.articleUrl.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ArticleWebView(blogUrl: widget.article.articleUrl),
                    ),
                  );
                }
              },
              child: const Center(
                child: Text(
                  "T A P   T O   R E A D   F U L L   A R T I C L E",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: StreamBuilder<DocumentSnapshot>(
                        stream: _db
                            .collection("articles")
                            .doc(widget.articleId)
                            .collection("likes")
                            .doc(currentUser?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          bool liked =
                              snapshot.hasData && snapshot.data!.exists;
                          return Icon(
                            liked ? Icons.favorite : Icons.favorite_border,
                            color: liked
                                ? const Color.fromARGB(255, 193, 36, 25)
                                : Colors.purple[900],
                            size: 30,
                          );
                        },
                      ),
                      onPressed: toggleLike,
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: _db
                          .collection("articles")
                          .doc(widget.articleId)
                          .collection("likes")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Text("0");
                        return Text(snapshot.data!.docs.length.toString());
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon:
                      Icon(Icons.comment, color: Colors.purple[900], size: 30),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CommentsPage(articleId: widget.articleId),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: StreamBuilder<DocumentSnapshot>(
                    stream: _db
                        .collection("Users")
                        .doc(currentUser?.uid)
                        .collection("bookmarks")
                        .doc(widget.articleId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      bool bookmarked =
                          snapshot.hasData && snapshot.data!.exists;
                      return Icon(
                        bookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: bookmarked
                            ? Colors.purple[900]
                            : Colors.purple[900],
                        size: 30,
                      );
                    },
                  ),
                  onPressed: toggleBookmark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}

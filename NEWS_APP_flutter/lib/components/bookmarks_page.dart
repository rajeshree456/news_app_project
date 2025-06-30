import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/article_model.dart';
import 'package:flutter_application_3/pages/homepage.dart';
import 'package:flutter_application_3/components/article_widget.dart';
import 'package:flutter_application_3/admin/adminbookmark_widget.dart';

class BookmarksPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  BookmarksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Center(child: Text("Please log in to view bookmarks."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "MY BOOKMARKS",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection("Users")
            .doc(currentUser.uid)
            .collection("bookmarks")
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, bookmarkSnapshot) {
          if (!bookmarkSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookmarkDocs = bookmarkSnapshot.data!.docs;
          if (bookmarkDocs.isEmpty) {
            return const Center(child: Text("No bookmarks yet :(", style: TextStyle(fontSize: 20),));
          }
          return PageView.builder(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemCount: bookmarkDocs.length,
            itemBuilder: (context, index) {
              final articleId = bookmarkDocs[index].id;
              return FutureBuilder<DocumentSnapshot>(
                future: _db.collection("articles").doc(articleId).get(),
                builder: (context, articleSnapshot) {
                  if (articleSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!articleSnapshot.hasData ||
                      !articleSnapshot.data!.exists ||
                      articleSnapshot.data!.data() == null) {
                    return const Center(child: Text("Article not found"));
                  }
                  final articleData =
                      articleSnapshot.data!.data() as Map<String, dynamic>;
                  final article = ArticleModel(
                    title: articleData['title'] ?? "No Title",
                    summary: articleData['summary'] ?? "No Summary Available",
                    imageUrl: articleData['image_url'] ?? "",
                    articleUrl: articleData['article_url'] ?? "",
                    fullText: articleData['full_text'] ??
                        articleData['content'] ??
                        "",
                          timestamp: articleData['timestamp'], 
                  );
                  final bool isAdmin = articleData['isAdmin'] ?? false;
                  if (isAdmin) {
                    return SizedBox(
                      height: screenHeight * 0.7,
                      child: AdminArticleBookmarkWidget(
                          articleId: articleId, article: article),
                    );
                  } else {
                    return SizedBox(
                      height: screenHeight * 0.7,
                      child:
                          ArticleWidget(articleId: articleId, article: article),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

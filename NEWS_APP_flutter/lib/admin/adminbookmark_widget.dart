import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/article_model.dart';
import 'package:flutter_application_3/components/comments_page.dart';


class AdminArticleBookmarkWidget extends StatefulWidget {
  final String articleId;
  final ArticleModel article;

  const AdminArticleBookmarkWidget({super.key, required this.articleId, required this.article});

  @override
  AdminArticleBookmarkWidgetState createState() => AdminArticleBookmarkWidgetState();
}

class AdminArticleBookmarkWidgetState extends State<AdminArticleBookmarkWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> toggleLike() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    final likeRef = _db
        .collection("adminNews")
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
        'timestamp': FieldValue.serverTimestamp(),
        'isAdmin': true,
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
          'isAdmin': true,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final currentUser = _auth.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        widget.article.imageUrl.isNotEmpty
            ? Image.network(
                widget.article.imageUrl,
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
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.article.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),              
    const SizedBox(height: 8),
                Text(
                  (((widget.article.fullText ?? "").isNotEmpty)
                      ? widget.article.fullText!
                      : (widget.article.summary)),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: StreamBuilder<DocumentSnapshot>(
                      stream: _db
                          .collection("adminNews")
                          .doc(widget.articleId)
                          .collection("likes")
                          .doc(currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        bool liked = snapshot.hasData && snapshot.data!.exists;
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
                        .collection("adminNews")
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
              IconButton(
                icon: Icon(Icons.comment, color: Colors.purple[900], size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsPage(articleId: widget.articleId),
                    ),
                  );
                },
              ),
              IconButton(
                icon: StreamBuilder<DocumentSnapshot>(
                  stream: _db
                      .collection("Users")
                      .doc(currentUser?.uid)
                      .collection("bookmarks")
                      .doc(widget.articleId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    bool bookmarked = snapshot.hasData && snapshot.data!.exists;
                    return Icon(
                      bookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: bookmarked ? Colors.purple[900] : Colors.purple[900],
                      size: 30,
                    );
                  },
                ),
                onPressed: toggleBookmark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

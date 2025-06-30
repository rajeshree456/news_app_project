import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/article_model.dart';
import 'package:flutter_application_3/admin/admin_myarticles_widget.dart';

class AdminMyArticlesPage extends StatelessWidget {
  const AdminMyArticlesPage({Key? key}) : super(key: key);

  Future<void> _deleteArticle(String articleId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('adminNews')
          .doc(articleId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Article deleted successfully"), backgroundColor: Colors.green,),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting article: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text("Not logged in"));
    }
    return Scaffold(
      appBar: AppBar(title: const Text("My Posted Articles")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('adminNews')
            .where('adminId', isEqualTo: currentUser.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final articleDocs = snapshot.data!.docs;
          if (articleDocs.isEmpty) {
            return const Center(
                child: Text("You haven't posted any articles yet."));
          }
          return ListView.builder(
            itemCount: articleDocs.length,
            itemBuilder: (context, index) {
              final newsData =
                  articleDocs[index].data() as Map<String, dynamic>;
              final article = ArticleModel(
                title: newsData['title'] ?? "No Title",
                summary: newsData['summary'] ?? "",
                imageUrl: (newsData['urlToImage'] as String?) ?? "",
                articleUrl: newsData['article_url'] ?? "",
                fullText: newsData['content'] ?? "",
              );
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: ListTile(
                  leading:
                      ((newsData['urlToImage'] as String?)?.isNotEmpty ?? false)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                (newsData['urlToImage'] as String?) ?? "",
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/images/customnews_4.png', 
                              height: 80,
                              width: 80,
                            ),
                  title: Text(
                    article.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Article"),
                          content: const Text(
                              "Are you sure you want to delete this article?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteArticle(articleDocs[index].id, context);
                              },
                              child: const Text("Delete",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyArticleWidget(
                          articleId: articleDocs[index].id,
                          article: article,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

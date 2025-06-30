import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/admin/admin_article_widget.dart';
import 'package:flutter_application_3/models/article_model.dart';

class AdminNewsListPage extends StatelessWidget {
  final String adminId;
  final String adminName;

  const AdminNewsListPage({super.key, required this.adminId, required this.adminName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("News by $adminName"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('adminNews')
            .where('adminId', isEqualTo: adminId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final newsDocs = snapshot.data!.docs;
          if (newsDocs.isEmpty) {
            return const Center(child: Text("No news available from this admin."));
          }
          return ListView.builder(
            itemCount: newsDocs.length,
            itemBuilder: (context, index) {
              final newsData = newsDocs[index].data() as Map<String, dynamic>;
              final article = ArticleModel(
                title: newsData['title'] ?? "No Title",
                summary: newsData['content'] ?? "No Content Available", 
                imageUrl: newsData['urlToImage'] ?? "",
                articleUrl: newsData['article_url'] ?? "",
                fullText: newsData['content'] ?? "",
              );
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminArticleWidget(
                          articleId: newsDocs[index].id,
                          article: article,
                          adminName: adminName,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        if (newsData['urlToImage'] != null &&
                            (newsData['urlToImage'] as String).isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              newsData['urlToImage'],
                              width: 120,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Image.asset(
                            "assets/images/customnews_4.png",
                            width: 120,
                            height: 100,
                            
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                newsData['title'] ?? "No Title",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                newsData['content'] ?? "No Content Available",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[700]),
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
          );
        },
      ),
    );
  }
}

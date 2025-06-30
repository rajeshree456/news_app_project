import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentsPage extends StatefulWidget {
  final String articleId;
  const CommentsPage({Key? key, required this.articleId}) : super(key: key);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> postComment() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || _commentController.text.trim().isEmpty) return;

    final userDoc = await _db.collection("Users").doc(currentUser.uid).get();
    final username = userDoc.data()?['username'] ?? 'Anonymous';

    await _db
        .collection("articles")
        .doc(widget.articleId)
        .collection("comments")
        .add({
      'userId': currentUser.uid,
      'username': username,
      'commentText': _commentController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
  }

  Future<void> deleteComment(String commentId) async {
    await _db
        .collection("articles")
        .doc(widget.articleId)
        .collection("comments")
        .doc(commentId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection("articles")
                  .doc(widget.articleId)
                  .collection("comments")
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final comments = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final data = comments[index].data() as Map<String, dynamic>;
                    final commentId = comments[index].id;
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(data['username'] ?? "Unknown"),
                      subtitle: Text(data['commentText'] ?? ""),
                      trailing: (data['userId'] == currentUser?.uid)
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Delete Comment"),
                                    content: const Text(
                                        "Are you sure you want to delete this comment?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );
                                if (shouldDelete ?? false) {
                                  await deleteComment(commentId);
                                }
                              },
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Enter your comment",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: postComment,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

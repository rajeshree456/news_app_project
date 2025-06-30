import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_news_list_page.dart';

class AdminList extends StatelessWidget {
  const AdminList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .where('isAdmin', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final adminDocs = snapshot.data!.docs;
        if (adminDocs.isEmpty) {
          return const Center(child: Text("No admin accounts found."));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(), 
          itemCount: adminDocs.length,
          itemBuilder: (context, index) {
            final adminData = adminDocs[index].data() as Map<String, dynamic>;
            final adminId = adminDocs[index].id;
            final adminName = adminData['username'] ?? "Admin";
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: (adminData['profileImageUrl'] != null &&
                        (adminData['profileImageUrl'] as String).isNotEmpty)
                    ? NetworkImage(adminData['profileImageUrl'])
                    : null,
                child: (adminData['profileImageUrl'] == null ||
                        (adminData['profileImageUrl'] as String).isEmpty)
                    ? Text(
                        adminName.isNotEmpty ? adminName[0].toUpperCase() : "A",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              title: Text(
                adminName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminNewsListPage(
                      adminId: adminId,
                      adminName: adminName,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

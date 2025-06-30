import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/admin/admin_addnews.dart';
import 'package:flutter_application_3/admin/admin_myarticles_page.dart';
import 'package:flutter_application_3/admin/admin_profile.dart';
import 'package:flutter_application_3/admin/admin_utils.dart';
import 'package:flutter_application_3/pages/auth_page.dart';

class AdminHomepage extends StatefulWidget {
  const AdminHomepage({super.key});

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
  bool isAdmin = false;
  String adminEmail = "";
  String adminName = "Admin";
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
    _checkAdminStatus();
  }

  Future<void> _loadAdminProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        adminEmail = currentUser.email ?? "";
        adminName = currentUser.displayName ?? "Admin";
      });
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          profileImageUrl = data['profileImageUrl'];
          adminName = data['username'] ?? adminName;
        });
      }
    }
  }

  Future<void> _checkAdminStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      bool adminStatus = await isUserAdmin(currentUser.uid);
      setState(() {
        isAdmin = adminStatus;
      });
      print("Admin status for ${currentUser.uid}: $adminStatus");
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  Widget buildDashboardButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.deepPurple),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(width: 56), 
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "News",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Colors.black),
            ),
            Text(
              "Hub",
              style: TextStyle(
                  color: Color.fromARGB(230, 136, 30, 155),
                  fontWeight: FontWeight.bold,
                  fontSize: 26),
            )
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context); 
                        await _logout(); 
                      },
                      child: const Text("Logout",
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: isAdmin
          ? SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfilePage()),
                            ).then((_) {
                              _loadAdminProfile();
                            });
                          },
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: profileImageUrl != null &&
                                    profileImageUrl!.isNotEmpty
                                ? NetworkImage(profileImageUrl!)
                                : const AssetImage(
                                        'assets/images/default_avatar_4.png')
                                    as ImageProvider,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfilePage()),
                            ).then((_) {
                              _loadAdminProfile();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 239, 213,
                                  242), 
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Edit Profile",
                              style: TextStyle(
                                color: Colors
                                    .deepPurple, 
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Welcome Admin, $adminName',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          adminEmail,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        buildDashboardButton(
                          icon: Icons.add,
                          label: "Add News",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AdminNewsPage()),
                            );
                          },
                        ),
                        buildDashboardButton(
                          icon: Icons.article,
                          label: "My Articles",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminMyArticlesPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                ],
              ),
            )
          : const Center(child: Text("You are not an admin.")),
    );
  }
}

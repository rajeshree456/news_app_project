import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/admin/admin_homepage.dart';
import 'package:flutter_application_3/pages/homepage.dart';
import 'package:flutter_application_3/pages/login_register.dart';
import 'package:flutter_application_3/admin/admin_utils.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            return FutureBuilder<bool>(
              future: isUserAdmin(snapshot.data!.uid),
              builder: (context, adminSnapshot) {
                if (adminSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (adminSnapshot.hasData && adminSnapshot.data == true) {
                  return const AdminHomepage();
                } else {
                  return const HomePage();
                }
              },
            );
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}

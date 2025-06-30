import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/auth_page.dart';
import 'package:flutter_application_3/pages/homepage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String username = "Loading...";
  String email = "Loading...";
  String profileImageUrl = ""; 
  bool isUpdating = false; 

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _db.collection("Users").doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            username = data['username'] ?? "No Username";
            email = data['email'] ?? "No Email";
            profileImageUrl = data['profileImageUrl'] ?? "";
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> updateUsername(String newUsername) async {
    if (newUsername.isEmpty || newUsername == username) return;
    setState(() => isUpdating = true);
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _db.collection("Users").doc(user.uid).update({"username": newUsername});
        setState(() {
          username = newUsername;
          isUpdating = false;
        });
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error updating username: $e");
      setState(() => isUpdating = false);
    }
  }

  void _showEditDialog() {
    TextEditingController usernameController = TextEditingController(text: username);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Username"),
          content: TextField(
            controller: usernameController,
            decoration: InputDecoration(labelText: "Enter new username"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                String newUsername = usernameController.text.trim();
                await updateUsername(newUsername);
              },
              child: isUpdating
                  ? CircularProgressIndicator() 
                  : Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AuthPage()),
                  (route) => false,
                );
              },
              child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const String cloudName = "dog7sqopg";
    const String uploadPreset = "my_unsigned_preset";   
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    var request = http.MultipartRequest("POST", url);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var data = json.decode(responseData);
      print("Profile image uploaded successfully. URL: ${data["secure_url"]}");
      return data["secure_url"];
    } else {
      print("Cloudinary upload failed with status: ${response.statusCode}");
      return null;
    }
  }
  Future<void> _editProfilePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File imageFile = File(image.path);
      String? newUrl = await uploadImageToCloudinary(imageFile);
      if (newUrl != null) {
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          await _db.collection("Users").doc(currentUser.uid).update({
            'profileImageUrl': newUrl,
          });
          setState(() {
            profileImageUrl = newUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile picture updated successfully!"), backgroundColor: Colors.green,),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload profile picture"), backgroundColor: Colors.red,),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("M Y  P R O F I L E", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _editProfilePicture,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : null,
                  child: profileImageUrl.isEmpty
                      ? Icon(Icons.person, size: 50, color: Colors.black)
                      : null,
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: _editProfilePicture,
                child: Text("Change Profile Photo"),
              ),
              SizedBox(height: 20),
              Text(username,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
              Text(email, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _showEditDialog,
                icon: Icon(Icons.edit, color: Colors.black),
                label: Text("Edit Username", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colors.deepPurple[100],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

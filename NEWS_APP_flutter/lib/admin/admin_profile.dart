import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  String? currentProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        _usernameController.text = data['username'] ?? "";
        setState(() {
          currentProfileImageUrl = data['profileImageUrl'];
        });
      }
    }
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
      print("Image uploaded successfully. URL: ${data["secure_url"]}");
      return data["secure_url"];
    } else {
      print("Cloudinary upload failed with status: ${response.statusCode}");
      return null;
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  Future<void> _deleteProfilePicture() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    try {
      await FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).update({
        'profileImageUrl': '',  
      });
      setState(() {
        currentProfileImageUrl = '';
        _pickedImage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture deleted.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting profile picture: $e")),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      String? imageUrl = currentProfileImageUrl;
      if (_pickedImage != null) {
        imageUrl = await uploadImageToCloudinary(_pickedImage!);
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile image upload failed."), backgroundColor: Colors.red,),
          );
          return;
        }
      }

      await FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).update({
        'username': _usernameController.text.trim(),
        'profileImageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green,),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (currentProfileImageUrl != null && currentProfileImageUrl!.isNotEmpty
                            ? NetworkImage(currentProfileImageUrl!)
                            : const AssetImage('assets/images/default_avatar_4.png')) as ImageProvider,
                  ),
                ),
                const SizedBox(height: 10),
                
                TextButton(
                  onPressed: _pickImage,
                  child: const Text("Edit Profile Photo"),
                ),
                
                TextButton(
                  onPressed: _deleteProfilePicture,
                  child: const Text(
                    "Delete Profile Photo",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Press Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Please enter a username" : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text("Save Profile"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

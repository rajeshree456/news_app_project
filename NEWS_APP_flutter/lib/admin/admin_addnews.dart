import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AdminNewsPage extends StatefulWidget {
  const AdminNewsPage({super.key});

  @override
  _AdminNewsPageState createState() => _AdminNewsPageState();
}

class _AdminNewsPageState extends State<AdminNewsPage> {
  final _formKey = GlobalKey<FormState>();
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();


  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _isLoading = false;
  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const String cloudName =
        "dog7sqopg"; 
    const String uploadPreset =
        "my_unsigned_preset"; 
    final url =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    var request = http.MultipartRequest("POST", url);
    request.fields['upload_preset'] = uploadPreset;
    request.files
        .add(await http.MultipartFile.fromPath("file", imageFile.path));

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

  Future<void> submitNews() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String? imageUrl;
      if (_pickedImage != null) {
        imageUrl = await uploadImageToCloudinary(_pickedImage!);
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image upload failed.") ,  backgroundColor: Colors.red),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      final adminId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

      final newsData = {
        'title': _titleController.text.trim(),
        'content':
            _contentController.text.trim(), 
        'urlToImage': imageUrl ?? '',
        'publishedAt': DateTime.now().toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
        'adminId': adminId,
        'isAdmin': true, 
      };

      try {
        await FirebaseFirestore.instance.collection('adminNews').add(newsData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("News submitted successfully!"), backgroundColor: Colors.green,),
        );
        _titleController.clear();
        _contentController.clear();
        setState(() {
          _pickedImage = null;
          _isLoading = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting news: $e")),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add News")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  counterText: "",
                ),
                minLines: 2,
                maxLines: 2,
                maxLength: 75,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                inputFormatters: [LengthLimitingTextInputFormatter(75)],
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter a title"
                    : null,
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: "Content",
                  counterText: "",
                ),
                minLines: 13,
                maxLines: 13,
                maxLength: 500,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter content"
                    : null,
              ),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Pick Image from Gallery"),
              ),
              if (_pickedImage != null)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 200,
                  child: Image.file(
                    _pickedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator()) 
                  : ElevatedButton(
                      onPressed: submitNews,
                      child: const Text("Submit News"),
                    ),
            ],
          )),
        ),
      ),
    );
  }
}

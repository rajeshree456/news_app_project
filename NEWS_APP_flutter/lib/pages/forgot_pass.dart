import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key});

  @override
  State<ForgotPass> createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String? errorText; 
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> resetPassword() async {
    setState(() {
      isLoading = true;
      errorText = null;
    });

    if (!isValidEmail(emailController.text)) {
      setState(() {
        errorText = "Please enter a valid email address.";
        isLoading = false;
      });
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text);

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password reset link sent to your email."),
          backgroundColor: Colors.green,
        ),
      );

      emailController.clear();
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });

      if (e.code == 'user-not-found') {
        setState(() {
          errorText = "This email is not registered. Please check again.";
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          errorText = "Invalid email format. Please try again.";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred: ${e.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[400],
        title: Text(
          "Forgot Password",
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Reset Your Password",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[400],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Enter your registered email address to receive a password reset link.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                TextField(
                  controller: emailController,
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    fillColor: Colors.grey[200],
                    filled: true,
                    hintText: "Enter your email",
                    errorText: errorText,
                  ),
                ),

                const SizedBox(height: 20),

                isLoading
                    ? CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.purple),
                      )
                    : ElevatedButton(
                        onPressed: resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 20),
                        ),
                        child: Text(
                          "Send Reset Link",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),

                const SizedBox(height: 30),

                Text(
                  "Make sure to check your spam folder if you don’t see the email.",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

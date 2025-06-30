import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'forgot_pass.dart';
import 'my_textfield.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isButtonDisabled = true; 
  String? emailError;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateFields);
    passwordController.addListener(_validateFields);
  }

  void _validateFields() {
    final isEmailValid = _isValidEmail(emailController.text);
    final isPasswordEntered = passwordController.text.isNotEmpty;

    setState(() {
      emailError = isEmailValid ? null : "Invalid email format";
      isButtonDisabled = !(isEmailValid && isPasswordEntered);
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  void signUserIn() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      showErrorMessage("Invalid email or password. Please try again.");
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  const Icon(Icons.lock, size: 100, color: Colors.black),

                  const SizedBox(height: 20),

                  Text(
                    "Welcome back, you've been missed!",
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),

                  const SizedBox(height: 30),

                  MyTextfield(
                    controller: emailController,
                    hintText: "Enter email",
                    obscureText: false,
                    errorText: emailError,
                    prefixIcon: Icon(Icons.email),

                  ),

                  const SizedBox(height: 15),

                  MyTextfield(
                    controller: passwordController,
                    hintText: "Enter password",
                    obscureText: !isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(mainAxisAlignment:MainAxisAlignment.end, children: [GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ForgotPass()),
                      );
                    },
        
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ]
              ),
                  

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: isButtonDisabled ? null : signUserIn,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.3,
                        vertical: 15,
                      ),
                      backgroundColor: isButtonDisabled
                          ? Colors.grey
                          : Colors.purple[400],
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Not a member? ", style: TextStyle(fontSize: 16),),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Register here",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

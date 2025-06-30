import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_3/models/database_auth.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final _db = DatabaseAuth();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String? emailError;

  Future<void> signUserUp() async {
    try {
      if (passwordController.text == confirmpasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        await _db.saveUserInfoInFirebase(
            username: usernameController.text, email: emailController.text);

        
      } else {
        showErrorMessage("Passwords don't match");
      }
    } catch (e) {
      showErrorMessage("Invalid Email or Password. Please try again.");
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void validateEmail(String value) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zAZ0-9.-]+\.[a-zA-Z]{2,}$');
    setState(() {
      if (!emailRegex.hasMatch(value)) {
        emailError = 'Invalid email format';
      } else {
        emailError = null;
      }
    });
  }


  bool isSignUpButtonEnabled() {
  return emailController.text.isNotEmpty &&
      passwordController.text.isNotEmpty &&
      confirmpasswordController.text.isNotEmpty &&
      usernameController.text.isNotEmpty &&
      emailError == null;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 30),

                  Icon(
                    Icons.lock,
                    size: 100,
                  ),
                  SizedBox(height: 20),

                  Text(
                    "Let's create an account for you!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),

                  TextField(
                    controller: emailController,
                    onChanged: (value) {
                      validateEmail(value);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "Enter email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  SizedBox(height: 5),
                  if (emailError != null)
                    Text(
                      emailError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  SizedBox(height: 15),

                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: "Enter Username",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "Enter password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  TextField(
                    controller: confirmpasswordController,
                    obscureText: obscureConfirmPassword,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: isSignUpButtonEnabled() ? signUserUp : null,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      backgroundColor: Colors.purple[400],
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 20),
                    ),
                  ),
                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Login now",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
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

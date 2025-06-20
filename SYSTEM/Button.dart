import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'athleteindex.dart'; // Athlete Dashboard
import 'coachindex.dart'; // Coach Dashboard
import 'adminindex.dart'; // Admin Dashboard

class Button extends StatelessWidget {
  final String? selectedRole;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  Button({required this.selectedRole, required this.emailController, required this.passwordController});

  Future<void> _login(BuildContext context) async {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a role")),
      );
      return;
    }

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Navigate based on role
        if (selectedRole == "Athlete") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AthleteIndex()));
        } else if (selectedRole == "Coach") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CoachIndex()));
        } else if (selectedRole == "Admin") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminIndex()));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid email or password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _login(context),
      child: Container(
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
          color: Colors.green[700],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            "Login",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

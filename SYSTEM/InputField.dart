import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  InputField({
    required this.emailController,
    required this.passwordController,
  });

  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Email Field with Label
        Text(
          'Email',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 4),
        TextField(
          controller: widget.emailController,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            hintText: "Enter your email",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 16),

        // Password Field with Label
        Text(
          'Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 4),
        TextField(
          controller: widget.passwordController,
          obscureText: _obscurePassword,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            hintText: "Enter your password",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

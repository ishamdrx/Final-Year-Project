import 'package:flutter/material.dart';
import 'Button.dart';
import 'InputField.dart';

class InputWrapper extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  InputWrapper({required this.emailController, required this.passwordController});

  @override
  _InputWrapperState createState() => _InputWrapperState();
}

class _InputWrapperState extends State<InputWrapper> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: DropdownButton<String>(
              value: selectedRole,
              hint: Text("Select Role", style: TextStyle(color: Colors.white)),
              dropdownColor: Colors.black,
              items: ["Athlete", "Coach", "Admin"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedRole = newValue;
                });
              },
            ),
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: InputField(
              emailController: widget.emailController,
              passwordController: widget.passwordController,
            ),
          ),
          SizedBox(height: 40),
          Button(
            selectedRole: selectedRole,
            emailController: widget.emailController,
            passwordController: widget.passwordController,
          ),
        ],
      ),
    );
  }
}

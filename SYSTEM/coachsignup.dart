import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class CoachSignUpPage extends StatefulWidget {
  @override
  _CoachSignUpPageState createState() => _CoachSignUpPageState();
}

class _CoachSignUpPageState extends State<CoachSignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController experienceYearsController = TextEditingController();
  final TextEditingController certificationController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedGender;
  bool isLoading = false;

  bool areFieldsValid() {
    return nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneNumberController.text.isNotEmpty &&
        ageController.text.isNotEmpty &&
        selectedGender != null &&
        experienceYearsController.text.isNotEmpty &&
        certificationController.text.isNotEmpty &&
        specializationController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
  }

  Future<void> registerCoach() async {
    if (!areFieldsValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all the fields.")),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String coachID = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('coach').doc(coachID).set({
        "coachID": coachID,
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phoneNumber": phoneNumberController.text.trim(),
        "age": int.tryParse(ageController.text.trim()),
        "gender": selectedGender,
        "experienceYears": int.tryParse(experienceYearsController.text.trim()),
        "certification": certificationController.text.trim(),
        "specialization": specializationController.text.trim(),
        "createdAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Coach registered successfully!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Coach Sign Up"),
        backgroundColor: Colors.green[800],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text("Welcome Coach!",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              SizedBox(height: 20),

              _buildLabel("Full Name"),
              _buildTextField(nameController, "Enter your full name", Icons.person),
              SizedBox(height: 5),

              _buildLabel("Email"),
              _buildTextField(emailController, "Enter your email", Icons.email,
                  keyboardType: TextInputType.emailAddress),
              SizedBox(height: 5),

              _buildLabel("Password"),
              _buildTextField(passwordController, "Enter your password", Icons.lock, obscureText: true),
              SizedBox(height: 5),

              _buildLabel("Phone Number"),
              _buildTextField(phoneNumberController, "Enter your phone number", Icons.phone,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              SizedBox(height: 5),

              _buildLabel("Age"),
              _buildTextField(ageController, "Enter your age", Icons.cake,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              SizedBox(height: 5),

              _buildLabel("Gender"),
              _buildDropdown("Select your gender", ["Male", "Female"], Icons.people,
                      (value) => setState(() => selectedGender = value)),
              SizedBox(height: 5),

              _buildLabel("Years of Experience"),
              _buildTextField(experienceYearsController, "Enter years of experience", Icons.timeline,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              SizedBox(height: 5),

              _buildLabel("Certification"),
              _buildTextField(certificationController, "Enter your certification", Icons.school),
              SizedBox(height: 5),

              _buildLabel("Specialization"),
              _buildTextField(specializationController, "Enter your specialization", Icons.star),
              SizedBox(height: 20),

              Center(child: _buildSignUpButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon,
      {bool obscureText = false,
        TextInputType? keyboardType,
        List<TextInputFormatter>? inputFormatters}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.green[500],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, List<String> items, IconData icon, Function(String?) onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.green[500],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        ),
        dropdownColor: Colors.green[900],
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        items: items.map((String value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : registerCoach,
      child: isLoading
          ? CircularProgressIndicator(color: Colors.black)
          : Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
        elevation: 5,
      ),
    );
  }
}

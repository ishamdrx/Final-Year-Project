import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AthleteSignUpPage extends StatefulWidget {
  @override
  _AthleteSignUpPageState createState() => _AthleteSignUpPageState();
}

class _AthleteSignUpPageState extends State<AthleteSignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController experienceYearsController = TextEditingController();

  String? selectedGender;
  String? selectedHighestLevel;
  bool isLoading = false;

  Future<void> registerAthlete() async {
    final age = int.tryParse(ageController.text.trim());
    final experience = int.tryParse(experienceYearsController.text.trim());
    final phone = phoneNumberController.text.trim();

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        phone.isEmpty ||
        age == null ||
        selectedGender == null ||
        experience == null ||
        selectedHighestLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all the fields.")),
      );
      return;
    }

    if (age < 18 || age > 35) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Age your valid age!")),
      );
      return;
    }

    if (experience < 0 || experience > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter your valid experience years!")),
      );
      return;
    }

    if (phone.length < 10 || phone.length > 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Phone number must be 10–11 digits.")),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String athleteID = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('athlete').doc(athleteID).set({
        "athleteID": athleteID,
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phoneNumber": phone,
        "age": age,
        "gender": selectedGender,
        "experienceYears": experience,
        "highestLevel": selectedHighestLevel,
        "createdAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Athlete registered successfully!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => isLoading = false);
  }
  bool obscurePassword = true;

  Widget _buildPasswordField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.green[500],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: TextField(
        controller: passwordController,
        obscureText: obscurePassword,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock, color: Colors.black),
          hintText: "Enter your password",
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.black87,
            ),
            onPressed: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Athlete Sign Up"),
        backgroundColor: Colors.green[800],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text("Welcome Athlete!",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              SizedBox(height: 20),

              _buildLabelWithInfo("Full Name"),
              _buildTextField(nameController, "Enter your full name", Icons.person),
              SizedBox(height: 5),

              _buildLabelWithInfo("Email"),
              _buildTextField(emailController, "Enter your email", Icons.email,
                  keyboardType: TextInputType.emailAddress),
              SizedBox(height: 5),

              _buildLabelWithInfo("Password", "Minimum 6 characters"),
              _buildPasswordField(),
              SizedBox(height: 5),

              _buildLabelWithInfo("Phone Number", "Starts with 01 and 10–11 digits"),
              _buildTextField(phoneNumberController, "Enter your phone number", Icons.phone,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11)
                  ]),
              SizedBox(height: 5),

              _buildLabelWithInfo("Age", "Between 18 to 35 years"),
              _buildTextField(ageController, "Enter your age", Icons.cake,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2)
                  ]),
              SizedBox(height: 5),

              _buildLabelWithInfo("Gender"),
              _buildDropdown("Select your gender", ["Male", "Female"], Icons.people,
                      (value) => setState(() => selectedGender = value)),
              SizedBox(height: 5),

              _buildLabelWithInfo("Years of Experience", "0 to 20 years"),
              _buildTextField(experienceYearsController, "Enter years of experience", Icons.timeline,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2)
                  ]),
              SizedBox(height: 5),

              _buildLabelWithInfo("Highest Level Achieved", "Select highest competition level reached"),
              _buildDropdown("Select highest level", ["School", "University", "District", "State", "National"],
                  Icons.bar_chart, (value) => setState(() => selectedHighestLevel = value)),
              SizedBox(height: 20),

              Center(child: _buildSignUpButton()),
            ],
          ),
        ),
      ),
    );
  }

  // Label with tooltip annotation
  Widget _buildLabelWithInfo(String text, [String? tooltip]) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (tooltip != null) ...[
            SizedBox(width: 5),
            Tooltip(
              message: tooltip,
              child: Icon(Icons.help_outline, size: 16, color: Colors.white70),
            )
          ]
        ],
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
      onPressed: isLoading ? null : registerAthlete,
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

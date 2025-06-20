import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminFunctions {
  // Table Column Definitions
  static List<DataColumn> _getColumns(String collection) {
    return collection == "Athlete Database"
        ? [
      DataColumn(label: Text("Name", style: TextStyle(color: Colors.white))),
      DataColumn(label: Text("Email", style: TextStyle(color: Colors.white))),
      DataColumn(label: Text("Phone Number", style: TextStyle(color: Colors.white))),
      DataColumn(label: Text("Age", style: TextStyle(color: Colors.white))),
      DataColumn(label: Text("Gender", style: TextStyle(color: Colors.white))),
      DataColumn(label: Text("Experience Years", style: TextStyle(color: Colors.white))),
      DataColumn(label: Text("Highest Level", style: TextStyle(color: Colors.white))),
    ]
        : [
      DataColumn(label: Text("Name", style: TextStyle(color: Colors.white))),
      DataColumn(label: Text("Email", style: TextStyle(color: Colors.white))),
      DataColumn(label: Text("Phone Number", style: TextStyle(color: Colors.white))),
      DataColumn(label: Text("Age", style: TextStyle(color: Colors.white))),
      DataColumn(label: Text("Gender", style: TextStyle(color: Colors.white))),
      DataColumn(label: Text("Experience Years", style: TextStyle(color: Colors.white))),
      DataColumn(label: Text("Certification", style: TextStyle(color: Colors.white))),
      DataColumn(label: Text("Specialization", style: TextStyle(color: Colors.white))),
    ];
  }

  // Helper method for table cells
  static List<DataCell> _buildDataCells(QueryDocumentSnapshot doc, String collection) {
    var data = doc.data() as Map<String, dynamic>;
    return collection == "Athlete Database"
        ? [
      DataCell(Text(data["name"] ?? "-", style: TextStyle(color: Colors.white))),
      DataCell(Text(data["email"] ?? "-", style: TextStyle(color: Colors.white))),
      DataCell(Text(data["phoneNumber"] ?? "-", style: TextStyle(color: Colors.white))),
      DataCell(Text(data["age"]?.toString() ?? "-", style: TextStyle(color: Colors.white))),
      DataCell(Text(data["gender"] ?? "-", style: TextStyle(color: Colors.white))),
      DataCell(Text(data["experienceYears"]?.toString() ?? "-", style: TextStyle(color: Colors.white))),
      DataCell(Text(data["highestLevel"] ?? "-", style: TextStyle(color: Colors.white))),
    ]
        : [
      DataCell(Text(data["name"] ?? "-", style: TextStyle(color: Colors.white))),
      DataCell(Text(data["email"] ?? "-", style: TextStyle(color: Colors.white))),
      DataCell(Text(data["phoneNumber"] ?? "-", style: TextStyle(color: Colors.white))),
      DataCell(Text(data["age"]?.toString() ?? "-", style: TextStyle(color: Colors.white))),
      DataCell(Text(data["gender"] ?? "-", style: TextStyle(color: Colors.white))),
      DataCell(Text(data["experienceYears"]?.toString() ?? "-", style: TextStyle(color: Colors.white))),
      DataCell(Text(data["certification"] ?? "-", style: TextStyle(color: Colors.white))),
      DataCell(Text(data["specialization"] ?? "-", style: TextStyle(color: Colors.white))),
    ];
  }

  // Main table with dark theme
  static Widget buildFirestoreDataTable(
      String collection,
      DocumentSnapshot? selectedDoc,
      void Function(DocumentSnapshot) onRowSelected,
      ) {
    TextEditingController searchController = TextEditingController();
    ValueNotifier<String> searchQuery = ValueNotifier("");

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Search...",
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.search, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
            ),
            onChanged: (value) => searchQuery.value = value.toLowerCase(),
          ),
        ),

        Expanded(
          child: ValueListenableBuilder<String>(
            valueListenable: searchQuery,
            builder: (context, query, child) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(collection == "Athlete Database" ? "athlete" : "coach")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.green));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text("No data available. Select a database first.", style: TextStyle(color: Colors.white)),
                    );
                  }

                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return data.values.any((field) =>
                        field.toString().toLowerCase().contains(query));
                  }).toList();

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      decoration: BoxDecoration(color: Colors.grey[900]),
                      columns: _getColumns(collection),
                      rows: filteredDocs.map((doc) => DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                                (states) => selectedDoc?.id == doc.id ? Colors.green[800] : null
                        ),
                        cells: _buildDataCells(doc, collection),
                        onSelectChanged: null,
                        onLongPress: () => onRowSelected(doc),
                      )).toList(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Insert Dialog
  static void showInsertDialog(BuildContext context, String collection) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController ageController = TextEditingController();
    TextEditingController experienceYearsController = TextEditingController();
    TextEditingController certificationController = TextEditingController();
    String? selectedGender;
    String? selectedHighestLevel;
    TextEditingController specializationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Add New ${collection.split(" ")[0]}", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: "Name", labelStyle: TextStyle(color: Colors.white)),
            ),
            TextField(
              controller: emailController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: "Email", labelStyle: TextStyle(color: Colors.white)),
            ),
            TextField(
              controller: phoneController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: "Phone Number", labelStyle: TextStyle(color: Colors.white)),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: ageController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: "Age", labelStyle: TextStyle(color: Colors.white)),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Gender", labelStyle: TextStyle(color: Colors.white)),
              dropdownColor: Colors.grey[800],
              items: ["Male", "Female"].map((g) => DropdownMenuItem(value: g, child: Text(g, style: TextStyle(color: Colors.white)))).toList(),
              onChanged: (v) => selectedGender = v,
            ),
            TextField(
              controller: experienceYearsController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: "Experience (Years)", labelStyle: TextStyle(color: Colors.white)),
              keyboardType: TextInputType.number,
            ),
            if (collection == "Athlete Database")
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Highest Level", labelStyle: TextStyle(color: Colors.white)),
                dropdownColor: Colors.grey[800],
                items: ["School", "University", "District", "State", "National"]
                    .map((lvl) => DropdownMenuItem(value: lvl, child: Text(lvl, style: TextStyle(color: Colors.white))))
                    .toList(),
                onChanged: (v) => selectedHighestLevel = v,
              ),
            if (collection == "Coach Database") ...[
              TextField(
                controller: certificationController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: "Certification", labelStyle: TextStyle(color: Colors.white)),
              ),
              TextField(
                controller: specializationController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: "Specialization", labelStyle: TextStyle(color: Colors.white)),
              ),
            ],
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: Colors.white))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              // Validation
              final phone = phoneController.text.trim();
              final age = int.tryParse(ageController.text.trim());
              final exp = int.tryParse(experienceYearsController.text.trim());

              if (phone.length < 10 || phone.length > 11) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter a valid phone number!")));
                return;
              }
              if (collection == "Athlete Database") {
                if (age == null || age < 18 || age > 35) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter your valid age!")));
                  return;
                }
                if (exp == null || exp < 0 || exp > 20) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter your valid experience years!")));
                  return;
                }
              } else {
                if (age == null || age <= 30) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter a valid coach age (>30)!")));
                  return;
                }
                if (exp == null || exp < 5 || exp > 40) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter coach experience between 5–40 years!")));
                  return;
                }
              }

              try {
                UserCredential userCredential = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(email: emailController.text.trim(), password: "111111");
                await FirebaseFirestore.instance
                    .collection(collection == "Athlete Database" ? "athlete" : "coach")
                    .doc(userCredential.user!.uid)
                    .set({
                  if (collection == "Athlete Database")
                    "athleteID": userCredential.user!.uid else "coachID": userCredential.user!.uid,
                  "name": nameController.text,
                  "email": emailController.text,
                  "phoneNumber": phone,
                  "age": age,
                  "gender": selectedGender,
                  "experienceYears": exp,
                  if (collection == "Athlete Database") "highestLevel": selectedHighestLevel,
                  if (collection == "Coach Database") ...{
                    "certification": certificationController.text,
                    "specialization": specializationController.text,
                  },
                  "createdAt": FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${collection.split(" ")[0]} added successfully!")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
              }
            },
            child: Text("Add", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // Modify Dialog
  static void showModifyDialog(BuildContext context, String collection, DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    TextEditingController nameController = TextEditingController(text: data['name']);
    TextEditingController phoneController = TextEditingController(text: data['phoneNumber'] ?? '');
    TextEditingController ageController = TextEditingController(text: data['age']?.toString() ?? '');
    TextEditingController experienceYearsController = TextEditingController(text: data['experienceYears']?.toString() ?? '');
    TextEditingController certificationController = TextEditingController(text: data['certification'] ?? '');
    TextEditingController specializationController = TextEditingController(text: data['specialization'] ?? '');
    String? selectedGender = data['gender'];
    String? selectedHighestLevel = data['highestLevel'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Modify ${collection.split(" ")[0]}", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: "Name", labelStyle: TextStyle(color: Colors.white)),
            ),
            TextField(
              controller: phoneController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: "Phone Number", labelStyle: TextStyle(color: Colors.white)),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: ageController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: "Age", labelStyle: TextStyle(color: Colors.white)),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: InputDecoration(labelText: "Gender", labelStyle: TextStyle(color: Colors.white)),
              dropdownColor: Colors.grey[800],
              items: ["Male", "Female"]
                  .map((g) => DropdownMenuItem(value: g, child: Text(g, style: TextStyle(color: Colors.white))))
                  .toList(),
              onChanged: (v) => selectedGender = v,
            ),
            TextField(
              controller: experienceYearsController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: "Experience (Years)", labelStyle: TextStyle(color: Colors.white)),
              keyboardType: TextInputType.number,
            ),
            if (collection == "Athlete Database")
              DropdownButtonFormField<String>(
                value: selectedHighestLevel,
                decoration: InputDecoration(labelText: "Highest Level", labelStyle: TextStyle(color: Colors.white)),
                dropdownColor: Colors.grey[800],
                items: ["School", "University", "District", "State", "National"]
                    .map((lvl) => DropdownMenuItem(value: lvl, child: Text(lvl, style: TextStyle(color: Colors.white))))
                    .toList(),
                onChanged: (v) => selectedHighestLevel = v,
              ),
            if (collection == "Coach Database") ...[
              TextField(
                controller: certificationController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: "Certification", labelStyle: TextStyle(color: Colors.white)),
              ),
              TextField(
                controller: specializationController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: "Specialization", labelStyle: TextStyle(color: Colors.white)),
              ),
            ],
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: Colors.white))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              // Validation
              final phone = phoneController.text.trim();
              final age = int.tryParse(ageController.text.trim());
              final exp = int.tryParse(experienceYearsController.text.trim());

              if (phone.length < 10 || phone.length > 11) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter a valid phone number!")));
                return;
              }
              if (collection == "Athlete Database") {
                if (age == null || age < 18 || age > 35) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter your valid age!")));
                  return;
                }
                if (exp == null || exp < 0 || exp > 20) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter your valid experience years!")));
                  return;
                }
              } else {
                if (age == null || age <= 30) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter a valid coach age (>30)!")));
                  return;
                }
                if (exp == null || exp < 5 || exp > 40) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter coach experience between 5–40 years!")));
                  return;
                }
              }

              try {
                await doc.reference.update({
                  'name': nameController.text,
                  'phoneNumber': phone,
                  'age': age,
                  'gender': selectedGender,
                  'experienceYears': exp,
                  if (collection == "Athlete Database") 'highestLevel': selectedHighestLevel,
                  if (collection == "Coach Database") ...{
                    'certification': certificationController.text,
                    'specialization': specializationController.text,
                  },
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Profile updated successfully!")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
              }
            },
            child: Text("Update", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // Archive a user
  static Future<void> archiveUser(BuildContext context, String collection, DocumentSnapshot doc) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Archive User", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to archive this user?", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel", style: TextStyle(color: Colors.white))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: Text("Archive", style: TextStyle(color: Colors.black))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      var data = doc.data() as Map<String, dynamic>;
      String source = collection == "Athlete Database" ? "athlete" : "coach";
      String archive = "${source}_archived";
      data['archivedAt'] = FieldValue.serverTimestamp();
      await FirebaseFirestore.instance.collection(archive).doc(doc.id).set(data);
      await doc.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User archived successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error archiving user: ${e.toString()}")));
    }
  }

  // Show archived users
  static void showArchivedUsersDialog(BuildContext context, String collection) {
    String archive = collection == "Athlete Database" ? "athlete_archived" : "coach_archived";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Archived ${collection.split(" ")[0]}s", style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection(archive).snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Colors.green));
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return Center(child: Text("No archived users found", style: TextStyle(color: Colors.white)));
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snap.data!.docs.length,
                itemBuilder: (context, i) {
                  var d = snap.data!.docs[i];
                  var u = d.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(u['name'] ?? 'No name', style: TextStyle(color: Colors.white)),
                    subtitle: Text(u['email'] ?? 'No email', style: TextStyle(color: Colors.white70)),
                    onLongPress: () => _showArchiveOptions(context, collection, d),
                  );
                },
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close", style: TextStyle(color: Colors.white)))],
      ),
    );
  }

  static void _showArchiveOptions(BuildContext context, String collection, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Manage Archived User", style: TextStyle(color: Colors.white)),
        content: Text("Choose an action for this user:", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: Colors.white))),
          ElevatedButton(onPressed: () { Navigator.pop(context); _confirmDelete(context, doc); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text("Delete", style: TextStyle(color: Colors.white))),
          ElevatedButton(onPressed: () { Navigator.pop(context); _confirmRestore(context, collection, doc); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: Text("Restore", style: TextStyle(color: Colors.black))),
        ],
      ),
    );
  }

  static Future<void> _confirmRestore(BuildContext context, String collection, DocumentSnapshot doc) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Restore User", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to restore this user?", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel", style: TextStyle(color: Colors.white))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: Text("Restore", style: TextStyle(color: Colors.black))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      var data = doc.data() as Map<String, dynamic>;
      String source = collection == "Athlete Database" ? "athlete" : "coach";
      String archive = "${source}_archived";
      data.remove('archivedAt');
      await FirebaseFirestore.instance.collection(source).doc(doc.id).set(data);
      await doc.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User restored successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error restoring user: ${e.toString()}")));
    }
  }

  static Future<void> _confirmDelete(BuildContext context, DocumentSnapshot doc) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Delete Forever", style: TextStyle(color: Colors.white)),
        content: Text("This cannot be undone. Are you sure?", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel", style: TextStyle(color: Colors.white))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text("Delete", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await doc.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Permanently deleted!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting: ${e.toString()}")));
    }
  }
}

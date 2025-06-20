import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loginpage.dart';
import 'admin_functions.dart';

class AdminIndex extends StatefulWidget {
  @override
  _AdminIndexState createState() => _AdminIndexState();
}

class _AdminIndexState extends State<AdminIndex> {
  String selectedDatabase = '';
  DocumentSnapshot? selectedDoc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Admin Panel", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[900],
      ),
      body: Row(
        children: [
          // Sidebar Menu
          Container(
            width: 250,
            color: Colors.green[900],
            child: Column(
              children: [
                SizedBox(height: 40),
                Text("UrCoach",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                _buildDatabaseButton("Athlete Database"),
                _buildDatabaseButton("Coach Database"),
                Spacer(),
                _buildLogoutButton(),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedDatabase.isEmpty
                        ? "Select a Database"
                        : selectedDatabase,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: selectedDatabase.isEmpty
                          ? Center(
                        child: Text(
                          "Please select a database from the sidebar",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                          : AdminFunctions.buildFirestoreDataTable(
                        selectedDatabase,
                        selectedDoc,
                            (doc) => setState(() => selectedDoc = doc),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildAdminControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseButton(String title) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: () {
        setState(() {
          selectedDatabase = title;
          selectedDoc = null;
        });
      },
    );
  }

  Widget _buildLogoutButton() {
    return ListTile(
      leading: Icon(Icons.logout, color: Colors.white),
      title: Text("Logout", style: TextStyle(color: Colors.white)),
      onTap: () => _showLogoutConfirmation(context),
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white)),
      onPressed: onPressed,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Confirm Logout", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to logout?", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Logged out successfully")),
              );
            },
            child: Text("Logout", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(Icons.add, "Insert", () {
          if (selectedDatabase.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please select a database first")),
            );
          } else {
            AdminFunctions.showInsertDialog(context, selectedDatabase);
          }
        }),
        _buildControlButton(Icons.edit, "Modify", () {
          if (selectedDoc == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please select a record first (long press on row)")),
            );
          } else {
            AdminFunctions.showModifyDialog(context, selectedDatabase, selectedDoc!);
          }
        }),
        _buildControlButton(Icons.archive, "Archive", () {
          if (selectedDoc == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please select a record first (long press on row)")),
            );
          } else {
            AdminFunctions.archiveUser(context, selectedDatabase, selectedDoc!);
          }
        }),
        _buildControlButton(Icons.delete, "View Archived", () {
          if (selectedDatabase.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please select a database first")),
            );
          } else {
            AdminFunctions.showArchivedUsersDialog(context, selectedDatabase);
          }
        }),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'loginpage.dart';
import 'gpt_service.dart';

class CoachIndex extends StatefulWidget {
  @override
  _CoachIndexState createState() => _CoachIndexState();
}

class _CoachIndexState extends State<CoachIndex> {
  String _selectedOption = "Create Training Program";
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _chatController = TextEditingController();
  List<Map<String, String>> _messages = [
    {"sender": "Chatbot", "message": "How can I assist you today?"}
  ];

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<String> getCoachName() async {
    final doc = await FirebaseFirestore.instance
        .collection('coach')
        .doc(currentUser?.uid)
        .get();
    if (doc.exists && doc.data()?['name'] != null) {
      return doc.data()!['name'];
    }
    return "No Name Set";
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.green[900],
        title: Text("Logout", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to logout?", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Logout successful!")));
            },
            child: Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final email = currentUser?.email ?? "Unknown";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Profile", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person, color: Colors.white),
              title: Text("Name", style: TextStyle(color: Colors.white)),
              subtitle: FutureBuilder<String>(
                future: getCoachName(),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting)
                    return Text("Loading...", style: TextStyle(color: Colors.white70));
                  if (snap.hasError)
                    return Text("Error", style: TextStyle(color: Colors.red));
                  return Text(snap.data!, style: TextStyle(color: Colors.white70));
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.white),
              title: Text("Email", style: TextStyle(color: Colors.white)),
              subtitle: Text(email, style: TextStyle(color: Colors.white70)),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.lock_reset, color: Colors.black),
              label: Text("Reset Password", style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[400]),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Password reset email sent.")));
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.email_outlined, color: Colors.black),
              label: Text("Change Email", style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[300]),
              onPressed: () {
                final ctrl = TextEditingController();
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.grey[900],
                    title: Text("Enter New Email", style: TextStyle(color: Colors.white)),
                    content: TextField(
                      controller: ctrl,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "newemail@example.com",
                        hintStyle: TextStyle(color: Colors.white60),
                        enabledBorder:
                        UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel", style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            Navigator.pop(context);
                            await currentUser?.verifyBeforeUpdateEmail(ctrl.text.trim());
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Verification email sent.")));
                          } catch (e) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text("Error: $e")));
                          }
                        },
                        child: Text("Send Link", style: TextStyle(color: Colors.greenAccent)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendChatToGPT(String input) async {
    final result = await getTrainingPlan(goal: input);
    setState(() {
      _messages.add({
        "sender": "Chatbot",
        "message": result ?? "Sorry, I couldn't generate a response right now."
      });
    });
  }

  // Updated: showRecordDialog now handles completed vs. pending
  void _showRecordDialog(DocumentSnapshot recordDoc) async {
    final data = recordDoc.data()! as Map<String, dynamic>;
    final athleteEmail = data['email'] as String? ?? '';
    final name = data['name'] ?? '';
    final eventType = data['event_type'] as String? ?? '';
    final sessionType = data['session_type'] as String? ?? '';
    final recordText = data['record'] as String? ?? '';
    final date = (data['date'] as Timestamp).toDate();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final isDone = data['is_done'] == true;

    if (isDone) {
      // Show read-only report
      final fbQuery = await FirebaseFirestore.instance
          .collection('feedback_records')
          .where('athlete_email', isEqualTo: athleteEmail)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      final fbData = fbQuery.docs.isNotEmpty ? fbQuery.docs.first.data() : null;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("Training Report", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Athlete: $name", style: TextStyle(color: Colors.white70)),
              Text("Email: $athleteEmail", style: TextStyle(color: Colors.white70)),
              Text("Event: $eventType", style: TextStyle(color: Colors.white70)),
              Text("Session: $sessionType", style: TextStyle(color: Colors.white70)),
              Text("Date: $dateStr", style: TextStyle(color: Colors.white70)),
              Text("Record: $recordText", style: TextStyle(color: Colors.white70)),
              SizedBox(height: 10),
              if (fbData != null) ...[
                Divider(color: Colors.white24),
                Text("Feedback:", style: TextStyle(color: Colors.greenAccent)),
                Text(fbData['feedback'] ?? '-', style: TextStyle(color: Colors.white)),
                Text("Reviewed by: ${fbData['coach_name'] ?? 'Unknown'}",
                    style: TextStyle(color: Colors.white38)),
              ] else
                Text("No feedback found", style: TextStyle(color: Colors.white38)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close", style: TextStyle(color: Colors.white))),
          ],
        ),
      );
    } else {
      // Pending: allow feedback
      final feedbackCtrl = TextEditingController();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("Record Details", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Athlete: $athleteEmail", style: TextStyle(color: Colors.white70)),
              Text("Event: $eventType", style: TextStyle(color: Colors.white70)),
              Text("Session: $sessionType", style: TextStyle(color: Colors.white70)),
              Text("Date: $dateStr", style: TextStyle(color: Colors.white70)),
              SizedBox(height: 10),
              Text("Record:", style: TextStyle(color: Colors.white70)),
              Text(recordText, style: TextStyle(color: Colors.white)),
              SizedBox(height: 20),
              TextField(
                controller: feedbackCtrl,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter feedback...",
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.green[800],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 3,
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: Colors.white))),
            TextButton(
              onPressed: () async {
                final fb = feedbackCtrl.text.trim();
                if (fb.isEmpty) return;
                await FirebaseFirestore.instance.collection('feedback_records').add({
                  'athlete_email': athleteEmail,
                  'coach_name': await getCoachName(),
                  'coach_email': currentUser?.email,
                  'feedback': fb,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                await FirebaseFirestore.instance
                    .collection('training_records')
                    .doc(recordDoc.id)
                    .update({'is_done': true});
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Feedback sent & marked done.")));
              },
              child: Text("Send & Done", style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildViewProgress() {
    TextEditingController searchController = TextEditingController();
    String searchText = "";

    return StatefulBuilder(builder: (context, setInnerState) {
      return Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: (value) => setInnerState(() => searchText = value.toLowerCase()),
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search athlete name or event...",
              hintStyle: TextStyle(color: Colors.white54),
              prefixIcon: Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.green[900],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('training_records')
                  .orderBy('date', descending: false)
                  .snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData) return Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final event = (data['event_type'] ?? '').toString().toLowerCase();
                  return name.contains(searchText) || event.contains(searchText);
                }).toList();

                final pending = docs.where((d) {
                  final isDone = (d.data() as Map<String, dynamic>)['is_done'];
                  return isDone == null || isDone == false;
                }).toList();

                final done = docs.where((d) {
                  final isDone = (d.data() as Map<String, dynamic>)['is_done'];
                  return isDone == true;
                }).toList();

                return ListView(
                  children: [
                    if (pending.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Pending",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ...pending.map((d) => _buildRecordTile(d, isDone: false)),
                    if (done.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Completed",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ...done.map((d) => _buildRecordTile(d, isDone: true)),
                  ],
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildRecordTile(DocumentSnapshot d, {required bool isDone}) {
    final data = d.data()! as Map<String, dynamic>;
    final name = data['name'] ?? 'Unknown';
    final event = data['event_type'] ?? '';
    final date = (data['date'] as Timestamp).toDate();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    return Card(
      color: isDone ? Colors.grey[800] : Colors.green[800],
      child: ListTile(
        title: Text("$name — $event", style: TextStyle(color: Colors.white)),
        subtitle: Text(dateStr, style: TextStyle(color: Colors.white70)),
        trailing: isDone
            ? Icon(Icons.check_circle_outline, color: Colors.white38)
            : TextButton(
          onPressed: () => _showRecordDialog(d),
          child: Text("View", style: TextStyle(color: Colors.white)),
        ),
        onTap: () => _showRecordDialog(d),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_selectedOption == "Create Training Program") {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Create Training Program",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: _messages
                  .map((msg) => _buildChatMessage(msg["sender"]!, msg["message"]!))
                  .toList(),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: Colors.green[900], borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),                IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    final input = _chatController.text.trim();
                    if (input.isEmpty) return;
                    setState(() {
                      _messages.add({"sender": "Coach", "message": input});
                      _chatController.clear();
                    });
                    _sendChatToGPT(input);
                  },
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      content = _buildViewProgress();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.green[900],
            child: Column(
              children: [
                SizedBox(height: 40),
                Text("UrCoach",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 40),
                _buildMenuOption("Create Training Program"),
                _buildMenuOption("View Athlete Progress"),
                Spacer(),
                ListTile(
                  leading: Icon(Icons.person, color: Colors.white),
                  title: Text("Profile", style: TextStyle(color: Colors.white)),
                  onTap: () => _showProfileDialog(context),
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.white),
                  title: Text("Logout", style: TextStyle(color: Colors.white)),
                  onTap: () => _logout(context),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Container(color: Colors.black, padding: EdgeInsets.all(20), child: content),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(String title) {
    return ListTile(
      title: Text(title,
          style: TextStyle(color: _selectedOption == title ? Colors.white : Colors.grey, fontSize: 16)),
      onTap: () => setState(() => _selectedOption = title),
    );
  }

  Widget _buildChatMessage(String sender, String message) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: Colors.green[700], child: Text(sender[0], style: TextStyle(color: Colors.white))),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green[700], borderRadius: BorderRadius.circular(10)),
              child: Text(message, style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

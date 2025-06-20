import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'loginpage.dart';
import 'gpt_service.dart';

class AthleteIndex extends StatefulWidget {
  @override
  _AthleteIndexState createState() => _AthleteIndexState();
}

class _AthleteIndexState extends State<AthleteIndex> {
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

  Future<String> getAthleteName() async {
    final doc = await FirebaseFirestore.instance
        .collection('athlete')
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
        content: Text("Are you sure you want to logout?",
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginPage()));
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Logout successful!")));
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
                future: getAthleteName(),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting)
                    return Text("Loading...",
                        style: TextStyle(color: Colors.white70));
                  if (snap.hasError)
                    return Text("Error loading name",
                        style: TextStyle(color: Colors.red));
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
              label:
              Text("Reset Password", style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[400]),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Password reset email sent.")));
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
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.orange[300]),
              onPressed: () {
                final ctrl = TextEditingController();
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.grey[900],
                    title:
                    Text("Enter New Email", style: TextStyle(color: Colors.white)),
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
                        child:
                        Text("Send Link", style: TextStyle(color: Colors.greenAccent)),
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

  // Updated feedback dialog with error & loading handling
  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (_) {
        TextEditingController searchCtrl = TextEditingController();
        String filter = "";
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text("Training Reports", style: TextStyle(color: Colors.white)),
            content: Container(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: searchCtrl,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search by date/event...",
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIcon: Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.green[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setState(() => filter = v.toLowerCase()),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('training_records')
                          .where('email', isEqualTo: currentUser?.email)
                          .orderBy('date', descending: true)
                          .snapshots(),
                      builder: (ctx2, snap) {
                        // 1) error
                        if (snap.hasError) {
                          return Center(
                            child: Text(
                              "Error loading reports:\n${snap.error}",
                              style: TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        // 2) loading
                        if (snap.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        // 3) data ready
                        final docs = snap.data!.docs.where((d) {
                          final data = d.data() as Map<String, dynamic>;
                          final dateStr = DateFormat('yyyy-MM-dd')
                              .format((data['date'] as Timestamp).toDate());
                          final event = (data['event_type'] ?? '').toString();
                          return dateStr.contains(filter) ||
                              event.toLowerCase().contains(filter);
                        }).toList();

                        if (docs.isEmpty) {
                          return Center(
                              child: Text("No reports found",
                                  style: TextStyle(color: Colors.white54)));
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (_, i) {
                            final d = docs[i];
                            final data = d.data()! as Map<String, dynamic>;
                            final dateStr = DateFormat('yyyy-MM-dd')
                                .format((data['date'] as Timestamp).toDate());
                            final event = data['event_type'] ?? '';
                            final session = data['session_type'] ?? '';
                            final record = data['record'] ?? '';
                            return FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('feedback_records')
                                  .where('athlete_email',
                                  isEqualTo: currentUser?.email)
                                  .orderBy('timestamp', descending: true)
                                  .limit(1)
                                  .get(),
                              builder: (fCtx, fSnap) {
                                String fbText = "No feedback yet";
                                String coachName = "";
                                if (fSnap.hasData && fSnap.data!.docs.isNotEmpty) {
                                  final fbDoc =
                                  fSnap.data!.docs.first.data() as Map<String, dynamic>;
                                  fbText = fbDoc['feedback'] ?? fbText;
                                  coachName = fbDoc['coach_name'] ?? "";
                                }
                                return Card(
                                  color: Colors.green[800],
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    title: Text("$dateStr — $event",
                                        style: TextStyle(color: Colors.white)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Session: $session",
                                            style: TextStyle(color: Colors.white70)),
                                        Text("Record: $record",
                                            style: TextStyle(color: Colors.white70)),
                                        SizedBox(height: 4),
                                        Text("Feedback:",
                                            style:
                                            TextStyle(color: Colors.greenAccent)),
                                        Text(fbText,
                                            style: TextStyle(color: Colors.white)),
                                        if (coachName.isNotEmpty)
                                          Text("By: $coachName",
                                              style: TextStyle(
                                                  color: Colors.white38,
                                                  fontStyle: FontStyle.italic)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                Text("Close", style: TextStyle(color: Colors.greenAccent)),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_selectedOption == "Create Training Program") {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_selectedOption,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
                children: _messages
                    .map((msg) =>
                    _buildChatMessage(msg["sender"]!, msg["message"]!))
                    .toList()),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: Colors.green[900],
                borderRadius: BorderRadius.circular(10)),
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
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    final input = _chatController.text.trim();
                    if (input.isEmpty) return;
                    setState(() {
                      _messages
                          .add({"sender": "Athlete", "message": input});
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
      content = RecordSubmissionForm(currentUser: currentUser);
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
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 40),
                _buildMenuOption("Create Training Program"),
                _buildMenuOption("Submit Daily Record"),
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
            child: Container(
              color: Colors.black,
              padding: EdgeInsets.all(20),
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(String title) {
    return ListTile(
      title: Text(title,
          style: TextStyle(
              color: _selectedOption == title ? Colors.white : Colors.grey,
              fontSize: 16)),
      onTap: () => setState(() => _selectedOption = title),
    );
  }

  Widget _buildChatMessage(String sender, String message) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
              backgroundColor: Colors.green[700],
              child: Text(sender[0], style: TextStyle(color: Colors.white))),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(10)),
              child: Text(message, style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class RecordSubmissionForm extends StatefulWidget {
  final User? currentUser;
  RecordSubmissionForm({required this.currentUser});
  @override
  _RecordSubmissionFormState createState() => _RecordSubmissionFormState();
}

class _RecordSubmissionFormState extends State<RecordSubmissionForm> {
  final TextEditingController _recordController = TextEditingController();
  final TextEditingController _sessionTypeController = TextEditingController();
  final TextEditingController _eventTypeController = TextEditingController();

  String athleteName = "Loading...";
  DateTime? _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchAthleteName();
  }

  Future<void> _fetchAthleteName() async {
    final doc = await FirebaseFirestore.instance
        .collection('athlete')
        .doc(widget.currentUser?.uid)
        .get();
    if (doc.exists && doc.data()?['name'] != null) {
      setState(() => athleteName = doc.data()!['name']);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submitRecord() async {
    final email = widget.currentUser?.email;
    final recordText = _recordController.text.trim();
    final sessionType = _sessionTypeController.text.trim();
    final eventType = _eventTypeController.text.trim();
    if (email == null || recordText.isEmpty || sessionType.isEmpty || eventType.isEmpty || _selectedDate == null)
      return;

    final dateOnly = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
    await FirebaseFirestore.instance.collection('training_records').add({
      'email': email,
      'name': athleteName,
      'event_type': eventType,
      'session_type': sessionType,
      'record': recordText,
      'date': Timestamp.fromDate(dateOnly),
      'submitted_at': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Record submitted.")));
    _recordController.clear();
    _sessionTypeController.clear();
    _eventTypeController.clear();
  }

  // Just moved your original feedback dialog function here directly
  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (_) {
        TextEditingController searchCtrl = TextEditingController();
        String filter = "";
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text("Training Reports", style: TextStyle(color: Colors.white)),
            content: Container(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search by date/event...",
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIcon: Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.green[800],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (v) => setState(() => filter = v.toLowerCase()),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('training_records')
                          .where('email', isEqualTo: widget.currentUser?.email)
                          .orderBy('date', descending: true)
                          .snapshots(),
                      builder: (ctx2, snap) {
                        if (snap.hasError) {
                          return Center(
                            child: Text("Error loading reports:\n${snap.error}", style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
                          );
                        }
                        if (snap.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final docs = snap.data!.docs.where((d) {
                          final data = d.data() as Map<String, dynamic>;
                          final dateStr = DateFormat('yyyy-MM-dd').format((data['date'] as Timestamp).toDate());
                          final event = (data['event_type'] ?? '').toString();
                          return dateStr.contains(filter) || event.toLowerCase().contains(filter);
                        }).toList();

                        if (docs.isEmpty) {
                          return Center(child: Text("No reports found", style: TextStyle(color: Colors.white54)));
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (_, i) {
                            final d = docs[i];
                            final data = d.data()! as Map<String, dynamic>;
                            final dateStr = DateFormat('yyyy-MM-dd').format((data['date'] as Timestamp).toDate());
                            final event = data['event_type'] ?? '';
                            final session = data['session_type'] ?? '';
                            final record = data['record'] ?? '';

                            return FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('feedback_records')
                                  .where('athlete_email', isEqualTo: widget.currentUser?.email)
                                  .orderBy('timestamp', descending: true)
                                  .limit(1)
                                  .get(),
                              builder: (fCtx, fSnap) {
                                String fbText = "No feedback yet";
                                String coachName = "";
                                if (fSnap.hasData && fSnap.data!.docs.isNotEmpty) {
                                  final fbDoc = fSnap.data!.docs.first.data() as Map<String, dynamic>;
                                  fbText = fbDoc['feedback'] ?? fbText;
                                  coachName = fbDoc['coach_name'] ?? "";
                                }
                                return Card(
                                  color: Colors.green[800],
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    title: Text("$dateStr — $event", style: TextStyle(color: Colors.white)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Session: $session", style: TextStyle(color: Colors.white70)),
                                        Text("Record: $record", style: TextStyle(color: Colors.white70)),
                                        SizedBox(height: 4),
                                        Text("Feedback:", style: TextStyle(color: Colors.greenAccent)),
                                        Text(fbText, style: TextStyle(color: Colors.white)),
                                        if (coachName.isNotEmpty)
                                          Text("By: $coachName", style: TextStyle(color: Colors.white38, fontStyle: FontStyle.italic)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text("Close", style: TextStyle(color: Colors.greenAccent))),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Submit Daily Record", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.receipt_long, color: Colors.white),
              tooltip: 'View Reports',
              onPressed: _showFeedbackDialog,
            ),
          ],
        ),
        SizedBox(height: 10),
        Text("Training Date", style: TextStyle(color: Colors.white)),
        Row(children: [
          Icon(Icons.calendar_today, color: Colors.white70),
          SizedBox(width: 10),
          Text(
            _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : "No date selected",
            style: TextStyle(color: Colors.white),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () => _pickDate(context),
            child: Text("Pick Date", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
          ),
        ]),
        SizedBox(height: 10),
        TextField(
          controller: _eventTypeController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Event Type (100m, Hurdles, High Jump)",
            labelStyle: TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.green[800],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _sessionTypeController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Session Type (Speed, Endurance, Strength)",
            labelStyle: TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.green[800],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _recordController,
          style: TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            labelText: "Record / Notes",
            labelStyle: TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.green[800],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _submitRecord,
          icon: Icon(Icons.upload_file, color: Colors.black),
          label: Text("Submit", style: TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreenAccent),
        ),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ensure FirebaseAuth is imported

class CreateJournalScreen extends StatefulWidget {
  @override
  _CreateJournalScreenState createState() => _CreateJournalScreenState();
}

class _CreateJournalScreenState extends State<CreateJournalScreen> {
  String? selectedMood;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final List<String> moods = ['😭','😔', '🙂', '😃', '🤩'];

  Future<void> saveJournal() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty || selectedMood == null) {
      // Show an error message or alert
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select a mood.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Handle the case when there is no logged-in user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to save your journal.')),
      );
      return;
    }

    // Save the journal to Firestore
    await FirebaseFirestore.instance.collection('journals').add({
      'title': titleController.text,
      'content': contentController.text,
      'mood': selectedMood,
      'userId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Journal saved successfully!')),
    );

    // Clear the fields and navigate back
    titleController.clear();
    contentController.clear();
    setState(() {
      selectedMood = null;
    });

    Navigator.pop(context); // Navigate back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Create Journal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: moods.map((mood) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMood = mood;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: selectedMood == mood ? Colors.blue : Colors.grey[200],
                    child: Text(
                      mood,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Your story',
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
            ),
            SizedBox(height: 20),
            Spacer(),
            ElevatedButton(
              onPressed: saveJournal,
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Buat tombol memenuhi lebar layar
              ),
            ),
          ],
        ),
      ),
    );
  }
}

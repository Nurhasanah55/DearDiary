import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JournalDetailScreen extends StatefulWidget {
  final String id;
  final String title;
  final String mood;
  final String content;
  final Timestamp timestamp;

  JournalDetailScreen({
    Key? key,
    required this.id,
    required this.title,
    required this.mood,
    required this.content,
    required this.timestamp,
  }) : super(key: key);

  @override
  _JournalDetailScreenState createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  String? selectedMood;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final List<String> moods = ['😭', '😔', '🙂', '😃', '🤩'];

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title;
    contentController.text = widget.content;
    selectedMood = widget.mood;
  }

  Future<void> updateJournal() async {
    if (titleController.text.isEmpty ||
        contentController.text.isEmpty ||
        selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select a mood.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to save your journal.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('journals').doc(widget.id).update({
      'title': titleController.text,
      'content': contentController.text,
      'mood': selectedMood,
      'userId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Journal updated successfully!')),
    );

    Navigator.pop(context); // Navigate back to the previous screen
  }

  Future<void> deleteJournal() async {
    await FirebaseFirestore.instance.collection('journals').doc(widget.id).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Journal deleted successfully!')),
    );

    Navigator.pop(context); // Navigate back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Journal Detail'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Confirm Delete'),
                    content: Text('Are you sure you want to delete this journal?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: deleteJournal,
                        child: Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                labelText: 'Your Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
            ),
            SizedBox(height: 20),
            Spacer(),
            ElevatedButton(
              onPressed: updateJournal,
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Full width button
              ),
            ),
          ],
        ),
      ),
    );
  }
}

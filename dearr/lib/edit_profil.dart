import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedLanguage = 'Indonesian';
  String _selectedGender = 'Female';
  final TextEditingController _hobbyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLatestProfile();
  }

  Future<void> _fetchLatestProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print('User ID: ${user.uid}');

      final profileSnapshot = await FirebaseFirestore.instance
          .collection('profile')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (profileSnapshot.docs.isNotEmpty) {
        final data = profileSnapshot.docs.first.data();
        print('Profile data: $data');

        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _selectedLanguage = data['language'] ?? 'Indonesian';
          _selectedGender = data['gender'] ?? 'Female';
          _hobbyController.text = data['hobby'] ?? '';
        });
      } else {
        print('No profile documents found.');
      }
    } else {
      print('No user is logged in.');
    }
  }

  Future<void> _saveProfile() async {
    final String nama = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String phone = _phoneController.text.trim();
    final String language = _selectedLanguage;
    final String gender = _selectedGender;
    final String hobby = _hobbyController.text.trim();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Save data to Firestore
      await FirebaseFirestore.instance.collection('profile').doc().set({
        'name': nama,
        'email': email,
        'phone': phone,
        'language': language,
        'gender': gender,
        'hobby': hobby,
        'timestamp': FieldValue.serverTimestamp(), // Adding timestamp field
      });

      // Navigate back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Language'),
              value: _selectedLanguage,
              items: ['Indonesian', 'English'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Gender'),
              value: _selectedGender,
              items: ['Female', 'Male'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
            ),
            TextField(
              controller: _hobbyController,
              decoration: InputDecoration(labelText: 'Hobby'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    void _showExitConfirmationDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Log Out"),
            content: Text("Are you sure you want to log out?"),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: Text("Log Out"),
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('profile')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data?.docs;

          if (documents == null || documents.isEmpty) {
            return Center(child: Text('No profile data found'));
          }

          final userData = documents.first.data() as Map<String, dynamic>?;

          if (userData == null) {
            return Center(child: Text('No profile data found'));
          }

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage('https://example.com/profile-pic.jpg'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      userData['name'] ?? 'No name',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${userData['email'] ?? 'No email'} | ${userData['phone'] ?? 'No phone'}',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                    ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit Profile Information'),
                      onTap: () {
                        Navigator.pushNamed(context, '/editProfile');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.language),
                      title: Text('Language'),
                      onTap: () {
                        Navigator.pushNamed(context, '/language');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.brightness_6),
                      title: Text('Theme'),
                      trailing: Switch(
                        value: themeNotifier.isDarkMode,
                        onChanged: (value) {
                          themeNotifier.toggleTheme();
                        },
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.lock),
                      title: Text('Privacy Policy'),
                      onTap: () {
                        Navigator.pushNamed(context, '/privacyPolicy');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Log Out'),
                      onTap: () {
                        _showExitConfirmationDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Journals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/my_journals');
          }
        },
      ),
    );
  }
}

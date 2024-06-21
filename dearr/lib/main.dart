import 'package:dearr/calendar.dart';
import 'package:dearr/create_journal.dart';
import 'package:dearr/edit_profil.dart';
import 'package:dearr/firebase_options.dart';
import 'package:dearr/home.dart';
import 'package:dearr/language.dart';
import 'package:dearr/my_journals.dart';
import 'package:dearr/privacy_policy.dart';
import 'package:dearr/profil.dart';
import 'package:dearr/sign_in.dart';
import 'package:dearr/sign_up.dart';
import 'package:dearr/theme_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dearr/journal_detail.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: MyApp(),
    ),
  );

  
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'Dear Diary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(), // Menambahkan darkTheme
      themeMode: themeNotifier.currentTheme, // Menggunakan themeMode dari ThemeNotifier
      initialRoute: '/',
      routes: {
        '/': (context) => SignInScreen(),
        '/sign_up': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/editProfile': (context) => EditProfileScreen(),
        '/language': (context) => LanguageScreen(),
        '/privacyPolicy': (context) => PrivacyPolicyScreen(),
        '/my_journals': (context) => MyJournalsScreen(),
        '/create_journal': (context) => CreateJournalScreen(),
        '/calendar': (context) => CalendarScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/journal_detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return JournalDetailScreen(
                id: args['id']!,
                title: args['title']!,
                mood: args['mood']!,
                content: args['content']!,
                timestamp: args['timestamp']!, // Provide the timestamp parameter
              );
            },
          );
        }
        return null;
      },
    );
  }
}

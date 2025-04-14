import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_iii/loginscreen.dart';
import 'package:task_iii/model/user.dart';
import 'homescreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBiT1ZwNesaP5usDGTA5fG2w3fFGfiFHpE",
          authDomain: "attendence-35036.firebaseapp.com",
          projectId: "attendence-35036",
          storageBucket: "attendence-35036.firebasestorage.app",
          messagingSenderId: "111371475209",
          appId: "1:111371475209:web:95d7879c58c64981661bd8",
          measurementId: "G-T2P3TNFKHG"));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendence',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const KeyboardVisibilityProvider(
          child: AuthCheck(),
      ),
      localizationsDelegates: [
        MonthYearPickerLocalizations.delegate,
      ] ,
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool userAvailable = false;
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();

    _getCurrentUser();
  }

  void _getCurrentUser() async {
    sharedPreferences = await SharedPreferences.getInstance();
    try {
      String? employeeId = sharedPreferences.getString('employeeId');
      if (employeeId != null && employeeId.trim().isNotEmpty) {
        setState(() {
          User.employeeId = employeeId.trim(); // Trim whitespace
          userAvailable = true;
        });
      }
    } catch (e) {
      setState(() {
        userAvailable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return userAvailable ? Homescreen() : Loginscreen();
  }
}

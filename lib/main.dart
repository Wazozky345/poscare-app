import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// TAMBAHKAN IMPORT INI
import 'firebase_options.dart'; 

// Import halaman Login & Config warna
import 'package:poscare/user_features/screens/Login_page/login_screen.dart';
import 'package:poscare/admin_features/screens/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // UBAH BAGIAN INI AGAR MENGGUNAKAN OPTIONS
  await Firebase.initializeApp(
    
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Poscare+',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Sans', 
        scaffoldBackgroundColor: Colors.white,
        
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 15,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: mainBlue, width: 1), 
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: mainBlue, width: 2),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
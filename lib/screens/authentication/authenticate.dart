// import 'package:flutter/material.dart';
// import 'package:sin_ocr/screens/authentication/register.dart';
// import 'package:sin_ocr/screens/authentication/sign_in.dart';

// class Authenticate extends StatefulWidget {
//   const Authenticate({super.key});

//   @override
//   State<Authenticate> createState() => _AuthenticateState();
// }

// class _AuthenticateState extends State<Authenticate> {
//   bool signInPage = true;
//   //toggle pages
//   void switchPages() {
//     setState(() {
//       signInPage = !signInPage;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (signInPage == true) {
//       return SignIn(toggle: switchPages);
//     } else {
//       return Register(toggle: switchPages);
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:sin_ocr/screens/authentication/register.dart';
import 'package:sin_ocr/screens/authentication/sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool signInPage = true;

  void switchPages() {
    setState(() {
      signInPage = !signInPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        primaryColor: const Color(0xFF2196F3),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home:
          signInPage
              ? SignIn(toggle: switchPages)
              : Register(toggle: switchPages),
    );
  }
}

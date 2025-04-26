import 'package:flutter/material.dart';
import 'package:project_fyp/screens/authentication/register.dart';
import 'package:project_fyp/screens/authentication/sign_in.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool signInPage = true;
  //toggle pages
  void switchPages() {
    setState(() {
      signInPage = !signInPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (signInPage == true) {
      return SignIn(toggle: switchPages);
    } else {
      return Register(toggle: switchPages);
    }
  }
}

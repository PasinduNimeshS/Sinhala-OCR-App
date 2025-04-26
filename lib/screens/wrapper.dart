import 'package:flutter/material.dart';
import 'package:project_fyp/models/user_model.dart';
import 'package:project_fyp/screens/authentication/authenticate.dart';
import 'package:project_fyp/screens/home/home.dart';
import 'package:provider/provider.dart';
// import 'package:project_fyp/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    //the user data that the provider provides this can be a user data or can be null
    final user = Provider.of<UserModel?>(context);
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}

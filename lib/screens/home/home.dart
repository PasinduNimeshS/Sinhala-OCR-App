import 'package:flutter/material.dart';
import 'package:project_fyp/constants/description.dart';
import 'package:project_fyp/constants/styles.dart';
import 'package:project_fyp/services/auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //create a object from authservice
  final AuthServices _auth = AuthServices();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xffF8EDED),
          appBar: AppBar(
            elevation: 0,

            backgroundColor: Color(0xffF8EDED),
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Color(0xffB43F3F)),
                onPressed: () async {
                  await _auth.signOut();
                },
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Center(
                    child: Image.asset("assets/images/logo.png", height: 150),
                  ),
                  Text(
                    "Welcome Pasindu",
                    style: TextStyle(
                      color: Color(0xffB43F3F),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    description,
                    style: descriptionStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

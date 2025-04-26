import 'package:flutter/material.dart';

import 'package:project_fyp/constants/styles.dart';
import 'package:project_fyp/services/auth.dart';

class SignIn extends StatefulWidget {
  //Functin
  final Function toggle;
  const SignIn({super.key, required this.toggle});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  //reference for the authService class
  final AuthServices _auth = AuthServices();
  //form key
  final _formKey = GlobalKey<FormState>();
  //email password states
  String email = "";
  String password = "";
  String error = "";
  bool _isPasswordVisible = false;
  FocusNode _passwordFocusNode = FocusNode();
  final RegExp emailRegex = RegExp(
    r"^(?![_.])([a-z0-9]+[._-])*[a-z0-9]+@[a-z0-9]+\.[a-z]{2,6}$",
  );

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(
      _focusNodeListener,
    ); // Add listener for password field focus
  }

  @override
  void dispose() {
    _passwordFocusNode.removeListener(
      _focusNodeListener,
    ); // Remove listener when widget is disposed
    super.dispose();
  }

  void _focusNodeListener() {
    setState(() {
      _isPasswordVisible = _passwordFocusNode.hasFocus && password.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffF8EDED),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              children: [
                SizedBox(height: 60),
                Center(
                  child: Image.asset("assets/images/logo.png", height: 100),
                ),
                Text(
                  textAlign: TextAlign.center,
                  "SINHALA TEXT",
                  style: TextStyle(
                    color: Color(0xffB43F3F),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  textAlign: TextAlign.center,
                  "SCANNING",
                  style: TextStyle(
                    color: Color(0xffB43F3F),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  textAlign: TextAlign.center,
                  "Login to your account",
                  style: TextStyle(
                    color: Color(0xffB43F3F),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        //email
                        TextFormField(
                          style: TextStyle(color: Color(0xffB43F3F)),
                          decoration: texInputDecoration,
                          // validator:
                          //     (val) =>
                          //         val?.isEmpty == true ? "Enter a valid email"
                          //             : null,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Enter a valid email";
                            } else if (!emailRegex.hasMatch(val)) {
                              return "Email cannot start with a special character or space";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        //password
                        // TextFormField(
                        //   obscureText: true,
                        //   style: TextStyle(color: Colors.white),
                        //   decoration: texInputDecoration.copyWith(
                        //     hintText: "Password",
                        //   ),
                        TextFormField(
                          focusNode: _passwordFocusNode, // Attach focus node
                          obscureText:
                              !_isPasswordVisible, // Toggle password visibility
                          style: TextStyle(color: Color(0xffB43F3F)),
                          decoration: texInputDecoration.copyWith(
                            hintText: "Password",
                            suffixIcon:
                                password
                                        .isNotEmpty // Show icon only when password has text
                                    ? IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Color(0xffB43F3F),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible; // Toggle visibility
                                        });
                                      },
                                    )
                                    : null, // Don't show icon when password is empty
                          ),
                          validator:
                              (val) =>
                                  val!.length < 6
                                      ? "Enter a valid password"
                                      : null,
                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Forgot Password ?",
                                style: TextStyle(
                                  color: Color(0xffB43F3F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        //google
                        SizedBox(height: 10),
                        Text(
                          error,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text("Or sign in with", style: descriptionStyle),
                        SizedBox(height: 10),
                        GestureDetector(
                          //Sign with google
                          onTap: () async {
                            dynamic result = await _auth.signInWithGoogle();
                            if (result == null) {
                              print("Google sign-in failed");
                            } else {
                              print("Signed in with Google: ${result.uid}");
                              // Navigate to home or handle successful login
                            }
                          },
                          child: Center(
                            child: Image.asset(
                              "assets/images/google.png",
                              height: 40,
                            ),
                          ),
                        ),
                        //register
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don’t have an account ?",
                              style: descriptionStyle,
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              //Go to the register page
                              onTap: () {
                                widget.toggle();
                              },
                              child: Text(
                                "Sign up here",
                                style: TextStyle(
                                  color: Color(0xffB43F3F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        //button
                        SizedBox(height: 60),
                        GestureDetector(
                          //method for login user
                          onTap: () async {
                            dynamic result = await _auth
                                .signInUsingEmailAndPassword(email, password);
                            if (result == null) {
                              setState(() {
                                error =
                                    "Could not signin with those credentials";
                              });
                            }
                          },
                          child: Container(
                            height: 40,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Color(0xffFF8225),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                width: 2,
                                color: Color(0xffB43F3F),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Sign in",
                                style: TextStyle(
                                  color: Color(0xff173B45),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        //anonymous login
                        SizedBox(height: 10),
                        GestureDetector(
                          //method for anonymous login
                          onTap: () async {
                            dynamic result = await _auth.signInAnonymously();
                            if (result == Null) {
                              print("Error in Sign in anonymously");
                            } else {
                              print("Sign in anonymously");
                              print(result.uid);
                            }
                          },
                          child: Container(
                            height: 40,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Color(0xffFF8225),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                width: 2,
                                color: Color(0xffB43F3F),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Sign in as Guest",
                                style: TextStyle(
                                  color: Color(0xff173B45),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//  ElevatedButton(
//         onPressed: () async {
//           dynamic resulut = await _auth.signInAnonymously();
//           if (resulut == Null) {
//             print("Error in Sign in anonymously");
//           } else {
//             print("Sign in anonymously");
//             print(resulut.uid);
//           }
//         },
//         child: Text("Sign in Anonymously"),
//       ),

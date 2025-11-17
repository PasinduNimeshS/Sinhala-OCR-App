import 'package:flutter/material.dart';
import 'package:sin_ocr/constants/styles.dart';
import 'package:sin_ocr/services/auth.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  const SignIn({super.key, required this.toggle});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthServices _auth = AuthServices();
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String error = "";
  bool _isPasswordVisible = false;
  final FocusNode _passwordFocusNode = FocusNode();
  final RegExp emailRegex = RegExp(
    r"^(?![.])([a-z0-9]+[.-])*[a-z0-9]+@[a-z0-9]+\.[a-z]{2,6}$",
  );

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color secondaryColor = Color(0xFF757575);
  static const Color buttonColor = Color(0xFF2196F3);

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(_focusNodeListener);
  }

  @override
  void dispose() {
    _passwordFocusNode.removeListener(_focusNodeListener);
    super.dispose();
  }

  void _focusNodeListener() {
    setState(() {
      _isPasswordVisible = _passwordFocusNode.hasFocus && password.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: Image.asset("assets/images/logo.png", height: 80),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "SINHALA TEXT",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    "SCANNING",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Login to your account",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Poppins',
                      color: secondaryColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          style: const TextStyle(
                            color: textColor,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: const TextStyle(
                              color: secondaryColor,
                              fontFamily: 'Poppins',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: secondaryColor.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: secondaryColor,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Enter a valid email";
                            } else if (!emailRegex.hasMatch(val)) {
                              return "Email cannot start with a special character or space";
                            }
                            return null;
                          },
                          onChanged: (val) => setState(() => email = val),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          focusNode: _passwordFocusNode,
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(
                            color: textColor,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(
                              color: secondaryColor,
                              fontFamily: 'Poppins',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: secondaryColor.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outlined,
                              color: secondaryColor,
                              size: 20,
                            ),
                            suffixIcon:
                                password.isNotEmpty
                                    ? IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: primaryColor,
                                        size: 20,
                                      ),
                                      onPressed:
                                          () => setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          }),
                                    )
                                    : null,
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator:
                              (val) =>
                                  val!.length < 6
                                      ? "Enter a valid password"
                                      : null,
                          onChanged: (val) => setState(() => password = val),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Forgot Password?",
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'Poppins',
                                color: primaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (error.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              error,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                                fontFamily: 'Poppins',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ] else
                          const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              dynamic result = await _auth
                                  .signInUsingEmailAndPassword(email, password);
                              if (result == null) {
                                setState(() {
                                  error =
                                      "Could not sign in with those credentials";
                                });
                              } else {
                                setState(() {
                                  error = "";
                                });
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.login,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            "Sign in",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () async {
                            dynamic result = await _auth.signInAnonymously();
                            if (result == null) {
                              print("Error in Sign in anonymously");
                            } else {
                              print("Sign in anonymously");
                            }
                          },
                          icon: const Icon(
                            Icons.abc_rounded,
                            color: primaryColor,
                            size: 18,
                          ),
                          label: const Text(
                            "Sign in as Guest",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: primaryColor),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Or sign in with",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Poppins',
                            color: secondaryColor,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            dynamic result = await _auth.signInWithGoogle();
                            if (result == null) {
                              print("Google sign-in failed");
                            } else {
                              print("Signed in with Google: ${result.uid}");
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(
                                color: secondaryColor.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              "assets/images/google.png",
                              height: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don’t have an account?",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'Poppins',
                                color: secondaryColor,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                widget.toggle();
                              },
                              child: Text(
                                "Sign up here",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'Poppins',
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

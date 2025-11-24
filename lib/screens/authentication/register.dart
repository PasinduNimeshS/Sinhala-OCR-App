import 'package:flutter/material.dart';
// import 'package:sin_ocr/constants/styles.dart';
import 'package:sin_ocr/services/auth.dart';

class Register extends StatefulWidget {
  final Function toggle;
  const Register({super.key, required this.toggle});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthServices _auth = AuthServices();
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String error = "";
  bool _isPasswordVisible = false;
  FocusNode _passwordFocusNode = FocusNode();
  final RegExp emailRegex = RegExp(
    r"^(?![_.])([a-z0-9]+[._-])*[a-z0-9]+@[a-z0-9]+\.[a-z]{2,6}$",
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Center(
                  child: Image.asset("assets/images/logo.png", height: 120),
                ),
                const SizedBox(height: 24),
                Text(
                  "Welcome!",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create your account",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Poppins',
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(height: 32),
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
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: secondaryColor,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return "Enter a valid email";
                          if (!emailRegex.hasMatch(val)) {
                            return "Email cannot start with a special character or space";
                          }
                          return null;
                        },
                        onChanged: (val) => setState(() => email = val),
                      ),
                      const SizedBox(height: 16),
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
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outlined,
                            color: secondaryColor,
                          ),
                          suffixIcon:
                              password.isNotEmpty
                                  ? IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: primaryColor,
                                    ),
                                    onPressed:
                                        () => setState(
                                          () =>
                                              _isPasswordVisible =
                                                  !_isPasswordVisible,
                                        ),
                                  )
                                  : null,
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator:
                            (val) =>
                                val!.length < 6
                                    ? "Password must be at least 6 characters"
                                    : null,
                        onChanged: (val) => setState(() => password = val),
                      ),
                      const SizedBox(height: 16),
                      if (error.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            error,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            dynamic result = await _auth
                                .registerUsingEmailAndPassword(email, password);
                            if (result == null) {
                              setState(() {
                                error = "Please enter valid email!";
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        label: const Text(
                          "REGISTER",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Or login with social accounts",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Poppins',
                          color: secondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
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
                            horizontal: 32,
                            vertical: 16,
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
                            height: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Do you have an account?",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Poppins',
                              color: secondaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => widget.toggle(),
                            child: Text(
                              "Sign in here",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'Poppins',
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

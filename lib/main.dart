import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sin_ocr/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sin_ocr/models/user_model.dart';
import 'package:sin_ocr/screens/wrapper.dart';
import 'package:sin_ocr/services/auth.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
  FlutterNativeSplash.remove();
}

//(options: DefaultFirebaseOptions.currentPlatform)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
      initialData: UserModel(uid: ""),
      value: AuthServices().user,
      child: MaterialApp(debugShowCheckedModeBanner: false, home: Wrapper()),
    );
  }
}

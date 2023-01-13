import 'package:flutter/material.dart';
import 'package:trans_pay/screen/LoginScreen.dart';
import 'package:trans_pay/screen/SignUpScreen.dart';
import 'package:trans_pay/source/common.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      routes: {
        '/':(context) => LoginPage(),
        '/signUp':(context)=>SignUpPage(),
      },
      debugShowCheckedModeBanner: false
    );
  }
}



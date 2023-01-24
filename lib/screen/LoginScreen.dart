import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:trans_pay/constants/appConstants.dart';
import 'package:trans_pay/helper/helper_function.dart';
import 'package:trans_pay/models/userDetails.dart';
import 'package:trans_pay/constants/common.dart';
import 'package:trans_pay/services/authentication.dart';
import 'package:trans_pay/services/databaseService.dart';

import '../widget/widget.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loginCheking = true;
  AuthService _auth = AuthService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HelperFunctions.getUserLoggedInStatus().then((value) {
      if (value == true) {
        Navigator.pushReplacementNamed(context, '/homeScreen');
      }
      setState(() {
        _loginCheking = false;
      });
    });
  }

  void logIn(context) async {
    setState(() {
      _loginCheking = true;
    });
    _auth
        .signInUserWithEmailandPassword(
            email: _emailCtrl.text, password: _passwordController.text)
        .then((value) async {
      if (value == true) {
        QuerySnapshot query =
            await DatabaseService().gettingUserData(_emailCtrl.text);

        final data = query.docs[0];
        await HelperFunctions.saveUserNameSF(data['username']);
        await HelperFunctions.saveUserEmailSF(data['email']);
        await HelperFunctions.saveUserLoggedInStatus(true);
        await HelperFunctions.saveUserIdSF('${_auth.uid}');

        Navigator.pushReplacementNamed(context, '/homeScreen');
      } else {
        setState(() {
          _loginCheking = false;
        });
        showSnackbar(context, Colors.red, value.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: transText(text: 'TransPay'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Center(
          child: _loginCheking
              ? CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontFamily: 'SofiSans',
                                  fontSize: 30,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            transText(text: 'Email', size: 17, bold: true),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _emailCtrl,
                              validator: (value) {
                                if (RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value!)) {
                                  return null;
                                }
                                return "Enter valid email";
                              },
                              decoration: const InputDecoration(
                                //border: OutlineInputBorder(),
                                hintText: 'Enter your username',
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            transText(text: 'Password', size: 17, bold: true),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              obscureText: true,
                              controller: _passwordController,
                              validator: (value) {
                                if (value!.length < 6) {
                                  return 'Password must be atleast 6 character';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                //border: OutlineInputBorder(),
                                hintText: 'Enter your password',
                                prefixIcon: Icon(Icons.lock),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      logIn(context);
                                    }
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    )),
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontFamily: 'SofiSans',
                                      fontSize: 17,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, '/signUp');
                                  },
                                  child: const Text(
                                    'SIGN UP',
                                    style: TextStyle(
                                      fontFamily: 'SofiSans',
                                      fontSize: 15,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

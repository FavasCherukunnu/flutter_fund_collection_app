import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trans_pay/services/databaseService.dart';

import '../helper/helper_function.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future registerUserWithEmailandPassword(
      {required String username,
      required String email,
      required String password}) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        // call our database service to update the user data.
        await DatabaseService(uid: user.uid).savingUserData(username, email);

        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future signInUserWithEmailandPassword(
      {required String email, required String password}) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        // call our database service to update the user data.
        //await DatabaseService(uid: user.uid).savingUserData(username, email);

        return true;
      }
    } on FirebaseAuthException catch (e) {
      print('message is ${e.message}');
      return e.message;
    }
  }

  Future logout(context) async {
    try {
      await HelperFunctions.saveUserNameSF("");
      await HelperFunctions.saveUserEmailSF("");
      await HelperFunctions.saveUserLoggedInStatus(false);
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      return null;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:trans_pay/constants/common.dart';

class ProfileScreen extends StatelessWidget {
  String? email;
  String? username;
  ProfileScreen({super.key, this.username, this.email});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    email = arguments['email'];
    username = arguments['username'];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: transText(text: 'Profile'),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle,
              size: 200,
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                transText(text: 'Username', bold: true, size: 17),
                transText(text: username ?? 'NA', size: 17)
              ],
            ),
            const SizedBox(
              height: 17,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                transText(text: 'Email', bold: true, size: 17),
                transText(text: email ?? 'NA', size: 17),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

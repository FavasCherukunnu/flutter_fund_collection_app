import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:trans_pay/constants/common.dart';

class SignUpPage extends StatelessWidget {
   SignUpPage({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: primaryBgColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text(
            'TransPay',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'SofiSans',
              letterSpacing: 1,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 30),
          child: Center(
            child: SingleChildScrollView(
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
                            'SIGNUP',
                            style: TextStyle(
                              fontFamily: 'SofiSans',
                              fontSize: 30,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 50,),

                        const Text(
                          'Username',
                          style: TextStyle(
                            fontFamily: 'SofiSans',
                            fontSize: 17,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            //border: OutlineInputBorder(),
                            hintText: 'Enter your username',
                            prefixIcon: Icon(Icons.person),
                          ),
                  
                        ),
                        const SizedBox(height: 30,),

                        const Text(
                          'Email',
                          style: TextStyle(
                            fontFamily: 'SofiSans',
                            fontSize: 17,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextFormField(
                          validator: (value) {
                            if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!)) {                              
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
                        const SizedBox(height: 30,),

                        const Text(
                          'Password',
                          style: TextStyle(
                            fontFamily: 'SofiSans',
                            fontSize: 17,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextFormField(
                          //obscureText: true,
                          validator: (value) {
                            if (value!.length<6) {
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
                        const SizedBox(height: 20,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: () { 

                                _formKey.currentState!.validate();

                              },
                              style: ButtonStyle(
                                shape:  MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  )
                                ),
                              ),
                              child: const Text(
                                'Sign Up',
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
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children:  [
                            TextButton(
                              onPressed: () { 
                                Navigator.pushReplacementNamed(context, '/');
                              },
                              child: const Text(
                                'LOGIN',
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
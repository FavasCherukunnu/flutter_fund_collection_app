import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trans_pay/models/userDetails.dart';
import 'package:trans_pay/screen/LoginScreen.dart';
import 'package:trans_pay/screen/SignUpScreen.dart';
import 'package:trans_pay/screen/chatScreen/chatDetailsScreen.dart';
import 'package:trans_pay/screen/chatScreen/chatScreen.dart';
import 'package:trans_pay/screen/homeScreen.dart';
import 'package:trans_pay/screen/settingsScreen.dart';
import 'package:trans_pay/constants/common.dart';

import 'constants/appConstants.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  //check it is web or android
  if(kIsWeb){
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: Constants.apiKey, 
        appId: Constants.appId, 
        messagingSenderId: Constants.messagingSenderId, 
        projectId: Constants.projectId,
      )
    );
  }else{
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserClass>(
      create: (context)=>UserClass(userName: 'favas', password: 'saleel'),
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        // initialRoute: '/homeScreen',
        routes: {
          '/':(context) => LoginPage(),
          '/signUp':(context)=>SignUpPage(),
          '/homeScreen':(context)=>HomeScreen(),
          '/settingsScreen':(context)=>SettingsScreen(),
          '/chatScreen':(context)=>ChatScreen(),
          '/chatDetailsScreen':(context) => ChatDetailsScreen(),
        },
        debugShowCheckedModeBanner: false
      ),
    );
  }
}



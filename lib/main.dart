
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trans_pay/models/userDetails.dart';
import 'package:trans_pay/screen/LoginScreen.dart';
import 'package:trans_pay/screen/SignUpScreen.dart';
import 'package:trans_pay/screen/chatScreen/chatScreen.dart';
import 'package:trans_pay/screen/homeScreen.dart';
import 'package:trans_pay/screen/profileScreen.dart';
import 'package:trans_pay/screen/searchScreen.dart';
import 'constants/appConstants.dart';

void main() async {
  String? groupIdN=null;
  WidgetsFlutterBinding.ensureInitialized();

  //check it is web or android
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
      apiKey: Constants.apiKey,
      appId: Constants.appId,
      messagingSenderId: Constants.messagingSenderId,
      projectId: Constants.projectId,
    ));
  } else {
    await Firebase.initializeApp();
      // Get any initial links
    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if(initialLink!=null){
      Uri deeplink = initialLink.link;
      groupIdN = deeplink.queryParameters['groupIdN'];
      print('in the deep linking');
    }else{
      print('link is null');
    }
  }



  runApp( MyApp(groupIdN:groupIdN));
}

class MyApp extends StatelessWidget {
  MyApp({super.key,this.groupIdN});

  String? groupIdN;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserClass>(
      create: (context) => UserClass(userName: 'favas', password: 'saleel'),
      child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
          ),
          // initialRoute: '/homeScreen',
          routes: {
            '/': (context) => LoginPage(groupIdN: groupIdN,),
            '/signUp': (context) => SignUpPage(),
            '/homeScreen': (context) => HomeScreen(),
            '/profileScreen': (context) => ProfileScreen(),
            '/searchScreen': (context) => SearchScreen(),
          },
          debugShowCheckedModeBanner: false),
    );
  }
}

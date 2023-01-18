import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:trans_pay/constants/common.dart';
import 'package:trans_pay/models/userDetails.dart';

class ChatDetailsScreen extends StatelessWidget {
  const ChatDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final arguments = ModalRoute.of(context)!.settings.arguments ;
    Map args ={};
    Group group = Group(name: 'NA');

    if(arguments == null){
      args={};
    }else{
      args = arguments as Map ;
      
      group = args['group'];
    }


    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            
            color: primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 40,
                  child: Icon(
                    Icons.group,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 20,),
                Center(child: transText(text: group.name,size:25,color: Colors.white)),
                const SizedBox(height: 20,)
          
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child:Text(
              group.groupDetails.toString()
            ),

          )

        ],
      ),
    );
  }
}
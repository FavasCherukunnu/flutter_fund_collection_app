import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:trans_pay/models/userDetails.dart';
import 'package:trans_pay/source/common.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {

    final arguments = ModalRoute.of(context)!.settings.arguments as Map;

    Chat chat = arguments['chatData'];

    return Scaffold(
      appBar: AppBar(
        title: transText(text: chat.name ),
      ),
      body:Column(
        children: [
          Flexible(
            child: ListView.builder(
              itemBuilder: (context, index){
                return buildItem(chat.message[index]);
              },
              itemCount: chat.message.length,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 5, 10, 5),
            child:Row(
              children: [
                Flexible(
                  child: Container(
                    child: TextField(
                      onSubmitted: (value) {

                      },
                      style: const TextStyle(
                        fontFamily: 'SofiSans',
                        letterSpacing: 1,
                      ),
                      //controller: ,
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Enter Amount',
                        hintStyle: TextStyle(
                          fontFamily: 'SofiSans',
                          letterSpacing: 1,
                        ),
                      ),
                      //focusNode: focusNode,
                      autofocus: true,
                    ),
                  ),
                ),
                Material(
                  color: Colors.white,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {},
                      color: primaryColor,
                      tooltip: 'pay',
                    ),
                  ),
                ),
              ],
            ),

          )
        ],
      ) ,
    );
  }

  Widget buildItem (Messages messages){

    return Row(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
          width: 200,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          margin:const  EdgeInsets.only(bottom: 10, right: 10),
          child: transText(
            text:messages.messages,
            size: 17
          ),
        )
      ],
    );

  }


}
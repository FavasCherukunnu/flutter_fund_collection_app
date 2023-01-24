import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:trans_pay/models/userDetails.dart';
import 'package:trans_pay/constants/common.dart';
import 'package:trans_pay/screen/chatScreen/chatDetailsScreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController amountDetails = TextEditingController();
  late String groupName;
  late String groupId;

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;

    groupName = arguments['groupName'];
    groupId = arguments['groupId'];
    ScrollController listViewController = ScrollController();

    return Scaffold(
        backgroundColor: primaryBgColor,
        appBar: AppBar(
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                child: transText(text: groupName),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatDetailsScreen(
                                groupId: groupId,
                              )));
                },
              ),
            ],
          ),
        ),
        body: Container()
        // Column(
        //   children: [
        //     Flexible(
        //       child: ListView.builder(
        //         itemBuilder: (context, index) {
        //           return buildItem(userclass
        //               .groups[indexofChat].message.reversed
        //               .toList()[index]);
        //         },
        //         itemCount: userclass.groups[indexofChat].message.length,
        //         reverse: true,
        //         controller: listViewController,
        //       ),
        //     ),
        //     Container(
        //       padding: EdgeInsets.fromLTRB(20, 5, 10, 5),
        //       child: Row(
        //         children: [
        //           Flexible(
        //             child: Container(
        //               child: TextField(
        //                 keyboardType: TextInputType.number,
        //                 controller: amountDetails,
        //                 // onSubmitted: (value) {

        //                 // },
        //                 style: const TextStyle(
        //                   fontFamily: 'SofiSans',
        //                   letterSpacing: 1,
        //                 ),
        //                 //controller: ,
        //                 decoration: const InputDecoration.collapsed(
        //                   hintText: 'Enter Amount',
        //                   hintStyle: TextStyle(
        //                     fontFamily: 'SofiSans',
        //                     letterSpacing: 1,
        //                   ),
        //                 ),
        //                 //focusNode: focusNode,
        //                 autofocus: false,
        //               ),
        //             ),
        //           ),
        //           Material(
        //             //color: Colors.white,
        //             child: Container(
        //               margin: EdgeInsets.symmetric(horizontal: 8),
        //               child: IconButton(
        //                 icon: Icon(Icons.send),
        //                 onPressed: () {
        //                   final String amount = amountDetails.text;
        //                   FocusScopeNode currentFocus =
        //                       FocusScope.of(context);
        //                   //got to bottom of listview
        //                   listViewController.animateTo(
        //                       listViewController.position.minScrollExtent,
        //                       duration: Duration(milliseconds: 500),
        //                       curve: Curves.easeOut);
        //                   if (amount.isNotEmpty) {
        //                     if (!currentFocus.hasPrimaryFocus) {
        //                       currentFocus.unfocus();
        //                     }
        //                     amountDetails.clear();
        //                     userclass.addmsg(
        //                         msg: amount,
        //                         index: indexofChat,
        //                         senterId: senterId);
        //                   }
        //                 },
        //                 color: primaryColor,
        //                 tooltip: 'pay',
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     )
        //   ],
        // )
        );
  }

  Widget buildItem(Messages messages) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            width: 200,
            decoration: BoxDecoration(
                color: chatColor, borderRadius: BorderRadius.circular(8)),
            //margin:const  EdgeInsets.only(bottom: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: transText(
                          text: messages.amount, size: 20, color: Colors.white),
                    )
                  ],
                ),
                transText(text: messages.formattedTime, color: Colors.white)
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:trans_pay/helper/helper_function.dart';
import 'package:trans_pay/models/userDetails.dart';
import 'package:trans_pay/constants/common.dart';
import 'package:trans_pay/screen/chatScreen/chatDetailsScreen.dart';
import 'package:trans_pay/services/databaseService.dart';
import 'package:trans_pay/widget/messageTile.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen(
      {super.key,
      required this.groupName,
      required this.groupId,
      required this.userId});

  String groupName;
  String groupId;
  String userId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController amountDetails = TextEditingController();
  String? userName;
  ScrollController listViewController = ScrollController();
  Stream? messages;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMessages();
  }

  getMessages() async {
    messages = await DatabaseService()
        .groupCollection
        .doc(widget.groupId)
        .collection('messages')
        .orderBy("time", descending: true)
        .snapshots();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: primaryBgColor,
        appBar: AppBar(
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                child: transText(text: widget.groupName),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatDetailsScreen(
                                groupId: widget.groupId,
                              )));
                },
              ),
            ],
          ),
        ),
        body: chatSection());
  }

  sentMessage(String amount) async {
    String? userName = await HelperFunctions.getUserNameFromSF();
    String senterId = '${widget.userId}_$userName';
    await DatabaseService()
        .sentMessage(widget.groupId, amount, senterId, DateTime.now());
  }

  getId(String data) {
    return data.substring(0, data.indexOf('_'));
  }

  getName(String data) {
    return data.substring(data.indexOf('_') + 1);
  }

  checkSenter(String senterId) {
    String realUserId = getId(senterId);
    if (realUserId == widget.userId) {
      return true;
    } else {
      return false;
    }
  }

  Column chatSection() {
    return Column(
      children: [
        Flexible(
          child: StreamBuilder(
            stream: messages,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data.docs;

                return ListView.builder(
                  itemBuilder: (context, index) {
                    return MessageTile(
                      amount: data[index]['amount'],
                      isSenter: checkSenter(data[index]['senterId']),
                      time: data[index]['time'],
                      senderName: getName(data[index]['senterId']),
                    );
                  },
                  itemCount: data.length,
                  reverse: true,
                  controller: listViewController,
                );
              } else {
                return Container();
              }
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
          padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Flexible(
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: amountDetails,
                  // onSubmitted: (value) {

                  // },
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
                  autofocus: false,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  final String amount = amountDetails.text;
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  //got to bottom of listview

                  if (amount.isNotEmpty && isNumeric(amount) && int.parse(amount)>=0) {
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    amountDetails.clear();
                    await sentMessage(amount);
                  }
                  // listViewController.animateTo(
                  //     listViewController.position.minScrollExtent,
                  //     duration: const Duration(milliseconds: 500),
                  //     curve: Curves.easeOut);
                },
                color: primaryColor,
                tooltip: 'pay',
              ),
            ],
          ),
        )
      ],
    );
  }
}

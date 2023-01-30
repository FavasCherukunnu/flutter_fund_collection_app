import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:trans_pay/helper/helper_function.dart';
import 'package:trans_pay/models/userDetails.dart';
import 'package:trans_pay/constants/common.dart';
import 'package:trans_pay/screen/chatScreen/chatDetailsScreen.dart';
import 'package:trans_pay/services/authentication.dart';
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
  DocumentSnapshot? groupDetails;
  bool _isChatLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMessages();
  }

  Future getMessages() async {
    //getting group details
    groupDetails = await DatabaseService().getGroupInfo(widget.groupId);

    messages = await DatabaseService()
        .groupCollection
        .doc(widget.groupId)
        .collection('messages')
        .orderBy("time", descending: true)
        .snapshots();
    setState(() {
      _isChatLoaded = true;
    });
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
    final groupInfo = groupDetails!.data() as Map;
    String? userName = await HelperFunctions.getUserNameFromSF();
    String senterId = '${widget.userId}_$userName';
    await DatabaseService().sentMessage(widget.groupName, widget.groupId,
        amount, senterId, DateTime.now(), getId(groupInfo['admin']));
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

  bool isAdmin({String? senterIDN = null}) {
    String? adminIdN;
    String? checkingId;

    if (senterIDN != null) {
      checkingId = getId(senterIDN);
    } else {
      checkingId = widget.userId;
    }
    final groupInfo = groupDetails!.data() as Map;
    adminIdN = groupInfo['admin'];
    if (getId(adminIdN!) == checkingId) {
      return true;
    } else {
      return false;
    }
  }

  Column chatSection() {
    return Column(
      children: [
        Flexible(
          child: _isChatLoaded
              ? StreamBuilder(
                  stream: messages,
                  builder: (context, AsyncSnapshot snapshot) {
                    final groupInfo = groupDetails!.data() as Map;

                    if (snapshot.hasData) {
                      final data = snapshot.data.docs;

                      return ListView.builder(
                        itemBuilder: (context, index) {
                          return MessageTile(
                            amount: data[index]['amount'],
                            isSenter: checkSenter(data[index]['senterId']),
                            time: data[index]['time'],
                            senderName: getName(data[index]['senterId']),
                            isAdmin:
                                isAdmin(senterIDN: data[index]['senterId']),
                          );
                        },
                        itemCount: data.length,
                        reverse: true,
                        controller: listViewController,
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                )
              : const CircularProgressIndicator(),
        ),
        _isChatLoaded
            ? Container(
                margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
                decoration: const BoxDecoration(
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
                    isAdmin()
                        ? TextButton(
                            onPressed: () {},
                            child: transText(text: 'withdraw'))
                        : IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () async {
                              final String amount = amountDetails.text;
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              //got to bottom of listview

                              if (amount.isNotEmpty &&
                                  isNumeric(amount) &&
                                  int.parse(amount) >= 0) {
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
            : Container()
      ],
    );
  }
}

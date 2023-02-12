import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_upi_payment/easy_upi_payment.dart';
import 'package:flutter/material.dart';
import 'package:trans_pay/constants/appConstants.dart';
import 'package:trans_pay/helper/helper_function.dart';
import 'package:trans_pay/constants/common.dart';
import 'package:trans_pay/models/groupDetails.dart';
import 'package:trans_pay/screen/chatScreen/chatDetailsScreen.dart';
import 'package:trans_pay/services/databaseService.dart';
import 'package:trans_pay/widget/dateTile.dart';
import 'package:trans_pay/widget/messageTile.dart';
import 'package:trans_pay/widget/widget.dart';

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
  TextEditingController noteController = TextEditingController();
  String? userName;
  ScrollController listViewController = ScrollController();
  Stream? messages;
  Stream? totalAmount;
  Stream? groupDetailsStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? amountDetailsStream;
  DocumentSnapshot? groupDetails;
  bool _isChatLoaded = false;
  GroupType groupType = GroupType();
  AmountDetails totalAmountDetails = AmountDetails();
  String errorText = '';
  dynamic groupInfo;
  bool _isUpiValid = true;
  bool _errorTextChanged = false;

  final payKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMessages();
  }

  Future getMessages() async {
    //getting group details
    groupDetails = await DatabaseService().getGroupInfo(widget.groupId);
    groupDetailsStream = DatabaseService().getGroupInfoStream(widget.groupId);
    totalAmount = DatabaseService().amountDetails(widget.groupId);
    amountDetailsStream = DatabaseService().amountDetails(widget.groupId);
    groupInfo = groupDetails!.data() as Map;
    setState(() {
      groupType.setGroupType = groupInfo['groupType'];
    });

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
                              groupName: widget.groupName,
                              groupId: widget.groupId,
                              groupType: groupType,
                              adminIdN: groupInfo['admin'])));
                },
              ),
            ],
          ),
        ),
        body: chatSection());
  }

  sentMessage(String amount, String message, bool isWithdraw) async {
    final groupInfo = groupDetails!.data() as Map;
    String? userName = await HelperFunctions.getUserNameFromSF();
    String senterIdN = '${widget.userId}_$userName';
    await DatabaseService().sentMessage(widget.groupName, widget.groupId,
        amount, senterIdN, DateTime.now(), getId(groupInfo['admin']),
        isWithdraw: isWithdraw, message: message);
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

  Widget buildUserSentButton() {
    return TextButton(
      child: transText(text: 'Pay'),
      onPressed: () async {
        final String amount = amountDetails.text;
        final String message = noteController.text;
        FocusScopeNode currentFocus = FocusScope.of(context);
        _errorTextChanged=false;
        //got to bottom of listview

        if (payKey.currentState!.validate()) {
          if (amount.isNotEmpty &&
              isNumeric(amount) &&
              double.parse(amount) >= 0 && !totalAmountDetails.isLimitReached()) {
            
            if(totalAmountDetails.isLimitReachedAmount(double.parse(amount))){
              setState(() {
                _errorTextChanged=true;
                errorText='Exeeds the limit';
              });
              return;
            }
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            groupDetails = await DatabaseService().getGroupInfo(widget.groupId);
            final data = groupDetails!.data() as Map;
            // await sentMessage(amount, message, false);

            try {
              final res = await EasyUpiPaymentPlatform.instance.startPayment(
                EasyUpiPaymentModel(
                  payeeVpa: data['upiId'],
                  payeeName: data['upiName'],
                  amount: double.parse(amount),
                  description: message.isEmpty ? 'payment' : message,
                ),
              );
              amountDetails.clear();
              noteController.clear();
              await sentMessage(amount, message, false);
              if (res != null) {
                print(res.transactionId);
              } else {
                print('result is null');
              }
            } catch (exception, subtrace) {
              exception as EasyUpiPaymentException;
              if (exception.type ==
                  EasyUpiPaymentExceptionType.unknownException) {
                showSnackbar(context, Colors.red, 'Somthing went wrong !!!');
              } else if (exception.type ==
                  EasyUpiPaymentExceptionType.cancelledException) {
                showSnackbar(context, Colors.red, 'You Cancelled payment!!!');
              } else if (exception.type ==
                  EasyUpiPaymentExceptionType.appNotFoundException) {
                showSnackbar(context, Colors.red, 'App Not found!!!');
              } else if (exception.type ==
                  EasyUpiPaymentExceptionType.failedException) {
                showSnackbar(context, Colors.red, 'Failed payment!!!');
              } else if (exception.type ==
                  EasyUpiPaymentExceptionType.submittedException) {
                showSnackbar(context, Colors.red,
                    'payment is pending. if successfull approch admin!!!');
              }
            }
          }
        }

        // listViewController.animateTo(
        //     listViewController.position.minScrollExtent,
        //     duration: const Duration(milliseconds: 500),
        //     curve: Curves.easeOut);
      },
    );
  }

  Widget buildAdminWithrawalbutton() {
    return TextButton(
        onPressed: () async {
          final String amount = amountDetails.text;
          final message = noteController.text;
          FocusScopeNode currentFocus = FocusScope.of(context);
          //got to bottom of listview

          if (amount.isNotEmpty && isNumeric(amount) && num.parse(amount) > 0) {
            if (totalAmountDetails.isdebitable(amount: double.parse(amount))) {
              errorText = '';
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              amountDetails.clear();
              noteController.clear();
              await sentMessage(amount, message, true);
            } else {
              setState(() {
                errorText = 'No Money In Group';
              });
            }
          }
        },
        child: transText(text: 'withdraw'));
  }

  Widget buildUserSentAndWithrawalButton() {
    return Row(
      children: [
        buildAdminWithrawalbutton(),
        buildUserSentButton(),
      ],
    );
  }

  Widget? buildbottombutton() {
    if (isAdmin()) {
      if (groupType.getGroupType == GroupType.memberWithdrawal) {
        return buildUserSentAndWithrawalButton();
      } else if (groupType.getGroupType == GroupType.memberNonWithdrawal) {
        return buildAdminWithrawalbutton();
      }
    } else {
      if (groupType.getGroupType == GroupType.memberWithdrawal) {
        return buildUserSentAndWithrawalButton();
      } else {
        return buildUserSentButton();
      }
    }
    return null;
  }

  chatSection() {
    return StreamBuilder(
        stream: amountDetailsStream,
        builder: (context, snapshotAmount) {
          if (snapshotAmount.hasData) {
            final userDetails = snapshotAmount.data!.docs;
            return Column(
              children: [
                Flexible(
                  child: _isChatLoaded
                      ? StreamBuilder(
                          stream: messages,
                          builder: (context, AsyncSnapshot snapshot) {
                            final groupInfo = groupDetails!.data() as Map;
                            DateTime prevDay;
                            DateTime currentDay;

                            if (snapshot.hasData &&
                                snapshot.data.docs.isNotEmpty) {
                              final data = snapshot.data.docs;

                              return ListView.builder(
                                itemBuilder: (context, index) {
                                  //determine new day

                                  //checking the user is removed or not
                                  QueryDocumentSnapshot? user;
                                  userDetails.forEach((e) {
                                    if (e['memberId'] ==
                                        data[index]['senterId']) {
                                      user = e;
                                    }
                                  });

                                  currentDay =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          data[index]['time']);
                                  prevDay = DateTime.fromMillisecondsSinceEpoch(
                                      data[index == 0 ? index : index - 1]
                                          ['time']);
                                  Duration diff =
                                      currentDay.difference(prevDay);

                                  bool isChanged =
                                      (diff.inDays > 1 || diff.inDays < -1) ||
                                              currentDay.day != prevDay.day
                                          ? true
                                          : false;

                                  return Column(
                                    children: [
                                      index == data.length - 1
                                          ? dateTile(
                                              text:
                                                  '${currentDay.day}-${currentDay.month}-${currentDay.year}')
                                          : const SizedBox.shrink(),
                                      GestureDetector(
                                        onLongPress: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return StatefulBuilder(
                                                builder: (context, setState) {
                                                  final MessageAmount
                                                      messageAmount1 =
                                                      MessageAmount()
                                                        ..setValues(data,
                                                            startPosition:
                                                                index,
                                                            endPosition:
                                                                data.length);

                                                  return SimpleDialog(
                                                    children: [
                                                      Text(messageAmount1
                                                          .credited
                                                          .toString())
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                        child: MessageTile(
                                          amount: data[index]['amount'],
                                          isSenter: checkSenter(
                                              data[index]['senterId']),
                                          time: data[index]['time'],
                                          senderName: user!['isRemoved']
                                              ? 'Unknown'
                                              : getName(
                                                  data[index]['senterId']),
                                          isAdmin: isAdmin(
                                              senterIDN: data[index]
                                                  ['senterId']),
                                          groupType: groupType.getGroupType,
                                          isWithdraw: data[index]['isWithdraw'],
                                          message: data[index]['message'],
                                        ),
                                      ),
                                      isChanged
                                          ? dateTile(
                                              text:
                                                  '${prevDay.day}-${prevDay.month}-${prevDay.year}')
                                          : const SizedBox.shrink(),
                                    ],
                                  );
                                },
                                itemCount: data.length,
                                reverse: true,
                                controller: listViewController,
                              );
                            } else if (snapshot.hasData &&
                                !snapshot.data.docs.isNotEmpty) {
                              return Container();
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        )
                      : const CircularProgressIndicator(),
                ),
                StreamBuilder(
                  stream: groupDetailsStream,
                  builder: (context, snapshot1) {
                    return _isChatLoaded
                        ? StreamBuilder(
                            stream: totalAmount,
                            builder: (context, snapshot) {
                              if (snapshot1.hasData&&snapshot.hasData) {
                                totalAmountDetails.setValues(snapshot.data.docs);

                                final data1 = snapshot1.data;
                                if(_errorTextChanged==false){
                                  errorText='';
                                }
                                
                                if (totalAmountDetails.isdebitable(
                                    amount: amountDetails.text.isEmpty
                                        ? null
                                        : double.parse(amountDetails.text))) {
                                  //errorText = '';
                                } else {
                                  errorText = 'No Money In Group';
                                }

                                totalAmountDetails.limit =  data1['Amount_limit'];
                                print('limit is ${totalAmountDetails.limit}');
                                if(totalAmountDetails.isLimitReached()){
                                  errorText = 'No more Money accepted';
                                }
                
                                return SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.fromLTRB(5, 10, 5, 5),
                                        padding: const EdgeInsets.fromLTRB(
                                            15, 20, 5, 20),
                                        decoration: const BoxDecoration(
                                          borderRadius:
                                              BorderRadius.all(Radius.circular(20)),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Form(
                                                key: payKey,
                                                child: Column(
                                                  children: [
                                                    TextFormField(
                                                      maxLines: null,
                                                      controller: noteController,
                                                      textInputAction:
                                                          TextInputAction.newline,
                                                      decoration:
                                                          const InputDecoration
                                                              .collapsed(
                                                        hintText:
                                                            'Add Note(Optional)',
                                                        hintStyle: TextStyle(
                                                          fontFamily: 'SofiSans',
                                                          letterSpacing: 1,
                                                        ),
                                                      ),
                                                    ),
                                                    Divider(),
                                                    TextFormField(
                                                      validator: (value) {
                                                        if (value!.isEmpty) {
                                                          return 'Please Enter the amount';
                                                        }
                                                      },
                                                      keyboardType:
                                                          TextInputType.number,
                                                      controller: amountDetails,
                                                      // onSubmitted: (value) {
                
                                                      // },
                                                      style: const TextStyle(
                                                        fontFamily: 'SofiSans',
                                                        letterSpacing: 1,
                                                      ),
                                                      //controller: ,
                                                      decoration:
                                                          const InputDecoration
                                                              .collapsed(
                                                        hintText: 'Enter Amount',
                                                        hintStyle: TextStyle(
                                                          fontFamily: 'SofiSans',
                                                          letterSpacing: 1,
                                                        ),
                                                      ),
                                                      //focusNode: focusNode,
                                                      autofocus: false,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            buildbottombutton()!
                                          ],
                                        ),
                                      ),
                                      transText(text: errorText, color: Colors.red),
                                    ],
                                  ),
                                );
                                //
                
                              } else {
                                return SizedBox.shrink();
                              }
                            })
                        : Container();
                  }
                )
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

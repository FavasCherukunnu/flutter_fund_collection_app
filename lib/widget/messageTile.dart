import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trans_pay/constants/appConstants.dart';

import '../constants/common.dart';
import '../models/userDetails.dart';

class MessageTile extends StatelessWidget {
  MessageTile(
      {Key? key,
      required this.amount,
      required this.isSenter,
      required this.time,
      required this.senderName,
      required this.isAdmin,
      required this.groupType,
      required this.isWithdraw})
      : super(key: key);

  String amount;
  bool isSenter;
  int time;
  String senderName;
  bool isAdmin;
  int groupType;
  bool isWithdraw;

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    final DateFormat formatter = DateFormat('jm');
    final String formatted = formatter.format(dateTime);

    return Flex(
        direction: Axis.horizontal,
        mainAxisAlignment:
            isSenter ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                minWidth: MediaQuery.of(context).size.width * 0.3),
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            margin: isSenter
                ? const EdgeInsets.fromLTRB(20, 10, 5, 0)
                : const EdgeInsets.fromLTRB(5, 10, 10, 0),
            decoration: BoxDecoration(
                color: isWithdraw
                    ? debitColor
                    : isSenter
                        ? senterChatColor
                        : recieverChatColor,
                borderRadius: BorderRadius.circular(8)),
            //margin:const  EdgeInsets.only(bottom: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: transText(
                      text: isSenter ? 'You' : senderName,
                      bold: true,
                      color: Colors.white,
                      size: 17),
                ),
                Container(
                    padding: isSenter
                        ? EdgeInsets.only(right: 20)
                        : EdgeInsets.only(left: 20),
                    child:
                        transText(text: amount, size: 25, color: Colors.white)),
                transText(text: formatted, color: Colors.white, size: 10)
              ],
            ),
          ),
        ]);
  }
}

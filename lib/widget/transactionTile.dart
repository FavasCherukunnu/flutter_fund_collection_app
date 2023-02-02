import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

import '../constants/common.dart';

class TransactionTile extends StatelessWidget {
  TransactionTile(
      {super.key, required this.transactionData, required this.userId});

  QueryDocumentSnapshot transactionData;
  bool _isWithdraw = false;
  bool _isAdmin = false;
  String userId;
  bool own = false;

  @override
  Widget build(BuildContext context) {
    _isWithdraw = transactionData['isWithdraw'];
    _isAdmin = transactionData['isAdmin'];
    String senterIdN = transactionData['senterId'];
    own = userId == getId(senterIdN);
    print(getId(senterIdN));

    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(transactionData['time']);
    final DateFormat formatter = DateFormat('jm');
    final String formattedTime = formatter.format(dateTime);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        isThreeLine: own ? false : true,
        horizontalTitleGap: 30,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        selectedTileColor: Colors.white,
        selected: true,
        title: transText(
            text: _isWithdraw ? 'Withdrew From' : 'Paid To',
            color: getThemeColor(),
            size: 15),
        onTap: () {},
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            transText(
                text: '${getName(transactionData['groupId'])}',
                color: Colors.black,
                overflow: TextOverflow.ellipsis,
                bold: true,
                size: 20),
            own
                ? Container()
                : transText(
                    text: '${getName(transactionData['senterId'])}',
                    color: Colors.black),
          ],
        ),
        trailing: Column(
          children: [
            Expanded(
              child: transText(
                  text: '${transactionData['amount']}',
                  color: getThemeColor(),
                  size: 25),
            ),
            transText(text: formattedTime, color: Colors.black),
          ],
        ),
      ),
    );
  }

  getThemeColor() => _isWithdraw
      ? own
          ? credittedColor
          : debitColor
      : own
          ? debitColor
          : credittedColor;
}

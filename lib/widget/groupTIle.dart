import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:trans_pay/helper/helper_function.dart';
import 'package:trans_pay/screen/chatScreen/chatScreen.dart';

import '../constants/common.dart';

class GroupTile extends StatelessWidget {
  GroupTile({super.key, required this.groupName, required this.groupId});

  String groupName;
  String groupId;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0.3),
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(15, 8, 5, 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: primaryColor,
          child: Center(
            child: transText(
                text: groupName.substring(0, 1), size: 22, bold: true),
          ),
        ),
        title: transText(text: groupName, size: 17),
        onTap: () async {
          String? userId = await HelperFunctions.getUserIdFromSF();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen(
                      groupName: groupName,
                      groupId: groupId,
                      userId: userId!)));
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trans_pay/constants/appConstants.dart';
import 'package:trans_pay/constants/common.dart';
import 'package:trans_pay/models/groupDetails.dart';
import 'package:trans_pay/models/userDetails.dart';
import 'package:trans_pay/services/databaseService.dart';

class ChatDetailsScreen extends StatefulWidget {
  ChatDetailsScreen(
      {super.key, required this.groupId, required this.groupType});

  String groupId;
  GroupType groupType;

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  late UserClass userdata;

  late int indexOfGroup;

  Stream? groupInfo;
  Stream? amountDetails;
  late double totalAmount;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    groupInfo = DatabaseService().getGroupInfoStream(widget.groupId);
    amountDetails = DatabaseService().amountDetails(widget.groupId);
    // final totalAmount = DatabaseService().getTotalAmountInfo(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    userdata = Provider.of<UserClass>(context);

    late String adminIdN;

    isAdmin(String userIdN) => getId(adminIdN) == getId(userIdN) ? true : false;

    int getGroupType() {
      return widget.groupType.getGroupType;
    }

    return Scaffold(
      backgroundColor: primaryBgColor,
      appBar: AppBar(
        elevation: 0,
      ),
      body: StreamBuilder(
          stream: groupInfo,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            //final totalAmount = snapshot.data;
            if (snapshot.hasData) {
              final group = snapshot.data;
              String admin = group['admin'];
              adminIdN = admin;
              String groupName = group['groupName'];
              final members = group['members'];

              return Column(
                children: [
                  Container(
                    color: primaryColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 40,
                          child: transText(
                              text: groupName.substring(0, 1),
                              size: 30,
                              bold: true),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: transText(
                                text: groupName, size: 25, color: Colors.white),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              transText(
                                  text: 'Admin: ',
                                  color: Colors.white,
                                  size: 15,
                                  bold: true),
                              transText(
                                  text: getName(admin),
                                  color: Colors.white,
                                  size: 15)
                            ],
                          ),
                        ),
                        StreamBuilder(
                          stream: amountDetails,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            final data = snapshot.data.docs;
                            final AmountDetails amounts = AmountDetails()
                              ..setValues(data);
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    transText(
                                        text: 'CREDITTED: ',
                                        color: Colors.white,
                                        size: 15,
                                        bold: true),
                                    transText(
                                        text: amounts.credited.toString(),
                                        color: Colors.white,
                                        size: 16)
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    transText(
                                        text: 'DEBITTED: ',
                                        color: Colors.white,
                                        size: 15,
                                        bold: true),
                                    transText(
                                        text: amounts.debited.toString(),
                                        color: Colors.white,
                                        size: 16)
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    transText(
                                        text: 'BALANCE: ',
                                        color: Colors.white,
                                        size: 15,
                                        bold: true),
                                    transText(
                                        text: amounts.getBalance.toString(),
                                        color: Colors.white,
                                        size: 16)
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                )
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Card(
                                margin: EdgeInsets.all(0.3),
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(15, 8, 5, 8),
                                  leading: const CircleAvatar(
                                    radius: 25,
                                    backgroundColor: primaryColor,
                                  ),
                                  title:
                                      transText(text: getName(members[index])),
                                  trailing: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: StreamBuilder(
                                      stream: DatabaseService()
                                          .getTotalAmountInfo(
                                              widget.groupId, members[index]),
                                      builder: (context,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        if (snapshot.hasData) {
                                          final doc = snapshot.data!.docs[0];
                                          return SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                transText(
                                                    text: doc['depositAmount']
                                                        .toString(),
                                                    color: credittedColor),
                                                isAdmin(members[index]) ||
                                                        getGroupType() ==
                                                            GroupType
                                                                .memberWithdrawal
                                                    ? transText(
                                                        text:
                                                            doc['withdrawAmount']
                                                                .toString(),
                                                        color: debitColor)
                                                    : SizedBox.shrink(),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return transText(text: 'Na');
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        itemCount: members.length,
                      ),
                    ),
                  )
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  void editGroupName() async {
    final formKey = GlobalKey<FormState>();
    final groupName = TextEditingController();
    groupName.text = userdata.groups[indexOfGroup].name;
    switch (await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    transText(text: 'Group name', bold: true, size: 17),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      autofocus: true,
                      controller: groupName,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter group name';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        //border: OutlineInputBorder(),
                        hintText: 'Enter group name',
                        prefixIcon: Icon(Icons.group),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SimpleDialogOption(
                          child: transText(
                              text: 'Cancel', bold: true, color: primaryColor),
                          onPressed: () {
                            Navigator.pop(context, 0);
                          },
                        ),
                        SimpleDialogOption(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.pop(context, 1);
                              }
                            },
                            child: transText(
                                text: 'Add', bold: true, color: primaryColor)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    )) {
      case 0:
        break;
      case 1:
        userdata.editGroupName(groupName: groupName.text, index: indexOfGroup);
    }
  }
}

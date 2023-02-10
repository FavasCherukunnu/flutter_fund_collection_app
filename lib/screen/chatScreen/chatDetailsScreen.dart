import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trans_pay/constants/appConstants.dart';
import 'package:trans_pay/constants/common.dart';
import 'package:trans_pay/helper/helper_function.dart';
import 'package:trans_pay/models/groupDetails.dart';
import 'package:trans_pay/models/userDetails.dart';
import 'package:trans_pay/screen/chatScreen/addMembers.dart';
import 'package:trans_pay/services/databaseService.dart';

class ChatDetailsScreen extends StatefulWidget {
  ChatDetailsScreen(
      {super.key,
      required this.groupName,
      required this.groupId,
      required this.groupType,
      required this.adminIdN});

  String groupId;
  GroupType groupType;
  String? adminIdN;
  String groupName;

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  late UserClass userdata;

  late int indexOfGroup;

  Stream? groupInfo;
  Stream? amountDetails;
  late double totalAmount;
  bool _fullLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    groupInfo = DatabaseService().getGroupInfoStream(widget.groupId);
    amountDetails = DatabaseService().amountDetails(widget.groupId);
    // final totalAmount = DatabaseService().getTotalAmountInfo(widget.groupId);
  }

  showAddMembers() async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddMembersScreen(groupId: widget.groupId),
        ));
  }

  showUpiDetails() async {
    final upiIdctrl = TextEditingController();
    final upiNamectrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        Stream? groupinfo1 = DatabaseService().getGroupInfoStream(widget.groupId);
        return StatefulBuilder(builder: (context, setState) {
          return SimpleDialog(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                child: StreamBuilder(
                  stream: groupinfo1,
                  builder: (context, snapshot) {
                    var upi = 'loading';
                    var name = 'loading';
                    if(snapshot.hasData){

                      final data = snapshot.data;
                      upi = data['upiId'];
                      name = data['upiName'];
                      setState;
                    }
                    return Column(
                      children: [Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          transText(text:'UPI: '),
                          transText(text: upi)
                          
                        ]
                      ),
                      Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                          transText(text: "Name: "),
                          transText(text: name)
                        ],
                      )
                      ],
                      
                    );
                  },
                ),
              ),
              Divider(),
              Container(
                padding:
                    EdgeInsets.only(top: 20, left: 25, right: 25, bottom: 10),
                child: Form(
                    child: Column(
                  children: [
                    transText(text: 'UPI ID'),
                    TextFormField(
                      controller: upiIdctrl,
                      decoration: const InputDecoration(
                        //border: OutlineInputBorder(),
                        hintText: 'Enter merchant upi id',
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    transText(text: 'Name'),
                    TextFormField(
                      controller: upiNamectrl,
                      decoration: const InputDecoration(
                        //border: OutlineInputBorder(),
                        hintText: 'Enter the name',
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await DatabaseService().updateUpiValues(
                              groupId: widget.groupId,
                              upiId: upiIdctrl.text,
                              upiName: upiNamectrl.text);
                          Navigator.pop(context);
                        },
                        child: transText(text: 'Update'))
                  ],
                )),
              )
            ],
          );
        });
      },
    );
  }

  setFullLoaded() {
    // notify the UI that the group details has been fully loaded
    if (_fullLoaded == false) {
      Future.delayed(Duration(seconds: 1)).whenComplete(() {
        setState(() {
          _fullLoaded = true;
        });
      });
    }
  }

  late String adminIdN;

  isAdmin(String userIdN) {
    if (widget.adminIdN != null) {
      if (getId(widget.adminIdN!) == getId(userIdN)) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  showLeftGroupIndication() async {
    switch(await showDialog(
        context: context,
        builder: ((context) {
          return SimpleDialog(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  children: [
                    transText(text: 'Do you want to left from the group?'),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context,0);
                            }, child: transText(text: 'No')),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context,1);
                            }, child: transText(text: 'Yes'))
                      ],
                    )
                  ],
                ),
              )
            ],
          );
        }))){
          case 0:
            break;
          case 1:
            await DatabaseService().leftFromeGroup(widget.groupId, HelperFunctions.userId!, HelperFunctions.userName!, widget.groupName);
            Navigator.pop(context);
            Navigator.pop(context);
            break;


        }
  }

  @override
  Widget build(BuildContext context) {
    userdata = Provider.of<UserClass>(context);

    int getGroupType() {
      return widget.groupType.getGroupType;
    }

    return Scaffold(
      backgroundColor: primaryBgColor,
      appBar: AppBar(
        elevation: 0,
        actions: [
          Consumer(
              //animation: loading,
              builder: (context, _, child) {
            return isAdmin(
                    '${HelperFunctions.userId}_${HelperFunctions.userName}')
                ? IconButton(
                    onPressed: () {
                      showAddMembers();
                    },
                    icon: const Icon(Icons.person_add))
                : SizedBox.shrink();
          }),
          isAdmin('${HelperFunctions.userId}_${HelperFunctions.userName}')
              ? IconButton(
                  onPressed: () {
                    showUpiDetails();
                  },
                  icon: Icon(Icons.payment))
              : IconButton(
                  onPressed: () {
                    showLeftGroupIndication();
                  },
                  icon: Icon(Icons.exit_to_app),
                  tooltip: 'left group',
                )
        ],
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
              //final members = group['members'];
              // setFullLoaded();

              return StreamBuilder(
                  stream: amountDetails,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final members = snapshot.data.docs;

                    final AmountDetails amounts = AmountDetails()
                      ..setValues(members);

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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Center(
                                  child: transText(
                                      text: groupName,
                                      size: 25,
                                      color: Colors.white),
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
                              // StreamBuilder(
                              //   stream: amountDetails,
                              //   builder: (context, snapshot) {
                              //
                              // return
                              Column(
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
                              )
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
                                        title: transText(
                                            text: members[index]['isRemoved'] ==
                                                    true
                                                ? 'Unknown'
                                                : getName(
                                                    members[index]['memberId']),
                                            color: isAdmin(
                                                    members[index]['memberId'])
                                                ? primaryColor
                                                : null),
                                        trailing: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  transText(
                                                      text: members[index]
                                                              ['depositAmount']
                                                          .toString(),
                                                      color: credittedColor),
                                                  isAdmin(members[index]
                                                              ['memberId']) ||
                                                          getGroupType() ==
                                                              GroupType
                                                                  .memberWithdrawal
                                                      ? transText(
                                                          text: members[index][
                                                                  'withdrawAmount']
                                                              .toString(),
                                                          color: debitColor)
                                                      : const SizedBox.shrink(),
                                                ],
                                              ),
                                            )),
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
                  });
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
                    const SizedBox(
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

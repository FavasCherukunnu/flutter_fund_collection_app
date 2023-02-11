import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:trans_pay/constants/common.dart';
import 'package:trans_pay/helper/helper_function.dart';
import 'package:trans_pay/models/userDetails.dart';
import 'package:trans_pay/services/databaseService.dart';
import 'package:trans_pay/widget/widget.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key,this.deeplinkgroupIdN});
  String? deeplinkgroupIdN;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController groupCtrl = TextEditingController();
  QuerySnapshot? groups;
  bool _isLoading = false;
  bool _searchFinished = false;
  bool _isJoined = false;
  String? username;
  String? uid;
  StreamController<bool> searchMenuCtrl = StreamController<bool>();

  @override
  void initState() {
    // TODO: implement initState
    widget.deeplinkgroupIdN==null?groupCtrl.text='': groupCtrl.text=getId(widget.deeplinkgroupIdN!);
    super.initState();
  }

  getUidAndUsername() async {
    uid = await HelperFunctions.getUserIdFromSF();
    username = await HelperFunctions.getUserNameFromSF();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBgColor,
      appBar: AppBar(
        elevation: 0,
        title: transText(text: 'Search'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            color: primaryColor,
            child: Row(
              children: [
                Expanded(
                    child: TextFormField(
                      
                  controller: groupCtrl,
                  style: const TextStyle(color: Colors.white),
                  // initialValue: widget.deeplinkgroupIdN==null?null: getId(widget.deeplinkgroupIdN!),
                  decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: primaryBgColor, width: 0.5),
                      ),
                      border: InputBorder.none,
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.white)),
                  cursorColor: Colors.white,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      searchMenuCtrl.add(true);
                      setState(() {});
                    } else {
                      searchMenuCtrl.add(false);
                    }
                  },
                  
                )),
                IconButton(
                    onPressed: () {
                      if(widget.deeplinkgroupIdN==null){
                        initiateSearchMethod();
                      }else{
                        initiateSearchMethodDeepLink(getId(widget.deeplinkgroupIdN!));
                      }
                    },
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    )),
                StreamBuilder(
                  stream: searchMenuCtrl.stream,
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return IconButton(
                          onPressed: () {
                            groupCtrl.clear();
                            searchMenuCtrl.add(false);
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.white,
                          ));
                    } else {
                      return SizedBox();
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchFinished
                    ? Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5)),
                        ),
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return groupTile(index);
                            },
                            itemCount: groups!.docs.length),
                      )
                    : Container(),
          )
        ],
      ),
    );
  }

  initiateSearchMethod() async {
    await getUidAndUsername();
    if (groupCtrl.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      groups = await DatabaseService().gpSearchByName(groupCtrl.text);
      setState(() {
        _searchFinished = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  initiateSearchMethodDeepLink(String groupId)async{
    setState(() {
      _isLoading = true;
    });
    groups = await DatabaseService().gpSearchById(groupId);
    setState(() {
      _searchFinished = true;
      _isLoading = false;
    });
  }

  checkMembership(List groupMembers) {
    if (groupMembers.contains('${HelperFunctions.userId}_${HelperFunctions.userName}')) {
      _isJoined = true;
    } else {
      _isJoined = false;
    }
  }

  groupTile(index) {
    final group = groups!.docs[index];

    checkMembership(group['members']);

    return ListTile(
      contentPadding: const EdgeInsets.all(10),
      leading: CircleAvatar(
        child: Text(group['groupName'].substring(0, 1)),
      ),
      title: transText(text: group['groupName'], size: 15, bold: true),
      subtitle: transText(text: group['groupId']),
      trailing: _isJoined
          ? ElevatedButton(
              onPressed: () async {
                await DatabaseService().leftFromeGroup(
                    group['groupId'], uid!, username!, group['groupName']);
                groups = await DatabaseService().gpSearchByName(groupCtrl.text);
                setState(() {
                  _isJoined = false;
                });
              },
              child: transText(text: 'joined'),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryBgColor),
              onPressed: () async {
                await DatabaseService().joinGroup(
                    group['groupId'], HelperFunctions.userId!, HelperFunctions.userName!, group['groupName']);
                groups = await DatabaseService().gpSearchByName(groupCtrl.text);

                setState(() {
                  _isJoined = true;
                });
                // showSnackbar(
                //     context, Colors.green, 'successfully joined the group');
              },
              child: transText(text: 'join', color: primaryColor),
            ),
    );
  }
}

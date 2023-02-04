import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:trans_pay/constants/common.dart';
import 'package:trans_pay/services/databaseService.dart';

class AddMembersScreen extends StatefulWidget {
  AddMembersScreen({super.key, required this.groupId});

  String groupId;

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  String memberName = '';
  Stream? groupInfo;
  bool _isSearching = false;
  List dataArray = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    groupInfo = DatabaseService().getGroupInfoStream(widget.groupId);
  }

  checkMembership(List groupMembers, String userIdN) {
    if (groupMembers.contains('$userIdN')) {
      return true;
    } else {
      return false;
    }
  }

  isAdmin(String adminIdN, String userIdN) =>
      getId(adminIdN) == getId(userIdN) ? true : false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: transText(text: 'Add Members'),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryBgColor, width: 0.5),
                  ),
                  border: InputBorder.none,
                  hintText: 'Search members...',
                ),
                onChanged: (value) {
                  memberName = value;
                  DatabaseService().searchMembers(memberName).then((value) {
                    dataArray = value;
                    final ids = Set();
                    dataArray.retainWhere((element) => ids.add(element.id));
                    // dataArray = data.toSet().toList();
                    setState(() {
                      _isSearching = false;
                    });
                  });
                },
              ),
            ),
            Expanded(
                child: _isSearching == false
                    ? ListView.builder(
                        itemBuilder: (context, index) {
                          final data = dataArray[index];

                          if (dataArray.isNotEmpty) {
                            return StreamBuilder(
                                stream: groupInfo,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final group = snapshot.data;
                                    return !isAdmin(group['admin'],
                                            '${data['uid']}_${data['username']}')
                                        ? ListTile(
                                            leading: CircleAvatar(
                                              radius: 25,
                                              child: transText(
                                                  text: data['username'][0]),
                                            ),
                                            title: transText(
                                                text: data['username']),
                                            subtitle: transText(
                                                text: data['uid'], size: 10),
                                            trailing: ElevatedButton(
                                                onPressed: () async {
                                                  checkMembership(
                                                          group['members'],
                                                          '${data['uid']}_${data['username']}')
                                                      ? await DatabaseService()
                                                          .leftFromeGroup(
                                                              group['groupId'],
                                                              data['uid'],
                                                              data['username'],
                                                              group[
                                                                  'groupName'])
                                                      : await DatabaseService()
                                                          .joinGroup(
                                                              group['groupId'],
                                                              data['uid'],
                                                              data['username'],
                                                              group[
                                                                  'groupName']);
                                                },
                                                child: checkMembership(
                                                        group['members'],
                                                        '${data['uid']}_${data['username']}')
                                                    ? transText(text: 'remove')
                                                    : transText(text: 'add')))
                                        : const SizedBox.shrink();
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                });
                          } else {
                            return Center(
                              child: transText(text: 'No users found'),
                            );
                          }
                        },
                        itemCount: dataArray.length,
                      )
                    : const Center(child: CircularProgressIndicator()))
          ],
        ));
  }
}

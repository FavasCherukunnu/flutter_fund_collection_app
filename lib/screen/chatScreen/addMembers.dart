import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:trans_pay/constants/common.dart';
import 'package:trans_pay/services/databaseService.dart';

class AddMembersScreen extends StatefulWidget {
  AddMembersScreen({super.key,required this.groupId});

  String groupId;

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  String? memberName='';
  Stream? groupInfo ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    groupInfo = DatabaseService().getGroupInfoStream(widget.groupId);
  }

  checkMembership(List groupMembers,String userIdN){
    if (groupMembers.contains('$userIdN')) {
      return true;
    } else {
      return false;
    }
  }

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
                    borderSide:
                        BorderSide(color: primaryBgColor, width: 0.5),
                  ),
                  border: InputBorder.none,
                  hintText: 'Search members...',
              ),
              onChanged: (value) {
                setState(() {
                  memberName = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: memberName!.isNotEmpty  ? DatabaseService().searchMembers(memberName!):null,
              builder: (context, snapshot) {
                
                if(snapshot.hasData){
                 final dataArray = snapshot.data!.docs;
          
                 if(dataArray.length >0){
                  return ListView.builder(
                      itemBuilder: (context, index) {
            
                        final data = dataArray[index];
            
                        return ListTile(
                          leading: CircleAvatar(
                            child: transText(text: data['username'][0]),
                            radius: 25,
                          ),
                          title: transText(text: data['username']),
                          subtitle: transText(text: data['uid']),
                          trailing: StreamBuilder(
                            stream: groupInfo,
                            builder: (context,snapshot) {  
                              
                              if(snapshot.hasData){

                                final group = snapshot.data;
                                String groupName = group['groupName'];
                                print(groupName);
                                return ElevatedButton(onPressed: (){}, child:
                                checkMembership(group[''], userIdN) transText(text: 'add') );
                                
                              }else{
                                return SizedBox.shrink();
                              }

                            },
                          ),
                        );
                      
                      },
                      itemCount: dataArray.length,
                  );
                }else{
                  return Center(child:
                  transText(text: 'no user found'));
                }
                }else{
                  return const  Center(child: CircularProgressIndicator());
                }
            
                
              
              },
            ),
          )
        ],
      )
    );
  }
}
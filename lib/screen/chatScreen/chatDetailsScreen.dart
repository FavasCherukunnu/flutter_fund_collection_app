import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:trans_pay/constants/common.dart';
import 'package:trans_pay/models/userDetails.dart';

class ChatDetailsScreen extends StatefulWidget {
  const ChatDetailsScreen({super.key});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {

  late UserClass userdata;
  
  late int indexOfGroup;
  @override
  Widget build(BuildContext context) {
    userdata = Provider.of<UserClass>(context);
    final arguments = ModalRoute.of(context)!.settings.arguments ;
    Map args ={};
    Group group = Group(name: 'NA');
    List<GroupDetails> groupDetails =[];

    if(arguments == null){
      args={};
      indexOfGroup = 0;
    }else{
      args = arguments as Map ;
      
      group = args['group'];
      indexOfGroup = args['index'];
      
      group.groupDetails.forEach((key, value) { groupDetails.add(GroupDetails(key, value));});

    }


    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 40,
                  child: Icon(
                    Icons.group,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 20,),
                Center(child: transText(text: group.name,size:25,color: Colors.white)),
                IconButton(
                  icon: Icon(Icons.edit,color: Colors.white,),
                  onPressed: (){
                    editGroupName();
                  },
                ),
                const SizedBox(height: 20,)
          
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Card(margin: EdgeInsets.all(0.3),
                        child: ListTile(
                          contentPadding: EdgeInsets.fromLTRB(15, 8, 5 , 8),
                          leading: const CircleAvatar(
                            radius: 25,
                            backgroundColor: primaryColor,
                      
                          ),
                          title: transText(text:groupDetails[index].senterId,size: 17),
                          trailing: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: transText(text: groupDetails[index].amount.toString(),size: 17),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                itemCount: groupDetails.length,

                
              ),
            ),
          )

        ],
      ),
    );
  }


  void editGroupName()async{

    final formKey = GlobalKey<FormState>();
    final groupName = TextEditingController();
    groupName.text = userdata.groups[indexOfGroup].name;
    switch(await showDialog(
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
                    transText(text: 'Group name',bold: true,size: 17),
                    const SizedBox(height: 10,),
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
                    SizedBox(height: 30,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        
                        SimpleDialogOption(
                          child: transText(text: 'Cancel',bold: true,color: primaryColor),
                          onPressed: (){
                            Navigator.pop(context,0);
                          },
                        ),
                        SimpleDialogOption(
                          
                          onPressed: () { 

                            if(formKey.currentState!.validate()) {
                              Navigator.pop(context,1);
                            }

                          },
                          
                          child: transText(text: 'Add',bold: true,color: primaryColor)
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      }
      ,
    )){
      case 0 :
        break;
      case 1 :
        userdata.editGroupName(groupName: groupName.text,index: indexOfGroup);

    }
  }
}


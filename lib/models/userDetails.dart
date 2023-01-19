import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class UserClass extends ChangeNotifier{

  String userName;
  String password;
  List<Group> groups=[];

  UserClass({required this.userName,required this.password});

  void addToGroup(Group value){
    groups.add(value);
    notifyListeners();
  }

  void addmsg({required String msg,required int index,required String senterId}){

    groups[index].message.add(Messages(time: DateTime.now(),amount: msg,senderId: senterId));
    groups[index].addGroupDetails(amount: msg,userId:senterId );
    notifyListeners();

  }

  void editGroupName({required int index,required String groupName}){
    groups[index].name = groupName;
    notifyListeners();
  }
  
}



class Group{
  String name;
  List<Messages> message =[];
  Map<String,int> groupDetails = {};
  Group({required this.name});

  void addGroupDetails({required String userId,required String amount}){
    int? totAmount = groupDetails[userId];
    if(totAmount==null){
      groupDetails[userId] = int.parse(amount);
    }else{
      groupDetails[userId] = int.parse(amount)+totAmount;
    }

  }

}

class Messages {
  String amount=''; //amount
  DateTime time = DateTime.now();
  String senderId;
  Messages({this.amount='',required this.time, required this.senderId});

  String get formattedTime => DateFormat('kk:mm:a').format(time);

}

class GroupDetails{

  String senterId;
  int amount;

  GroupDetails(this.senterId,this.amount);

}
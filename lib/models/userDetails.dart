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

  void addmsg(String msg,int index){
    groups[index].message.add(Messages(time: DateTime.now(),messages: msg));
    notifyListeners();
  }
  
}



class Group{
  String name;
  List<Messages> message =[];
  Group({required this.name});
}

class Messages {
  String messages='';
  DateTime time = DateTime.now();
  Messages({this.messages='',required this.time});

  String get formattedTime => DateFormat('kk:mm:a').format(time);

}
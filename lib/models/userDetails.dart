import 'package:flutter/cupertino.dart';

class UserClass extends ChangeNotifier{

  String userName;
  String password;
  List<Chat> chat=[];

  UserClass({required this.userName,required this.password});

  void addToChat(Chat value){
    chat.add(value);
  }

  void addmsg(String msg,int index){
    chat[index].message.add(Messages(time: DateTime.now(),messages: msg));
    notifyListeners();
  }
  
}



class Chat{
  String name;
  List<Messages> message =[];
  Chat({required this.name});
}

class Messages {
  String messages='';
  DateTime time = DateTime.now();
  Messages({this.messages='',required this.time});
}
class UserClass {

  String userName;
  String password;
  List<Chat> chat=[];

  UserClass({required this.userName,required this.password});

  void addToChat(Chat value){
    chat.add(value);
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
}
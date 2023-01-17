import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:trans_pay/constants/appConstants.dart';
import 'package:trans_pay/models/popUpChoices.dart';
import 'package:trans_pay/models/userDetails.dart';
import 'package:trans_pay/source/common.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PopupChoices> choices = [
    PopupChoices(title: 'Settings', icon: Icons.settings),
    PopupChoices(title: 'Logout', icon: Icons.logout),
  ];

  late UserClass userdata;
  //bottom navigation index
  int _bottomNavValue=0;




  @override
  Widget build(BuildContext context) {


    userdata = Provider.of<UserClass>(context);
    fetchUserData();

    print(userdata.chat.length.toString());


    return Scaffold(

      appBar: AppBar(
        title: transText(text: AppConstants.homeTitle),
        actions: [
          buildPopUpMenu()
        ],
      ),
      body: SafeArea(
        child: _buildScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap:(value){
          _bottomNavValue = value;
          setState(() {
            
          });
        },
        currentIndex: _bottomNavValue,
        items:const  [
          BottomNavigationBarItem(
            label: 'home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'transactions',
            icon: Icon(Icons.balance)
          )
        ],

      ),
    );
  }

  PopupMenuButton<PopupChoices> buildPopUpMenu() {
    return PopupMenuButton<PopupChoices>(
      onSelected: (
        (value) {
          if(value.title == 'Settings'){
            Navigator.pushNamed(context,'/settingsScreen' );
          }
          if(value.title == 'Logout'){
            Navigator.pushReplacementNamed(context, '/');
          }
        }
      ),
      itemBuilder: (BuildContext context) { 

          return choices.map(
            (choiceItem){
              return PopupMenuItem<PopupChoices>(
                value: choiceItem,
                child: Row(
                  children: [
                    Icon(choiceItem.icon,color: primaryColor),
                    const SizedBox(width: 10,),
                    Text(choiceItem.title),

                  ],
                ),
              );
            }
          ).toList();
            

        },
      );
  }

  Widget _buildScreen(){

    switch (_bottomNavValue) {
      case 0:
        
        return ListView.builder(
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
                    title: Text(userdata.chat[index].name),
                    onTap: () {
                      Navigator.pushNamed(context, '/chatScreen',arguments: {
                        'chatData':userdata.chat[index],
                        'index':index,
                      });
                    },
                  ),
                ),
              ],
            );
          },
          itemCount: userdata.chat.length,
        );
        break;
      case 1:
          return  Center(
            child: transText(text: 'This is transaction page',size: 17)
          );
          break;
      default:
        return Container();
    }

  }

  void fetchUserData(){
    
    List<Chat> value = [
      Chat(name: 'group1'),
      Chat(name: 'group2'),
      Chat(name: 'group3'),
      Chat(name: 'group4'),
      Chat(name: 'group5'),
      Chat(name: 'group6'),
      Chat(name: 'group7'),
      Chat(name: 'group8'),
      Chat(name: 'group9'),
      Chat(name: 'group10'),
      Chat(name: 'group11'),
      Chat(name: 'group12'),
      Chat(name: 'group13'),

    ];

    if(userdata.chat.isEmpty){
      value.forEach((element) {userdata.addToChat(element);});
    }else{
      print('data already fetched');
    }

  }

}
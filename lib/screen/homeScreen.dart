import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trans_pay/constants/appConstants.dart';
import 'package:trans_pay/helper/helper_function.dart';
import 'package:trans_pay/models/popUpChoices.dart';
import 'package:trans_pay/models/userDetails.dart';
import 'package:trans_pay/constants/common.dart';
import 'package:trans_pay/services/authentication.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PopupChoices> choices = [
    PopupChoices(title: 'Profile', icon: Icons.account_circle),
    PopupChoices(title: 'Logout', icon: Icons.logout),
  ];
  late UserClass userdata;
  //bottom navigation index
  int _bottomNavValue = 0;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    userdata = Provider.of<UserClass>(context);

    return Scaffold(
      appBar: AppBar(
        title: transText(text: AppConstants.homeTitle),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          buildPopUpMenu(),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          _bottomNavValue = value;
          setState(() {});
        },
        currentIndex: _bottomNavValue,
        items: const [
          BottomNavigationBarItem(
            label: 'home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
              label: 'transactions', icon: Icon(Icons.balance))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          addGroup();
        },
        tooltip: 'Create Group',
      ),
    );
  }

  void addGroup() async {
    final formKey = GlobalKey<FormState>();
    final groupName = TextEditingController();
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
                    const Center(
                      child: Text(
                        'Add Group',
                        style: TextStyle(
                          fontFamily: 'SofiSans',
                          fontSize: 20,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    transText(text: 'Group name', bold: true, size: 17),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
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
                    SizedBox(
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
        userdata.addToGroup(Group(name: groupName.text));
    }
  }

  PopupMenuButton<PopupChoices> buildPopUpMenu() {
    return PopupMenuButton<PopupChoices>(
      onSelected: ((value) {
        if (value.title == 'Profile') {
          Navigator.pushNamed(context, '/profileScreen');
        }
        if (value.title == 'Logout') {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Center(child: Text('Logout')),
                content: const Text("Are you sure you want to logout?"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('No')),
                  TextButton(
                      onPressed: () async {
                        await authService.logout(context);
                      },
                      child: const Text('Yes'))
                ],
              );
            },
          );
        }
      }),
      itemBuilder: (BuildContext context) {
        return choices.map((choiceItem) {
          return PopupMenuItem<PopupChoices>(
            value: choiceItem,
            child: Row(
              children: [
                Icon(choiceItem.icon, color: primaryColor),
                const SizedBox(
                  width: 10,
                ),
                Text(choiceItem.title),
                const SizedBox(
                  width: 10,
                )
              ],
            ),
          );
        }).toList();
      },
      padding: EdgeInsets.all(1),
    );
  }

  Widget _buildScreen() {
    switch (_bottomNavValue) {
      case 0:
        return ListView.builder(
          itemBuilder: (context, index) {
            return Column(
              children: [
                Card(
                  margin: EdgeInsets.all(0.3),
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(15, 8, 5, 8),
                    leading: const CircleAvatar(
                      radius: 25,
                      backgroundColor: primaryColor,
                    ),
                    title:
                        transText(text: userdata.groups[index].name, size: 17),
                    onTap: () {
                      Navigator.pushNamed(context, '/chatScreen', arguments: {
                        'chatData': userdata.groups[index],
                        'index': index,
                        'senterId': userdata.userName
                      });
                    },
                  ),
                ),
              ],
            );
          },
          itemCount: userdata.groups.length,
        );
        break;
      case 1:
        return Center(
            child: transText(text: 'This is transaction page', size: 17));
        break;
      default:
        return Container();
    }
  }
}

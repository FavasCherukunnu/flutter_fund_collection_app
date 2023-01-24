import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trans_pay/constants/appConstants.dart';
import 'package:trans_pay/helper/helper_function.dart';
import 'package:trans_pay/models/popUpChoices.dart';
import 'package:trans_pay/models/userDetails.dart';
import 'package:trans_pay/constants/common.dart';
import 'package:trans_pay/services/authentication.dart';

import '../services/databaseService.dart';
import '../widget/groupTIle.dart';
import '../widget/widget.dart';

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
  String? email;
  String? username;
  Stream? groups;
  bool _isLoading = false;
  String groupName = "";

  //bottom navigation index
  int _bottomNavValue = 0;
  AuthService authService = AuthService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gettingUserData();
  }

  @override
  Widget build(BuildContext context) {
    userdata = Provider.of<UserClass>(context);

    return Scaffold(
      backgroundColor: primaryBgColor,
      appBar: AppBar(
        title: transText(text: AppConstants.homeTitle),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/searchScreen');
              },
              icon: Icon(Icons.search)),
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

  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((val) {
      setState(() {
        username = val!;
      });
    });
    // getting the list of snapshots in our stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
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
        // userdata.addToGroup(Group(name: groupName.text));

        if (groupName.text != "") {
          setState(() {
            _isLoading = true;
          });
          DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
              .createGroup(username!, FirebaseAuth.instance.currentUser!.uid,
                  groupName.text)
              .whenComplete(() {
            _isLoading = false;
          });
          //Navigator.of(context).pop();
          showSnackbar(context, Colors.green, "Group created successfully.");
        }
    }
  }

  String getName(String id) {
    return id.substring(id.indexOf('_') + 1);
  }

  String getId(String id) {
    return id.substring(0, id.indexOf('_'));
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  //sorting the recent created group first
                  final reverseIndex =
                      snapshot.data['groups'].length - index - 1;
                  return GroupTile(
                    groupName: getName(snapshot.data['groups'][reverseIndex]),
                    groupId: getId(snapshot.data['groups'][reverseIndex]),
                  );
                },
                itemCount: snapshot.data['groups'].length,
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              addGroup();
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not joined any groups, tap on the add icon to create a group or also search from top search button.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  PopupMenuButton<PopupChoices> buildPopUpMenu() {
    return PopupMenuButton<PopupChoices>(
      onSelected: ((value) {
        if (value.title == 'Profile') {
          Navigator.pushNamed(context, '/profileScreen', arguments: {
            'username': username,
            'email': email,
          });
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
        return groupList();

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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trans_pay/models/userDetails.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  // saving the userdata
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "username": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  //retrieve user data
  Future gettingUserData(String email) async {
    final QuerySnapshot? snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  // creating a group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });
    // update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  getGroupInfo(String groupId) {
    return groupCollection.doc(groupId).snapshots();
  }

  gpSearchByName(String groupName) {
    return groupCollection.where('groupName', isEqualTo: groupName).get();
  }

  joinGroup(
      String groupId, String userId, String username, String groupName) async {
    await groupCollection.doc(groupId).update({
      'members': FieldValue.arrayUnion(['${userId}_$username'])
    });
    await userCollection.doc(userId).update({
      'groups': FieldValue.arrayUnion(['${groupId}_$groupName'])
    });
  }

  leftFromeGroup(
      String groupId, String userId, String username, String groupName) async {
    await groupCollection.doc(groupId).update({
      'members': FieldValue.arrayRemove(['${userId}_$username'])
    });
    await userCollection.doc(userId).update({
      'groups': FieldValue.arrayRemove(['${groupId}_$groupName'])
    });
  }
}

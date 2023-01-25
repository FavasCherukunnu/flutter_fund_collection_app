import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trans_pay/constants/common.dart';
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

    storeAmount(groupDocumentReference.id, "${id}_$userName", 0);

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  getGroupInfo(String groupId) {
    return groupCollection.doc(groupId).snapshots();
  }

// total amount of each members in a group
  getTotalAmountInfo(String groupId, String memberIdN) {
    return groupCollection
        .doc(groupId)
        .collection('AmountDetails')
        .where('memberId', isEqualTo: memberIdN)
        .snapshots();
  }

  gpSearchByName(String groupName) {
    return groupCollection.where('groupName', isEqualTo: groupName).get();
  }
  //add total amount of a member to database of group

  storeAmount(String groupId, String senterIdN, int amount) async {
    await groupCollection
        .doc(groupId)
        .collection('AmountDetails')
        .doc(getId(senterIdN))
        .set({'amount': amount, 'memberId': senterIdN});
  }

  joinGroup(
      String groupId, String userId, String username, String groupName) async {
    await groupCollection.doc(groupId).update({
      'members': FieldValue.arrayUnion(['${userId}_$username'])
    });
    await userCollection.doc(userId).update({
      'groups': FieldValue.arrayUnion(['${groupId}_$groupName'])
    });
    await storeAmount(groupId, '${userId}_$username', 0);
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

  sentMessage(String groupId, String amount, String senterId, DateTime time,
      {String message = ""}) async {
    await groupCollection
        .doc(groupId)
        .collection('AmountDetails')
        .doc(getId(senterId))
        .update({'amount': FieldValue.increment(double.parse(amount))});
    DocumentReference messageReference =
        await groupCollection.doc(groupId).collection('messages').add({
      'amount': amount,
      'message': message,
      'senterId': senterId,
      'time': time.millisecondsSinceEpoch,
      'messegeId': ''
    });
    await groupCollection
        .doc(groupId)
        .collection('messages')
        .doc(messageReference.id)
        .update({'messageId': messageReference.id});
    await groupCollection
        .doc(groupId)
        .update({'recentMessage': amount, 'recentMessageSender': senterId});
  }

  //get messages from group
  Future getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }
}

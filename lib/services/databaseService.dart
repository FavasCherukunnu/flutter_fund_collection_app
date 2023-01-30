import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trans_pay/constants/common.dart';

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
    QuerySnapshot? snapshot =
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

  getGroupInfo(String groupId) async {
    return await groupCollection.doc(groupId).get();
  }

  getGroupInfoStream(
    String groupId,
  ) {
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

// get total amount transacted in group
  Future getGroupTotalAount(String groupId) async {
    double totalAmount = 0;
    final collection =
        await groupCollection.doc(groupId).collection('AmountDetails').get();

    collection.docs.forEach((element) {
      final map = element.data();
      totalAmount = totalAmount + map['depositAmount'];
    });
    return totalAmount;
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
        .set({'depositAmount': amount, 'memberId': senterIdN,'withdrawAmount':0});
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

  sentMessage(String groupName, String groupId, String amount, String senterIdN,
      DateTime time, String AdminId,
      {String message = ""}) async {
    if (AdminId == getId(senterIdN)) {
      await groupCollection
          .doc(groupId)
          .collection('AmountDetails')
          .doc(getId(senterIdN))
          .update({
        'withdrawAmount': FieldValue.increment(int.parse(amount)),
      });
    } else {
      await groupCollection
          .doc(groupId)
          .collection('AmountDetails')
          .doc(getId(senterIdN))
          .update({
        'DepositAmount': FieldValue.increment(double.parse(amount)),
      });
    }

    DocumentReference messageReference =
        await groupCollection.doc(groupId).collection('messages').add({
      'amount': amount,
      'message': message,
      'senterId': senterIdN,
      'time': time.millisecondsSinceEpoch,
      'messegeId': ''
    });
    await groupCollection
        .doc(groupId)
        .collection('messages')
        .doc(messageReference.id)
        .update({'messageId': messageReference.id});

//check admin is paying his own group
    if (AdminId == getId(senterIdN)) {
      await userCollection.doc(getId(senterIdN)).collection('transaction').add({
        'groupId': '${groupId}_$groupName',
        'amount': amount,
        'time': time.millisecondsSinceEpoch,
        'messageId': messageReference.id,
        'senterId': senterIdN,
        'isAdmin': true,
        'isRecieve': false,
      });
    } else {
      await userCollection.doc(getId(senterIdN)).collection('transaction').add({
        'groupId': '${groupId}_$groupName',
        'amount': amount,
        'time': time.millisecondsSinceEpoch,
        'messageId': messageReference.id,
        'senterId': senterIdN,
        'isAdmin': false,
        'isRecieve': false,
      });
      await userCollection.doc(AdminId).collection('transaction').add({
        'groupId': '${groupId}_$groupName',
        'amount': amount,
        'time': time.millisecondsSinceEpoch,
        'messageId': messageReference.id,
        'senterId': senterIdN,
        'isAdmin': false,
        'isRecieve': true
      });
    }

    await groupCollection
        .doc(groupId)
        .update({'recentMessage': amount, 'recentMessageSender': senterIdN});
  }

  //get messages from group
  Future getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  //get transaction details of given user user
  getTransaction(String userId) {
    return userCollection
        .doc(userId)
        .collection('transaction')
        .orderBy('time')
        .snapshots();
  }
}

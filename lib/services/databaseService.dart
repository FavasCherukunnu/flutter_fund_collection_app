import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trans_pay/constants/appConstants.dart';
import 'package:trans_pay/constants/common.dart';
import 'package:trans_pay/models/groupDetails.dart';

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
  Future createGroup(
      String userName, String id, String groupName, int grouptype) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      'groupType': grouptype,
      "groupId": "",
      "upiId":"",
      "upiName":"",
      "recentMessage": "",
      "recentMessageSender": "",
      "Amount_limit":0,
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

  updateUpiValues({required String groupId,required String upiId, required String upiName,required double creditLimit}){
    groupCollection.doc(groupId).update({'upiId':upiId,'upiName':upiName,'Amount_limit':creditLimit});
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
  Stream<QuerySnapshot<Map<String, dynamic>>> amountDetails(String groupId) {
    // double totalAmount = 0;
    // final collection = await
    return groupCollection.doc(groupId).collection('AmountDetails').snapshots();

    // collection.docs.forEach((element) {
    //   final map = element.data();
    //   totalAmount = totalAmount + map['depositAmount'];
    // });
    // return collection;
  }

  gpSearchByName(String groupName) {
    return groupCollection.where('groupName', isEqualTo: groupName).get();
  }
  
  gpSearchById(String groupId) {
    return groupCollection.where('groupId', isEqualTo: groupId).get();
  }  
  //add total amount of a member to database of group

  storeAmount(String groupId, String senterIdN, double amount) async {
    final docref = await groupCollection
        .doc(groupId)
        .collection('AmountDetails')
        .doc(getId(senterIdN))
        .get();
    if (docref.exists) {
      await groupCollection
          .doc(groupId)
          .collection('AmountDetails')
          .doc(getId(senterIdN))
          .update({'isRemoved': false});
    } else {
      await groupCollection
          .doc(groupId)
          .collection('AmountDetails')
          .doc(getId(senterIdN))
          .set({
        'depositAmount': 0,
        'memberId': senterIdN,
        'withdrawAmount': 0.0,
        'isRemoved': false
      });
    }
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

    await groupCollection
        .doc(groupId)
        .collection('AmountDetails')
        .doc(userId)
        .update({'isRemoved': true});

    await userCollection.doc(userId).update({
      'groups': FieldValue.arrayRemove(['${groupId}_$groupName'])
    });
  }

  sentMessage(String groupName, String groupId, String amount, String senterIdN,
      DateTime time, String AdminId,
      {required String message, required bool isWithdraw}) async {
    if (isWithdraw) {
      await groupCollection
          .doc(groupId)
          .collection('AmountDetails')
          .doc(getId(senterIdN))
          .update({
        'withdrawAmount': FieldValue.increment(double.parse(amount)),
      });
    } else {
      await groupCollection
          .doc(groupId)
          .collection('AmountDetails')
          .doc(getId(senterIdN))
          .update({
        'depositAmount': FieldValue.increment(double.parse(amount)),
      });
    }

    DocumentReference messageReference =
        await groupCollection.doc(groupId).collection('messages').add({
      'amount': amount,
      'message': message,
      'senterId': senterIdN,
      'time': time.millisecondsSinceEpoch,
      'isWithdraw': isWithdraw,
      'messageId': ''
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
        'isWithdraw': isWithdraw
      });
    } else {
      await userCollection.doc(getId(senterIdN)).collection('transaction').add({
        'groupId': '${groupId}_$groupName',
        'amount': amount,
        'time': time.millisecondsSinceEpoch,
        'messageId': messageReference.id,
        'senterId': senterIdN,
        'isAdmin': false,
        'isWithdraw': isWithdraw
      });
      await userCollection.doc(AdminId).collection('transaction').add({
        'groupId': '${groupId}_$groupName',
        'amount': amount,
        'time': time.millisecondsSinceEpoch,
        'messageId': messageReference.id,
        'senterId': senterIdN,
        'isAdmin': false,
        'isWithdraw': isWithdraw
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

  Future<List> searchMembers(String keyword) async {
    final uNameEqualList =
        await userCollection.where('username', isEqualTo: keyword).get();
    final emailEaualList =
        await userCollection.where('email', isEqualTo: keyword).get();
    final uIdEqualList =
        await userCollection.where('uid', isEqualTo: keyword).get();

    List finalList = [];
    finalList.addAll(uNameEqualList.docs);
    finalList.addAll(emailEaualList.docs);
    finalList.addAll(uIdEqualList.docs);

    return finalList;

    // return userCollection
    // .where(FieldPath(['username', 'email', 'uid']), whereIn: [keyword])
    // .where('email', isEqualTo: keyword)
    // .where('uid', isEqualTo: keyword)
    // .snapshots();
  }

  //get transaction details of given user user
  Stream? getTransaction(String userId, {String? groupIdN}) {
    if (groupIdN != null) {
      return userCollection
          .doc(userId)
          .collection('transaction')
          .where('groupId', isEqualTo: groupIdN)
          .orderBy('time', descending: true)
          .snapshots();
    }
    return userCollection
        .doc(userId)
        .collection('transaction')
        .orderBy('time', descending: true)
        .snapshots();
  }
}

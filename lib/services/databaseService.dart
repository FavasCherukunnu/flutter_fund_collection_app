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
}

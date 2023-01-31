class AppConstants {
  static const String homeTitle = 'Dashbord';
  static const String transactionTitle = 'Transactions';
}

class Constants {
  static String apiKey = "AIzaSyC-brZy9PKDpPjq-xM49JyMfNopWUnKboQ";
  static String appId = "1:101452769298:web:6ba8037df37a46808410cb";
  static String messagingSenderId = "101452769298";
  static String projectId = "transpay-7464a";
}

class GroupType{
  int groupType =0;
  //withdrawal to member
  static const int memberWithdrawal = 0;
  //can not withraw by members
  static const int memberNonWithdrawal=1;
  set setGroupType (value){
    this.groupType = value;
  }
  int get getGroupType => groupType;
}
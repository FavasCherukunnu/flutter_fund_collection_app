class AmountDetails {
  double credited = 0;
  double debited = 0;
  double balance = 0;
  dynamic limit =0;

  double get getBalance => credited - debited;
  bool isdebitable({double? amount}) => amount == null
      ? credited - debited > 0
          ? true
          : false
      : credited - debited >= amount
          ? true
          : false;

  bool isLimitReached(){
    if(limit>0 && credited>=limit){
      return true;
    }else{
      return false;
    }
  }
  bool isLimitReachedAmount(amount)=>limit>0&&limit-credited<amount?true:false;

  setValues(data) {
    credited = 0;
    debited = 0;
    for (var element in data) {
      credited += element['depositAmount'];
      debited += element['withdrawAmount'];
    }
  }
}

class MessageAmount {
  double credited = 0;
  double debited = 0;
  double balance = 0;

  double get getBalance => credited - debited;
  setValues(data, {required int startPosition, required int endPosition}) {
    credited = 0;
    debited = 0;
    int startPostionO = startPosition;

    for (startPostionO; startPostionO < endPosition; startPostionO++) {
      data[startPostionO]['isWithdraw']
          ? debited += int.parse(data['amount'])
          : credited += int.parse(data['amount']);
    }
  }
}

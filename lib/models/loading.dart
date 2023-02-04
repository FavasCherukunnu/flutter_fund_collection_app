import 'package:flutter/cupertino.dart';

class Loading extends ChangeNotifier {
  bool _isloaded = false;

  setLoaded() {
    if (_isloaded == false) {
      _isloaded = true;
      notifyListeners();
    }
  }

  bool get isLoaded => _isloaded;
}

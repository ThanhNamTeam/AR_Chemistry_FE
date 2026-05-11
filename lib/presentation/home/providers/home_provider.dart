import 'package:flutter/foundation.dart';

class HomeProvider extends ChangeNotifier {
  int _currentTabIndex = 0;

  int get currentTabIndex => _currentTabIndex;

  void setTab(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }
}

import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';

class HomeProvider with ChangeNotifier {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  final List<int> _navStack = <int>[0];

  List<int> get navStack => _navStack;

  PageController get pageController => _pageController;

  int get selectedIndex => _selectedIndex;

  Future<void> handleBack(bool didPop, result) async {
    _navStack.removeAt(0);
    _selectedIndex = _navStack[0];
    _animateToPage(_selectedIndex);
    notifyListeners();
  }

  void navigateToPage(int index) {
    if (index != 0) {
      // home is always at bottom of the stack
      _navStack.removeWhere((element) => element == index);
      _navStack.insert(0, index);
    }

    _animateToPage(index);
    _selectedIndex = index;
    notifyListeners();
  }

  void reset() {
    _navStack.clear();
    _navStack.add(0);
    _selectedIndex = 0;
    notifyListeners();
  }

  void _animateToPage(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.ease);
    hideKeyboard();
  }
}

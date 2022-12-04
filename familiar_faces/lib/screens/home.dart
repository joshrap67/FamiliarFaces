import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/screens/main_screen.dart';
import 'package:familiar_faces/screens/saved_media_screen.dart';
import 'package:familiar_faces/screens/about_screen.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController();

  int _selectedIndex = 0;
  List<Widget> _screens = <Widget>[MainScreen(), SavedMediaScreen(), AboutScreen()];
  List<int> _navStack = <int>[];

  @override
  void initState() {
    super.initState();
    _navStack.add(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleBackButton,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: _selectedIndex != 0,
          body: PageView(
            children: _screens,
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.movie_creation_rounded), label: 'My Media'),
              BottomNavigationBarItem(icon: Icon(Icons.help_rounded), label: 'About'),
            ],
            currentIndex: _selectedIndex,
            onTap: onItemTapped,
            elevation: 12.0,
          ),
        ),
      ),
    );
  }

  Future<bool> handleBackButton() async {
    if (_navStack.length <= 1) {
      return true;
    } else {
      setState(() {
        _navStack.removeAt(0);
        _selectedIndex = _navStack[0];
        switchPages(_selectedIndex);
      });
      return false;
    }
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _navStack.insert(0, index);
      switchPages(index);
    });
  }

  void switchPages(int index) {
    _pageController.animateToPage(index, duration: Duration(milliseconds: 400), curve: Curves.ease);
    hideKeyboard(context);
  }
}

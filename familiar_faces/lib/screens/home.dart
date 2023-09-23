import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/screens/about_screen.dart';
import 'package:familiar_faces/screens/main_screen.dart';
import 'package:familiar_faces/screens/saved_media_screen.dart';
import 'package:familiar_faces/services/saved_media_service.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SavedMediaService.load(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleBackButton,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 0,
        ),
        resizeToAvoidBottomInset: _selectedIndex != 0,
        body: PageView(
          children: _screens,
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.175,
              ),
            ),
          ),
          child: NavigationBar(
            destinations: const <Widget>[
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.movie_outlined),
                selectedIcon: Icon(Icons.movie),
                label: 'My Media',
              ),
              NavigationDestination(
                icon: Icon(Icons.help_outline),
                selectedIcon: Icon(Icons.help),
                label: 'About',
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: onItemTapped,
            elevation: 15,
            surfaceTintColor: const Color(0x00000000),
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
    if (index != 0) {
      // home is always at bottom of the stack
      _navStack.removeWhere((element) => element == index);
      _navStack.insert(0, index);
    }

    setState(() {
      switchPages(index);
      _selectedIndex = index;
    });
  }

  void switchPages(int index) {
    _pageController.animateToPage(index, duration: Duration(milliseconds: 400), curve: Curves.ease);
    hideKeyboard();
  }
}

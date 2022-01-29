import 'package:familiar_faces/imports/globals.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/screens/settings_screen.dart';
import 'package:familiar_faces/screens/media_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'saved_media_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SavedMediaListScreen _mediaListScreen = new SavedMediaListScreen();
  final MediaInputScreen _mediaInputScreen = new MediaInputScreen();
  final SettingsScreen _settingsScreen = new SettingsScreen();
  final List<Widget> _pageOptions = [];
  final _pageController = PageController(initialPage: 1);
  final List<int> _navigationStack = [];

  int _selectedIndex = 1;

  @override
  void initState() {
    updateGlobalSettings();
    _pageOptions.addAll([_mediaListScreen, _mediaInputScreen, _settingsScreen]);
    _navigationStack.insert(0, _selectedIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBackPressed(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () => hideKeyboard(context),
          child: PageView(
            children: _pageOptions,
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xFF1D1D1D),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.movie),
              label: 'My Media',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          onTap: (index) => onItemTapped(index),
        ),
      ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      _navigationStack.insert(0, index);
      _selectedIndex = index;
      _pageController.animateToPage(index, duration: Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  Future<bool> onBackPressed() async {
    if (_navigationStack.length > 1) {
      _navigationStack.removeAt(0);
      _selectedIndex = _navigationStack.elementAt(0);
      setState(() {
        _pageController.animateToPage(_selectedIndex, duration: Duration(milliseconds: 200), curve: Curves.easeOut);
      });
      return false;
    } else {
      return true;
    }
  }

  // bit of an anti pattern, but i would rather not have async calls everywhere for these global settings
  Future<void> updateGlobalSettings() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      Globals.settings.showCharacters = prefs.getBool(Globals.showCharacterKey) ?? true;
    });
  }
}

import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/screens/about_screen.dart';
import 'package:familiar_faces/screens/media_input_screen.dart';
import 'package:flutter/material.dart';

import 'media_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  final MediaListScreen _mediaListScreen = new MediaListScreen();
  final MediaInputScreen _mediaInputScreen = new MediaInputScreen();
  final AboutScreen _aboutScreen = new AboutScreen();
  final List<Widget> _pageOptions = [];
  final pageController = PageController(initialPage: 1);

  @override
  void initState() {
    _pageOptions.addAll([_mediaListScreen, _mediaInputScreen, _aboutScreen]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Familiar Faces')),
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => hideKeyboard(context),
        child: PageView(
          children: _pageOptions,
          controller: pageController,
          onPageChanged: _onItemTapped,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF323433),
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
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
        ],
        onTap: (index) => pageController.jumpToPage(index),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

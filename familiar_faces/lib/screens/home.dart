import 'package:familiar_faces/providers/home_provider.dart';
import 'package:familiar_faces/screens/about_screen.dart';
import 'package:familiar_faces/screens/main_screen.dart';
import 'package:familiar_faces/screens/saved_media_screen.dart';
import 'package:familiar_faces/services/saved_media_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Widget> _screens = <Widget>[MainScreen(), SavedMediaScreen(), AboutScreen()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SavedMediaService.load(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    var navStack = context.watch<HomeProvider>().navStack;
    var pageController = context.watch<HomeProvider>().pageController;
    var selectedIndex = context.watch<HomeProvider>().selectedIndex;
    return PopScope(
      canPop: navStack.length <= 1,
      onPopInvokedWithResult: handleBackButton,
      child: Scaffold(
        appBar: AppBar(elevation: 0, toolbarHeight: 0),
        resizeToAvoidBottomInset: selectedIndex != 0,
        body: PageView(children: _screens, physics: NeverScrollableScrollPhysics(), controller: pageController),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 0.175)),
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
              NavigationDestination(icon: Icon(Icons.help_outline), selectedIcon: Icon(Icons.help), label: 'About'),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: onItemTapped,
            elevation: 15,
            surfaceTintColor: const Color(0x00000000),
          ),
        ),
      ),
    );
  }

  Future<void> handleBackButton(bool didPop, result) async {
    context.read<HomeProvider>().handleBack(didPop, result);
  }

  void onItemTapped(int index) {
    context.read<HomeProvider>().navigateToPage(index);
  }
}

import 'package:familiar_faces/screens/home.dart';
import 'package:familiar_faces/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'imports/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.black));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Palette.colorSwatch,
          scaffoldBackgroundColor: Color(0xfffffcf0),
          brightness: Brightness.light),
      home: GestureDetector(
        onTap: () => hideKeyboard(context),
        child: Home(),
      ),
    );
  }
}



class Palette {
	static const MaterialColor colorSwatch = MaterialColor(primaryColor, <int, Color>{
		50: Color(0xFFF8EBEB),
		100: Color(0xFFECCDCD),
		200: Color(0xFFE0ABAB),
		300: Color(0xFFD48989),
		400: Color(0xFFCA7070),
		500: Color(primaryColor),
		600: Color(0xFFBB4F4F),
		700: Color(0xFFB34646),
		800: Color(0xFFAB3C3C),
		900: Color(0xFF9E2C2C),
	});
	static const int primaryColor = 0xFFC15757;

	static const MaterialColor mcgpalette0Accent = MaterialColor(_mcgpalette0AccentValue, <int, Color>{
		100: Color(0xFFFFE1E1),
		200: Color(_mcgpalette0AccentValue),
		400: Color(0xFFFF7B7B),
		700: Color(0xFFFF6262),
	});
	static const int _mcgpalette0AccentValue = 0xFFFFAEAE;
}

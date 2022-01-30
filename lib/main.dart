import 'package:familiar_faces/screens/home_screen.dart';
import 'package:familiar_faces/screens/media_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
	  statusBarColor: Colors.black
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Palette.colorSwatch,
          cardColor: Color(0xff2a2a2a),
          scaffoldBackgroundColor: Colors.black,
          brightness: Brightness.dark),
      home: MediaInputScreen(),
    );
  }
}

class Palette {
  static const MaterialColor colorSwatch = const MaterialColor(
    0xff5a9e6c, // 0%
    const <int, Color>{
      50: const Color(0xff518e61), //10%
      100: const Color(0xff487e56), //20%
      200: const Color(0xff487e56), //30%
      300: const Color(0xff365f41), //40%
      400: const Color(0xff2d4f36), //50%
      500: const Color(0xff243f2b), //60%
      600: const Color(0xff1b2f20), //70%
      700: const Color(0xff122016), //80%
      800: const Color(0xff09100b), //90%
      900: const Color(0xff000000), //100%
    },
  );
}

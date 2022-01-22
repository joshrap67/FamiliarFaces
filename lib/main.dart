import 'package:familiar_faces/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
	  // Set the path to the database. Note: Using the `join` function from the
	  // `path` package is best practice to ensure the path is correctly
	  // constructed for each platform.
	  join(await getDatabasesPath(), 'media_database.db'),
	);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.green, brightness: Brightness.dark),
      home: HomeScreen(),
    );
  }
}

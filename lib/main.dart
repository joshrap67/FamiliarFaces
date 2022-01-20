import 'package:familiar_faces/contracts/grouped_movie_response.dart';
import 'package:familiar_faces/screens/movie_filter_screen.dart';
import 'package:familiar_faces/services/tmdb_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.green, brightness: Brightness.dark),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  GroupedMovieResponse? _groupedMovies;
  bool loading = false;
  bool hasMovies = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
      getGroupedMovies();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future getGroupedMovies() async {
    loading = true;

    _groupedMovies = await TmdbService.getGroupedMovieResponse(550);
    var movie = await TmdbService.getMovieWithCastAsync(550);
    setState(() {
      loading = false;
      hasMovies = true;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MovieFilterScreen(
                groupedMovieResponse: _groupedMovies!,
                movieResponse: movie,
              )),
    );
  }
}

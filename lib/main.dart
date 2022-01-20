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
  GroupedMovieResponse? _groupedMovies;
  bool loading = false;
  bool hasMovies = false;
  int _selectedIndex = 1;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  Container(
                    child: Text('Hello'),
                  ),
                  Expanded(
                    child: TextFormField(),
                  )
                ],
              ),
              Row(
                children: [
                  Container(
                    child: Text('Hello'),
                  ),
                  Expanded(
                    child: TextFormField(),
                  )
                ],
              ),
              MaterialButton(
                onPressed: getGroupedMovies,
                child: Text('Where have i seen this actor?'),
                color: Colors.greenAccent,
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
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
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        ),
      ),
    );
  }
}

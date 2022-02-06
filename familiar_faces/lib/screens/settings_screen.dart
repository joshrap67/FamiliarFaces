import 'package:familiar_faces/imports/globals.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _showCharacter;
  String? _appVersion;
  String? _appName;

  @override
  void initState() {
    super.initState();
    _showCharacter = Globals.settings.showCharacters;
    getAppVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings & App Info'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 150,
              width: 150,
              child: Image.asset(
                'assets/icon/foreground.png',
                colorBlendMode: BlendMode.dstATop,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('$_appName Version $_appVersion'),
          ),
          Expanded(
            child: ListView(
              children: [
                Card(
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      'Character Names',
                      style: TextStyle(fontSize: 25),
                    ),
                    tileColor: Color(0xff2a2f38),
                    subtitle: Text('If disabled, character names will never be shown unless searching them.'),
                    onTap: () {
                      setShowCharacters(!_showCharacter);
                    },
                    trailing: Checkbox(
                      onChanged: (value) => setShowCharacters(value!),
                      checkColor: Colors.white,
                      activeColor: Color(0xff009257),
                      value: _showCharacter,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 30.0, 8.0, 8.0),
                  child: Text(
                    'This product uses the TMDB API but is not endorsed or certified by TMDB.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Image.asset('assets/images/tmdb_logo.png')
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> setShowCharacters(bool value) async {
    setState(() {
      _showCharacter = value;
    });
    Globals.settings.setShowCharacters(value);
  }

  Future<void> getAppVersion() async {
    var packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
	  _appName = packageInfo.appName;
    });
  }
}

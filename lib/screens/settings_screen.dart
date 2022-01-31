import 'package:familiar_faces/imports/globals.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

// todo say how there may be discrepancies in the data since this api is dogshit
class _SettingsScreenState extends State<SettingsScreen> {
  late bool _showCharacter;
  String? _appVersion;

  @override
  void initState() {
    _showCharacter = Globals.settings.showCharacters;
    getAppVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings & App Info'),
      ),
      body: ListView(
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
              trailing: Checkbox(
                onChanged: (value) => setShowCharacters(value!),
                checkColor: Colors.white,
                activeColor: Color(0xff009257),
                value: _showCharacter,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(5.0)),
          Card(
            child: ListTile(
              leading: Icon(Icons.info),
              tileColor: Color(0xff2a2f38),
              title: Text(
                'About',
                style: TextStyle(fontSize: 25),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return AboutScreen();
                }));
              },
            ),
          ),
          Padding(padding: const EdgeInsets.all(5.0)),
          Card(
            child: ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 25),
              ),
              tileColor: Color(0xff2a2f38),
              onTap: () async {
                // const String url = '';
                // if (await canLaunch(url)) {
                //   await launch(url);
                // } else {
                //   throw 'Could not launch $url';
                // }
              },
            ),
          ),
          Padding(padding: const EdgeInsets.all(5.0)),
          Card(
            child: ListTile(
              leading: Icon(Icons.article),
              title: Text(
                'Terms of Service',
                style: TextStyle(fontSize: 25),
              ),
              tileColor: Color(0xff2a2f38),
              onTap: () async {
                // const String url = '';
                // if (await canLaunch(url)) {
                //   await launch(url);
                // } else {
                //   throw 'Could not launch $url';
                // }
              },
            ),
          ),
          Padding(padding: const EdgeInsets.all(5.0)),
          Card(
            child: ListTile(
              leading: Icon(Icons.phone_android),
              title: Text(
                _appVersion ?? '',
                style: TextStyle(fontSize: 25),
              ),
              tileColor: Color(0xff2a2f38),
              subtitle: Text('App Version'),
            ),
          ),
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
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }
}

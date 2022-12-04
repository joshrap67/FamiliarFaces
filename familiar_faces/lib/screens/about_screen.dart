import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? _appVersion;
  String? _appName;

  @override
  void initState() {
    super.initState();
    getAppVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 150,
                  width: 150,
                  child: Image.asset(
                    'assets/icon/logo.png',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '$_appName',
                        style: const TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      Text(
                        'Version $_appVersion',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 30.0, 8.0, 8.0),
                  child: AutoSizeText(
                    'This product uses the TMDB API but is not endorsed or certified by TMDB.',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    minFontSize: 8,
                  ),
                ),
                Image.asset('assets/images/tmdb_logo.png')
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> getAppVersion() async {
    var packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _appName = packageInfo.appName;
    });
  }
}

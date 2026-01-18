import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/services/saved_media_database.dart';
import 'package:familiar_faces/services/saved_media_service.dart';
import 'package:file_picker/file_picker.dart';
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
                child: Container(height: 150, width: 150, child: Image.asset('assets/icon/logo.png')),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('$_appName', style: const TextStyle(fontSize: 30)),
                      Text('Version $_appVersion', style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: promptBackup,
                icon: Icon(Icons.backup, color: Colors.white),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  shape: const StadiumBorder(),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                label: Text('Backup to File', style: const TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: promptRestore,
                icon: Icon(Icons.restore, color: Colors.white),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  shape: const StadiumBorder(),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                label: Text('Restore from File', style: const TextStyle(color: Colors.white)),
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
                  child: const AutoSizeText(
                    'This product uses the TMDB API but is not endorsed or certified by TMDB.',
                    style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 11),
                    maxLines: 1,
                    minFontSize: 8,
                  ),
                ),
                Image.asset('assets/images/tmdb_logo.png'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> promptBackup() async {
    await SavedMediaDatabase.instance.exportDatabase(context: context);
  }

  Future<void> promptRestore() async {
    try {
      var result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);

      if (result != null && result.files.single.path != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: LinearProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
        );

        await SavedMediaDatabase.instance.restoreDB(result.files.single.path!);

        Navigator.pop(context);
        showSnackbar('Database import success!', context);
        SavedMediaService.load(context);
      }
    } catch (e) {
      // close loading dialog
      Navigator.pop(context);
    }
  }

  Future<void> getAppVersion() async {
    var packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _appName = packageInfo.appName;
    });
  }
}

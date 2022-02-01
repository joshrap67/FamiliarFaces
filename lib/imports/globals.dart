import 'package:shared_preferences/shared_preferences.dart';

enum SortingValues { AlphaDescending, AlphaAscending, ReleaseDateDescending, ReleaseDateAscending }

class Globals {
  static String showCharacterKey = 'showCharacterKey';
  static final Settings settings = new Settings(true);
}

class Settings {
  bool showCharacters;

  Settings(this.showCharacters);

  setShowCharacters(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Globals.showCharacterKey, value);
    showCharacters = value;
  }
}

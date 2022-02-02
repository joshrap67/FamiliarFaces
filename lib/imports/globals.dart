import 'package:shared_preferences/shared_preferences.dart';

enum SortingValues { AlphaDescending, AlphaAscending, ReleaseDateDescending, ReleaseDateAscending }

class Globals {
  static String showCharacterKey = 'showCharacterKey';
  static final Settings settings = new Settings(true);
}

// bit of an anti pattern, but i would rather not have async calls everywhere for these global settings
class Settings {
  bool showCharacters;

  Settings(this.showCharacters);

  Future<void> setShowCharacters(bool value) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(Globals.showCharacterKey, value);
    showCharacters = value;
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences prefs;

  static Future<SharedPreferences> getPrefs() async {
    try {
      if (prefs == null) {
        prefs = await SharedPreferences.getInstance();
      }
    } catch (error) {
      print("Error Getting SharedPreference => $error");
    }
    // prefs.clear();
    return prefs;
  }
}

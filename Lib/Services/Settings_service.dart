
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Sensitivity 0.0 (strict) – 1.0 (sensitive)
  static double get sensitivity => _prefs.getDouble('sensitivity') ?? 0.55;
  static set sensitivity(double v) => _prefs.setDouble('sensitivity', v);

  static bool get vibrationEnabled => _prefs.getBool('vibration') ?? true;
  static set vibrationEnabled(bool v) => _prefs.setBool('vibration', v);

  static bool get soundAlertEnabled => _prefs.getBool('soundAlert') ?? true;
  static set soundAlertEnabled(bool v) => _prefs.setBool('soundAlert', v);

  static bool get continuousMode => _prefs.getBool('continuous') ?? true;
  static set continuousMode(bool v) => _prefs.setBool('continuous', v);

  // Minimum consecutive detections before alert (reduces false positives)
  static int get consecutiveRequired => _prefs.getInt('consecutive') ?? 3;
  static set consecutiveRequired(int v) => _prefs.setInt('consecutive', v);
}

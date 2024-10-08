import 'package:shared_preferences/shared_preferences.dart';


Future<void> saveUserData(String firebaseUserId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('firebaseUserId', firebaseUserId);

}

Future<String?> getUserData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('firebaseUserId')) {
    return prefs.getString('firebaseUserId')!;
  }
  return null;
}

Future<void> logout() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();  // 全てのデータを削除
}
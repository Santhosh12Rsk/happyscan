import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<bool> checkAlreadyLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs.getBool('isUserLoggedIn') ?? false;
    return status;
  }
}

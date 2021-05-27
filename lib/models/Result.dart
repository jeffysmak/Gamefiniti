import 'package:indianapp/models/User.dart';

class AuthenticationResult {
  static final int RESULT_OK = 0;
  static final int RESULT_CANCELED = 1;
  static final int RESULT_EXISTING = 2;

  AppUser _user;
  int result;

  AuthenticationResult(this._user, this.result);
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:indianapp/models/User.dart';

class FacebookAuthentication {
  static Future<UserCredential> AuthenticateUserWithFacebook(AppUser user, Function onErrorCallback) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    user.provider = 'Email/Facebook';

    FacebookLogin facebookLogin = FacebookLogin();
    FacebookLoginResult fbResult = await facebookLogin.logIn(['email']).catchError((e) {
      debugPrint(e.toString() + 'eryjgv');
    });
    AuthCredential credential = FacebookAuthProvider.credential(fbResult.accessToken.token);
    UserCredential authResult = await _auth.signInWithCredential(credential);
    return authResult;

//    if (fbResult.status == FacebookLoginStatus.loggedIn) {
//
//    } else if (fbResult.status == FacebookLoginStatus.cancelledByUser) {
//      onErrorCallback('canceled by user');
//      return null;
//    } else {
//      onErrorCallback('Some thing went wrong, try gain later.');
//      return null;
//    }
  }
}

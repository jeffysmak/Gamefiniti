import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:indianapp/models/User.dart';

class GoogleAuthentication {
  static Future<UserCredential> authenticateWithGoogleAccount(AppUser user, Function onErrorCallback) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    user.provider = 'Email/Google';

    GoogleSignIn googleSignIn = GoogleSignIn();

    GoogleSignInAccount signInAccount = await googleSignIn.signIn();

    if (signInAccount == null) {
      onErrorCallback.call('some thing went wrong, try again after some time');
      return null;
    }

    GoogleSignInAuthentication googleSignInAuthentication = await signInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    UserCredential authResult = await _auth.signInWithCredential(credential);

    return authResult;
  }
}

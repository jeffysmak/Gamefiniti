import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:indianapp/models/User.dart';

class EmailPassAuthentication {
  static Future<UserCredential> loginWithEmail(Function onErrorCallback, {@required String email, @required String password}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    UserCredential authResult = await auth.signInWithEmailAndPassword(email: email, password: password).catchError(
      (error) {
        onErrorCallback.call();
        debugPrint(error.toString());
      },
    );
    return authResult;
  }

  static Future<UserCredential> signUpWithEmail({AppUser user}) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    user.provider = 'Email/Pass';

    UserCredential authResult = await auth.createUserWithEmailAndPassword(email: user.email, password: user.password);

    try {
      await authResult.user.sendEmailVerification();
    } catch (e) {
      debugPrint('error while sending email verification !');
    }

    return authResult;
  }

  static Future linkWithEmalPass(AppUser user) async {
    AuthCredential credential = EmailAuthProvider.credential(email: user.email, password: user.password);
    FirebaseAuth auth = FirebaseAuth.instance;
    User firebaseUser = auth.currentUser;
    firebaseUser.linkWithCredential(credential);
  }
}

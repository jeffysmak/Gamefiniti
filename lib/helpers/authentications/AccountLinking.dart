import 'package:firebase_auth/firebase_auth.dart';
import 'package:indianapp/models/User.dart';

class AccountLinking {
  static Future linkAccountWith(AppUser user) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    AuthCredential credential = EmailAuthProvider.credential(email: user.email, password: user.password);

    User firebaseUser = auth.currentUser;

    firebaseUser.linkWithCredential(credential);
  }
}

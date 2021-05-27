import 'package:firebase_auth/firebase_auth.dart';
import 'package:indianapp/models/User.dart';

class PhoneAuthentication {
  static Future<UserCredential> authenticateUserWithPhone(
      AppUser user,
      Function onVerificationCompleted,
      Function onVerificationFailed,
      Function onCodeSent,
      Function onCodeAutoRetrievalTimeout,
      bool resend,
      int resendingToken) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    if (resend) {
      auth.verifyPhoneNumber(
          phoneNumber: user.phone,
          timeout: Duration(seconds: 60),
          verificationCompleted: onVerificationCompleted,
          verificationFailed: onVerificationFailed,
          codeSent: onCodeSent,
          codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
          forceResendingToken: resendingToken);
    } else {
      auth.verifyPhoneNumber(
          phoneNumber: user.phone,
          timeout: Duration(seconds: 60),
          verificationCompleted: onVerificationCompleted,
          verificationFailed: onVerificationFailed,
          codeSent: onCodeSent,
          codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout);
    }
  }

  static Future<UserCredential> signInWithAuthCredentials(AuthCredential authCredentials) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    UserCredential authResult = await auth.signInWithCredential(authCredentials);
    return authResult;
  }

  static Future<UserCredential> signInWithAuthIdOtp(String verificationID, String otpCode) async {
    AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationID, smsCode: otpCode);
    UserCredential authResult = await signInWithAuthCredentials(credential);
    return authResult;
  }
}

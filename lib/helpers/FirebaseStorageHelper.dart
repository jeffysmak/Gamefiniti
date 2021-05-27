import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:indianapp/models/User.dart';

class FirebaseStorageHelper {
  static void uploadUserSelfieToStorage(AppUser user, File selfieFile, Function onCompleteCallback, Function onErrorCallback) async {
    Reference firebaseStorageRefrence = FirebaseStorage.instance.ref().child('UserSelfies');
    // UploadTask uploadTask = firebaseStorageRefrence.child('${user.phone}.jpg').putFile(selfieFile);
    TaskSnapshot taskSnapshot = await firebaseStorageRefrence.child('${user.phone}.jpg').putFile(selfieFile);
    String url = await taskSnapshot.ref.getDownloadURL();

    // String url = await snap.ref.getDownloadURL();

    onCompleteCallback.call(url);
  }

  static void uploadUserDocumentToStorage(AppUser user, File selfieFile, Function onCompleteCallback, Function onErrorCallback) async {
    Reference firebaseStorageRefrence = FirebaseStorage.instance.ref().child('UserDocuments');

    TaskSnapshot taskSnapshot = await firebaseStorageRefrence.child('${user.phone}.jpg').putFile(selfieFile);
    String url = await taskSnapshot.ref.getDownloadURL();

    // String url = await snap.ref.getDownloadURL();

    onCompleteCallback.call(url);
  }

  static void GroupPhotoTask(AppUser user, File imageFile, Function onComplete) async {
    Reference firebaseStorageRefrence = FirebaseStorage.instance.ref().child('GroupCovers');
    TaskSnapshot taskSnapshot = await firebaseStorageRefrence.child('${DateTime.now().millisecondsSinceEpoch}.jpg').putFile(imageFile);
    String url = await taskSnapshot.ref.getDownloadURL();
    onComplete.call(url);
  }

  static Future<String> uploadGroupMessageImage(File file) async {
    Reference firebaseStorageRefrence = FirebaseStorage.instance.ref().child('GroupChat');
    UploadTask uploadTask =
        firebaseStorageRefrence.child('${DateTime.now().millisecondsSinceEpoch}${DateTime.now().microsecondsSinceEpoch}.jpg').putFile(file);
    TaskSnapshot snap = await uploadTask.snapshot;
    return await snap.ref.getDownloadURL();
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indianapp/Common.dart';

class Feedback extends StatefulWidget {
  @override
  _FeedbackState createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  String title, feedback = '';
  bool busy = false;

  void setBusy(bool b) {
    setState(() {
      busy = b;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Feedback',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - 100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.all(16),
                    color: Colors.grey.shade100,
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      onChanged: (String v) {
                        title = v;
                      },
                      maxLines: 1,
                      minLines: 1,
                      decoration: InputDecoration(fillColor: Colors.grey.shade200, border: InputBorder.none, hintText: 'Title'),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.all(16),
                    color: Colors.grey.shade100,
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      onChanged: (String v) {
                        feedback = v;
                      },
                      maxLines: 3,
                      minLines: 3,
                      decoration: InputDecoration(fillColor: Colors.grey.shade200, border: InputBorder.none, hintText: 'Write your feedback'),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.all(16),
                    child: RaisedButton(
                      onPressed: () {
                        if (title.length > 0 && feedback.length > 0) {
                          setBusy(true);
                          FirebaseFirestore.instance.collection('Feedbacks').add({
                            'from': FirebaseFirestore.instance.collection('Users').doc(Common.signedInUser.email),
                            'message': feedback,
                            'subject': title,
                            'timestamp': DateTime.now().millisecondsSinceEpoch,
                          }).whenComplete(() {
                            setBusy(false);
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: Text('SEND', style: TextStyle(color: Colors.white)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      color: Colors.orange.shade300,
                    ),
                  ),
                  busy
                      ? Container(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

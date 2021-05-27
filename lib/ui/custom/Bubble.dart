import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final String time;
  final bool fromGroup;

  Bubble({this.message, this.isMe, this.time, this.fromGroup});

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: isMe ? EdgeInsets.only(left: 40) : EdgeInsets.only(right: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isMe ? Colors.grey.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                  borderRadius: isMe
                      ? BorderRadius.only(
                          topRight: Radius.circular(25),
                          topLeft: Radius.circular(25),
                          bottomRight: Radius.circular(0),
                          bottomLeft: Radius.circular(25),
                        )
                      : BorderRadius.only(
                          topRight: Radius.circular(25),
                          topLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                          bottomLeft: Radius.circular(0),
                        ),
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey, fontSize: MediaQuery.of(context).size.height * 0.012),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      message,
                      style: TextStyle(color: Colors.black87, fontSize: MediaQuery.of(context).size.height * 0.015),
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

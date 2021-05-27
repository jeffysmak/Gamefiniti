// import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:indianapp/models/GroupChatMessage.dart';

class ViewImage extends StatefulWidget {
  GroupChatMessage message;

  ViewImage(this.message);

  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('${widget.message.senderName} :'),
        actions: [
          IconButton(icon: Icon(Icons.file_download), onPressed: () {}),
        ],
      ),
      // body: Container(
      //   width: MediaQuery.of(context).size.width,
      //   height: MediaQuery.of(context).size.height,
      //   child: Stack(
      //     children: [
      //       Positioned(
      //         top: 0,
      //         bottom: 0,
      //         left: 0,
      //         right: 0,
      //         child: ExtendedImage.network(
      //           widget.message.messageImage,
      //           fit: BoxFit.contain,
      //           mode: ExtendedImageMode.gesture,
      //           initGestureConfigHandler: (state) {
      //             return GestureConfig(
      //               minScale: 0.9,
      //               animationMinScale: 0.7,
      //               maxScale: 3.0,
      //               animationMaxScale: 3.5,
      //               speed: 1.0,
      //               inertialSpeed: 100.0,
      //               initialScale: 1.0,
      //               inPageView: false,
      //               initialAlignment: InitialAlignment.center,
      //             );
      //           },
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}

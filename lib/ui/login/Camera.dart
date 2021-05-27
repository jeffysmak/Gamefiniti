import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CameraPreviewScreen extends StatefulWidget {
  List<CameraDescription> cameras;

  CameraPreviewScreen({this.cameras});

  @override
  _CameraPreviewScreenState createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  List<CameraDescription> cameras;
  CameraController controller;
  String imagePath;
  var size;

  @override
  void initState() {
    super.initState();
    this.cameras = widget.cameras;
    controller = CameraController(cameras[1], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void _takePhoto(BuildContext ctx) async {
    try {
      // Construct the path where the image should be saved using the path
      // package.
      final path = join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path, '${DateTime.now()}.png',
      );

      // Attempt to take a picture and log where it's been saved.
      await controller.takePicture(path);
      File(path).exists().then((value) {
        if (value != null) {
          imagePath = path;
          Navigator.pop(ctx, imagePath);
        }
      });
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    if (!controller.value.isInitialized) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: WillPopScope(
        child: Stack(
          children: [
            Transform.scale(
              scale: controller.value.aspectRatio / (size.width / size.height),
              child: Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(controller),
                ),
              ),
            ),
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.srcOut,
              ), // This one will create the magic
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ), // This one will handle background + difference out
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: MediaQuery.of(context).size.width,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width / 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 50.0, horizontal: 30),
                child: RawMaterialButton(
                  onPressed: () async {
                    _takePhoto(context);
                  },
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: Icon(
                    Icons.done,
                    size: 35.0,
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
              ),
            ),
          ],
        ),
        onWillPop: () {
          Navigator.pop(context, imagePath);
          return new Future(() => true);
        },
      ),
    );
  }
}

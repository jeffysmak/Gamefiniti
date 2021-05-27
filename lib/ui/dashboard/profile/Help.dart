import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:indianapp/ui/dashboard/profile/Feedback.dart' as f;

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
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
          'Help & Support',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // body
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: TitleText(text: 'Rate Us'),
                          leading: Icon(Icons.star_border),
                          subtitle: Text(Platform.isAndroid ? 'Rate us on the Google playstore' : 'Rate us on the Apple appstore'),
                          onTap: () {
                            openStore();
                          },
                        ),
                        ListTile(
                          title: TitleText(text: 'Write a feedback'),
                          subtitle: Text('Write a feedback or suggestion to improve the app'),
                          leading: Icon(Icons.feedback),
                          onTap: () {
//                            launchReportaProblem('Feedback');
                            Navigator.push(context, MaterialPageRoute(builder: (ctx) => f.Feedback()));
                          },
                        ),
                        ListTile(
                          title: TitleText(text: 'Report a problem'),
                          leading: Icon(Icons.report_problem),
                          onTap: () {
                            launchReportaProblem('Report a Problem');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openStore() async {
    if (Platform.isAndroid) {
      var url = "market://details?id=com.indianapp";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      var url = "itms-apps://itunes.apple.com/app/apple-store/id375380948?mt=8";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  void launchReportaProblem(String subject) async {
    var url = 'mailto:support@khelbuddy.com?subject=$subject';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

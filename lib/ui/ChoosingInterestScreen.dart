import 'package:flutter/material.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/Group.dart';
import 'package:indianapp/models/Notification.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/Chip.dart';
import 'package:indianapp/ui/custom/models/InterestModel.dart';
import 'package:indianapp/ui/dashboard/profile/AboutApp.dart';
import 'package:indianapp/ui/dashboard/profile/Help.dart';
import 'package:indianapp/ui/dashboard/profile/Settings.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class ChoosingInterestScreen extends StatefulWidget {
  int maxSelection;
  List<InterestModel> interests;

  ChoosingInterestScreen({this.maxSelection, this.interests});

  @override
  _ChoosingInterestScreenState createState() => _ChoosingInterestScreenState();
}

class _ChoosingInterestScreenState extends State<ChoosingInterestScreen> {
  InterestModel model;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: WillPopScope(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    Navigator.pop(context, model);
                  },
                ),
                title: Text(
                  'Interests',
                  style: TextStyle(color: Colors.black87),
                ),
                actions: [
                  IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        Navigator.pop(context, model);
                      }),
                ],
              ),
              // body
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                'Select only one interest for your group',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            padding: EdgeInsets.only(top: 16, left: 16),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Wrap(
                              children: widget.interests
                                  .map(
                                    (e) => Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4),
                                      child: CustomChip(
                                        e,
                                        (model) {
                                          widget.interests.forEach((element) {
                                            element.isSelected = false;
                                          });
                                          setState(() {
                                            e.isSelected = true;
                                          });
                                          this.model = model;
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // button continue
            ],
          ),
          onWillPop: () {
            Navigator.pop(context, model);
            return new Future(() => true);
          },
        ),
      ),
    );
  }
}

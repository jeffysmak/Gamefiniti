import 'package:flutter/material.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/Chip.dart';
import 'package:indianapp/ui/custom/models/InterestModel.dart';
import 'package:indianapp/ui/dashboard/Dashboard.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class ChooseInterests extends StatefulWidget {
  AppUser user;

  ChooseInterests(this.user);

  @override
  _ChooseInterestsState createState() => _ChooseInterestsState();
}

class _ChooseInterestsState extends State<ChooseInterests> {
  GlobalKey<ScaffoldState> scaffOldKey = GlobalKey();
  List<InterestModel> _interestsList = List();

  List<InterestModel> _selectedInterests = List();
  bool busy = false;
  AppUser user;

  Stream s;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = widget.user;
    _initInterests();
  }

  void _initInterests() async {
    this._interestsList = await FirestoreHelper.getInterest();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffOldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TitleText(text: 'Select few interests', fontSize: MediaQuery.of(context).size.height * 0.0275),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              child: CircleImageInkWell(
                                  image: AssetImage('assets/images/iiii.png'), onPressed: null, size: MediaQuery.of(context).size.height * 0.2),
                            ),
                            Text(
                              'You\'ll be able to matched \nwith others based on your interests.',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: MediaQuery.of(context).size.height * 0.02,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                children: _interestsList
                                    .map((e) => Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4),
                                          child: CustomChip(
                                            e,
                                            (InterestModel model) {
                                              setState(() {
                                                model.isSelected ? _selectedInterests.remove(model) : _selectedInterests.add(model);
                                                model.isSelected ? model.isSelected = false : model.isSelected = true;

                                                _interestsList.forEach((InterestModel loopedelement) {
                                                  if (_selectedInterests.length == 5) {
                                                    if (!loopedelement.isSelected) {
                                                      loopedelement.isDisabled = true;
                                                    }
                                                  } else {
                                                    loopedelement.isDisabled = false;
                                                  }
                                                });
                                              });
                                            },
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 45,
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: RaisedButton(
                  elevation: 0,
                  focusElevation: 0,
                  hoverElevation: 0,
                  highlightElevation: 0,
                  onPressed: addInterest,
                  color: Colors.orange,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'CONTINUE',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
              busy ? LinearProgressIndicator() : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  void addInterest() async {
    if (_selectedInterests.length > 0) {
      _setBudy(true);
      List<String> inn = List();
      _selectedInterests.forEach((element) {
        inn.add(element.interestID);
      });
      user.interests = inn;
      FirestoreHelper.insertInterestsToUserAccount(
        user,
        () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (ctx) => DashboardScreen(user),
              ),
              (route) => false);
        },
      );
    } else {
      scaffOldKey.currentState.showSnackBar(SnackBar(
        content: Text('Select at least one interes'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  void _setBudy(bool busy) {
    setState(() {
      this.busy = busy;
    });
  }
}

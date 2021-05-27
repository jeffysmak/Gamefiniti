import 'package:age/age.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/helpers/FirestoreHelper.dart';
import 'package:indianapp/models/AgeFactor.dart';
import 'package:indianapp/models/PostActivity.dart';
import 'package:indianapp/models/User.dart';
import 'package:indianapp/ui/custom/GenderRadio.dart';
import 'package:indianapp/ui/custom/models/InterestModel.dart';
import 'package:indianapp/ui/custom/models/RadioItem.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';
import 'package:location/location.dart';

class PostNewInterest extends StatefulWidget {
  List<InterestModel> selectedInterest;

  PostNewInterest({this.selectedInterest});

  @override
  _PostNewInterestState createState() => _PostNewInterestState();
}

class _PostNewInterestState extends State<PostNewInterest> {
  List<TimeOfDay> hoursList = Common.getHursLeftFromNowOn();
  List<InterestModel> selectedInterest;

  final _formKey = GlobalKey<FormState>();

  String _defaultValue = 'Choose gender';
  String _defaultValueAgeFactor = 'Select age factor';
  String _defaultValueLanguageFactor = 'Select prefer language';

  // app bar title
  StringBuffer appBarTitle = StringBuffer();

  // how long will it be
  String timeDuration = '';

  // input controllers
  TextEditingController whenFieldController, whatTimeController, durationController;

  // Posting interest model
  PostActivity postActivityModel = PostActivity.empty();

  // showing progress bar
  bool isBusy = false;

  // location current
  Location location;
  LocationData locationData;

  void setBusy(bool busy) {
    setState(() {
      isBusy = busy;
    });
  }

  List<RadioModel> genderRadioModel = List();
  List<String> selectedRadio = List();
  List<AgeFactor> ageFactorList = List();

  List<RadioModel> languageRadioModel = List();
  List<String> selectedlanguages = List();
  List<AgeFactor> selectedAgeFactors = List();

  // gender
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.selectedInterest = widget.selectedInterest;

    _setAppBarTitle();

    genderRadioModel = Common.genderChoiceOptions();
    languageRadioModel = Common.languageChoiceOptions();
    ageFactorList = Common.defaultAgeFactorsList();

    whenFieldController = TextEditingController();
    whatTimeController = TextEditingController();
    durationController = TextEditingController();

    postActivityModel.choosenDateTime = DateTime.now();

    postActivityModel.choosenInterestList = selectedInterest;

    handleCurrentLocationCoordinates();
  }

  // handle permissons & locations
  void handleCurrentLocationCoordinates() async {
    location = Location();
    if ((await location.hasPermission() == PermissionStatus.GRANTED)) {
      bool serviceEnabled = await location.serviceEnabled();
      if (serviceEnabled) {
        // get location now
        locationData = await location.getLocation();
        // set to model class
        postActivityModel.currentCoordinates = Coordinates(locationData.latitude, locationData.longitude);
      } else {
        await location.requestService();
        handleCurrentLocationCoordinates();
      }
    } else {
      await location.requestPermission();
      handleCurrentLocationCoordinates();
    }
  }

  // handle when it occurs
  void handleDateTime() async {
    DateTime date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + Duration(days: 30).inMilliseconds),
    );
    if (date != null) {
      setState(() {
        whenFieldController.text = Common.formatDate(date);
        postActivityModel.choosenDateTime = date;
      });
    }
  }

  // handle time
  void _pickTime() async {
    TimeOfDay t =
        await showTimePicker(context: context, initialTime: postActivityModel.timeChoosen != null ? postActivityModel.timeChoosen : TimeOfDay.now());
    if (t != null) {
      if (postActivityModel.choosenDateTime.day == DateTime.now().day) {
        if (t.minute > 30) {
          t = t.replacing(minute: 0, hour: t.hour + 1);
        } else {
          t = t.replacing(minute: 30);
        }
      }
      setState(() {
        whatTimeController.text = t.format(context);
        postActivityModel.timeChoosen = t;
      });
    }
  }

  // handles how long it be
  howLongWillItBe(int position) {
    setState(() {
      durationController.text = position == 3 ? 'more than 4 Hours' : '${position + 1} - ${position + 2} Hours';
      postActivityModel.duration = Common.getDuration()[position].inMilliseconds;
    });
  }

  void _setAppBarTitle() {
    selectedInterest.forEach(
      (element) {
        appBarTitle.write(element.title + ', ');
      },
    );
  }

  Widget _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
      title: Text(
        'New ${appBarTitle.toString().substring(0, appBarTitle.toString().lastIndexOf(','))} Activity',
        style: TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget _durationWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              hintText: 'How long will it be?',
              labelText: 'How long will it be?',
              icon: Icon(Icons.timeline, color: Color(0x0ff3a4752)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.6), width: 0.5),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.orange[400],
                ),
              ),
            ),
            readOnly: true,
            controller: durationController,
            validator: (String v) {
              return v == null || v.length == 0 ? 'Must select an option' : null;
            },
          ),
          SizedBox(
            height: 6,
          ),
          Container(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext ctx, int position) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    selected: true,
                    label: Text(
                      position == 3 ? 'more than 4 Hours' : '${position + 1} - ${position + 2} Hours',
                      style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: Colors.orange.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      side: BorderSide(width: 1, color: Colors.orange),
                    ),
                    onSelected: (bool value) {
                      howLongWillItBe(position);
                    },
                  ),
                );
              },
              itemCount: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderOptionsWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/images/gender.png', height: 26),
              SizedBox(width: 12),
              TitleText(text: 'Select Gender'),
            ],
          ),
          Wrap(
            direction: Axis.horizontal,
            runAlignment: WrapAlignment.start,
            children: genderRadioModel
                .map(
                  (RadioModel e) => Padding(
                    padding: EdgeInsets.all(4),
                    child: ChoiceChip(
                      selected: !e.isSelected,
                      label: Text(
                        e.text,
                        style: TextStyle(
                          color: e.enabled
                              ? e.isSelected
                                  ? Colors.white
                                  : Colors.black45
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Colors.orange.withOpacity(0.6),
                      disabledColor: Colors.grey.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16.0),
                        ),
                        side: BorderSide(width: 1, color: e.enabled ? Colors.orange : Colors.grey),
                      ),
                      onSelected: e.enabled
                          ? (bool value) {
                              setState(() {
                                e.isSelected = !e.isSelected;
                                value ? selectedRadio.remove(e.text) : selectedRadio.add(e.text);
                                debugPrint(selectedRadio.length.toString());

                                handleEnableDisable(e);
                              });
                            }
                          : null,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // age factor
  Widget _ageFactorWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pages),
              SizedBox(width: 16),
              Expanded(child: TitleText(text: 'Select Age Group')),
            ],
          ),
          Wrap(
            direction: Axis.horizontal,
            runAlignment: WrapAlignment.start,
            children: ageFactorList
                .map(
                  (e) => Padding(
                    padding: EdgeInsets.all(4),
                    child: ChoiceChip(
                      selected: !e.isSelected,
                      label: Text(e.format(), style: TextStyle(color: e.isSelected ? Colors.white : Colors.black45, fontWeight: FontWeight.w600)),
                      backgroundColor: Colors.orange.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)), side: BorderSide(width: 1, color: Colors.orange)),
                      onSelected: (bool value) {
                        setState(() {
                          e.isSelected = !e.isSelected;
                          value ? selectedAgeFactors.remove(e) : selectedAgeFactors.add(e);
                        });
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // language factor
  Widget _languageFactorWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/language-solid.svg',
                height: 26,
              ),
              SizedBox(width: 12),
              TitleText(text: 'Select Language'),
            ],
          ),
          Wrap(
            direction: Axis.horizontal,
            runAlignment: WrapAlignment.start,
            children: languageRadioModel
                .map(
                  (e) => Padding(
                    padding: EdgeInsets.all(4),
                    child: ChoiceChip(
                      selected: !e.isSelected,
                      label: Text(
                        e.text,
                        style: TextStyle(
                          color: e.enabled
                              ? e.isSelected
                                  ? Colors.white
                                  : Colors.black45
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Colors.orange.withOpacity(0.6),
                      disabledColor: Colors.grey.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16.0),
                        ),
                        side: BorderSide(width: 1, color: e.enabled ? Colors.orange : Colors.grey),
                      ),
                      onSelected: e.enabled
                          ? (bool value) {
                              setState(() {
                                e.isSelected = !e.isSelected;
                                value ? selectedlanguages.remove(e.text) : selectedlanguages.add(e.text);
                                debugPrint(selectedlanguages.length.toString());

                                handleEnableDisableLanguage(e);
                              });
                            }
                          : null,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),
            SizedBox(
              height: 8,
            ),
            // body
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  child: Form(
                    key: _formKey,
                    child: Center(
                      child: Column(
                        children: [
                          // When
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'When?',
                                    labelText: 'When?',
                                    icon: Icon(Icons.calendar_today, color: Color(0x0ff3a4752)),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.6), width: 0.5),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.orange[400],
                                      ),
                                    ),
                                  ),
                                  readOnly: true,
                                  controller: whenFieldController,
                                  onTap: handleDateTime,
                                  validator: _whenFieldValidator,
                                ),
                                SizedBox(height: 6),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'What Time?',
                                    labelText: 'What Time?',
                                    icon: Icon(Icons.access_time, color: Color(0x0ff3a4752)),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.6), width: 0.5),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.orange[400],
                                      ),
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: _pickTime,
                                  controller: whatTimeController,
                                  validator: _timeFieldValidator,
                                ),
                                SizedBox(height: 6),
                                Container(
                                  height: 56,
                                  width: MediaQuery.of(context).size.width,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (BuildContext ctx, int position) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4),
                                        child: ChoiceChip(
                                          selected: true,
                                          label: Text(
                                            hoursList[position].format(context),
                                            style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600),
                                          ),
                                          backgroundColor: Colors.orange.withOpacity(0.6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                            side: BorderSide(width: 1, color: Colors.orange),
                                          ),
                                          onSelected: (bool value) {
                                            postActivityModel.timeChoosen = hoursList[position];
                                            whatTimeController.text = hoursList[position].format(context);
                                          },
                                        ),
                                      );
                                    },
                                    itemCount: hoursList.length,
                                  ),
                                ),
                                // How long will it be
                                _durationWidget(),
                                _genderOptionsWidget(),
                                _languageFactorWidget(),
                                _ageFactorWidget(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // button
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                onPressed: () {
                  // validate the form first
                  if (_formKey.currentState.validate()) {
                    postActivityModel.dateTimeInMilis = Common.getTimeDateInMilist(postActivityModel.choosenDateTime, postActivityModel.timeChoosen);
                    if (selectedRadio.length > 0) {
                      postActivityModel.gendersList = selectedRadio;
                    }
                    if (selectedlanguages.length > 0) {
                      postActivityModel.languageList = selectedlanguages;
                    }
                    if (selectedAgeFactors.length > 0) {
                      postActivityModel.ageFactor = selectedAgeFactors;
                    }

                    if (postActivityModel.isNotNull()) {
                      setBusy(true);
                      FirestoreHelper.postNewKhelBuddyRequest(Common.signedInUser, postActivityModel, () {
                        setBusy(false);
                        Navigator.pop(context, true);
                      });
                    }
                  }
                },
                padding: EdgeInsets.all(12),
                color: Colors.orange,
                child: Text('POST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
            isBusy ? LinearProgressIndicator() : SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  String _whenFieldValidator(String value) {
    if (value != null && value.length > 0) {
      if (postActivityModel.choosenDateTime != null) {
        if (postActivityModel.choosenDateTime.month == DateTime.now().month) {
          if (postActivityModel.choosenDateTime.day >= DateTime.now().day) {
            // proceed
            return null;
          } else {
            return 'Must be a future date';
          }
        } else if (postActivityModel.choosenDateTime.month > DateTime.now().month) {
          return null;
        } else {
          return 'Must be a future date';
        }
      } else {
        return 'Please select date first.';
      }
    } else {
      return 'Please select date first.';
    }
  }

  String _timeFieldValidator(String value) {
    if (value != null && value.length > 0) {
      if (postActivityModel.timeChoosen != null) {
        if (postActivityModel.timeChoosen.hour >= TimeOfDay.now().hour || postActivityModel.timeChoosen.minute >= TimeOfDay.now().minute) {
          // proceed
          return null;
        } else {
          return 'Must be a future time';
        }
      } else {
        return 'Please select time';
      }
    } else {
      return 'Please select time';
    }
  }

  void handleEnableDisable(RadioModel e) {
    if (e.isSelected) {
      if (e.text == 'Male' || e.text == 'Female') {
        setState(() {
          RadioModel model = genderRadioModel[2];
          model.enabled = false;
          genderRadioModel[2] = model;

          RadioModel model2 = genderRadioModel[3];
          model2.enabled = false;
          genderRadioModel[3] = model2;
        });
      } else {
        setState(() {
          for (int i = 0; i < genderRadioModel.length; i++) {
            if (genderRadioModel[i].text != e.text) {
              RadioModel rm = genderRadioModel[i];
              rm.enabled = false;
              genderRadioModel[i] = rm;
            }
          }
        });
      }
    } else {
      if (e.text == 'Male' || e.text == 'Female') {
        if (!genderRadioModel[0].isSelected && !genderRadioModel[1].isSelected) {
          setState(() {
            RadioModel model = genderRadioModel[2];
            model.enabled = true;
            genderRadioModel[2] = model;

            RadioModel model2 = genderRadioModel[3];
            model2.enabled = true;
            genderRadioModel[3] = model2;
          });
        }
      } else {
        setState(() {
          for (int i = 0; i < genderRadioModel.length; i++) {
            if (genderRadioModel[i].text != e.text) {
              RadioModel rm = genderRadioModel[i];
              rm.enabled = true;
              genderRadioModel[i] = rm;
            }
          }
        });
      }
    }
  }

  void handleEnableDisableLanguage(RadioModel e) {
    if (e.isSelected) {
      if (e.text == 'Hindi' || e.text == 'English') {
        setState(() {
          RadioModel model = languageRadioModel[2];
          model.enabled = false;
          languageRadioModel[2] = model;
        });
      } else {
        setState(() {
          for (int i = 0; i < languageRadioModel.length; i++) {
            if (languageRadioModel[i].text != e.text) {
              RadioModel rm = languageRadioModel[i];
              rm.enabled = false;
              languageRadioModel[i] = rm;
            }
          }
        });
      }
    } else {
      if (e.text == 'English' || e.text == 'Hindi') {
        if (!languageRadioModel[0].isSelected && !languageRadioModel[1].isSelected) {
          setState(() {
            RadioModel model = languageRadioModel[2];
            model.enabled = true;
            languageRadioModel[2] = model;
          });
        }
      } else {
        setState(() {
          for (int i = 0; i < languageRadioModel.length; i++) {
            if (languageRadioModel[i].text != e.text) {
              RadioModel rm = languageRadioModel[i];
              rm.enabled = true;
              languageRadioModel[i] = rm;
            }
          }
        });
      }
    }
  }
}

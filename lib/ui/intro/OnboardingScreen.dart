import 'package:flutter/material.dart';
import 'package:indianapp/Common.dart';
import 'package:indianapp/models/onboardmodel.dart';
import 'package:indianapp/prefsHelper.dart';
import 'package:indianapp/ui/login/LoginScreen.dart';
import 'package:indianapp/ui/widgets/TitleText.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<OnBoardModel> onboarding;
  int currentIndex = 0;
  PageController pageController = PageController(keepPage: true, initialPage: 0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onboarding = Common.getOnboardingItems();
  }

  Widget indicator(bool current) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2),
      height: current ? 10 : 6,
      width: current ? 10 : 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: current ? Colors.grey : Colors.grey[300],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: onboarding.length,
        controller: pageController,
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        itemBuilder: (ctx, index) {
          return OnboardItem(onboarding[index]);
        },
      ),
      bottomSheet: currentIndex != onboarding.length - 1
          ? Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      PrefsHelper().saveRuntimevalue();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => LoginScreen()));
                    },
                    child: Text('SKIP'),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < onboarding.length; i++)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: indicator(currentIndex == i),
                          ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        currentIndex++;
                        pageController.animateToPage(currentIndex, duration: Duration(milliseconds: 300), curve: Curves.bounceInOut);
                      });
                    },
                    child: Text('NEXT'),
                  ),
                ],
              ),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.075,
              color: Colors.orange,
              child: GestureDetector(
                onTap: () {
                  PrefsHelper().saveRuntimevalue();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => LoginScreen()));
                },
                child: Center(
                  child: Text(
                    'GET STARTED NOW',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.height * 0.0175,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class OnboardItem extends StatelessWidget {
  OnBoardModel model;

  OnboardItem(this.model);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(model.image, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.3),
          SizedBox(height: 20),
          Text(model.title, textAlign: TextAlign.center),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(model.desc, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

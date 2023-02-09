import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constant.dart';
import 'package:frontend/screens/translate_page.dart';

import '../components/rounded_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.camera}) : super(key: key);
  final CameraDescription camera;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(gradient: background),
            child: SafeArea(
              child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 30, left: MediaQuery.of(context).size.width / 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          // Welcome Text
                          Padding(
                            padding: EdgeInsets.only(bottom: 0, left: MediaQuery.of(context).size.width / 20),
                            child: Text(
                              "Welcome to hAIndle!",
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.height * 0.01 * 3,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                color: darkTextColor,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          // Help Button
                          Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 10),
                              child: Container(
                                      height: MediaQuery.of(context).size.height / 22,
                                      width: MediaQuery.of(context).size.width / 10,
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.all(MediaQuery.of(context).size.height / 1000),
                                      decoration: const BoxDecoration(
                                        gradient: circleGradient,
                                        borderRadius: BorderRadius.all(Radius.circular(40)),
                                      ),
                                      child: MaterialButton(
                                        hoverColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                              onPressed: () => {
                                                // Help Popup
                                                showDialog(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      alignment: Alignment.center,
                                                      title: Container(
                                                        width: MediaQuery.of(context).size.width / 1.5,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: <Widget>[
                                                            Column(
                                                              children: <Widget>[
                                                                Text(
                                                                  "How to use hAIndle?",
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                      fontSize: MediaQuery.of(context).size.height * 0.01 * 2,
                                                                      fontStyle: FontStyle.normal,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: darkTextColor),
                                                                ),
                                                                SizedBox(
                                                                  height: MediaQuery.of(context).size.height / 20,
                                                                ),
                                                                Text(
                                                                  "Step 1: Press the “Start Translating” button",
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                      fontSize: MediaQuery.of(context).size.height * 0.01 * 1.7,
                                                                      fontStyle: FontStyle.normal,
                                                                      fontWeight: FontWeight.normal,
                                                                      color: darkTextColor),
                                                                ),
                                                                SizedBox(
                                                                  height: MediaQuery.of(context).size.height / 20,
                                                                ),
                                                                Text(
                                                                  "Step 2: Point your camera at the person signing",
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                      fontSize: MediaQuery.of(context).size.height * 0.01 * 1.7,
                                                                      fontStyle: FontStyle.normal,
                                                                      fontWeight: FontWeight.normal,
                                                                      color: darkTextColor),
                                                                ),
                                                                SizedBox(
                                                                  height: MediaQuery.of(context).size.height / 20,
                                                                ),
                                                                Text(
                                                                  "Step 3: Sign language will be immediately translated to written English",
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                      fontSize: MediaQuery.of(context).size.height * 0.01 * 1.7,
                                                                      fontStyle: FontStyle.normal,
                                                                      fontWeight: FontWeight.normal,
                                                                      color: darkTextColor),
                                                                ),
                                                                SizedBox(
                                                                  height: MediaQuery.of(context).size.height / 40,
                                                                ),
                                                                  RoundedButton(
                                                                    title: 'Ok',
                                                                    colour: pink,
                                                                    onTap: () {
                                                                      Navigator.pop(context);
                                                                    },
                                                                  ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    barrierDismissible: false),
                                              },
                                              child: Text(
                                                "?",
                                                style: TextStyle(
                                                  fontSize: MediaQuery.of(context).size.height * 0.01 * 2,
                                                  fontStyle: FontStyle.normal,
                                                  fontWeight: FontWeight.bold,
                                                  color: lightTextColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ))
                        ],
                      ),
                      // Translate Button
                      Padding(
                          padding: EdgeInsets.only(bottom: 0),
                          child: Container(
                              height: MediaQuery.of(context).size.height / 2.5,
                              width: MediaQuery.of(context).size.width / 1.17,
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 6),
                              decoration: const BoxDecoration(
                                color: translucentPink,
                                borderRadius: BorderRadius.all(Radius.circular(180)),
                              ),
                              child: Container(
                                  height: MediaQuery.of(context).size.height / 2.5,
                                  width: MediaQuery.of(context).size.width / 1.17,
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.all(MediaQuery.of(context).size.height / 50),
                                  decoration: const BoxDecoration(
                                    gradient: circleGradient,
                                    borderRadius: BorderRadius.all(Radius.circular(180)),
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.all(MediaQuery.of(context).size.height / 50),
                                    child: SizedBox(
                                      height: MediaQuery.of(context).size.height / 2.5,
                                      width: MediaQuery.of(context).size.width / 1.17,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          primary: translucentWhite,
                                          onPrimary: translucentWhite,
                                          splashFactory: NoSplash.splashFactory,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(180)),
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed: () => {
                                        Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                        builder: (context) => TranslatePage(camera: widget.camera),
                                        ),
                                        )
                                        },
                                        child: Text(
                                          "START TRANSLATING",
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context).size.height * 0.01 * 3.8,
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.bold,
                                              color: lightTextColor,
                                        ),
                                          textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )))
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
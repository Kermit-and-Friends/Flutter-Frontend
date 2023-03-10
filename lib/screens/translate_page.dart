import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:frontend/constant.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({Key? key, required this.camera}) : super(key: key);
  final CameraDescription camera;

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late IO.Socket socket;
  String translatedText = "";
  Timer? timer;
  int mode = 0;
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    if (widget.camera !=
        CameraDescription(
            name: "noCamera",
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0)) {
      _controller = CameraController(
        // Get a specific camera from the list of available cameras.
        widget.camera,
        // Define the resolution to use.
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      // Next, initialize the controller. This returns a Future.
      _initializeControllerFuture = _controller.initialize();
    }
    _initSpeech();
  }

  initSocket() {
    socket = IO.io("https://f1c1-137-132-119-1.ap.ngrok.io", <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
    });
    socket.connect();
    socket.onConnect((_) {
      print('Connection established');
    });
    socket.onDisconnect((_) => print('Connection Disconnection'));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));
    socket.on('response_back', (newMessage) {
      translatedText = translatedText + newMessage[0];
      _updateState();
    });
    timer =
        Timer.periodic(Duration(seconds: 1), (Timer t) => takeAndSendPicture());
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    print("listening");
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      translatedText = result.recognizedWords;
      print(translatedText);
    });
  }

  @override
  void dispose() {
    if (widget.camera !=
        CameraDescription(
            name: "noCamera",
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0)) {
      // Dispose of the controller when the widget is disposed.
      _controller.dispose();
    }
    super.dispose();
  }

  sendMessage(imagePath) async {
    print("sendingmessage");
    ByteData byteData = await rootBundle.load(imagePath);
    Uint8List bytes = byteData.buffer.asUint8List();
    String base64Image = base64.encode(bytes);
    base64Image = "data:image/jpeg;base64," + base64Image;
    // Transmit image to server
    socket.emit('image', base64Image);
  }

  takeAndSendPicture() async {
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;
      // Attempt to take a picture and then get the location
      // where the image file is saved.
      final image = await _controller.takePicture();
      sendMessage(image.path);
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: MediaQuery
              .of(context)
              .size
              .height,
          decoration: const BoxDecoration(gradient: background),
          child: SafeArea(
            child: Container(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  mode == 1 ?
                  // Instruction
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: 0,
                        left: MediaQuery
                            .of(context)
                            .size
                            .width / 20),
                    child: Text(
                      "Point your camera at the person signing!",
                      style: TextStyle(
                        fontSize:
                        MediaQuery
                            .of(context)
                            .size
                            .height * 0.01 * 2.8,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        color: darkTextColor,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  )
                      : mode == 2 ?
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: 0,
                        left: MediaQuery
                            .of(context)
                            .size
                            .width / 20),
                    child: Text(
                      "Speak into the microphone!",
                      style: TextStyle(
                        fontSize:
                        MediaQuery
                            .of(context)
                            .size
                            .height * 0.01 * 2.8,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        color: darkTextColor,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  )
                      : Container(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height / 12,
                  ),
                  mode != 2
                      ? // Camera Feed
                  widget.camera !=
                      CameraDescription(
                          name: "noCamera",
                          lensDirection: CameraLensDirection.back,
                          sensorOrientation: 0)
                      ? Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height / 2,
                      child: FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            // If the Future is complete, display the preview.
                            return CameraPreview(_controller);
                          } else {
                            // Otherwise, display a loading indicator.
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      ))
                      : Padding(
                    padding: EdgeInsets.fromLTRB(
                        MediaQuery
                            .of(context)
                            .size
                            .width / 30,
                        MediaQuery
                            .of(context)
                            .size
                            .height / 4.5,
                        MediaQuery
                            .of(context)
                            .size
                            .width / 30,
                        MediaQuery
                            .of(context)
                            .size
                            .height / 10),
                    child: Text(
                      "No camera detected.\nPlease allow camera access in Settings, or use another device with a camera.\nThank you! :)",
                      style: TextStyle(
                        fontSize:
                        MediaQuery
                            .of(context)
                            .size
                            .height * 0.01 * 2,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        color: darkTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                      : // Audio input gif
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        MediaQuery
                            .of(context)
                            .size
                            .width / 30,
                        0,
                        MediaQuery
                            .of(context)
                            .size
                            .width / 30,
                        0),
                    child: Image.asset(
                      "assets/images/audioInput.gif",
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height / 50,
                  ),
                  // Translated Text
                  mode == 1 || mode == 2
                      ? Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          MediaQuery
                              .of(context)
                              .size
                              .width / 20,
                          0,
                          MediaQuery
                              .of(context)
                              .size
                              .width / 20,
                          0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical, //.horizontal
                        child: Text(
                          translatedText,
                          style: TextStyle(
                            fontSize:
                            MediaQuery
                                .of(context)
                                .size
                                .height * 0.01 * 2,
                            color: darkTextColor,
                          ),
                        ),
                      ),
                    ),
                  )
                      : Container(),
                  mode == 1 || mode == 2
                      ?
                  // Stop Button
                  Padding(
                      padding: EdgeInsets.only(bottom: 0),
                      child: Container(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height / 19,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.17,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                              top: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 30),
                          decoration: const BoxDecoration(
                            color: translucentPink,
                            borderRadius:
                            BorderRadius.all(Radius.circular(180)),
                          ),
                          child: Container(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 19,
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 1.17,
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(
                                  MediaQuery
                                      .of(context)
                                      .size
                                      .height / 200),
                              decoration: const BoxDecoration(
                                gradient: circleGradient,
                                borderRadius:
                                BorderRadius.all(Radius.circular(180)),
                              ),
                              child: Container(
                                  margin: EdgeInsets.all(
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .height / 200),
                                  child: SizedBox(
                                    height:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .height / 19,
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width /
                                        1.17,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: translucentWhite,
                                        onPrimary: translucentWhite,
                                        splashFactory: NoSplash.splashFactory,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(180)),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () =>
                                      {
                                        if (mode == 1) {
                                          timer?.cancel(),
                                          socket.disconnect(),
                                          socket.dispose(),
                                        },
                                        if (mode == 2) {
                                          _stopListening(),
                                        },
                                        translatedText = "",
                                        mode = 0,
                                        _updateState(),
                                      },
                                      child: Text(
                                        "STOP",
                                        style: TextStyle(
                                          fontSize: MediaQuery
                                              .of(context)
                                              .size
                                              .height *
                                              0.01 *
                                              2.2,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.bold,
                                          color: lightTextColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )))))
                      : // Mic and Video Button
                  Column(
                      children: [
                        SizedBox(
                            height: MediaQuery
                                .of(context)
                                .size
                                .height / 8),
                        Row(
                          children: [
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width / 14),
                            Padding(
                                padding: EdgeInsets.only(bottom: 0),
                                child: Container(
                                    height: MediaQuery
                                        .of(context)
                                        .size
                                        .height / 19,
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width / 2.5,
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(
                                        top: MediaQuery
                                            .of(context)
                                            .size
                                            .height / 40),
                                    decoration: const BoxDecoration(
                                      color: translucentPink,
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(180)),
                                    ),
                                    child: Container(
                                        height: MediaQuery
                                            .of(context)
                                            .size
                                            .height / 19,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width / 2.5,
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.all(
                                            MediaQuery
                                                .of(context)
                                                .size
                                                .height / 200),
                                        decoration: const BoxDecoration(
                                          gradient: circleGradient,
                                          borderRadius:
                                          BorderRadius.all(
                                              Radius.circular(180)),
                                        ),
                                        child: Container(
                                            margin: EdgeInsets.all(
                                                MediaQuery
                                                    .of(context)
                                                    .size
                                                    .height / 200),
                                            child: SizedBox(
                                              height:
                                              MediaQuery
                                                  .of(context)
                                                  .size
                                                  .height / 19,
                                              width: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width /
                                                  2.5,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: translucentWhite,
                                                  onPrimary: translucentWhite,
                                                  splashFactory: NoSplash
                                                      .splashFactory,
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(180)),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                onPressed: () =>
                                                {
                                                  mode = 2,
                                                  _updateState(),
                                                  _startListening(),
                                                },
                                                child: Text(
                                                  "SPEECH",
                                                  style: TextStyle(
                                                    fontSize: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .height *
                                                        0.01 *
                                                        2,
                                                    fontStyle: FontStyle.normal,
                                                    fontWeight: FontWeight.bold,
                                                    color: lightTextColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ))))),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 18,
                            ),
                            Padding(
                                padding: EdgeInsets.only(bottom: 0),
                                child: Container(
                                    height: MediaQuery
                                        .of(context)
                                        .size
                                        .height / 19,
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width / 2.5,
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(
                                        top: MediaQuery
                                            .of(context)
                                            .size
                                            .height / 40),
                                    decoration: const BoxDecoration(
                                      color: translucentPink,
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(180)),
                                    ),
                                    child: Container(
                                        height: MediaQuery
                                            .of(context)
                                            .size
                                            .height / 19,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width / 2.5,
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.all(
                                            MediaQuery
                                                .of(context)
                                                .size
                                                .height / 200),
                                        decoration: const BoxDecoration(
                                          gradient: circleGradient,
                                          borderRadius:
                                          BorderRadius.all(
                                              Radius.circular(180)),
                                        ),
                                        child: Container(
                                            margin: EdgeInsets.all(
                                                MediaQuery
                                                    .of(context)
                                                    .size
                                                    .height / 200),
                                            child: SizedBox(
                                              height:
                                              MediaQuery
                                                  .of(context)
                                                  .size
                                                  .height / 19,
                                              width: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width /
                                                  2.5,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: translucentWhite,
                                                  onPrimary: translucentWhite,
                                                  splashFactory: NoSplash
                                                      .splashFactory,
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(180)),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                onPressed: () =>
                                                {
                                                  mode = 1,
                                                  _updateState(),
                                                  initSocket(),
                                                },
                                                child: Text(
                                                  "VIDEO",
                                                  style: TextStyle(
                                                    fontSize: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .height *
                                                        0.01 *
                                                        2,
                                                    fontStyle: FontStyle.normal,
                                                    fontWeight: FontWeight.bold,
                                                    color: lightTextColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ))))),
                          ],
                        ),
                      ]
                  ),
                  // Back Button
                  Padding(
                      padding: EdgeInsets.only(bottom: 0),
                      child: Container(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height / 19,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.17,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                              top: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 40),
                          decoration: const BoxDecoration(
                            color: translucentPink,
                            borderRadius:
                            BorderRadius.all(Radius.circular(180)),
                          ),
                          child: Container(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 19,
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 1.17,
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(
                                  MediaQuery
                                      .of(context)
                                      .size
                                      .height / 200),
                              decoration: const BoxDecoration(
                                gradient: circleGradient,
                                borderRadius:
                                BorderRadius.all(Radius.circular(180)),
                              ),
                              child: Container(
                                  margin: EdgeInsets.all(
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .height / 200),
                                  child: SizedBox(
                                    height:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .height / 19,
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width /
                                        1.17,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: translucentWhite,
                                        onPrimary: translucentWhite,
                                        splashFactory: NoSplash.splashFactory,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(180)),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () =>
                                      {
                                        if (mode == 1) {
                                          timer?.cancel(),
                                          socket.disconnect(),
                                          socket.dispose(),
                                        } else if (mode == 2) {
                                          _stopListening(),
                                        },
                                        Navigator.pop(context),
                                      },
                                      child: Text(
                                        "BACK",
                                        style: TextStyle(
                                          fontSize: MediaQuery
                                              .of(context)
                                              .size
                                              .height *
                                              0.01 *
                                              2.2,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.bold,
                                          color: lightTextColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ))))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateState() {
    setState(() {});
  }
}

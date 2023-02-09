import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constant.dart';

import 'screens/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
// Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();
// Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.camera}) : super(key: key);
  final CameraDescription camera;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hAIndle',
      theme: ThemeData(
        primarySwatch: pinkBase,
        fontFamily: 'Poppins',
      ),
      home: HomePage(camera: camera),
    );
  }
}

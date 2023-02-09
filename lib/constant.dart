import 'package:flutter/material.dart';

const MaterialColor pinkBase = MaterialColor(
  0xFFEB8181,
  <int, Color>{
    50: Color(0xFFFFEBEE),
    100: Color(0xFFFFCDD2),
    200: Color(0xFFEF9A9A),
    300: Color(0xFFE57373),
    400: Color(0xFFEF5350),
    500: Color(0xFFEB8181),
    600: Color(0xFFE53935),
    700: Color(0xFFD32F2F),
    800: Color(0xFFC62828),
    900: Color(0xFFB71C1C),
  },
);

const Color mainColor = Color(0xFFFDF5E6);
const Color lightTextColor = Color(0xffffffff);
const Color darkTextColor = Color(0xff211e1e);
const Color translucentPink = Color(0x41ff727b);
const Color translucentWhite = Color(0x33ffffff);
const Color pink = Color.fromRGBO(255, 112, 122, 1.0);
const Color orange = Color.fromRGBO(255, 164, 138, 1.0);

const LinearGradient background = LinearGradient(
  colors: <Color>[Color(0xfff5f7fb), Color(0xffe1e5eb)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const LinearGradient circleGradient = LinearGradient(
  colors: <Color>[Color.fromRGBO(255, 112, 122, 1.0), Color.fromRGBO(255, 164, 138, 1.0)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const maxScreenWidth = 750.0;
const screenPadding = EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 30.0);
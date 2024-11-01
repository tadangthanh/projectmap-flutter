import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget loading() {
  return const Center(
    child: SpinKitFadingCircle(
      color: Colors.blueAccent,
      size: 40,
    ),
  );
}

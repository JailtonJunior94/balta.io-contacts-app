import 'dart:io';
import 'package:flutter/material.dart';

import 'package:contact_app/ios/ios.app.dart';
import 'package:contact_app/android/android.app.dart';

void main() {
  if (Platform.isIOS) {
    runApp(IOSApp());
  } else {
    runApp(AndroidApp());
  }
}

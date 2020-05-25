import 'package:flutter/material.dart';

import 'package:contact_app/android/styles.dart';
import 'package:contact_app/android/views/home.view.dart';

class AndroidApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts',
      debugShowCheckedModeBanner: false,
      theme: androidTheme(),
      home: HomeView(),
    );
  }
}

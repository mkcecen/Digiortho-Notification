import 'dart:async';

import 'package:digiortho/custom_appbar_sample.dart';
import 'package:digiortho/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:digiortho/convex_bottom_bar.dart';
import 'package:digiortho/file_utils.dart';
import 'package:digiortho/timer/count_down_timer.dart';
import 'package:flutter/material.dart';

import 'package:digiortho/timer/neu_digital_clock.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.blueGrey, accentColor: Colors.blueGrey),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    ));

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DateTime alert;
  bool isStart = false;
  String readText;
  Duration differenceTimer;
  @override
  void initState() {
    super.initState();
    _readData();
    Timer(Duration(seconds: 2), () => print("Splach Done!"));
    Future.delayed(const Duration(seconds: 2), () async {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new CustomAppBarDemo(
                  alert, isStart, readText, differenceTimer)));
      // new MaterialPageRoute(builder: (context) => new HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/logo.jpg',
                        width: 225,
                        height: 225,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                      Text(
                        "Telsiz Ortodonti Sistemi",
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _readData() async {
    readText = await FileUtils.readFromFile();
    if (readText != null && readText != '') {
      var arr = readText.split(';');
      var oldTime = DateTime.parse(arr[1]);
      var newTime = DateTime.now();
      var difference = newTime.difference(oldTime);
      if (difference < Duration(seconds: 0)) {
        isStart = arr[0].toLowerCase() == 'true';
        alert = oldTime;
        differenceTimer = oldTime.difference(newTime);
        ;
      }
      print('readText => $readText');
      print('isStart => $isStart');
      print('alert => $alert');
      print('differenceTimer => $differenceTimer');
    }
  }
}

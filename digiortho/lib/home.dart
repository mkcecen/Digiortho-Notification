import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timer_builder/timer_builder.dart';
import 'file_utils.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime alert;
  bool isStart = false;
  String readText;
  FlutterLocalNotificationsPlugin localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  initializeNotifications() async {
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = IOSInitializationSettings();
    var initSettings = InitializationSettings(android, ios);
    await localNotificationsPlugin.initialize(initSettings);
  }

  @override
  void initState() {
    super.initState();
    alert = DateTime.now();
    parseValue();
    initializeNotifications();
  }

  Future singleNotification(DateTime datetime, String message, String subtext,
      int hashcode,
      {String sound}) async {
    var androidChannel = AndroidNotificationDetails(
      'channel-id',
      'channel-name',
      'channel-description',
      importance: Importance.Max,
      priority: Priority.Max,
    );

    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(androidChannel, iosChannel);
    localNotificationsPlugin.schedule(
        hashcode, message, subtext, datetime, platformChannel,
        payload: hashcode.toString());
  }

  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    return false; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme
        .of(context)
        .textTheme
        .bodyText1;
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            flexibleSpace: Image(
              image: AssetImage('assets/telsiz.jpg'),
              fit: BoxFit.cover,
            ),
//          centerTitle: true,
//          actions: [
//            Image.asset(
//              'assets/dental.png',
//              height: 40,
//              width: 40,
//            ),
//            SizedBox(
//              width: 20,
//            )
//            //Sağ tarafa dayalı
//          ],
//          leading: Icon(Icons.access_alarm),
            automaticallyImplyLeading: false,
          ),
        ),
        body: Container(
          color: Colors.white,
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: MediaQuery
              .of(context)
              .size
              .height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
//            Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              mainAxisSize: MainAxisSize.min,
//              children: <Widget>[
//                Text(
//                  'Şu an $nowPlackCount. plaktasınız.',
//                  style: textStyle,
//                ),
//              ],
//            ),
              Image.asset(
                'assets/logo.jpg',
                height: 100,
                width: 200,
              ),
              RaisedButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Colors.blueGrey[400],
                onPressed: _startTimer,
                child: Text(
                  'Zamanlayıcıyı\n       Başlat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
              SizedBox(height: 20),

              Icon(
                Icons.alarm_on,
                color: Colors.green,
                size: 48,
              ),
              Container(
                child: TimerBuilder.periodic(
                  Duration(seconds: 1),
                  alignment: Duration.zero,
                  builder: (context) {
                    var now = DateTime.now();
                    var difference = alert.difference(now);
                    return Text(formatDuration(difference), style: textStyle);
                  },
                ),
              ),

              SizedBox(height: 150),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(
            Icons.help,
            size: 60,
            color: Colors.blueGrey,
          ),
          onPressed: () {
            createHelpDialog(context);
          },
        ),
      ),
    );
  }

  _startTimer() async {
    isStart = true;
    alert = DateTime.now().add(Duration(days: 15));
    //alert = DateTime.now().add(Duration(seconds: 15));

    String value = isStart.toString() + ";" + alert.toString();
    FileUtils.saveToFile(value);
    _showNotification(alert);
  }

  String formatDuration(Duration d) {
    String lbl = "";
    print("kaan girdi => $d");
    print("isStart => $isStart");
    if (isStart == true) {
      String f(int n) {
        return n.toString().padLeft(2, '0');
      }

      d += Duration(microseconds: 999999);

      lbl =
      "Plak Değişimine Kalan\n ${f(d.inDays)} gün ${f(d.inHours % 24)} saat ${f(
          d.inMinutes % 60)}:${f(d.inSeconds % 60)}";
      print("lbl => $lbl");

      if (d.inSeconds == 0) {
        _changeValue();
      }
    } else {
      lbl = "Plak Değişimine Kalan\n 00 gün 00 saat 00:00";
    }
    return lbl;
  }

  _changeValue() {
    isStart = false;
    alert = DateTime.now();
  }

  _showNotification(DateTime time) async {
    await singleNotification(
      time,
      'Plak Değişimi',
      'Plak değiştime zamanın geldi. WhatsApp üzerinden hekiminle fotoğraf paylaşmayı unutma :)',
      98123871,
    );
  }

  createHelpDialog(BuildContext context) {
    TextEditingController customController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Nasıl Kullanırım ?',
            style: Theme
                .of(context)
                .textTheme
                .title,
          ),
          content: Text(
            'Zamanlayıcıyı başlat butonu ile sayaç çalışmaya başlar ve her 15 günde bir sana hatırlatma gönderir.\n\nUnutma her hatırlatma sonrası sayacı tekrar başlatmalısın :) ',
            style: Theme
                .of(context)
                .textTheme
                .caption,
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 5.0,
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop(customController.text.toString());
              },
            ),
          ],
        );
      },
    );
  }

  parseValue() async {
    readText = await FileUtils.readFromFile();
    if (readText != null && readText != '') {
      var arr = readText.split(';');
      var oldTime = DateTime.parse(arr[1]);
      var newTime = DateTime.now();
      var difference = newTime.difference(oldTime);
      if (difference < Duration(seconds: 0)) {
        print('oldTime => $oldTime');
        print('newTime => $newTime');
        print('difference => $difference');
        isStart = arr[0].toLowerCase() == 'true';
        alert = oldTime;
      }
    }
  }
}

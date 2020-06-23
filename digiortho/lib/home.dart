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
  int nowPlackCount;
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

  Future singleNotification(
      DateTime datetime, String message, String subtext, int hashcode,
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

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.title;
    return Scaffold(
      appBar: AppBar(
        title: Text('Digiortho'),
        leading: new Container(),
      ),
      body: Container(
        padding: EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: _startTimer,
              child: Text(
                'Zamanlayıcıyı başlat',
                style: textStyle,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.alarm_on,
                  color: Colors.green,
                  size: 48,
                ),
                TimerBuilder.periodic(
                  Duration(seconds: 1),
                  alignment: Duration.zero,
                  builder: (context) {
                    var now = DateTime.now();
                    var difference = alert.difference(now);
                    return Text(formatDuration(difference), style: textStyle);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.help),
        onPressed: () {
          createHelpDialog(context);
        },
      ),
    );
  }

  _startTimer() async {
    isStart = true;
//    alert = DateTime.now().add(Duration(minutes: 5));
    alert = DateTime.now().add(Duration(seconds: 15));
    if (nowPlackCount != null) {
      nowPlackCount += 1;
    } else {
      nowPlackCount = 1;
    }
    String value = isStart.toString() +
        ";" +
        alert.toString() +
        ";" +
        nowPlackCount.toString();
    FileUtils.saveToFile(value);
    _showNotification(alert);
  }

  String formatDuration(Duration d) {
    String lbl = "";
    if (isStart == true) {
      String f(int n) {
        return n.toString().padLeft(2, '0');
      }

      d += Duration(microseconds: 999999);

      lbl =
          "Plak Değişimine Kalan\n${f(d.inDays)} gün ${f(d.inMinutes % 60)}:${f(d.inSeconds % 60)}";

      if (d.inSeconds == 0) {
        _changeValue();
      }
    } else {
      lbl = "Plak Değişimine Kalan\n 00 gün 00:00";
    }
    return lbl;
  }

  _changeValue() {
    isStart = false;
    nowPlackCount += 1;
  }

  _showNotification(DateTime time) async {
    await singleNotification(
      time,
      '$nowPlackCount . Plak Değişimi',
      'Plak değiştime zamanın geldi. Sakın unutma :) ',
      98123871,
    );
  }

  createHelpDialog(BuildContext context) {
    TextEditingController customController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nasıl Kullanırım ?'),
          content: Text(
              'Zamanlayıcıyı başlat butonu ile sayaç çalışmaya başlar ve her 15 günde bir sana hatırlatma gönderir.\n\nHer hatırlatma sonrası sayacı tekrar başlatmalısın yoksa 2 saatte bir sana uyarı mesajı gelecektir :) '),
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
    if (readText != null) {
      var arr = readText.split(';');
      isStart = arr[0].toLowerCase() == 'true';
      alert = DateTime.parse(arr[1]);
      nowPlackCount = int.parse(arr[2]);
    }
  }
}

import 'dart:ui';

import 'package:digiortho/convex_bottom_bar.dart';
import 'package:digiortho/file_utils.dart';
import 'package:digiortho/timer/count_down_timer.dart';
import 'package:flutter/material.dart';

import 'package:digiortho/timer/neu_digital_clock.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CustomAppBarDemo extends StatefulWidget {
  final String readText;
  final DateTime alert;
  final bool isStart;
  final Duration differenceTimer;
  const CustomAppBarDemo(
      this.alert, this.isStart, this.readText, this.differenceTimer);
  @override
  State createState() {
    return _State();
  }
}

class _State extends State<CustomAppBarDemo>
    with SingleTickerProviderStateMixin {
  DateTime alert;
  bool isStart = false;
  String readText;
  Duration differenceTimer;
  initializeNotifications() async {
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = IOSInitializationSettings();
    var initSettings = InitializationSettings(android, ios);
    await localNotificationsPlugin.initialize(initSettings);
  }

  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final ScrollController _scrollController = ScrollController();
  AnimationController controller;
  List<TabItem> items = <TabItem>[
    TabItem(icon: Icons.home, title: 'Home'),
    TabItem(icon: Icons.map, title: 'Discovery'),
    TabItem(icon: Icons.plus_one, title: 'Add'),
  ];

  @override
  void initState() {
    isStart = widget.isStart;
    alert = widget.alert;
    readText = widget.readText;
    differenceTimer = widget.differenceTimer;
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: differenceTimer,
    );
    alert = DateTime.now();
    initializeNotifications();
    _timerStartAndRestart(isStart, false);
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
    return DefaultTabController(
      length: items.length,
      initialIndex: 1,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0),
          child: AppBar(
            flexibleSpace: Image(
              image: AssetImage('assets/logo.jpg'),
              fit: BoxFit.cover,
            ),
            automaticallyImplyLeading: false,
          ),
        ),
        body: TabBarView(
          children: items
              .map(
                (i) => i.title == 'Discovery'
                    ? getTimerBody()
                    : (i.title == 'Add'
                        ? Center(
                            child: getHelp(i.title),
                          )
                        : Center(
                            child: ListView(
                            children: getInfo(i.title),
                          ))),
              )
              .toList(growable: false),
        ),
        bottomNavigationBar: StyleProvider(
          style: Style(),
          child: ConvexAppBar(
            height: 50,
            top: -30,
            curveSize: 100,
            style: TabStyle.fixedCircle,
            items: [
              TabItem(icon: Icons.info),
              TabItem(icon: Icons.alarm),
              TabItem(icon: Icons.help),
            ],
          ),
        ),
      ),
    );
  }

  Widget builder() {
    return ConvexAppBar.builder(
      itemBuilder: _CustomBuilder(items),
      count: items.length,
    );
  }

  Container tabContent(TabItem data, Color color) {
    return Container(
        height: 50,
        padding: EdgeInsets.only(bottom: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(data.icon, color: color),
            Text(data.title, style: TextStyle(color: color))
          ],
        ));
  }

  List<Widget> getInfo(String title) {
    List<ExpansionTile> tabs = [
      _getExpansionTile(
          'Nasıl Kullanırım', 0, Icon(Icons.perm_device_information)),
      _getExpansionTile('İletişim', 1, Icon(Icons.contacts)),
      _getExpansionTile('Uygulama Hakkında', 2, Icon(Icons.computer)),
    ];
    return tabs;
  }

  Container getHelp(String title) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            width: 200,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: Colors.lightBlue,
              elevation: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.album, size: 70),
                    title: Text('Heart Shaker',
                        style: TextStyle(color: Colors.white)),
                    subtitle:
                        Text('TWICE', style: TextStyle(color: Colors.white)),
                  ),
                  ButtonTheme.bar(
                    child: ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('Edit',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {},
                        ),
                        FlatButton(
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AlertDialog(
            title: Center(
              child: Text(
                'Hatırlatma',
                style: Theme.of(context).textTheme.title,
              ),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Plak değişm zamanında hekiminiz ile fotoğraf paylaşmayı unutmayın !',
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
            contentPadding: EdgeInsets.all(60.0),
            shape: CircleBorder(),
          ),
        ],
      ),
    );
  }

  ExpansionTile _getExpansionTile(String title, int index, Icon incon) {
    final GlobalKey expansionTileKey = GlobalKey();
    double previousOffset;

    return ExpansionTile(
      key: expansionTileKey,
      onExpansionChanged: (isExpanded) {
        if (isExpanded) previousOffset = _scrollController.offset;
        _scrollToSelectedContent(
            isExpanded, previousOffset, index, expansionTileKey);
      },
      leading: incon,
      title: Text(title),
      children: <Widget>[
        title == 'İletişim'
            ? getContactCard()
            : (title == 'Uygulama Hakkında' ? getAbout() : getHowUse())
      ],
    );
  }

  Column getAbout() {
    return Column(
      children: <Widget>[
        ListTile(
          leading: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 40,
              minHeight: 40,
              maxWidth: 60,
              maxHeight: 60,
            ),
            child: Image.asset('assets/dental.png', fit: BoxFit.cover),
          ),
          title: const Text('Digiortho Hatırlatıcı'),
          subtitle: const Text(
              'Versiyon : 0.0.1\nYazılım Geliştirici: Kaan ÇEÇEN | mkcecen@gmail.com\nCopyright © 2020 Tüm Hakları Saklıdır.'),
        ),
      ],
    );
  }

  Column getContactCard() {
    return Column(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.map),
          title: const Text('Adres'),
          subtitle: const Text(
              'Halaskargazi Caddesi No 174/7 Aykaç Plaza\nŞişli-İstanbul'),
        ),
        ListTile(
          leading: const Icon(Icons.phone),
          title: const Text('Telefon'),
          subtitle: const Text('02122480740'),
        ),
        ListTile(
          leading: const Icon(Icons.mail),
          title: const Text('Mail'),
          subtitle: const Text('info@digiortho.com'),
        ),
      ],
    );
  }

  Column getHowUse() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(25, 5, 20, 15),
          child: Text(
              'Zamanlayıcıyı başlat butonu ile sayaç çalışmaya başlar ve her 15 günde bir sana hatırlatma gönderir.\n\nUnutma her hatırlatma sonrası sayacı tekrar başlatmalısın :)'),
        ),
      ],
    );
  }

  void _scrollToSelectedContent(
      bool isExpanded, double previousOffset, int index, GlobalKey myKey) {
    final keyContext = myKey.currentContext;

    if (keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox;
      _scrollController.animateTo(
          isExpanded ? (box.size.height * index) : previousOffset,
          duration: Duration(milliseconds: 500),
          curve: Curves.linear);
    }
  }

  Scaffold getTimerBody() {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.lightBlue[50],
                      height:
                          controller.value * MediaQuery.of(context).size.height,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: FractionalOffset.center,
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: Stack(
                                children: <Widget>[
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: CustomTimerPainter(
                                        animation: controller,
                                        backgroundColor: Colors.orange,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: FractionalOffset.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "\nPlak Değişimine Kalan",
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        AnimatedBuilder(
                                            animation: controller,
                                            builder: (context, child) {
                                              return FloatingActionButton
                                                  .extended(
                                                onPressed: () {
                                                  if (controller.isAnimating) {
                                                    confirmDialog(context)
                                                        .then((bool isRestart) {
                                                      _timerStartAndRestart(
                                                          false, false);
                                                    });

                                                    print('stop');
                                                  } else {
                                                    _timerStartAndRestart(
                                                        true, true);

                                                    controller.reverse(
                                                        from: controller
                                                                    .value ==
                                                                0.0
                                                            ? 1.0
                                                            : controller.value);
                                                  }
                                                },
                                                icon: Icon(
                                                    controller.isAnimating
                                                        ? Icons.refresh
                                                        : Icons.play_arrow),
                                                label: Text(
                                                  controller.isAnimating
                                                      ? "Tekrar Başlat"
                                                      : "Başlat",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            }),
                                        Text(
                                          timerString,
                                          style: TextStyle(
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  String get timerString {
    String lbl = "";
    Duration d = controller.duration * controller.value;

    String f(int n) {
      return n.toString().padLeft(2, '0');
    }

    d += Duration(microseconds: 999999);

    lbl =
        "${f(d.inDays)} gün ${f(d.inHours % 24)} saat \n        ${f(d.inMinutes % 60)}:${f(d.inSeconds % 60)}";

    return lbl;
  }

  Future<bool> confirmDialog(BuildContext context) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Yeniden başlatmak istediğinize emin misiniz ?'),
            actions: <Widget>[
              FlatButton(
                child: const Text('Evet'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              FlatButton(
                child: const Text('Hayır'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });
  }

  void _timerStartAndRestart(bool nowStart, bool isNowRun) async {
    isStart = nowStart;
    var s = controller.isAnimating;
    print('isStart $isStart');
    print('s=>  $s');
    if (controller.isAnimating) {
      confirmDialog(context).then((bool isRestart) {
        if (isRestart) {
          controller.reset();
        }
      });
    } else if (isStart && !controller.isAnimating) {
      controller.reverse(
          from: controller.value == 0.0 ? 1.0 : controller.value);
    }
    if (isNowRun) {
      print('saveToFile');
      isStart = true;
      alert = DateTime.now().add(Duration(days: 15));
      String value = isStart.toString() + ";" + alert.toString();
      FileUtils.saveToFile(value);
      _showNotification(alert);
    }
  }

  _showNotification(DateTime time) async {
    await singleNotification(
      time,
      'Plak Değişimi',
      'Plak değiştime zamanın geldi. WhatsApp üzerinden hekiminle fotoğraf paylaşmayı unutma :)',
      98123871,
    );
  }
}

class _CustomBuilder extends DelegateBuilder {
  final List<TabItem> items;

  _CustomBuilder(this.items);

  @override
  Widget build(BuildContext context, int index, bool active) {
    var navigationItem = items[index];
    var _color = active ? Colors.limeAccent : Colors.yellow;

    if (index == items.length ~/ 2) {
      return Container(
        width: 60,
        height: 60,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(shape: BoxShape.circle, color: _color),
        child: Icon(
          Icons.add,
          size: 40,
        ),
      );
    }
    var _icon = active
        ? navigationItem.activeIcon ?? navigationItem.icon
        : navigationItem.icon;
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(bottom: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(_icon, color: _color),
          Text(navigationItem.title, style: TextStyle(color: _color))
        ],
      ),
    );
  }

  @override
  bool fixed() {
    return true;
  }
}

class Style extends StyleHook {
  @override
  double get activeIconSize => 40;

  @override
  double get activeIconMargin => 10;

  @override
  double get iconSize => 25;

  @override
  TextStyle textStyle(Color color) {
    return TextStyle(fontSize: 20, color: color);
  }
}

Scaffold getTimerBody1() {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: Column(
        children: <Widget>[
          Column(children: <Widget>[
            NeuDigitalClock(),
            //NeuDigitalClock(),
          ]),
        ],
      ),
    ),
  );
}

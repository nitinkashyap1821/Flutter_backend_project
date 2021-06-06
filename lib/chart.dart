import 'dart:async';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:app_usage/app_usage.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class AppUsagePerDay {
  final String appName;
  final int usageTime;
  AppUsagePerDay(this.appName, this.usageTime);
}

class _MyHomePageState extends State<MyHomePage> {
  List<AppUsageInfo> _infos;
  List<String> _values;
  List list = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initUsage();
      getData();
    });
  }

  Future<void> initUsage() async {
    DateTime endDate = new DateTime.now();
    DateTime presentDate = new DateTime.now();
    DateTime startDate = DateTime(
        presentDate.year, presentDate.month, presentDate.day, 0, 0, 0, 1);

    try {
      List<AppUsageInfo> infoList =
          await AppUsage.getAppUsage(startDate, endDate);
      setState(() {
        _infos = infoList;
        _infos.sort((a, b) => b.usage.inSeconds.compareTo(a.usage.inSeconds));
      });
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }

  appNameProvider() async {
    for (var i = 0; i < _infos.length; i++) {
      Application apps = await DeviceApps.getApp(_infos[i].packageName);
      // Map<String, dynamic> _value = {
      //   "appName": apps.appName,
      //   "usage": _infos[i].usage.inMinutes,
      // };
      _values.add(apps.appName);
    }
    return _values;
  }
  getData() async {
    List x = await appNameProvider();
    setState(() {
      list = x;
    });
  }

  @override
  Widget build(BuildContext context) {

    var data = [
      AppUsagePerDay(list[0], _infos[1].usage.inMinutes),
      AppUsagePerDay(_infos[0].appName, _infos[0].usage.inMinutes),
    ];

    // var data = [
    //   AppUsagePerDay(_values[0]["appName"], _values[0]["usage"]),
    //   AppUsagePerDay(_values[1]["appName"], _values[1]["usage"]),
    // ];

    var series = [
      charts.Series(
        domainFn: (AppUsagePerDay appData, _) => appData.appName,
        measureFn: (AppUsagePerDay appData, _) => appData.usageTime,
        id: 'Apps',
        data: data,
      ),
    ];

    var chart = charts.BarChart(
      series,
      animate: true,
    );

    var chartWidget = Padding(
      padding: EdgeInsets.all(32.0),
      child: SizedBox(
        height: 400.0,
        child: chart,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text("Chart")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            chartWidget,
          ],
        ),
      ),
    );
  }
}

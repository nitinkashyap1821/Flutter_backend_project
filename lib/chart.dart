import 'package:charts_flutter/flutter.dart' as charts;
import 'package:app_usage/app_usage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chart Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class AppUsagePerDay {
  final String appName;
  final int usageTime;
  AppUsagePerDay(this.appName,this.usageTime);
}

class _MyHomePageState extends State<MyHomePage> {
  List<AppUsageInfo> _infos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initUsage();
    });
  }

  Future<void> initUsage() async {
    DateTime endDate = new DateTime.now();
    DateTime presentDate = new DateTime.now();
    DateTime startDate = DateTime(presentDate.year,presentDate.month,presentDate.day,0,0,0,1);

    try{
      List<AppUsageInfo> infoList = await AppUsage.getAppUsage(startDate, endDate);
      setState(() {
        _infos = infoList;
      });
    } on AppUsageException catch (exception) {print(exception);}
    _infos.sort((a,b) => b.usage.inSeconds.compareTo(a.usage.inSeconds));

  }

  @override
  Widget build(BuildContext context){

    var data = [
      AppUsagePerDay(_infos[0].appName, _infos[0].usage.inMinutes),
      AppUsagePerDay(_infos[1].appName, _infos[1].usage.inMinutes),
      AppUsagePerDay(_infos[2].appName, _infos[2].usage.inMinutes),
      AppUsagePerDay(_infos[3].appName, _infos[3].usage.inMinutes),
      AppUsagePerDay(_infos[4].appName, _infos[4].usage.inMinutes),
    ];

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
        height: 200.0,
        child: chart,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text("Chart")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[chartWidget,
          ],
        ),
      ),
    );
  }
}
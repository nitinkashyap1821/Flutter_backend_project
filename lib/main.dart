import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:devicetemperature/devicetemperature.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:x/services/geolocator_service.dart';
import 'package:light/light.dart';
import 'package:motion_sensors/motion_sensors.dart';
import 'package:battery/battery.dart';
//import 'package:usage_stats/usage_stats.dart';
//import 'package:device_apps/device_apps.dart';
import 'package:app_usage/app_usage.dart';



void main() => runApp(MaterialApp(
    home:Mapp(),
),
);

class Mapp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapState();
}

class _MapState extends State<Mapp> {


  final GeolocatorService geoService = GeolocatorService();
  final StreamController _stream1 = StreamController();
  final StreamController _stream2 = StreamController();
  final StreamController _stream3 = StreamController();
  final StreamController _stream4 = StreamController();
  final StreamController _stream5 = StreamController();
  final StreamController _stream6x = StreamController();
  final StreamController _stream6y = StreamController();
  final StreamController _stream6z = StreamController();
  final StreamController _stream7 = StreamController();
  final StreamController _streamYaw = StreamController();
  final StreamController _streampitch = StreamController();
  final StreamController _streamroll = StreamController();
  final StreamController _streamBattery = StreamController();
  Light _light = new Light();
  var _battery = Battery();

  File jsonFile;
  Directory dir;
  String fileName = "myFile.json";
  bool fileExists = false;
  int _luminance = 0;
  double _heading = 0;
  String get compass => _heading.toStringAsFixed(0) + '°';
  int get luminanceRead => _luminance;
  String _temp = "";
  List<Map<String, dynamic>> _values = List<Map<String, dynamic>>.empty(growable: true);
  double _x=0.0,_z=0.0,_y=0.0;
  double _yaw=0.0,_pitch=0.0,_roll=0.0;
  double get x => _x;double get y => _y;double get z => _z;
  double get yaw => _yaw;double get pitch => _pitch;double get roll => _roll;


  @override
  void initState() {
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      jsonFile.createSync();
      fileExists = jsonFile.existsSync();
    });

    Timer.periodic(Duration(seconds: 5), (timer) {initDeviceTemperature();});

    geoService.getCurrentLocation().listen((Position position) async {
      _stream1.sink.add(position.latitude.toString());
      _stream2.sink.add(position.longitude.toString());
      _stream3.sink.add(position.altitude.toString());

      FlutterCompass.events.listen(_onData);
      _stream5.sink.add(compass);

      _light.lightSensorStream.listen(_lightEvent);
      _stream4.sink.add(luminanceRead);
      _stream7.sink.add(_temp);

      motionSensors.userAccelerometer.listen(_accelerometerEvent);
      _stream6x.sink.add(x);
      _stream6y.sink.add(y);
      _stream6z.sink.add(z);

      _streamBattery.sink.add(await _battery.batteryLevel);
      int battery = await _battery.batteryLevel;

      motionSensors.absoluteOrientation.listen(_absoluteOrientationEvent);
      _streamYaw.sink.add(yaw);_streamroll.sink.add(roll);_streampitch.sink.add(pitch);

      writeToFile(
          position.latitude,
          position.longitude,
          position.altitude,
          position.speed,
          compass,
          x,y,z,yaw,pitch,roll,
          luminanceRead,
          _temp,
          battery);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _stream1.close();
    _stream2.close();
    _stream3.close();
    _stream4.close();
    _stream5.close();
    _stream6x.close();
    _stream6y.close();
    _stream6z.close();
    _stream7.close();
    _streamYaw.close();
    _streampitch.close();
    _streamroll.close();
    _streamBattery.close();
  }

  void _onData(double x) => setState(() { _heading = x; });
  void _lightEvent(int z) => setState(() {_luminance = z; });
  void _accelerometerEvent(UserAccelerometerEvent a){
    setState(() {
      _x = a.x;
      _y = a.y;
      _z = a.z;
    });
  }
  _absoluteOrientationEvent(AbsoluteOrientationEvent b){
    setState(() {
      _yaw = b.yaw;
      _pitch = b.pitch;
      _roll = b.roll;
    });
  }
  initDeviceTemperature() async {
    double g;
    try {
      g = await Devicetemperature.DeviceTemperature;
    } catch(e) {
      g = 0.0;
    }
    if (!mounted) return;
    setState(() {
      _temp = g.toString();
    });
  }

  Future<void> writeToFile(dynamic _lat, dynamic _lng,dynamic _alt,dynamic speed, dynamic compassReadout,dynamic xAxis,dynamic yAxis,dynamic zAxis,dynamic yaw,dynamic pitch,dynamic roll,dynamic lux,dynamic temp,dynamic batteryLevel) async {

    Map<String, dynamic> _value = {
      'LAT' : _lat,
      'LNG' : _lng,
      'ALT' : _alt,
      'SPEED' : speed,
      'TIME' : DateTime.now().microsecondsSinceEpoch,
      'DIRECTION' : compassReadout,
      'Accelerometer' : {'x':xAxis, 'y':yAxis, 'z':zAxis},
      'Orientation' : {'yaw' : yaw,'pitch':pitch,'roll':roll},
      'Lux' : lux,
      'temp' : temp,
      'battery': batteryLevel
    };
    if(_values.length>110){
      _values.clear();
    }
    else {
      _values.add(_value);
      jsonFile.writeAsStringSync(jsonEncode(_values), mode: FileMode.writeOnly);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title :Center(child:Text('Maps'),
        ),
      ),
      body: Container(
        child: Stack(
          children:[
            Center(
            child: ElevatedButton(
              child: Text("app list"),
                onPressed: () {
                Navigator.push(
                  context,
                MaterialPageRoute(builder: (context) => UsageScreen()),
                );
                },
            ),
            ),
            Container(
              child: StreamBuilder(
                stream: _streamBattery.stream,
                builder: (context, snapshot){
                  if(snapshot.hasError)
                    return Text("battery: - ");
                  return Align(alignment: Alignment(0,.3),
                    child:Text("battery:${snapshot.data}"),

                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder(
                stream: _stream1.stream,
                builder: (context, snapshot){
                  if(snapshot.hasError)
                    return Text("LAT: - ");
                  return Align(alignment: Alignment(0,.7),
                    child:Text("LAT:${snapshot.data}"),

                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder(
                stream: _stream2.stream,
                builder: (context, snapshot){
                  if(snapshot.hasError)
                    return Text("LNG: - ");
                  return Align(alignment: Alignment(0,.75),
                    child:Text("LNG:${snapshot.data}"),

                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder(
                stream: _stream3.stream,
                builder: (context, snapshot){
                  if(snapshot.hasError)
                    return Text("ALT: - ");
                  return Align(alignment: Alignment(0,.8),
                    child:Text("ALT:${snapshot.data}"),

                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder(
                stream: _stream4.stream,
                builder: (context, snapshot){
                  if(snapshot.hasError)
                    return Text("LUMEN: - ");
                  return Align(alignment: Alignment(0,.85),
                    child:Text("LUMEN:${snapshot.data}"),

                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder(
                stream: _stream5.stream,
                builder: (context, snapshot){
                  if(snapshot.hasError)
                    return Text("Compass: - ");
                  return Align(alignment: Alignment(0,.9),
                    child:Text("Compass:${snapshot.data}"),

                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder(
                stream: _stream6x.stream,
                builder: (context, snapshot){
                  if(snapshot.hasError)
                    return Text("x: - ");
                  return Align(alignment: Alignment(0,.55),
                    child:Text("x:${snapshot.data}"),

                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder(
                stream: _stream6y.stream,
                builder: (context, snapshot){
                  if(snapshot.hasError)
                    return Text("y: - ");
                  return Align(alignment: Alignment(0,.6),
                    child:Text("y:${snapshot.data}"),

                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder(
                stream: _stream6z.stream,
                builder: (context, snapshot){
                  if(snapshot.hasError)
                    return Text("z: - ");
                  return Align(alignment: Alignment(0,.65),
                    child:Text("z:${snapshot.data}"),

                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder(
                stream: _stream7.stream,
                builder: (context, snapshot){
                  if(snapshot.hasError)
                    return Text("temp: - ");
                  return Align(alignment: Alignment(0,.5),
                    child:Text("temp:${snapshot.data} °C"),

                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder(
                stream: _streamYaw.stream,
                builder: (context, snapshot){
                  if(snapshot.hasError)
                    return Text("yaw: - ");
                  return Align(alignment: Alignment(0,.45),
                    child:Text("yaw:${snapshot.data}"),

                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder(
                stream: _streampitch.stream,
                builder: (context, snapshot){
                  if(snapshot.hasError)
                    return Text("pitch: - ");
                  return Align(alignment: Alignment(0,.4),
                    child:Text("pitch:${snapshot.data}"),

                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder(
                stream: _streamroll.stream,
                builder: (context, snapshot){
                  if(snapshot.hasError)
                    return Text("roll: - ");
                  return Align(alignment: Alignment(0,.35),
                    child:Text("roll:${snapshot.data}"),

                  );
                },
              ),
            ),
          ],
        ),
      ),

    );
  }
}


class UsageScreen extends StatefulWidget {
  @override
  _UsageScreenState createState() => _UsageScreenState();
}

class _UsageScreenState extends State<UsageScreen> {
  //List<UsageInfo> events = [];
  //List installedApp = [];
  List<AppUsageInfo> _infos = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initUsage();
    });
  }

  Future<void> initUsage() async {
    //UsageStats.grantUsagePermission();
    try {
      DateTime endDate = new DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 1));
      List<AppUsageInfo> infoList = await AppUsage.getAppUsage(startDate, endDate);
      setState(() {
        _infos = infoList;
      });
    } on AppUsageException catch (exception) {
      print(exception);
    }

   /* List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);

     List apps =
    await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true,includeSystemApps: true);
    this.setState(() {
      events =usageStats.toList();
      installedApp = apps.toList();
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Usage Stats"),
        ),
        body: ListView.builder(
          itemCount: _infos.length,
          itemBuilder: (context, index) {
            return ListTile(
                title: Text(_infos[index].packageName),
                subtitle: Text(_infos[index].appName),
                trailing: Text(_infos[index].usage.toString()));
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: initUsage, child: Icon(Icons.refresh)),
    ),
    );
  }
}
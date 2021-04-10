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

class Mapp extends StatefulWidget {
  final Position initialPosition;
  Mapp(this.initialPosition);
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
  Light _light = new Light();

  File jsonFile;
  Directory dir;
  String fileName = "myFile.json";
  bool fileExists = false;
  int _luminance = 0;
  double _heading = 0;
  String get compass => _heading.toStringAsFixed(0) + '°';
  int get luminanceRead => _luminance;
  String _temp = "";
  UserAccelerometerEvent accelerometerEvent;
  List<Map<String, dynamic>> _values = List<Map<String, dynamic>>.empty(growable: true);


  @override
  void initState() {
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      jsonFile.createSync();
      fileExists = jsonFile.existsSync();
    });

    Timer.periodic(Duration(seconds: 5), (timer) {initDeviceTemperature();});

    geoService.getCurrentLocation().listen((Position position) {
    _stream1.sink.add(position.latitude.toString());
    _stream2.sink.add(position.longitude.toString());
    _stream3.sink.add(position.altitude.toString());

    FlutterCompass.events.listen(_onData);
    _stream5.sink.add(compass);

    _light.lightSensorStream.listen(_lightEvent);
    _stream4.sink.add(luminanceRead);

    _stream7.sink.add(_temp);

    motionSensors.userAccelerometer.listen((UserAccelerometerEvent accelerometerEvent) {
      _stream6x.sink.add(accelerometerEvent.x);
      _stream6y.sink.add(accelerometerEvent.y);
      _stream6z.sink.add(accelerometerEvent.z);


    writeToFile(
        position.latitude,
        position.longitude,
        position.altitude,
        position.speed,
        compass,
        accelerometerEvent,
        luminanceRead,
        _temp);
    });
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
  }

  void _onData(double x) => setState(() { _heading = x; });
  void _lightEvent(int z) => setState(() {_luminance = z; });
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

  Future<void> writeToFile(dynamic _lat, dynamic _lng,dynamic _alt,dynamic speed, dynamic compassReadout,dynamic accelerometerEvent,dynamic lux,dynamic temp) async {

    Map<String, dynamic> _value = {
      'LAT' : _lat,
      'LNG' : _lng,
      'ALT' : _alt,
      'SPEED' : speed,
      'TIME' : DateTime.now().microsecondsSinceEpoch,
      'DIRECTION' : compassReadout,
      'Accelerometer' : {'x':accelerometerEvent.x, 'y':accelerometerEvent.y, 'z':accelerometerEvent.z},
      'Lux' : lux,
      'temp' : temp
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
          ],
        ),
      ),
    );
  }
}
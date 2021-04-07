import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:x/services/geolocator_service.dart';
import 'package:sensors/sensors.dart';
import 'package:light/light.dart';

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
  Completer<GoogleMapController> _controller = Completer();
  Light _light = new Light();


  MapType _defaultMapType = MapType.normal;
  File jsonFile;
  Directory dir;
  String fileName = "myFile.json";
  bool fileExists = false;
  int _luminance = 0;
  double _heading = 0;
  String get compass => _heading.toStringAsFixed(0) + '°';
  int get luminanceRead => _luminance;
  List<Map<String, dynamic>> _values = List<Map<String, dynamic>>.empty(growable: true);


  @override
  void initState() {
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      jsonFile.createSync();
      fileExists = jsonFile.existsSync();
    });
    geoService.getCurrentLocation().listen((position){centerScreen(position);
    _stream1.sink.add(position.latitude.toString());
    _stream2.sink.add(position.longitude.toString());
    _stream3.sink.add(position.altitude.toString());
    FlutterCompass.events.listen(_onData);
    _light.lightSensorStream.listen(_lightEvent);
    _stream4.sink.add(luminanceRead);
    userAccelerometerEvents.listen((UserAccelerometerEvent accelerometerEvent) {
      writeToFile(
          position.latitude.toDouble(),
          position.longitude.toDouble(),
          position.altitude.toDouble(),
          position.speed.toDouble(),
          compass,
          accelerometerEvent,
          luminanceRead);
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
  }

  void _onData(double x) => setState(() { _heading = x; });
  void _lightEvent(int z) => setState(() {_luminance = z; });

  Future<void> writeToFile(dynamic _lat, dynamic _lng,dynamic _alt,dynamic speed, dynamic _compassreadout,dynamic accelerometerevent,dynamic lux) async {
    Map<String, dynamic> _value = {
      'LAT' : _lat,
      'LNG' : _lng,
      'ALT' : _alt,
      'SPEED' : speed,
      'TIME' : DateTime.now().microsecondsSinceEpoch,
      'DIRECTION' : _compassreadout,
      'Accelerometer' : {'x':accelerometerevent.x, 'y':accelerometerevent.y, 'z':accelerometerevent.z},
      'Lux' : lux
    };
    if(_values.length>110){
      _values.clear();
    }
    else {
      _values.add(_value);
      jsonFile.writeAsStringSync(jsonEncode(_values), mode: FileMode.writeOnly);
    }
  }

  void _changeMapType() {
    setState(() {
      _defaultMapType = _defaultMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
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
          children:[GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(widget.initialPosition.latitude,
                    widget.initialPosition.longitude),
                ),
            mapType: _defaultMapType,
            compassEnabled: true,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
            Container(
              margin: EdgeInsets.only(top: 620, right: 5),
              alignment: Alignment.topRight,
              child: Stack(
                children: [
                  FloatingActionButton(
                      child: Icon(Icons.layers),
                      mini: true,
                      backgroundColor: Colors.redAccent,
                      onPressed:_changeMapType,
                  )
                ],
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
          ],
        ),
      ),
    );
  }

  Future<void> centerScreen(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 17.5)));
  }
}
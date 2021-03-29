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




class Mapp extends StatefulWidget {
  final Position initialPosition;
  Mapp(this.initialPosition);
  @override
  State<StatefulWidget> createState() => _MapState();
}

class _MapState extends State<Mapp> {
  final GeolocatorService geoService = GeolocatorService();
  Completer<GoogleMapController> _controller = Completer();
  MapType _defaultMapType = MapType.normal;
  File jsonFile;
  Directory dir;
  String fileName = "myFile.json";
  bool fileExists = false;
  double _heading = 0;
  String get _compassreading => _heading.toStringAsFixed(0) + '°';
  List<Map<String, dynamic>> _values = List<Map<String, dynamic>>.empty(growable: true);

  @override
  void initState() {
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      jsonFile.createSync();
      fileExists = jsonFile.existsSync();
    });
    geoService.getCurrentLocation().listen((position) {centerScreen(position);
    FlutterCompass.events.listen(_onData);
    userAccelerometerEvents.listen((UserAccelerometerEvent accelerometerevent){
    writeToFile(position.latitude.toDouble(),position.longitude.toDouble(),position.altitude.toDouble(),position.speed.toDouble(),_compassreading,accelerometerevent);
    });
    });
    super.initState();
  }

  void _onData(double x) => setState(() { _heading = x; });

  void writeToFile(dynamic _lat, dynamic _lng,dynamic _alt,dynamic speed, dynamic _compassreading,dynamic accelerometerevent) {
    Map<String, dynamic> _value = {
      'LAT' : _lat,
      'LNG' : _lng,
      'ALT' : _alt,
      'SPEED' : speed,
      'TIME' : DateTime.now().microsecondsSinceEpoch,
      'DIRECTION' : _compassreading,
      'Accelerometer' : {'x':accelerometerevent.x, 'y':accelerometerevent.y, 'z':accelerometerevent.z}
    };
    _values.add(_value);
    jsonFile.writeAsStringSync(jsonEncode(_values),mode: FileMode.writeOnly);
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
                zoom: 17.5),
            mapType: _defaultMapType,
            compassEnabled: true,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
            Container(
              margin: EdgeInsets.only(top: 80, right: 10),
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  FloatingActionButton(
                      child: Icon(Icons.layers),
                      elevation: 10,
                      backgroundColor: Colors.blue,
                      onPressed:_changeMapType
                  ),
                ],
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
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:x/services/geolocator_service.dart';

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

  @override
  void initState() {
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      jsonFile.createSync();
      fileExists = jsonFile.existsSync();
    });
    geoService.getCurrentLocation().listen((position) {centerScreen(position);
    writeToFile('LAT', position.latitude.toString(),'LNG',position.longitude.toString());

    });

    super.initState();
  }


  void writeToFile(String key1, dynamic value1,String key2, dynamic value2) {
    var timeNow = DateTime.now().microsecondsSinceEpoch;
    print(timeNow);
    print("Writing to file!");
    Map<String, dynamic> content = new Map();
    var content1 = {key1: value1};
    var content2 = {key2: value2};
    var content3 = {"Time": timeNow};
    if (fileExists) {
      print("File exists");
      content.addAll(content1);
      content.addAll(content2);
      content.addAll(content3);
      print(content);
      jsonFile.writeAsStringSync(json.encode(content),mode: FileMode.append);
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
              zoom: 13.0),
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
        target: LatLng(position.latitude, position.longitude), zoom: 18.0)));
  }
}
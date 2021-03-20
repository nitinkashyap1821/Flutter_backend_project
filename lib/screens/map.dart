import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:x/services/geolocator_service.dart';
import 'package:x/jsonFiles/jsonFile.dart';

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
  final Json json = Json();

  @override
  void initState() {
    geoService.getCurrentLocation().listen((position) {
      centerScreen(position);
      json.save("LAT",position.latitude.toString(),"LNG",position.longitude.toString());


    });
    super.initState();

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
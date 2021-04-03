import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:x/services/geolocator_service.dart';
import 'package:provider/provider.dart';
import './screens/map.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final geoService = GeolocatorService();
  @override
  Widget build(BuildContext context) {
    return FutureProvider(
      create: (context) => geoService.getInitialLocation(),
      initialData: null,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: Consumer<Position>(
          builder: (context, position, widget) {
            return (position != null)
                ? Mapp(position)
                : Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
import 'package:geolocator/geolocator.dart';
import 'package:x/jsonFiles/jsonFile.dart';

class GeolocatorService {

final Json json = Json();


  Stream<Position> getCurrentLocation(){

    return Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation,forceAndroidLocationManager: true,intervalDuration: Duration(seconds: 5));
  }

  Future<Position> getInitialLocation() async {
    Position position= await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high,forceAndroidLocationManager: true);

    return position;
  }


}
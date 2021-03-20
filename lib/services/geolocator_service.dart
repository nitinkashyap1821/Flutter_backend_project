
import 'package:geolocator/geolocator.dart';

class GeolocatorService {


  Stream<Position> getCurrentLocation(){

    return Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation,forceAndroidLocationManager: false,intervalDuration: Duration(seconds: 5));
  }

  Future<Position> getInitialLocation()async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high,forceAndroidLocationManager: false);
    return position;
  }


}
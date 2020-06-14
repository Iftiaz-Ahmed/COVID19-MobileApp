import 'dart:async';

import 'package:Covid19/datamodels/user_location.dart';
import 'package:location/location.dart';

import '../mysql.dart';

class LocationService{
  //keep track of current location
  UserLocation _currentLocation;

  var location = Location();
  //Continuously emit location updates
  StreamController<UserLocation> _locationController = StreamController<UserLocation>.broadcast();

  LocationService() {
    location.requestPermission().then((granted) {
      if (granted != null) {                                // null added
        location.onLocationChanged.listen((locationData){   //() removed
          if(locationData != null) {
            _locationController.add(UserLocation(
                latitude: locationData.latitude,
                longitude: locationData.longitude,
                altitude: locationData.altitude,
            ));
          }
        });
      }
    });
  }

  Stream<UserLocation> get locationStream => _locationController.stream;

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
        altitude: userLocation.altitude,
      );
    } catch(e) {
      print("Could not trace location $e");
    }
    _saveData(_currentLocation);
    return _currentLocation;
  }
  var db = Mysql();
  Future _saveData(UserLocation currentLocation) async{
    db.getConnection().then((conn) {
      print("here");
      String sql = "'Insert into user_locations (u_id, longitude, latitude, altitude) values (?, ?, ?, ?)', [14, '${currentLocation?.longitude}', '${currentLocation?.latitude}', '${currentLocation?.altitude}']";
      conn.query(sql);
    });
  }
}

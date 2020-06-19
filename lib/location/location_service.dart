import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Covid19/datamodels/user_location.dart';
import 'package:location/location.dart';

import '../mysql.dart';

class LocationService{
  //keep track of current location
  UserLocation _currentLocation;
  int _id;
  var location = Location();
  //Continuously emit location updates
  StreamController<UserLocation> _locationController = StreamController<UserLocation>.broadcast();
  double _longtemp = 999.99;
  double _lattemp = 999.99;
  double _alttemp = 999.99;
  double _long = 999.99;
  double _lat = 999.99;
  double _alt = 999.99;

  LocationService() {
    Timer.run(() {
      _getData();
    });

    location.requestPermission().then((granted) {
      if (granted != null) {
        location.onLocationChanged.listen((locationData){
          if(locationData != null) {
            _locationController.add(UserLocation(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
              altitude: locationData.altitude,
            ));
            _long = locationData.longitude;
            _lat = locationData.latitude;
            _alt = locationData.altitude;
          }
        });
        Timer.periodic(Duration(minutes: 5), (timer) {
          _saveData();
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
    return _currentLocation;
  }
  var db = Mysql();
  Future _saveData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id = prefs.getInt('userID');
    _getData();
    print("DB long: $_longtemp\nDB lat: $_lattemp\nDB alt: $_alttemp\n");
    print("long: $_long\nlat: $_lat\nalt: $_alt\n");
    if(_long != _longtemp || _lat != _lattemp || _alt != _alttemp) {
      db.getConnection().then((conn) {
        print("here");
        String sql = "Insert into user_locations (u_id, longitude, latitude, altitude, checksum) values ('$_id', '$_long', '$_lat', '$_alt', '$_id')";
        conn.query(sql);
      });
    } else {
      print("Same location, data not saved");
    }
  }

  Future _getData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id = prefs.getInt('userID');
    db.getConnection().then((conn) {
      print("get here");
      var l = 1;
      String sql = "SELECT * FROM `user_locations` WHERE u_id=$_id Order by serial DESC limit $l";
      conn.query(sql).then((results) {
        for (var row in results) {
          _longtemp = row[2];
          _lattemp = row[3];
          _alttemp = row[4];
        }
      });
    });
  }

}

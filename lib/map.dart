import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'datamodels/user_location.dart';
import 'mysql.dart';
import 'package:flutter/services.dart' show rootBundle;


class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  var db = new Mysql();
  String _mapStyle;
  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor affectedIcon;
  BitmapDescriptor closeContactIcon;
  Set<Marker> markers = Set();

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController controller;
  var tempTarget;

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  void setCustomMapPin() async {

    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/current.png');

    affectedIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/affected.png');

    closeContactIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/close_contact.png');

  }


  @override
  Widget build(BuildContext context) {
    var userLocation = Provider.of<UserLocation>(context);
    var target;

    setState(() {
      target = LatLng(userLocation?.latitude, userLocation?.longitude);
      getBoundBox(userLocation, controller);

      if (tempTarget == null) {
        // ignore: unnecessary_statements
        tempTarget == target;
      }

      if(target!=tempTarget){
        tempTarget = target;
        centerScreen(userLocation);
      }

      Marker resultMarker = new Marker(
        markerId: MarkerId('myPos'),
        position: LatLng(userLocation?.latitude, userLocation?.longitude),
        icon: pinLocationIcon,
          infoWindow: InfoWindow(
            title: "I'm here!",
          )
      );
      markers.add(resultMarker);

    });

    return new Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: target,
            zoom: 17.0,
            tilt: 45,
          ),
          markers: markers,
          buildingsEnabled: true,
          onMapCreated: (GoogleMapController controller) async{
            _controller.complete(controller);
            this.controller = controller;
            this.controller.setMapStyle(_mapStyle);
          },
          mapType: MapType.normal,
        ),
      ),
    );
  }


  //changing map center dynamically
  Future<void> centerScreen(UserLocation position) async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 17.0,
        tilt: 45,
        bearing: 45
    )));
  }

  var northLatInc = 0.0;
  var northLatDec = 0.0;
  var northLngInc = 0.0;
  var northLngDec = 0.0;

  Future<void> getBoundBox(userLocation, controller) async {
    LatLngBounds latLngBounds = await controller.getVisibleRegion();

    if (latLngBounds.northeast.latitude >= northLatInc || latLngBounds.northeast.latitude <= northLatDec || latLngBounds.northeast.longitude >= northLngInc || latLngBounds.northeast.longitude <= northLngDec){
      print(latLngBounds.northeast.latitude);
      northLatInc = latLngBounds.northeast.latitude + 0.001;
      northLatDec = latLngBounds.northeast.latitude - 0.001;
      northLngInc = latLngBounds.northeast.longitude + 0.001;
      northLngDec = latLngBounds.northeast.longitude - 0.001;
      markers = {};  //clearing markers for new retrieved ones
      _getAffectedLoc(latLngBounds.northeast.latitude,latLngBounds.southwest.latitude,latLngBounds.northeast.longitude,latLngBounds.southwest.longitude);
      _getCloseContact(latLngBounds.northeast.latitude,latLngBounds.southwest.latitude,latLngBounds.northeast.longitude,latLngBounds.southwest.longitude);
    }
  }

  Future _getAffectedLoc(maxLat, minLat, maxLng, minLng) async{
    print("getting affected data");
    maxLng = maxLng + 0.002;
    maxLat = maxLat + 0.002;
    minLng = minLng - 0.002;
    minLat = minLat - 0.002;

    db.getConnection().then((conn) async{
      String sql = "SELECT latitude, longitude, date_time from user_locations where serial in (SELECT serial from user_locations WHERE u_id in (SELECT u_id from user_status where u_status=2) and serial in (SELECT max(serial) from user_locations group by u_id) GROUP by u_id) and latitude BETWEEN $minLat and $maxLat and longitude BETWEEN $minLng and $maxLng";
      conn.query(sql).then((results) {
        var i=0;
        var affLat = new List();
        var affLng = new List();
        for (var row in results) {
          setState(() {
            affLat.add(row[0]);
            affLng.add(row[1]);
            print("latlng retrieved");
            print(row[0]);
            print(row[1]);
          });
          i++;
        }
        i--;

        setState(() {
          while(i>-1) {
            Marker affMarker = new Marker(
              markerId: MarkerId("$i"),
              position: LatLng(affLat[i], affLng[i]),
              icon: affectedIcon,
            );
            print("marker $i added");
            markers.add(affMarker);
            i--;
          }
        });
      });
    });
  }

  Future _getCloseContact(maxLat, minLat, maxLng, minLng) async{
    print("getting close contact data");
    maxLng = maxLng + 0.002;
    maxLat = maxLat + 0.002;
    minLng = minLng - 0.002;
    minLat = minLat - 0.002;

    db.getConnection().then((conn) async{
      String sql = "SELECT latitude, longitude, date_time from user_locations where serial in (SELECT serial from user_locations WHERE u_id in (SELECT u_id from user_status where u_status=3) and serial in (SELECT max(serial) from user_locations group by u_id) GROUP by u_id) and latitude BETWEEN $minLat and $maxLat and longitude BETWEEN $minLng and $maxLng";
      conn.query(sql).then((results) {
        var i=0;
        var affLat = new List();
        var affLng = new List();
        for (var row in results) {
          setState(() {
            affLat.add(row[0]);
            affLng.add(row[1]);
            print("latlng of CC retrieved");
            print(row[0]);
            print(row[1]);
          });
          i++;
        }
        i--;

        setState(() {
          while(i>-1) {
            Marker affMarker = new Marker(
              markerId: MarkerId("C$i"),
              position: LatLng(affLat[i], affLng[i]),
              icon: closeContactIcon,
            );
            print("marker C$i added");
            markers.add(affMarker);
            i--;
          }
        });
      });
    });
  }
}

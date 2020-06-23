import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'datamodels/user_location.dart';
import 'mysql.dart';
import 'package:Covid19/globals.dart' as globals;


class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  var db = new Mysql();
  var affLat = new List();
  var affLng = new List();
  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor affectedIcon;
  Set<Marker> markers = Set();

  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
  }

  void setCustomMapPin() async {

    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/current.png');

    affectedIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/affected.png');

  }


  @override
  Widget build(BuildContext context) {
    var userLocation = Provider.of<UserLocation>(context);
    var target;

    setState(() {
      target = LatLng(userLocation?.latitude, userLocation?.longitude);
      centerScreen(userLocation);
      Marker resultMarker = new Marker(
        markerId: MarkerId('myPos'),
        position: LatLng(userLocation?.latitude, userLocation?.longitude),
        icon: pinLocationIcon,
      );
      //.icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN))
      markers.add(resultMarker);

    });

    return new Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: target,
            zoom: 15.0,
          ),
          markers: markers,
          onMapCreated: (GoogleMapController controller) async{
            _controller.complete(controller);
            getScreenBound(controller);
          },

        ),
      ),
    );
  }

  Future<void> getScreenBound(controller) async {
    LatLngBounds latLngBounds = await controller.getVisibleRegion();
    print(latLngBounds);
    _getAffectedLoc(latLngBounds.northeast.latitude,latLngBounds.southwest.latitude,latLngBounds.northeast.longitude,latLngBounds.southwest.longitude);
  }

  //changing map center dynamically
  Future<void> centerScreen(UserLocation position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15.0
    )));
  }

  Future _getAffectedLoc(maxLat, minLat, maxLng, minLng) async{
    print(".....");
    print(maxLat);
    print(minLat);
    print(maxLng);
    print(minLng);
    print(".....");
    db.getConnection().then((conn) {
      String sql = "SELECT latitude, longitude from user_locations where serial in (SELECT serial from user_locations WHERE u_id in (SELECT u_id from user_status where u_status=2) and serial in (SELECT max(serial) from user_locations group by u_id) GROUP by u_id) and latitude BETWEEN $minLat and $maxLat and longitude BETWEEN $minLng and $maxLng";
      conn.query(sql).then((results) {
        var i=0;
        for (var row in results) {
          setState(() {
            affLat.add(row[0]);
            affLng.add(row[1]);
            print("latlng of ");
            print(row[0]);
            print(row[1]);
          });
          i++;
        }
        i--;

        var affMarker = new List();
        setState(() {
          while(i>-1) {
            Marker affMarker = Marker(
              markerId: MarkerId("$i"),
              position: LatLng(affLat[i], affLng[i]),
              icon: affectedIcon,
            );
            markers.add(affMarker);
            i--;
          }
        });
      });
    });
  }
}

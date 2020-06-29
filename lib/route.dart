import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'datamodels/user_location.dart';
import 'location/direction_request.dart';
import 'package:Covid19/globals.dart' as globals;

import 'mysql.dart';


class RoutePage extends StatefulWidget {
  @override
  State<RoutePage> createState() => RoutePageState();
}

class RoutePageState extends State<RoutePage> {
  var db = new Mysql();
  String _mapStyle;
  bool loading = true;
  Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  Set<Polyline> get polyLines => _polyLines;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController controller;
  static LatLng locTarget;
  LocationData currentLocation;
  final place = TextEditingController();
  BitmapDescriptor affectedIcon;
  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor closeContactIcon;
  var routeAffectedPersonCounter = 0;
  var routeCloseContactPersonCounter = 0;
  var tempLat;
  var tempLng;
  var tempLat2;
  var tempLng2;

  List directionLatLng = List();
  List locationPointLat = List();
  List locationPointLng = List();

  void initState() {
    super.initState();
    setCustomMapPin();
    rootBundle.loadString('assets/route_map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  void setCustomMapPin() async {

    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/user.png');

    affectedIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/affected.png');

    closeContactIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/close_contact.png');
  }

  Future getAffectedData(List lat, List lng) async {
    db.getConnection().then((conn) {
      var x = 0;
      routeAffectedPersonCounter = 0;
      routeCloseContactPersonCounter = 0;
      while(x < lat.length) {
        //    creating a boundingBox for each point within 25m radius
        var maxLat = lat[x] + 0.00025;
        var minLat = lat[x] - 0.00025;
        var maxLng = lng[x] + 0.00025;
        var minLng = lng[x] - 0.00025;
        setAffectedMarker(maxLat,minLat,maxLng,minLng,conn,x);
        setCloseContactMarker(maxLat,minLat,maxLng,minLng,conn,x);
        x++;
      }
    });
  }

  void setAffectedMarker(maxLat,minLat,maxLng,minLng,conn,pointNo){
    var affLat = new List();
    var affLng = new List();
    String sql = "SELECT latitude, longitude, date_time from user_locations where serial in (SELECT serial from user_locations WHERE u_id in (SELECT u_id from user_status where u_status=2) and serial in (SELECT max(serial) from user_locations group by u_id) GROUP by u_id) and latitude BETWEEN $minLat and $maxLat and longitude BETWEEN $minLng and $maxLng";
    conn.query(sql).then((results) {
      for (var row in results) {
        setState(() {
          affLat.add(row[0]);
          affLng.add(row[1]);
          if(tempLat == null && tempLng == null) {
            tempLng = row[1];
            tempLat = row[0];
            routeAffectedPersonCounter++;
          }

          if(tempLat == row[0] && tempLng == row[1]) {
            //do nothing
          } else {
            print(tempLng);
            print(tempLat);
            routeAffectedPersonCounter++;
            tempLng = row[1];
            tempLat = row[0];
            print(routeAffectedPersonCounter);
          }
        });
      }

      setState(() {
        for (var i=0; i<affLng.length; i++) {
          Marker affMarker = new Marker(
            markerId: MarkerId("$pointNo$i"),
            position: LatLng(affLat[i], affLng[i]),
            icon: affectedIcon,
          );
          print("marker $pointNo$i added");
          _markers.add(affMarker);
        }
      });
    });
  }

  void setCloseContactMarker(maxLat,minLat,maxLng,minLng,conn,pointNo){
    var affLat = new List();
    var affLng = new List();
    String sql = "SELECT latitude, longitude, date_time from user_locations where serial in (SELECT serial from user_locations WHERE u_id in (SELECT u_id from user_status where u_status=3) and serial in (SELECT max(serial) from user_locations group by u_id) GROUP by u_id) and latitude BETWEEN $minLat and $maxLat and longitude BETWEEN $minLng and $maxLng";
    conn.query(sql).then((results) {
      for (var row in results) {
        setState(() {
          affLat.add(row[0]);
          affLng.add(row[1]);
          if(tempLat2 == null && tempLng2 == null) {
            tempLng2 = row[1];
            tempLat2 = row[0];
            routeCloseContactPersonCounter++;
          }

          if(tempLat2 == row[0] && tempLng2 == row[1]) {
            //do nothing
          } else {
            print(tempLng2);
            print(tempLat2);
            routeCloseContactPersonCounter++;
            tempLng2 = row[1];
            tempLat2 = row[0];
            print(routeCloseContactPersonCounter);
          }
        });
      }

      setState(() {
        for (var i=0; i<affLng.length; i++) {
          Marker affMarker = new Marker(
            markerId: MarkerId("C$pointNo$i"),
            position: LatLng(affLat[i], affLng[i]),
            icon: closeContactIcon,
          );
          print("marker C$pointNo$i added");
          _markers.add(affMarker);
        }
      });
    });
  }


  void onCameraMove(CameraPosition position) {
    locTarget = position.target;
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
        locationPointLat.add(points[i - 1]);
        locationPointLng.add(points[i]);
      }
    }
    return result;
  }

  void sendRequest(double lat, double lng, String placeName) async {
    LatLng destination = LatLng(lat, lng);

    String route = await _googleMapsServices.getRouteCoordinates(
        locTarget, destination);
    createRoute(route);
    _addMarker(destination, placeName);
    getAffectedData(locationPointLat, locationPointLng);
  }

  void createRoute(String encondedPoly) {
    _polyLines.add(Polyline(
        polylineId: PolylineId(locTarget.toString()),
        width: 8,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.green));
  }

  void _addMarker(LatLng location, String address) {
    _markers.add(Marker(
        markerId: MarkerId("112"),
        position: location,
        infoWindow: InfoWindow(title: address, snippet: "2"),
        icon: BitmapDescriptor.defaultMarker));
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    for (var i = 2; i < lList.length; i++){
      lList[i] += lList[i - 2];
    }

    return lList;
  }


  @override
  Widget build(BuildContext context) {
//    print("getLocation111:$latLng");
    var userLocation = Provider.of<UserLocation>(context);

    setState(() {
      locTarget = LatLng(userLocation?.latitude, userLocation?.longitude);
      Marker resultMarker = new Marker(
          markerId: MarkerId('myPos'),
          position: locTarget,
          icon: pinLocationIcon,
          infoWindow: InfoWindow(
            title: "I'm here!",
          )
      );
      _markers.add(resultMarker);
    });

    return Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                markers: _markers,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: locTarget,
                  zoom: 19,
                  tilt: 60,
                ),
                onCameraMove:  onCameraMove,
                polylines: polyLines,
                myLocationEnabled: true,
                liteModeEnabled: false,
                myLocationButtonEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  this.controller = controller;
                  this.controller.setMapStyle(_mapStyle);
                },
              ),
            ),

            Padding(
                padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Stack(
                  children: <Widget>[

                    TextFormField(
                      onTap: () async {
                        Prediction p = await PlacesAutocomplete.show(
                            context: context,
                            apiKey: "AIzaSyBWi73AXGHHu3EfXuJRha_MhHGbaOjLI6I",
                            language: "en",
                            components: [
                              Component(Component.country, "bd")
                            ]
                        );
                        if (p != null) {
                            place.text = p.description;
                        }
                      },
                      textAlign: TextAlign.center,
                      controller: place,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.grey[500])
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.grey[400])
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Where you want to go?",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.grey[600],
                          )
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(left: 15, top: 17),
                      width: 30,
                      height: 30,
                      color: Colors.white,
                      child: Icon(
                        Icons.local_taxi,
                        color: Colors.black,
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(left: 320, top: 8),
                      width: 40,
                      height: 40,
                      color: Colors.white,
                      child: IconButton(
                        icon: Icon(Icons.search),
                        iconSize: 30.0,
                        color: Colors.black87,
                        onPressed: () async {
                          List coord = new List();
                          coord = await _googleMapsServices.getLatlng(place.text);
                          setState(() {
//                          resetting the lists
                            _markers = {};
                            locationPointLat = [];
                            locationPointLng = [];
                            sendRequest(coord[0], coord[1], place.text);
                            globals.polyLines = polyLines;
                          });
                        },
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 200,
                      color: Colors.white70,
                      margin: EdgeInsets.only(top: 70, left: 240),
                      padding: EdgeInsets.only(right: 10, top: 5),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Affected: $routeAffectedPersonCounter',
                            style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                            ),

                          ),
                          SizedBox(height: 5,),
                          Text(
                            'Close Contacts: $routeCloseContactPersonCounter',
                            style: TextStyle(
                                color: Colors.amber[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 14
                            ),

                          ),
                        ],
                      )
                    )
                  ],
                )
            ),
          ],
        )
    );
  }
}


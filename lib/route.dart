import 'dart:async';
import 'package:flutter/material.dart';
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
  bool loading = true;
  Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  Set<Polyline> get polyLines => _polyLines;
  Completer<GoogleMapController> _controller = Completer();
  static LatLng locTarget;
  LocationData currentLocation;
  final place = TextEditingController();
  BitmapDescriptor affectedIcon;
  var routeAffectedPersonCounter = 0;
  var tempLat;
  var tempLng;

  List directionLatLng = List();
  List locationPointLat = List();
  List locationPointLng = List();

  void initState() {
    super.initState();
    setCustomMapPin();
  }

  void setCustomMapPin() async {
    affectedIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/affected.png');
  }

  Future getAffectedData(List lat, List lng) async {
    db.getConnection().then((conn) {
      var x = 0;
      routeAffectedPersonCounter = 0;
      while(x < lat.length) {
        //    creating a boundingBox for each point within 50m radius
        var maxLat = lat[x] + 0.0005;
        var minLat = lat[x] - 0.0005;
        var maxLng = lng[x] + 0.0005;
        var minLng = lng[x] - 0.0005;
        setAffectedMarker(maxLat,minLat,maxLng,minLng,conn,x);
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
        color: Colors.teal));
  }

  void _addMarker(LatLng location, String address) {
    _markers.add(Marker(
        markerId: MarkerId("112"),
        position: location,
        infoWindow: InfoWindow(title: address,),
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
                myLocationButtonEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
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
                      margin: EdgeInsets.only(left: 30, top: 17),
                      width: 10,
                      height: 10,
                      child: Icon(
                        Icons.local_taxi,
                        color: Colors.black,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(left: 310, top: 8),
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
                    )
                  ],
                )
            ),
          ],
        )
    );
  }
}


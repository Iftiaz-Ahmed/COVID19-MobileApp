import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'datamodels/user_location.dart';
import 'mysql.dart';


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
  @override
  void initState() {
    super.initState();
    setCustomMapPin();
    _getAffectedLoc();
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

    setState(() {
      Marker resultMarker = Marker(
        markerId: MarkerId('myPos'),
        position: LatLng(userLocation?.latitude, userLocation?.longitude),
        icon: pinLocationIcon,
      );
      //.icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN))
      markers.add(resultMarker);
    });

    return new Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(userLocation?.latitude, userLocation?.longitude),
          zoom: 17.0,
        ),
        markers: markers,
      ),
    );
  }

  Future _getAffectedLoc() async{
    db.getConnection().then((conn) {
      String sql = "Select latitude, longitude from user_locations INNER JOIN user_status ON user_status.u_id=user_locations.u_id WHERE u_status=2 Group by checksum order by serial DESC";
      conn.query(sql).then((results) {
        var i=0;
        for (var row in results) {
          setState(() {
            affLat.add(row[0]);
            affLng.add(row[1]);
          });
          i++;
        }
        i--;
        print(affLng[1]);
        print(affLat[1]);
        var affMarker = new List();
        setState(() {
          while(i>-1) {
            print("$i");
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

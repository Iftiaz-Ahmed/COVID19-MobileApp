import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
const apiKey = "your api key";

class GoogleMapsServices{
  Future<String> getRouteCoordinates(LatLng l1, LatLng l2)async{
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$apiKey&sensor=false&alternatives=true";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    print("====================>>>>>>>>$values");

    return values["routes"][0]["overview_polyline"]["points"];
  }

  Future<List<dynamic>> getLatlng(String address)async{
    String url = "https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    List coord = new List();
    double _lat = values["results"][0]["geometry"]["location"]["lat"];
    double _lng = values["results"][0]["geometry"]["location"]["lng"];
    coord.add(_lat);
    coord.add(_lng);
    return coord;
  }

}
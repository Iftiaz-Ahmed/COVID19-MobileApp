import 'package:Covid19/datamodels/user_location.dart';
import 'package:Covid19/login/login.dart';
import 'package:Covid19/profile.dart';
import 'package:Covid19/home.dart';
import 'package:Covid19/route.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Covid19/map.dart';
import 'package:provider/provider.dart';
import 'StatsPage.dart';
import 'datamodels/user_location.dart';
import 'location/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Covid19/globals.dart' as globals;

//void main() => runApp(MyApp());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  globals.temp = prefs.getInt('userID');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  void initState(){
    checkLoginStatus();
  }
  Future<void> checkLoginStatus() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
  }

  static const String _title = 'Covid19 Around Us';
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocation>(
      create: (BuildContext context) => LocationService().locationStream,
      child: MaterialApp(
        title: _title,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.cyan,
        ),
        home: globals.temp == null ? LoginScreen() : Home()
      ),
    );
  }
}

class Home extends StatefulWidget {
  final FirebaseUser user;

  Home({this.user});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int pageIndex = 0;
  final MapPage _mappage = new MapPage();
  final HomePage _homepage = new HomePage();
  final RoutePage _routepage = new RoutePage();
  final StatPage _statpage = new StatPage();

  Widget _showPage = new MapPage();

  Widget _pageChooser(int page) {
    switch (page) {
      case 0:
        return _mappage;
        break;
      case 1:
        return _homepage;
        break;
      case 2:
        return _statpage;
        break;
      case 3:
        return _routepage;
        break;
      default:
        return new Container(
          child: new Center(
            child: new Text(
              'No page found',
              style: TextStyle(
                color: Colors.red,
                fontSize: 30.0
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Covid19 Around Us'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.account_circle),
                  iconSize: 35.0,
                  color: Colors.black87,
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                )
              ],
            ),

            bottomNavigationBar: CurvedNavigationBar(
                color: Colors.cyan,
                backgroundColor: Colors.cyan,
                buttonBackgroundColor: Colors.cyan,
                height: 50.0,
                items: <Widget>[
                    Icon(Icons.map, size: 30, color: Colors.white,),
                    Icon(Icons.home, size: 30, color: Colors.white,),
                    Icon(Icons.assessment, size: 30, color: Colors.white,),
                    Icon(Icons.directions_car, size: 30, color: Colors.white,),
                ],
                animationDuration: Duration(
                  milliseconds: 300
                ),
                animationCurve: Curves.easeInOut,
                index: 0,
                onTap: (int tappedIndex){
                  setState(() {
                    _showPage = _pageChooser(tappedIndex);
                  });
                },
            ),
          body: Container(
            child: Center(
              child: _showPage,
            ),
          )
        ),
      );
  }
}










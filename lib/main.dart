import 'package:Covid19/home.dart';
import 'package:Covid19/route.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Covid19/map.dart';
import 'StatePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const String _title = 'Covid19 Around Us';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
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
      return Scaffold(
          appBar: AppBar(
            title: Text('Covid19 Around Us'),
          ),

          bottomNavigationBar: CurvedNavigationBar(
              color: Colors.cyan,
              backgroundColor: Colors.white,
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
          color: Colors.white,
          child: Center(
            child: _showPage,
          ),
        )
      );
  }
}










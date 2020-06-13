import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'mysql.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({ Key key }) : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  var db = new Mysql();
  var name = '';
  var email = '';
  var _uid = '';

  final uidCon = new TextEditingController();

  void _getData(String id){
    db.getConnection().then((conn) {
      String sql = "SELECT * FROM `users` WHERE u_id = $id";
      conn.query(sql).then((results) {
        for (var row in results) {
          setState(() {
            name = row[0];
            email = row[1];
          });
          print(name + "->" + email);
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'User ID: ' + _uid,
              style: (TextStyle(fontSize: 20.0, color: Colors.red)),
            ),
            Text(
              'Name: ' + name,
              style: (TextStyle(fontSize: 30.0)),
            ),
            Text(
              email + "\n\n",
              style: (TextStyle(fontSize: 30.0)),
            ),
            new TextField(
              controller: uidCon,
              textAlign: TextAlign.center,
              decoration: new InputDecoration.collapsed(
                  hintText: "  Add user id...."
              ),
            ),
            RaisedButton(
              onPressed: (){
                setState(() {
                  _uid = uidCon.text;
                  _getData(_uid);
                });
              },
              child: Text(
                'Get user',
                style: TextStyle(
                    color: Colors.white,
                ),
              ),
              color: Colors.pink,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
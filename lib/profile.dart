import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'mysql.dart';

class ProfilePage extends StatefulWidget{
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();

}

class _ProfilePageState extends State<ProfilePage> {
  var db = new Mysql();
  var name = '';
  var email = '';
  var phone = '';
  var nid = '';
  var gender = '';
  var age = 0;

  void initState() {
    _getProfile().then((value){
      print('Async done');
    });
    super.initState();
  }
  Future _getProfile() async{
    db.getConnection().then((conn) {
      String sql = "SELECT * FROM `users` WHERE u_id=11";
      conn.query(sql).then((results) {
        for (var row in results) {
          setState(() {
            name = row[0];
            email = row[1];
            phone = row[2];
            nid = row[4];
            age = row[5];
            gender = row[6];
          });
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Covid19 Around Us'),
      ),
      body: Container(
          margin: EdgeInsets.all(30.0),
          padding: EdgeInsets.only(top: 50.0),
          height: 500,
          width: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50.0),
              bottomRight: Radius.circular(50.0),
              topLeft: Radius.circular(50.0),
              topRight: Radius.circular(50.0),
            ),
            gradient: LinearGradient(
              colors: [Colors.white30, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan,
                blurRadius: 10.0,
                offset: Offset(0.0, 5.0),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Icon(
                Icons.account_circle,
                size: 100,
                color: Colors.black87,
              ),

              Container(
                child: Padding(
                  padding: EdgeInsets.only(top: 50.0, left: 35.0),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: RichText(
                          text: TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                  fontSize: 25.0,
                                  color: Colors.black,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: name,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.normal,
                                    )
                                )
                              ]
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: RichText(
                          text: TextSpan(
                              text: 'Age: ',
                              style: TextStyle(
                                  fontSize: 25.0,
                                  color: Colors.black,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: '$age',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.normal,
                                    )
                                )
                              ]
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: RichText(
                          text: TextSpan(
                              text: 'Gender: ',
                              style: TextStyle(
                                  fontSize: 25.0,
                                  color: Colors.black,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: gender,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22.0,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.normal,
                                    )
                                )
                              ]
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: RichText(
                          text: TextSpan(
                              text: 'Email: ',
                              style: TextStyle(
                                  fontSize: 25.0,
                                  color: Colors.black,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: email,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22.0,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.normal,
                                    )
                                )
                              ]
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: RichText(
                          text: TextSpan(
                              text: 'Phone: ',
                              style: TextStyle(
                                  fontSize: 25.0,
                                  color: Colors.black,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: phone,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22.0,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.normal,
                                    )
                                )
                              ]
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: RichText(
                          text: TextSpan(
                              text: 'NID: ',
                              style: TextStyle(
                                  fontSize: 25.0,
                                  color: Colors.black,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: nid,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22.0,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.normal,
                                    )
                                )
                              ]
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )

            ],
          )
      ),
    );
  }

}


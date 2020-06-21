import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mysql.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget{
  HomePage({Key key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();

}

class _HomepageState extends State<HomePage> {
  int _sts = 0;
  String _status = '';
  String _msg = '';
  Color _c;
  var selectedStatus='';
  var db = new Mysql();
  int _id;
//  getting status on page initiate
  String title = "title";
  String helper = "helper";
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void initState() {
    _getData().then((value){
      print('Async done');
    });
    super.initState();
    _firebaseMessaging.configure( //for notification
      onMessage: (message) async{
        setState(() {
          title = message["notification"]["title"];
          helper = "Status:";
        });

      },
      onResume: (message) async{
        setState(() {
          title = message["data"]["title"];
          helper = "New Notification!!";
        });
      },
      onLaunch: (message) async{
        setState(() {
          title = message["data"]["title"];
          helper = "New Notification!!";
        });
      }


    );
  }

  Future<http.Response> updateStatus(String selectedStatus) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int _id = prefs.getInt("userID");
    int _st = 0;
    if (selectedStatus == "Not Affected"){
      _st = 1;
    }else if (selectedStatus == "Affected"){
      _st = 2;
    }else{
      _st = 4;
    }

    print("Status in http $_st");
    return http.post(
      'http://192.168.1.45:80/covid19/update.php',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'uStatus': _st,
        'uid': _id,
      }),
    );
  }


  Future _getData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id = prefs.getInt('userID');
    db.getConnection().then((conn) {
      String sql = "SELECT * FROM `user_status` WHERE u_id=$_id";
      conn.query(sql).then((results) {
        for (var row in results) {
          setState(() {
            _sts = row[2];
            if (_sts == 1) {
              _status = 'Safe';
              _c = const Color(0xFF4CAF50);
              _msg = 'Stay at home, stay safe.';
            } else if (_sts == 2) {
              _status = 'Affected';
              _c = const Color(0xFFF44336);
              _msg = 'Contact your nearby hospital\nor call a doctor';
            } else if (_sts == 3) {
              _status = 'Close Contact';
              _c = const Color(0xFFFBC02D);
              _msg = row[3];
            } else if (_sts == 4) {
              _status = 'Recovered';
              _c = const Color(0xFF42A5F5);
              _msg = 'You fought well, soldier!';
            } else {
              _status = "Dead";
              _c = const Color(0xFF00695C);
              _msg = 'The person died on ' + row[4] + '\naccording to ' + row[3];
            }
            print("Status " + _status);
          });
        }
      });
    });
  }

  showAlertDialog(String selectedStatus, BuildContext context) {

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed:  () {
        updateStatus(selectedStatus);
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Changing your status"),
      content: Text("This is a very sensitive step,\nare you sure you want to change your status to $selectedStatus?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: new CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: true,
            backgroundColor: Colors.white,
            flexibleSpace: new FlexibleSpaceBar(
              background: Container(
                  margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  height: 150.0,
                  width: 400.0,
                  color: _c,
                  child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
//                          Text(//push notification
//                              "$title"
//                          ),
                          Text(
                            'Status: ' + _status,
                            style: TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              _msg,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      )
                  )
              ),
            ),
          ),
          SliverFixedExtentList(
            itemExtent: 500.0,
            delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      if (index > 0) return null; //helps to stop creating infinite list while scrolling
                return Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                        padding: const EdgeInsets.only(top: 15.0),
                        height: 200.0,
                        width: 400.0,
                        color: Colors.orange[900],
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Change your health status',
                              style: TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold),
                            ),

                            Padding(
                              padding: EdgeInsets.only(left: 80, right: 80, top: 20, bottom: 20),
                              child: DropdownButtonFormField(
                                iconSize: 30,
                                iconEnabledColor: Colors.white,
                                hint: Text(
                                    'Your Status',
                                    style: TextStyle(
                                      color: Colors.white
                                    ),
                                ),
                                onChanged: (value){
                                  setState(() {
                                    selectedStatus = value;
                                  });
                                },
                                value:null,
                                items:[
                                  DropdownMenuItem(
                                    value:'Not Affected',
                                    child: Text(
                                        'Not Affected',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value:'Affected',
                                    child: Text(
                                      'Affected',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value:'Recovered',
                                    child: Text(
                                      'Recovered',
                                       style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20
                                      ),
                                    ),
                                  ),
                                ],
                                style: TextStyle(

                                  fontSize: 20
                                ),
                              ),
                            ),


                            RaisedButton(
                              onPressed: () {
                                print('$selectedStatus');
                                showAlertDialog(selectedStatus, context);
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)
                              ),
                              color: Colors.grey[500],
                              child:  Text(
                                  'Confirm',
                                  style: TextStyle(fontSize: 15.0, color: Colors.white, fontWeight: FontWeight.bold)
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.all(20.0),
                          padding: EdgeInsets.only(top: 20.0),
                          width: 400,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0),
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            ),
                            color: Colors.teal[700],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 10.0,
                                offset: Offset(0.0, 15.0),
                              ),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                                  child: Column(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: RichText(
                                          text: TextSpan(
                                              text: 'Hotline',
                                              style: TextStyle(
                                                  fontSize: 25.0,
                                                  color: Colors.amber,
                                                  fontStyle: FontStyle.normal,
                                                  fontWeight: FontWeight.bold
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: ' Numbers',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontStyle: FontStyle.italic,
                                                      fontSize: 24.0,
                                                      fontWeight: FontWeight.bold,
                                                    )
                                                )
                                              ]
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 15.0),
                                        child: Column(
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: RichText(
                                                text: TextSpan(
                                                    text: 'জাতীয় কল সেন্টার: ',
                                                    style: TextStyle(
                                                        fontSize: 20.0,
                                                        color: Colors.white,
                                                        fontStyle: FontStyle.normal,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: '৩৩৩',
                                                          style: TextStyle(
                                                            color: Colors.amber,
                                                            fontStyle: FontStyle.italic,
                                                            fontSize: 25.0,
                                                            fontWeight: FontWeight.bold,
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
                                                    text: 'স্বাস্থ্য বাতায়ন: ',
                                                    style: TextStyle(
                                                        fontSize: 20.0,
                                                        color: Colors.white,
                                                        fontStyle: FontStyle.normal,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: '১৬২৬৩',
                                                          style: TextStyle(
                                                            color: Colors.amber,
                                                            fontStyle: FontStyle.italic,
                                                            fontSize: 25.0,
                                                            fontWeight: FontWeight.bold,
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
                                                    text: 'আইইডিসিআর: ',
                                                    style: TextStyle(
                                                        fontSize: 20.0,
                                                        color: Colors.white,
                                                        fontStyle: FontStyle.normal,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: '১০৬৫৫',
                                                          style: TextStyle(
                                                            color: Colors.amber,
                                                            fontStyle: FontStyle.italic,
                                                            fontSize: 25.0,
                                                            fontWeight: FontWeight.bold,
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
                                                    text: 'বিশেষজ্ঞ হেলথ লাইন: ',
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        color: Colors.white,
                                                        fontStyle: FontStyle.normal,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: '০৯৬১১৬৭৭৭৭৭',
                                                          style: TextStyle(
                                                            color: Colors.amber,
                                                            fontStyle: FontStyle.italic,
                                                            fontSize: 23.0,
                                                            fontWeight: FontWeight.bold,
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
                                                    text: 'সজাতীয় হেল্পলাইন: ',
                                                    style: TextStyle(
                                                        fontSize: 20.0,
                                                        color: Colors.white,
                                                        fontStyle: FontStyle.normal,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: '১০৯',
                                                          style: TextStyle(
                                                            color: Colors.amber,
                                                            fontStyle: FontStyle.italic,
                                                            fontSize: 25.0,
                                                            fontWeight: FontWeight.bold,
                                                          )
                                                      )
                                                    ]
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )

                                    ],
                                  ),
                                ),
                              )

                            ],
                          )
                      ),
                    ],
                  ),
                );
              }),
          )
        ],
      )
    );
  }

}


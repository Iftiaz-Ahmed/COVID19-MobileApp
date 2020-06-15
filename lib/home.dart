import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'datamodels/user_location.dart';
import 'mysql.dart';

class HomePage extends StatefulWidget{
  HomePage({Key key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();

}

class _HomepageState extends State<HomePage> {
  var sts = 0;
  var status = '';
  var msg = '';
  Color c;
  var db = new Mysql();
//  getting status on page initiate
  void initState() {
    _getData().then((value){
      print('Async done');
    });
    super.initState();
  }
  Future _getData() async{
    db.getConnection().then((conn) {
      String sql = "SELECT * FROM `user_status` WHERE u_id=11";
      conn.query(sql).then((results) {
        for (var row in results) {
          setState(() {
            sts = row[2];
            if (sts == 1) {
              status = 'Not affected';
              c = const Color(0xFF4CAF50);
              msg = 'Stay at home, stay safe.';
            } else if (sts == 2) {
              status = 'Affected';
              c = const Color(0xFFF44336);
              msg = 'Contact your nearby hospital\nor call a doctor';
            } else if (sts == 3) {
              status = 'Close Contact';
              c = const Color(0xFFFBC02D);
              msg = row[3];
            } else if (sts == 4) {
              status = 'Recovered';
              c = const Color(0xFF42A5F5);
              msg = 'You fought well, soldier!';
            } else {
              status = "Dead";
              c = const Color(0xFF00695C);
              msg = 'The person died on ' + row[4] + '\naccording to ' + row[3];
            }
            print("Status" + status);
          });
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    //print location
    var userLocation = Provider.of<UserLocation>(context);
    return Scaffold(
      body: new CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 165.0,
            floating: true,
            backgroundColor: Colors.white,
            flexibleSpace: new FlexibleSpaceBar(
              background: Container(
                  margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  height: 150.0,
                  width: 400.0,
                  color: c,
                  child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Lat: ${userLocation?.latitude}, Long: ${userLocation?.longitude}, Alt: ${userLocation?.altitude}'
                          ),
                          Text(
                            'Status: ' + status,
                            style: TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              msg,
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
                        height: 150.0,
                        width: 400.0,
                        color: Colors.orange[900],
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Change your health status',
                              style: TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold),
                            ),

                            MyStatefulWidget(),

                            RaisedButton(
                              onPressed: () {
                                print("clicked");
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


class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  String dropdownValue = 'Not Affected';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      dropdownColor: Colors.orange[900],
      icon: Icon(Icons.arrow_downward, color: Colors.white),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.white),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: <String>['Not Affected', 'Affected', 'Recovered']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';

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
      String sql = "SELECT * FROM `user_status` WHERE u_id=16";
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
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              height: 120.0,
              width: 400.0,
              color: c,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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

            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0, bottom: 30.0),
                padding: const EdgeInsets.only(top: 15.0, right: 15.0, bottom: 15.0, left: 15.0),
                width: 400.0,
                height: 230.0,
                color: Colors.cyan[600],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Live Statistics BD',
                      style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      'Total Affected: 0000',
                      style: TextStyle(
                          fontSize: 25.0,
                          color: Colors.white
                      ),
                    ),
                    Text(
                      'Total Recovered: 000',
                      style: TextStyle(
                          fontSize: 25.0,
                          color: Colors.white
                      ),
                    ),
                    Text(
                      'Total Death: 000',
                      style: TextStyle(
                          fontSize: 25.0,
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
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

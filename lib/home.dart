import 'package:flutter/material.dart';

class HomePage extends StatelessWidget{
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
              height: 100.0,
              width: 400.0,
              color: Colors.green,
              child: Center(
                child: Text(
                  'Status: Safe',
                  style: TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
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

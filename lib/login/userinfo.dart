import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../mysql.dart';


class SignUpScreen extends StatelessWidget {
  var db = new Mysql();
  final name = new TextEditingController();
  final email = new TextEditingController();
  final age = new TextEditingController();
  var gender='';
  final nid = new TextEditingController();
  var phone='';
  final password = new TextEditingController();
  SignUpScreen(TextEditingController phoneController){
    phone = phoneController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title:Text('Covid19 Around Us'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 20.0),
          padding: EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '*You only have to fill this one time, for keeping your record and providing you the best service possible.\n',
                  style: (TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This field cannot be empty';
                    }
                    return null;
                  },
                  controller: name,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[400])
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: "Enter your Name",
                  ),
                ),
                SizedBox(height: 16,),

                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This field cannot be empty';
                    }
                    return null;
                  },
                  controller: age,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly
                  ], // Only numbers can be entered
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[400])
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: "Enter your Age",
                  ),
                ),

                SizedBox(height: 16,),
                DropdownButtonFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This field cannot be empty';
                    }
                    return null;
                  },
                  hint: Text('Enter your Gender'),
                  onChanged: (value){
                    gender = value;
                  },
                  value:null,
                  items:[
                    DropdownMenuItem(
                      value:'male',
                      child: Text('Male'),
                    ),
                    DropdownMenuItem(
                      value:'female',
                      child: Text('Female'),
                    ),
                  ],


                ),



                SizedBox(height: 16,),
                TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[400])
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: "Enter your Email",
                  ),
                ),

                SizedBox(height: 16,),
                TextFormField(
                  controller: nid,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[400])
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: "Enter your NID",
                  ),
                ),
                SizedBox(height: 16,),

                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This field cannot be empty';
                    }
                    return null;
                  },
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[400])
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: "Password",
                  ),
                ),
                SizedBox(height: 16,),

                Container(
                  width: double.infinity,
                  child: FlatButton(
                    child: Text("SIGNUP"),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(16),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _setUserInfo(name.text, email.text, gender, phone, age.text, nid.text, password.text);
                        Timer(Duration(seconds: 2), (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => Home()
                          ));
                        });
                      }
                    },
                    color: Colors.cyan,
                  ),
                )
              ],

            ),
          ),
        ),
      ),
    );
  }
  Future _setUserInfo(name, email, gender, phone, age, nid, pass) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    db.getConnection().then((conn) {
      String sql = "Insert into users (name, email, phone, NID, age, gender, password) values ('$name', '$email', '$phone', '$nid', '$age', '$gender', '$pass')";
      conn.query(sql);

      String sql2 = "select u_id from users where phone=$phone limit 1";
      conn.query(sql2).then((results) async {
        for (var row in results) {
          print("Id retrieved " + row[0].toString());
          prefs.setInt('userID', row[0]);
          var id = row[0];
          String sql3 = "Insert into user_status (u_id, u_status) values ($id, 1)";
          conn.query(sql3);
        }
      });

    });

  }
}
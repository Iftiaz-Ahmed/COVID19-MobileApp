import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../mysql.dart';


// ignore: must_be_immutable
class SignUpScreen extends StatelessWidget {
  var db = new Mysql();
  final name = new TextEditingController();
  final email = new TextEditingController();
  final age = new TextEditingController();
  var gender='';
  final nid = new TextEditingController();
  var phone='';
  SignUpScreen(TextEditingController phoneController){
    phone = phoneController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('Covid19 Around Us'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 20.0),
          padding: EdgeInsets.all(30.0),
          child: Form(
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

                Container(
                  width: double.infinity,
                  child: FlatButton(
                    child: Text("SIGNUP"),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(16),
                    onPressed: () {
                      _setUserInfo(name.text, email.text, gender, phone, age.text, nid.text);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => Home()
                      ));
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
  Future _setUserInfo(name, email, gender, phone, age, nid) async{
    db.getConnection().then((conn) {
      String sql = "Insert into users (name, email, phone, NID, age, gender) values ('$name', '$email', '$phone', '$nid', '$age', '$gender')";
      conn.query(sql);
    });
  }
}

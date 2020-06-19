import 'package:flutter/material.dart';

import '../main.dart';


class SignUpScreen extends StatelessWidget {
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
                  onChanged: (val){
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
}

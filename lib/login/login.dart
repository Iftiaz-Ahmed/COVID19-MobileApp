import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'userinfo.dart';
import '../mysql.dart';

class LoginScreen extends StatefulWidget{
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {
  var userE = 0;
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  var db = new Mysql();
  final userPass = new TextEditingController();

  void checkEuser(String phone, BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    db.getConnection().then((conn) {
      print("Database connected.");
      String sql = "select u_id, password from users where phone=$phone";
      conn.query(sql).then((results) {
        if (results.length == 1) {
          for (var row in results){
            prefs.setInt('userID', row[0]);
            prefs.setString("pass", row[1]);
          }
          var pass = prefs.getString("pass");
          // User exists
          setState(() {
            showAlertDialog(pass, context);
          });
        } else {
          // User doesn't exist
          loginUser(phone, context);
        }
      });
    });
  }

  void loginUser(String phone, BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;

      _auth.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: Duration(seconds: 60),
          verificationCompleted: (AuthCredential credential) async{
            Navigator.of(context).pop();

            AuthResult result = await _auth.signInWithCredential(credential);

            FirebaseUser user = result.user;

            if(user != null){
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => SignUpScreen(_phoneController)
              ));
            }else{
              print("Error");
            }

            //This callback would gets called when verification is done automatically
          },
          verificationFailed: (AuthException exception){
            print(exception);
          },
          codeSent: (String verificationId, [int forceResendingToken]){
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Enter Verification Code"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: _codeController,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Confirm"),
                        textColor: Colors.white,
                        color: Colors.cyan,
                        onPressed: () async{
                          final code = _codeController.text.trim();
                          AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: code);

                          AuthResult result = await _auth.signInWithCredential(credential);

                          FirebaseUser user = result.user;

                          if(user != null){
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => SignUpScreen(_phoneController)
                            ));
                          }else{
                            print("Error");
                          }
                        },
                      )
                    ],
                  );
                }
            );
          },
          codeAutoRetrievalTimeout: null
      );
  }

  bool checkPass(pass) {
    if(pass==userPass.text){
      return true;
    } else {
      return false;
    }
  }

  showAlertDialog(String pass, BuildContext context) {
    var _msg = '';
    Widget continueButton = FlatButton(
      child: Text("Login"),
      onPressed:  () {
        setState(() {
          bool auth = checkPass(pass);
          if (auth){
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => Home()
            ));
          } else {
            setState(() {
              print("else part");
              _msg = "Wrong password!";
              print(_msg);
            });
          }
          print(_msg);
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Welcome Back!"),
      content: TextFormField(
        validator: (value) {
          if (value.isEmpty) {
            return 'This field cannot be empty';
          }
          return null;
        },
        controller: userPass,
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
          hintText: "Enter password",
        ),
      ),

      actions: [
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
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 80.0),
            padding: EdgeInsets.all(50.0),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: IconButton(
                      icon: Icon(Icons.label_important),
                      iconSize: 100.0,
                      color: Colors.cyan, onPressed: () {},
                    )
                  ),

                  SizedBox(height: 16,),

                  TextFormField(
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey[200])
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey[300])
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        hintText: "Enter your mobile number",

                    ),
                    textAlign: TextAlign.center,
                    controller: _phoneController,
                  ),

                  SizedBox(height: 16,),


                  Container(
                    width: double.infinity,
                    child: FlatButton(
                      child: Text("LOGIN"),
                      textColor: Colors.white,
                      padding: EdgeInsets.all(16),
                      onPressed: () {
                          final phone = _phoneController.text.trim();
                          checkEuser(phone, context);
                      },
                      color: Colors.cyan,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}


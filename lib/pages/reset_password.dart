import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:threadon/pages/login_screen.dart';

import 'package:threadon/pages/splesh_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Reset_PasswordPage extends StatefulWidget {
  static String tag = 'resetpassword';

  @override
  _Reset_PasswordPageState createState() => new _Reset_PasswordPageState();
}

//PageController _controller =
//new PageController(initialPage: 1, viewportFraction: 1.0);

class _Reset_PasswordPageState extends State<Reset_PasswordPage> {
  TextEditingController email = new TextEditingController();
  bool _isInAsyncCall = false;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          wifiName = await _connectivity.getWifiName();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          wifiBSSID = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _connectionStatus = '$result\n'
              'Wifi Name: $wifiName\n'
              'Wifi BSSID: $wifiBSSID\n'
              'Wifi IP: $wifiIP\n';
        });
        break;
      case ConnectivityResult.mobile:
        break;
      case ConnectivityResult.none:
        setState(() {
          _showDialog1();
        });
        break;
      default:
        break;
    }
  }

  void _showDialog1() {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("No Internet connection"),
          content: new Text(
              "We can\'t reach our network right now. Please check your connection."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                setState(() {
                  Navigator.of(context).pushAndRemoveUntil(
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                              new SplashScreen()),
                      (Route<dynamic> route) => false);
                });
              },
            ),
            new FlatButton(
              child: new Text("Retry"),
              onPressed: () {
                setState(() {
                  initConnectivity();
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Reset Password"),
          backgroundColor: Colors.white70,
        ),
        body: ModalProgressHUD(
          child: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 50.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Enter your email address and we will",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 0.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "send you instructions to reset your",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 0.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "password",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Container(
//          padding: const EdgeInsets.all(10.0),
                margin:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 50.0),
                child: new Column(
                  children: <Widget>[
                    new TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      // Use email input type for emails.
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black87,
                                style: BorderStyle.solid),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black87,
                                style: BorderStyle.solid),
                          ),
                          hintText: 'Your email address',
                          labelText: 'E-mail',
                          labelStyle: TextStyle(color: Colors.black54)),
                      validator: (val) =>
                          !val.contains('@') ? 'Not a valid email.' : null,
                    ),
                  ],
                ),
              ),
              new Container(
                width: MediaQuery.of(context).size.width,
                margin:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 50.0),
                alignment: Alignment.center,
                decoration: new BoxDecoration(color: Colors.black),
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new OutlineButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(2.0)),
                        borderSide: BorderSide(color: Colors.black),
                        color: Colors.black,
                        highlightedBorderColor: Colors.black,
                        onPressed: () {
                          print("Email : ${email.text}");
                          createPost(
                              email.text); //MyNavigator.goToMain(context),
                        },
                        child: new Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 15.0,
                          ),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Expanded(
                                child: Text(
                                  "Submit",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          inAsyncCall: _isInAsyncCall,
          opacity: 0.7,
          color: Colors.white,
          progressIndicator: CircularProgressIndicator(),
        ));
  }

  // createPost(String email) async {
  //   print("ID : $email");
  //   setState(() {
  //     _isInAsyncCall = true;
  //   });

  //   await _firebaseAuth.sendPasswordResetEmail(email: email);

  //   setState(() {
  //     _isInAsyncCall = false;
  //   });
  // }

  createPost(String id) async {
    setState(() {
      _isInAsyncCall = true;
    });

    var body = {"email_id": id};
    http.Response response = await http.post(
        "https://threadon-86254.firebaseapp.com/forgotpassword",
        body: body);

    if (response.statusCode == 200) {
      print('Login Success');
      var res1 = json.decode(response.body);
      var stcode = res1['status'];

      if (stcode == 200) {
        String msg = res1['message'];
        _showDialog('Password Reset', msg, 0);
      } else {
        String msg = res1['message'];
        _showDialog('Error', msg, 1);
      }

      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      //    showTost('Error');
      print('Error for Forget');
      _showDialog('Error', 'Please try again!', 1);
      setState(() {
        _isInAsyncCall = false;
      });
    }
  }

  void _showDialog(String title, String msg, int code) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                if (code == 1) {
                  Navigator.of(context).pop();
                } else {
                  email.clear();
                  Navigator.of(context).pushAndRemoveUntil(
                      new MaterialPageRoute(
                          builder: (BuildContext context) => new LoginPage()),
                      (Route<dynamic> route) => false);
                  /*  Route route = MaterialPageRoute(builder: (context) => LoginPage());
                  Navigator.pushReplacement(context, route);
                 // Navigator.pushReplacementNamed(context, 'listadecompras');
                 */ /* Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginPage()));

                */ /* // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginPage()));*/
                }
              },
            ),
          ],
        );
      },
    );
  }
}

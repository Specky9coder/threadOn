import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:flutter/services.dart';

class Change_Password_Screen extends StatefulWidget {
  String appbar_name;

  Change_Password_Screen({Key key, this.appbar_name}) : super(key: key);

  @override
  State<StatefulWidget> createState() => changePassword_screen(appbar_name);
}

class changePassword_screen extends State<Change_Password_Screen> {
  String tool_name1;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  changePassword_screen(this.tool_name1);
  String user_id;
  String password;

  TextEditingController curentPassword = new TextEditingController();
  TextEditingController newPassword = new TextEditingController();
  TextEditingController confformPassword = new TextEditingController();
  bool _isInAsyncCall = false;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    getCredential();
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
        setState((){
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
          content: new Text("We can\'t reach our network right now. Please check your connection."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog

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

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      password = sharedPreferences.getString('password');
      curentPassword = new TextEditingController(text: password);
      user_id = sharedPreferences.getString('user_id');

    });


  }


  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(value)));
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(tool_name1),
        backgroundColor: Colors.white70,
//        automaticallyImplyLeading: false,
      ),
      body:ModalProgressHUD( child:Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child:SingleChildScrollView(


          child:Form(
    key: formKey,

        child: Column(
          children: <Widget>[
            Container(

              child: new Column(
                children: <Widget>[
                  new TextFormField(
                    controller: curentPassword,

                      keyboardType: TextInputType.text,

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
                          labelText: 'Current password',
                          labelStyle: TextStyle(color: Colors.black54)),
                    validator: (val) =>
                    val.length < 6 ? 'Password too short.' : null,),
                ],
              ),
            ),
            Container(
//          padding: const EdgeInsets.all(10.0),
              child: new Column(
                children: <Widget>[
                  new TextFormField(
                    controller: newPassword,
                      keyboardType: TextInputType.text,
                    obscureText: true,
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
                          labelText: 'New password',
                          labelStyle: TextStyle(color: Colors.black54)),

                    validator: (val) =>
                    val.length < 6 ? 'Password too short.' : null,),
                ],
              ),
            ),
            Container(
//          padding: const EdgeInsets.all(10.0),

              child: new Column(
                children: <Widget>[
                  new TextFormField(
                    controller: confformPassword,
                    obscureText: true,
                      keyboardType: TextInputType.text,
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
                          labelText: 'Confirm password',
                          labelStyle: TextStyle(color: Colors.black54)),
                    validator: (value) {
                      if (value != newPassword.text) {
                        return 'Passwrod is not matching';
                      }
                    },
                    ),
                ],
              ),
            ),


            Container(

              margin: EdgeInsets.only(top: 20.0),
              alignment: Alignment.bottomCenter,
              child: Card(
                color: Colors.black,
                elevation: 3.0,
                child: Column(
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(10.0),
                        margin: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 5.0,bottom: 5.0),
                        child: GestureDetector(
                          onTap: () {
                            UpdateDataPost();
                          },
                          child:
                              Text(
                                "Save",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17.0,
                                ),

                          ),
                        )),
                  ],
                ),
              ),
            ),



          ],
        ),
      ),
        )

    ),
    inAsyncCall: _isInAsyncCall,
    opacity: 1,
    color: Colors.white,
    progressIndicator: CircularProgressIndicator(),


    // TODO: implement build
      )
    );
  }

  void UpdateDataPost() async {

    var db1 = Firestore.instance;
    final FormState form = formKey.currentState;

    if (form.validate()) {

      if(confformPassword.text != password) {
        form.save();

        var up1 = {
          'password': confformPassword.text,

        };

        db1.collection("users")
            .document(user_id)
            .updateData(up1)
            .then((val) {
          print("sucess");

          setState(() {
            _isInAsyncCall = false;
          });

          showInSnackBar('Passowrd successfully update');
        }).catchError((err) {
          print(err);
          _isInAsyncCall = false;
        });
      }
      else{
        showInSnackBar('You have entered old password!');
        _isInAsyncCall = false;
      }
    }

    else{
      showInSnackBar('Please fix the errors in red before submitting.');
      _isInAsyncCall = false;

    }
  }
}

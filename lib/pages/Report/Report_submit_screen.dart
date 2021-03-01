import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Cart.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/main_screen.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:flutter/services.dart';

class Report_Submitscreen extends StatefulWidget {
  String title;

  Report_Submitscreen({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new report_submit(title);
// TODO: implement createState

}

class report_submit extends State<Report_Submitscreen> {
  String title;
  String user_id = '', product_id = '';

  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  report_submit(this.title);
  final myController = TextEditingController();

  bool checkBoxValue = false,
      checkBoxValue1 = false,
      checkBoxValue2 = false,
      checkBoxValue3 = false,
      checkBoxValue4 = false;

  String value = '', value1 = '', value2 = '', value3 = '', value4 = '';

  bool _isInAsyncCall = false;

  List<Cart> cartList;
  List<Cart> cartList1 = new List<Cart>();
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String Carttotal = "0";



  getCredential() async {
    product_id = await SharedPreferencesHelper.getproduct_id();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      user_id= sharedPreferences.getString("user_id");
      if(user_id == null){
        user_id ="";
      }
    });
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



  void handleSubmit()async{
    String submit_value = value+','+value1+','+value2+','+value3+','+value4+','+myController.text;



    if(submit_value == "" || submit_value == null || submit_value == ",,,,,"){

      _showDialog('Report value null');

    }
    else{
      setState(() {
        _isInAsyncCall = true;
      });
      noteSub?.cancel();
      db.createReport('', user_id, product_id, '0', DateTime.now(), submit_value, '', '').then((_) {
        _isInAsyncCall = false;

        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(
                builder: (BuildContext context) => new MyHome()),
                (Route<dynamic> route) => false);

      });


    }

  }


  void _showDialog(String msg) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Warning"),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getCredential();

    cartList = new List();
    cartList.clear();
    noteSub?.cancel();
    noteSub = db.getCartList().listen((QuerySnapshot snapshot) {
      final List<Cart> notes = snapshot.documents
          .map((documentSnapshot) => Cart.fromMap(documentSnapshot.data))
          .toList();
      setState(() {
        for(int i=0;i<notes.length;i++){
          if(user_id == notes[i].user_id){
            cartList1.add(Cart(notes[i].cart_id, notes[i].product_id, notes[i].status, notes[i].user_id, notes[i].date));
          }
        }
        this.cartList = cartList1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    noteSub?.cancel();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white70,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.search),
            tooltip: 'Action Tool Tip',
            onPressed: () {
              print("onPressed");
            },
          ),
          new Stack(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      if (user_id == "") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupPage()));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CartScreen()));
                      }
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream:Firestore.instance
                        .collection("cart")
                        .where("user_id", isEqualTo: user_id)
                        .snapshots(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData)return Container();
                      Carttotal = snapshot.data.documents.length.toString();

                      if (Carttotal == "0") {
                        return Container();
                      } else {
                        return Container(
                          height: 30,
                          width: 60,
                          padding: EdgeInsets.only(right: 10),
                          alignment: Alignment.topRight,
                          child: Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(2),
                            child: Text(
                              Carttotal,
                              style: TextStyle(color: Colors.white),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                          ),
                        );
                      }

                    },
                  )
                ],
              )
            ],
          ),
          new IconButton(
            icon: new Icon(Icons.perm_identity),
            tooltip: 'Action Tool Tip',
            onPressed: () => MyNavigator.goToProfile(context),
          ),
        ],
      ),
      body: ModalProgressHUD(
        child: ListView(
          children: <Widget>[
            new Card(
              elevation: 4.0,
              child: new Column(
                children: <Widget>[
                  Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Checkbox(
                            activeColor: Colors.black,
                            value: checkBoxValue,
                            onChanged: (bool newValue) {
                              setState(() {
                                checkBoxValue = newValue;
                                if(newValue == true){
                                  value = 'Price too low for product';
                                } else {
                                  value = '';
                                }
                                print(checkBoxValue);
                              });
                            }),
                        new Text('Price too low for product'),
                      ],
                    ),
                  ),

                  Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Checkbox(
                            activeColor: Colors.black,
                            value: checkBoxValue1,
                            onChanged: (bool newValue) {
                              setState(() {
                                checkBoxValue1 = newValue;
                                if(newValue == true){
                                  value1 = 'Missing/incorrect serial tags';
                                } else {
                                  value1 = '';
                                }
                                print(checkBoxValue1);
                              });
                            }),
                        new Text('Missing/incorrect serial tags'),
                      ],
                    ),
                  ),

                  Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Checkbox(
                            activeColor: Colors.black,
                            value: checkBoxValue2,
                            onChanged: (bool newValue) {
                              setState(() {
                                checkBoxValue2 = newValue;
                                if(newValue == true){
                                  value2 = 'Incorrect logo';
                                } else {
                                  value2 = '';
                                }
                                print(checkBoxValue2);
                              });
                            }),
                        new Text('Incorrect logo'),
                      ],
                    ),
                  ),
                  Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Checkbox(
                            activeColor: Colors.black,
                            value: checkBoxValue3,
                            onChanged: (bool newValue) {
                              setState(() {
                                checkBoxValue3 = newValue;
                                if(newValue == true){
                                  value3 = 'Incorrect stitching pattern';
                                } else {
                                  value3 = '';
                                }
                                print(checkBoxValue3);
                              });
                            }),
                        new Text('Incorrect stitching pattern'),
                      ],
                    ),
                  ),
                  Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Checkbox(
                            activeColor: Colors.black,
                            value: checkBoxValue4,
                            onChanged: (bool newValue) {
                              setState(() {
                                checkBoxValue4 = newValue;
                                if(newValue == true){
                                  value4 = 'Seller states item is a replica';
                                } else {
                                  value4 = '';
                                }
                                print(checkBoxValue4);
                              });
                            }),
                        new Text('Seller states item is a replica'),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(
                        left: 10.0, top: 10.0, bottom: 0.0),
                    alignment: Alignment.centerLeft,
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Other",
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(
                        left: 10.0, top: 0.0, bottom: 0.0),
                    child: TextFormField(
                      controller: myController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white,style: BorderStyle.solid),
                        ),
                        focusedBorder:  UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white,style: BorderStyle.solid),
                        ),
                        hintText: 'Other ',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 50.0),
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
                      splashColor: Colors.grey,
                      highlightedBorderColor: Colors.black,
                      onPressed: () => handleSubmit(),
                      child: new Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 15.0,
                        ),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Expanded(
                              child: Text(
                                "Submit",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0),
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
        opacity: 0.5,
        color: Colors.black,
        progressIndicator: CircularProgressIndicator(),
      )

    );
  }
}

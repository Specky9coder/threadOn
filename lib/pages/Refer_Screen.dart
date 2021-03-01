import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/ChatMessage.dart';
import 'package:threadon/pages/Coman_SearchList_Screen.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/pages/splesh_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/my_navigator.dart';
// import 'package:advanced_share/advanced_share.dart';
import 'package:flutter/services.dart';

class Refer_Screen extends StatefulWidget {
  String appbar_name;

  Refer_Screen({Key key, this.appbar_name}) : super(key: key);

  @override
  State<StatefulWidget> createState() => refer_screen(appbar_name);
}

class refer_screen extends State<Refer_Screen> {
  String tool_name1;

  bool _value2 = true;
  String user_id = '';
  String Carttotal = "0";
  String ReferLink = "";
  String EaringTotal = "0";
  String RefelValueTotal = "0";
  String RefelCode = '';
  bool _isInAsyncCall = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  void _value2Changed(bool value) => setState(() => _value2 = value);

  @override
  void initState() {
    super.initState();

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getCredential();
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

  /*-----------------------------------------------------------------------*/

  getCredential() async {
    setState(() {
      _isInAsyncCall = true;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = sharedPreferences.getString("user_id");
      if (user_id == null) {
        user_id = "";
      }
    });

    getData();
  }

  Future getData() async {
    CollectionReference ref = Firestore.instance.collection('users');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      // eventsQuery.documents.forEach((doc) async {
      //   RefelCode = doc['refer_code'];
      //   ReferLink =
      //       'http://marumodasa.com/ThreadOn/web/invite/' + doc['refer_code'];

      //   setState(() {
      //     _isInAsyncCall = false;
      //   });
      // });
    }

    CollectionReference ref1 = Firestore.instance.collection('referral');
    QuerySnapshot eventsQuery1 =
        await ref1.where("sender_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery1.documents.isEmpty) {
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
        });
      }
    } else {
      eventsQuery1.documents.forEach((doc) async {
        EaringTotal = doc['sender_wallet_amount'];

        setState(() {
          _isInAsyncCall = false;
        });
      });
    }

    CollectionReference ref1_ch =
        Firestore.instance.collection('referral_charge');
    QuerySnapshot eventsQuery1_ch = await ref1_ch.getDocuments();

    if (eventsQuery1_ch.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery1_ch.documents.forEach((doc) async {
        RefelValueTotal = doc['receiver_amount'];
        if (this.mounted) {
          setState(() {
            _isInAsyncCall = false;
          });
        }
      });
    }
  }

  refer_screen(this.tool_name1);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    double width12 = width;

    return new Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
          title: new Text(tool_name1),
          backgroundColor: Colors.white70,
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.search),
                tooltip: 'Search product',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Coman_SearchList()));
                }
                /*  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductExampleHome()));
              },*/
                ),
            new IconButton(
              icon: new Icon(Icons.local_offer),
              tooltip: 'Add Product',
              onPressed: () => MyNavigator.gotoAddItemScreen(context),
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
                      stream: Firestore.instance
                          .collection("cart")
                          .where("user_id", isEqualTo: user_id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Container();
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
            IconButton(
              icon: new Icon(Icons.chat_bubble_outline),
              tooltip: 'MessageList',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatMessageList()));
              },
            ),
          ],

//        automaticallyImplyLeading: false,
        ),
        body: ModalProgressHUD(
          child: SingleChildScrollView(
              child: Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 15.0, bottom: 10.0),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text(
                          'Lorem ipsum dolor sit amet conse ctetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.',
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                    //  alignment: Alignment.center,
                    alignment: new FractionalOffset(1.0, 0.0),

                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new CheckboxListTile(
                          value: _value2,
                          onChanged: _value2Changed,
                          title: new Text(
                            'Accept our policy for referral',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0, bottom: 5.0),
                    child: Text(
                      'Your Unique referral Link',
                      style: TextStyle(
                          fontSize: 17.0, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: new Container(
                        padding: EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 2.0, bottom: 2.0),
                        child: Text(
                          ReferLink,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.w400),
                        )),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5.0, top: 10.0, bottom: 10.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          child: IconButton(
                            color: Colors.black87,
                            splashColor: Colors.grey,
                            icon: Icon(Icons.content_copy),
                            onPressed: () {
                              Clipboard.setData(
                                  new ClipboardData(text: ReferLink));
                              showInSnackBar('ReferLink Copy');
                            },
                          ),
                        ),
                        GestureDetector(
                          child: IconButton(
                            color: Colors.black87,
                            splashColor: Colors.grey,
                            icon: Icon(Icons.share),
                            onPressed: () {
                              final RenderBox box = context.findRenderObject();
                              Share.share(
                                  'I\'m giving you a up to \$25. To accept, use code ' +
                                      RefelCode +
                                      ' to sign up. Enjoy! Details:' +
                                      ReferLink,
                                  sharePositionOrigin:
                                      box.localToGlobal(Offset.zero) &
                                          box.size);
                            },
                          ),
                          onTap: () {},
                        ),
                        GestureDetector(
                          child: IconButton(
                            color: Colors.black87,
                            splashColor: Colors.grey,
                            icon: Icon(Icons.email),
                            onPressed: () {
                              gmail();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  new SizedBox(
                    height: 20.0,
                    child: new Center(
                      child: new Container(
                        margin: new EdgeInsetsDirectional.only(
                            start: 1.0, end: 1.0),
                        height: 2.0,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30.0, bottom: 10.0),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text(
                          'Your Referrals and Earning ',
                          style: TextStyle(
                              fontSize: 17.0, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 20.0,
                    ),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text(
                          '\$' + EaringTotal,
                          style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 3.0, bottom: 10.0),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text(
                          'Total Earning and Referrals',
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
          inAsyncCall: _isInAsyncCall,
          opacity: 1,
          color: Colors.white,
          progressIndicator: CircularProgressIndicator(),
        ));
  }

  void gmail() {
    // AdvancedShare.gmail(
    //         subject: "ThreadOn",
    //         msg: 'I\'m giving you a up to \$' +
    //             RefelValueTotal +
    //             '. To accept, use code ' +
    //             RefelCode +
    //             ' to sign up. Enjoy! Details:' +
    //             ReferLink,
    //         url: '')
    //     .then((response) {
    //   handleResponse(response, appName: "Gmail");
    // });
  }

  void handleResponse(response, {String appName}) {
    if (response == 0) {
      print("failed.");
    } else if (response == 1) {
      print("success");
    } else if (response == 2) {
      print("application isn't installed");
      if (appName != null) {
        scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text("${appName} isn't installed."),
          duration: new Duration(seconds: 4),
        ));
      }
    }
  }

  void showInSnackBar(String value) {
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }
}

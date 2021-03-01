import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/FirebaseDatabaseUtil.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/ChatMessage.dart';
import 'package:threadon/pages/Coman_SearchList_Screen.dart';
import 'package:threadon/pages/Message_Screen.dart';
import 'package:threadon/pages/Seller_User_Profile_Screen.dart';
import 'package:threadon/pages/category.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/pages/slider_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:flutter/services.dart';

class MyHome extends StatefulWidget {
  static String tag = 'mainadecompras';

  @override
  MyHomeState createState() => new MyHomeState();
}

// SingleTickerProviderStateMixin is used for animation
class MyHomeState extends State<MyHome> with SingleTickerProviderStateMixin {
  StreamSubscription<QuerySnapshot> noteSub;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  String user_id = "";
  String Carttotal = "0";
  bool _isInAsyncCall = false;
  CollectionReference ref;
  String nt = "";

  TabController controller;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isInAsyncCall = true;
    });

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getCredential();
    controller = new TabController(length: 2, vsync: this);

    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> msg) async {
        nt = msg["nt"];
        print('on message $msg');
        _goToDeeplyNestedView();
      },
      onResume: (Map<String, dynamic> msg) {
        nt = msg["nt"];
        print('on resume $msg');
        _goToDeeplyNestedView();
      },
      onLaunch: (Map<String, dynamic> msg) {
        nt = msg["nt"];
        print('on launch $msg');
        _goToDeeplyNestedView();
      },
    );

    firebaseMessaging.getToken().then((token) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString('token_id', token);
      print(token);
    });
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed: $setting');
    });

    // Initialize the Tab Controller

    noteSub?.cancel();
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

  _goToDeeplyNestedView() {
    if (nt == "1") {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Seller_Profile()));
    } else if (nt == "2") {
      //  Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatMessageList()));
    } else if (nt == "3") {}
  }

  _goToDeeplyNestedView1() {}

  /*-----------------------------------------------------------------------*/

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = sharedPreferences.getString("user_id");
      if (user_id == null) {
        user_id = "";
      }
    });

    setState(() {
      _isInAsyncCall = false;
    });
    //  getData();
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    controller.dispose();
    super.dispose();
  }

  /*
   *-------------------- Setup the page by setting up tabs in the body ------------------*
   */
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Exit"),
                  content: Text("Are you sure you want to exit?"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("YES"),
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                    ),
                    FlatButton(
                      child: Text("NO"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        },
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: new AppBar(
            // Title
            title: new Text(""),
            automaticallyImplyLeading: false,
            // Set the background color of the App Bar
            backgroundColor: Colors.white70,
            leading: Container(
              padding: EdgeInsets.only(
                  top: 15.0, left: 10.0, right: 10.0, bottom: 10.0),
              height: 20.0,
              width: 15.0,
              child: Image.asset('images/tonlogo.png'),
            ),
            actions: <Widget>[
              new IconButton(
                  icon: new Icon(Icons.search),
                  tooltip: 'Search product',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Coman_SearchList()));
                    /* Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => USPS()));
            },*/
                  }),
              new IconButton(
                  icon: new Icon(Icons.local_offer),
                  tooltip: 'Add Product',
                  onPressed: () {
                    if (user_id == "") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupPage()));
                    } else {
                      MyNavigator.gotoAddItemScreen(context);
                    }
                  }),
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
                  if (user_id == "") {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignupPage()));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatMessageList()));
                  }
                },
              ),
              new IconButton(
                icon: new Icon(Icons.perm_identity),
                tooltip: 'Me',
                onPressed: () => MyNavigator.goToProfile(context),
              ),
            ],
            bottom: getTabBar(),
          ),
          body: ModalProgressHUD(
            child: getTabBarView(
                <Widget>[new ImageCarousel(), new CategoryScreen()]),
            inAsyncCall: _isInAsyncCall,
            opacity: 1,
            color: Colors.white,
            progressIndicator: CircularProgressIndicator(),
          ),
        ));
  //  return Future.value(true);
  }

  TabBar getTabBar() {
    return new TabBar(
      tabs: <Tab>[
        new Tab(
          // set icon to the tab
          text: 'HOME',
        ),
        new Tab(
          text: 'DEPARTMENT',
        ),
      ],
      // setup the controller
      controller: controller,
    );
  }

  TabBarView getTabBarView(var tabs) {
    return new TabBarView(
      // Add tabs as widgets
      children: tabs,
      // set the controller
      controller: controller,
    );
  }
}

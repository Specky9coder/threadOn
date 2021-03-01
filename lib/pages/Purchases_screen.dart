import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/ChatMessage.dart';
import 'package:threadon/pages/Coman_SearchList_Screen.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/pages/splesh_screen.dart';
import 'package:threadon/tab_screen/Completed_Tab.dart';
import 'package:threadon/tab_screen/Orders_Tab.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:flutter/services.dart';

class Purchases_Screen extends StatefulWidget {
  String appbar_name;


  Purchases_Screen({Key key, this.appbar_name}) : super(key: key);

  @override
  State<StatefulWidget> createState() => purchases(appbar_name);
}

class purchases extends State<Purchases_Screen> with SingleTickerProviderStateMixin  {
  String appbar_name;
  TabController tabController;
  String user_id = '';
  String Carttotal = "0";

  purchases(this.appbar_name);

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

    getCredential();
    tabController = new TabController(length: 2, vsync: this);
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

  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
    super.dispose();

  }

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = sharedPreferences.getString("user_id");
      if(user_id == null){
        user_id ="";
      }
    });


    //  getData();
  }


  TabBar getTabBar() {
    return new TabBar(
      tabs: <Tab>[
        new Tab(
          // set icon to the tab
          text: 'ORDERS' ,
        ),
        new Tab(
          text: 'COMPLETED',
        ),
      ],
      // setup the controller
      controller: tabController,
    );
  }


  TabBarView getTabBarView(var tabs) {
    return new TabBarView(
      // Add tabs as widgets
      children: tabs,
      // set the controller
      controller: tabController,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(appbar_name),
        backgroundColor: Colors.white70,
          bottom: getTabBar(),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.search),
              tooltip: 'Search product',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => Coman_SearchList()));
              }
            /*  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductExampleHome()));
              },*/
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
          IconButton(
            icon: new Icon(Icons.chat_bubble_outline),
            tooltip: 'MessageList',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChatMessageList()));
            },
          ),
          new IconButton(
            icon: new Icon(Icons.perm_identity),
            tooltip: 'Me',
            onPressed: () => MyNavigator.goToProfile(context),
          ),
        ],

//        automaticallyImplyLeading: false,
      ),

      body: getTabBarView(<Widget>[new Orders_Tab(), new Completed_Order_Tab()]));

  }
}

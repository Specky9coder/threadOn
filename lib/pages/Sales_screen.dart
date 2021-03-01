import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Wallet.dart';
import 'package:threadon/pages/Patouts_Screen.dart';
import 'package:threadon/pages/splesh_screen.dart';
import 'package:threadon/tab_screen/Completed_Sales_Tab.dart';
import 'package:threadon/tab_screen/Open_Sales_Tab.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:flutter/services.dart';

class Sales_screen extends StatefulWidget {
  String appbar_name;

  Sales_screen({Key key, this.appbar_name}) : super(key: key);

  @override
  State<StatefulWidget> createState() => sales(appbar_name);
}

class sales extends State<Sales_screen> with SingleTickerProviderStateMixin {
  String appbar_name;
  TabController tabController;

  sales(this.appbar_name);

  List<Wallet_Model> item_list;
  List<Wallet_Model> final_item_list = new List<Wallet_Model>();
  List<Wallet_Model> Sold_final_item_list = new List<Wallet_Model>();

  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;

  String available_amount="",lifetime_earning="",pending_amount="", site_credit="",user_id1="",wallet_id="";
  String date="";


  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  String Name="",email_id="",profile_image="",facebook_id="",user_id="",about_me="",country="",cover_picture="",password="",username="@",followers ="",following="",device_id="";

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Name = sharedPreferences.getString('UserName');
    email_id = sharedPreferences.getString('loginname');
    profile_image = sharedPreferences.getString('profile_image');
    country = sharedPreferences.getString('country');
    about_me = sharedPreferences.getString('about_me');
    password = sharedPreferences.getString('password');
    username = sharedPreferences.getString('username');
    user_id = sharedPreferences.getString('user_id');
    following = sharedPreferences.getString('following');
    followers = sharedPreferences.getString('followers');
    device_id = sharedPreferences.getString('device_id');
    cover_picture = sharedPreferences.getString("cover_picture");
    setState(() {
      item_list = new List();



      Firestore.instance
          .collection('wallet')
          .where("user_id", isEqualTo: user_id)
          .snapshots()
          .listen((data) {
        data.documents.forEach((doc) async {

          /*item_list.add(Wallet_Model(
          available_amount = doc['available_amount'],
          lifetime_earning = doc['lifetime_earning'],
          pending_amount = doc['pending_amount'],
          site_credit = doc['site_credit'],
          user_id1 = doc['available_amount'],
          wallet_id = doc['user_id1'],
           date = doc['date'],
            ));

        */setState(() {
            //      _isInAsyncCall = false;
            available_amount = doc['available_amount'];
            lifetime_earning = doc['lifetime_earning'];
            pending_amount = doc['pending_amount'];
            site_credit = doc['site_credit'];
            user_id1 = doc['available_amount'];
            wallet_id = doc['user_id1'];
            date = doc['date'];

          });

        });
      });
    });


  }






  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCredential();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

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

  TabBar getTabBar() {
    return new TabBar(
      tabs: <Tab>[
        new Tab(
          // set icon to the tab
          text: 'OPEN SALES',
        ),
        new Tab(
          text: 'COMPLETED SALES',
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(110.0),
            child: Column(
              children: <Widget>[
                Container(

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      new Column(
                        children: <Widget>[
                          Text(
                            'Lifetime Earnings',
                            style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.black87),
                            maxLines: 1,
                          ),
                          Container(
                            margin: EdgeInsets.all(5.0),
                            child: Text(
                              lifetime_earning == "" ?'\$00.00':'\$'+ lifetime_earning,
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              maxLines: 1,
                            ),
                          )

                        ],
                      ),
                      GestureDetector(
                        child: new Column(
                          children: <Widget>[

                            Text(
                              'Available Earnings',
                              style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.redAccent),
                              maxLines: 1,
                            ),
                          Container(
                            margin: EdgeInsets.all(5.0),
                            child: Text(
                              available_amount == "" ?'\$00.00': '\$'+available_amount,
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent),
                              maxLines: 1,
                            ),
                          )
                          ],
                        ),
                        onTap:(){
                          MyNavigator.gotoPayoutScreen(context, 'Payouts');
                        }
                      )
                      ,
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: getTabBar(),
                )

              ],
            ),
          ),
        ),
        body: getTabBarView(
            <Widget>[new Open_Sale_Tab(), new Completed_Sale_Tab()]));
  }
}

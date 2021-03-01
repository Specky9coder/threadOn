import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/shipping_address.dart';
import 'package:threadon/pages/Add_Address_screen.dart';
import 'package:threadon/pages/Secure_Checkout_Screen.dart';
import 'package:threadon/pages/splesh_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/my_navigator.dart';

import 'package:flutter/services.dart';

class Address_Book extends StatefulWidget {
  String tool_name;

  Address_Book({Key key, this.tool_name}) : super(key: key);

  @override
  State<StatefulWidget> createState() => addressbook();
}

class addressbook extends State<Address_Book> {
  List<Shipping_address> shellingaddressList;
  List<Shipping_address> buyingaddressList;

  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  bool _isInAsyncCall = true;
  String user_id = "", user_name = "", profile_image = "", flag = "";
  SharedPreferences sharedPreferences;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = sharedPreferences.getString("user_id");
      user_name = sharedPreferences.getString("UserName");
      profile_image = sharedPreferences.getString("profile_image");
      flag = sharedPreferences.getString("flag1");
    });

    CollectionReference ref = Firestore.instance.collection('shipping_address');
    QuerySnapshot eventsQuery = await ref
        .where("user_id", isEqualTo: user_id)
        .where('status', isEqualTo: '0')
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        getBuyingAddress();
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        shellingaddressList.add(Shipping_address(
            doc['shipping_add_id'],
            doc['user_id'],
            doc['name'],
            doc['address_line_1'],
            doc['address_line_2'],
            doc['city'],
            doc['zipcode'],
            doc['state'],
            doc['date'].toDate(),
            doc['id_default'],
            doc['status'].toString()));

        //
      });

      setState(() {
        shellingaddressList = this.shellingaddressList;
        getBuyingAddress();
      });
    }
  }

  getBuyingAddress() async {
    CollectionReference ref = Firestore.instance.collection('shipping_address');
    QuerySnapshot eventsQuery = await ref
        .where("user_id", isEqualTo: user_id)
        .where('status', isEqualTo: '1')
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
        });
      }
    } else {
      eventsQuery.documents.forEach((doc) async {
        buyingaddressList.add(Shipping_address(
            doc['shipping_add_id'],
            doc['user_id'],
            doc['name'],
            doc['address_line_1'],
            doc['address_line_2'],
            doc['city'],
            doc['zipcode'],
            doc['state'],
            doc['date'],
            doc['id_default'],
            doc['status']));

        //
      });

      setState(() {
        buyingaddressList = this.buyingaddressList;
        _isInAsyncCall = false;
      });
    }
  }

  int _radioValue = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    shellingaddressList = new List();
    buyingaddressList = new List();

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
      case ConnectivityResult.none:
        setState(() {
          _showDialog1();
        });
        break;
      default:
        setState(() {
          _showDialog1();
        });
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
  void dispose() {
    noteSub?.cancel();
    super.dispose();
  }

  _buildMainContent() {
    return CustomScrollView(
      slivers: <Widget>[
        /* SliverAppBar(
          pinned: true,
          expandedHeight: 0.0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text('Title'),
          ),
        ),*/
        SliverList(
          delegate: SliverChildListDelegate([
            // getFullScreenCarousel(context),
            Container(
              padding:
                  const EdgeInsets.only(top: 15.0, left: 10.0, bottom: 10.0),
              child: new Row(
                children: <Widget>[
                  Text(
                    "Selling Address",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),

            sellingAddress(),
            new Divider(),

            Container(
              padding:
                  const EdgeInsets.only(top: 5.0, left: 10.0, bottom: 10.0),
              child: new Row(
                children: <Widget>[
                  Text(
                    "Buying Address",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
            buyingAddress(),
            /* new Padding(padding: EdgeInsets.symmetric(horizontal: 2,vertical: 10),child:  new Container(
              child: Text('Editor\'s Picks',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17.0),),
            ),),*/
          ]),
        )
      ],
    );
  }

  Widget sellingAddress() {
    return Column(
      children: <Widget>[
        Container(
          child: shellingaddressList.length > 0
              ? Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: ListView.builder(
                      itemCount: shellingaddressList.length,
                      itemBuilder: (context, position) {
                        return GestureDetector(
                          child: Container(
                            padding: EdgeInsets.all(5.0),
                            alignment: Alignment.centerRight,
                            color: Colors.white,

                            child: new Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: new Radio<int>(
                                    value: _radioValue,
                                    groupValue: _radioValue,
                                    onChanged: (int value) {
                                      setState(() {
                                        _radioValue = value;
                                      });
                                    },

                                    /* onChanged: handleRadioValueChanged(_radioValue,'${shipping_list[position].Id}'),*/
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Container(
                                      alignment: Alignment.topLeft,
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.topLeft,
                                            child: new Text(
                                                '${shellingaddressList[position].name}',
                                                style: TextStyle(
                                                    fontSize: 17.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black)),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 5.0),
                                          ),
                                          Container(
                                            alignment: Alignment.topLeft,
                                            padding: EdgeInsets.only(left: 5.0),
                                            child: Text(
                                              '${shellingaddressList[position].address_line_1}',
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.black87),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 5.0),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(left: 5.0),
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              '${shellingaddressList[position].address_line_2}',
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.black87),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 5.0),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(left: 5.0),
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              '${shellingaddressList[position].city}',
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.black87),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 5.0),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(left: 5.0),
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              '${shellingaddressList[position].state}' +
                                                  "  " +
                                                  '${shellingaddressList[position].zip_code}',
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.black87),
                                            ),
                                          ),
                                          new Container(
                                              margin: const EdgeInsets.only(
                                                  top: 5, bottom: 5.0),
                                              child: Divider(
                                                  color: Colors.black26)),
                                        ],
                                      )),
                                )
                              ],
                            ),
                            // photo and title
                          ),
                        );
                      }),
                )
              : Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: GestureDetector(
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                IconButton(
                                    icon: Icon(
                                      Icons.loyalty,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: null),
                                Text(
                                  'Add Selling Address',
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Text(
                                'This is where we sand your shipping kit when you sell an item.',
                                style: TextStyle(color: Colors.black26),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Add_Address_Screen(
                                  appbar_name: 'Selling Address',
                                  Flag: 3,
                                  exit_Flag: 2,
                                ))),
                  )),
        ),
      ],
    );
  }

  Widget buyingAddress() {
    return Column(
      children: <Widget>[
        Container(
          child: buyingaddressList.length > 0
              ? Container(
                  padding: EdgeInsets.only(top: 10.0, left: 5.0, bottom: 5.0),
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                      itemCount: buyingaddressList.length,
                      itemBuilder: (context, position) {
                        return GestureDetector(
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              alignment: Alignment.centerRight,
                              color: Colors.white,

                              child: new Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                      flex: 2,
                                      child: new IconButton(
                                          icon: Icon(
                                            Icons.home,
                                            size: 30.0,
                                          ),
                                          onPressed: null)),
                                  Expanded(
                                    flex: 8,
                                    child: Container(
                                        alignment: Alignment.topLeft,
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              alignment: Alignment.topLeft,
                                              child: new Text(
                                                  '${buyingaddressList[position].name}',
                                                  style: TextStyle(
                                                      fontSize: 17.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black)),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 5.0),
                                            ),
                                            Container(
                                              alignment: Alignment.topLeft,
                                              padding:
                                                  EdgeInsets.only(left: 5.0),
                                              child: Text(
                                                '${buyingaddressList[position].address_line_1}',
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.black87),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 5.0),
                                            ),
                                            Container(
                                              padding:
                                                  EdgeInsets.only(left: 5.0),
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                '${buyingaddressList[position].address_line_2}',
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.black87),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 5.0),
                                            ),
                                            Container(
                                              padding:
                                                  EdgeInsets.only(left: 5.0),
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                '${buyingaddressList[position].city}',
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.black87),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 5.0),
                                            ),
                                            Container(
                                              padding:
                                                  EdgeInsets.only(left: 5.0),
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                '${buyingaddressList[position].state}' +
                                                    "  " +
                                                    '${buyingaddressList[position].zip_code}',
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.black87),
                                              ),
                                            ),
                                            new Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5, bottom: 5.0),
                                                child: Divider(
                                                    color: Colors.black26)),
                                          ],
                                        )),
                                  )
                                ],
                              ),
                              // photo and title
                            ),
                            onTap: () async {
/*

                              setState(() {
                                _isInAsyncCall = true;
                              });




                              CollectionReference ref = Firestore.instance.collection('shipping_address');
                              QuerySnapshot eventsQuery =
                              await ref.where("user_id", isEqualTo: user_id).getDocuments();

                              if (eventsQuery.documents.isEmpty) {
                                setState(() {
                                  _isInAsyncCall = false;
                                });
                              } else {

                                var da = eventsQuery.documents;

                                for(int i=0;i<da.length;i++) {
                                  String shipp_id = da[i].data['shipping_add_id'];
                                  var up = {'id_default': '0'};
                                  var db = Firestore.instance;
                                  db.collection("shipping_address").document(shipp_id)
                                      .updateData(up)
                                      .then((val) {
                                    print("sucess");
                                  }).catchError((err) {
                                    print(err);
                                  });
                                }

                                var db1 = Firestore.instance;

                                var docId = buyingaddressList[position].shipping_add_id;
                                var updateId = {"id_default":"1"};

                                db1.collection("shipping_address")
                                    .document(docId)
                                    .updateData(updateId)
                                    .then((val) {

                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Secure_Checkout_Screen()));

                                  print("sucess");
                                }).catchError((err) {
                                  print(err);
                                  _isInAsyncCall = false;
                                });


                                setState(() {
                                  _isInAsyncCall = false;
                                });
                              }




                            },*/
                            });
                      }),
                )
              : Container(
                  child: GestureDetector(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(
                                    Icons.shopping_basket,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: null),
                              Text(
                                'Add Buying Address',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              'This is where we sand your purchases when you buy an item.',
                              style: TextStyle(color: Colors.black26),
                            ),
                          )
                        ],
                      ),
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Add_Address_Screen(
                                    appbar_name: 'Selling Address',
                                    Flag: 1,
                                    exit_Flag: 2,
                                  ))))),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text('Address Book'),
        backgroundColor: Colors.white70,
      ),

      body: ModalProgressHUD(
        child: SafeArea(child: _buildMainContent()
            /* Column(
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.only(top: 15.0, left: 10.0, bottom: 15.0),
                child: new Row(
                  children: <Widget>[
                    Text(
                      "Selling Address",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: shellingaddressList.length > 0
                    ? Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(5.0),
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: ListView.builder(
                            itemCount: shellingaddressList.length,
                            itemBuilder: (context, position) {
                              return GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(5.0),
                                  alignment: Alignment.centerRight,
                                  color: Colors.white,

                                  child: new Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: new Radio<int>(
                                          value: _radioValue,
                                          groupValue: _radioValue,
                                          onChanged: (int value) {
                                            setState(() {
                                              _radioValue = value;
                                            });
                                          },

                                          */ /* onChanged: handleRadioValueChanged(_radioValue,'${shipping_list[position].Id}'),*/ /*
                                        ),
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: Container(
                                            alignment: Alignment.topLeft,
                                            padding: EdgeInsets.only(left: 5.0),
                                            child: new Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  alignment: Alignment.topLeft,
                                                  child: new Text(
                                                      '${shellingaddressList[position].name}',
                                                      style: TextStyle(
                                                          fontSize: 17.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black)),
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 5.0),
                                                ),
                                                Container(
                                                  alignment: Alignment.topLeft,
                                                  padding: EdgeInsets.only(
                                                      left: 5.0),
                                                  child: Text(
                                                    '${shellingaddressList[position].address_line_1}',
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: Colors.black87),
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 5.0),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      left: 5.0),
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    '${shellingaddressList[position].address_line_2}',
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: Colors.black87),
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 5.0),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      left: 5.0),
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    '${shellingaddressList[position].city}',
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: Colors.black87),
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 5.0),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      left: 5.0),
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    '${shellingaddressList[position].state}' +
                                                        "  " +
                                                        '${shellingaddressList[position].zip_code}',
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: Colors.black87),
                                                  ),
                                                ),
                                                new Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 5,
                                                            bottom: 5.0),
                                                    child: Divider(
                                                        color: Colors.black26)),
                                              ],
                                            )),
                                      )
                                    ],
                                  ),
                                  // photo and title
                                ),
                              );
                            }),
                      )
                    : Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: GestureDetector(
                          child: Card(
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 10.0,
                                  right: 10.0,
                                  top: 15.0,
                                  bottom: 15.0),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      IconButton(
                                          icon: Icon(
                                            Icons.loyalty,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: null),
                                      Text(
                                        'Add Selling Address',
                                        style: TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 15.0),
                                    child: Text(
                                      'This is where we sand your shipping kit when you sell an item.',
                                      style: TextStyle(color: Colors.black26),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Add_Address_Screen(
                                        appbar_name: 'Selling Address',
                                        Flag: 3,
                                        exit_Flag: 2,
                                      ))),
                        )),
              ),
              Container(
                padding:
                    const EdgeInsets.only(top: 5.0, left: 10.0, bottom: 5.0),
                child: new Row(
                  children: <Widget>[
                    Text(
                      "Buying Address",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Container(
                  child: buyingaddressList.length > 0
                      ? Container(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 5.0, bottom: 5.0),
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: ListView.builder(
                              itemCount: buyingaddressList.length,
                              itemBuilder: (context, position) {
                                return GestureDetector(
                                    child: Container(
                                      padding: EdgeInsets.all(10.0),
                                      alignment: Alignment.centerRight,
                                      color: Colors.white,

                                      child: new Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                              flex: 2,
                                              child: new IconButton(
                                                  icon: Icon(
                                                    Icons.home,
                                                    size: 30.0,
                                                  ),
                                                  onPressed: null)),
                                          Expanded(
                                            flex: 8,
                                            child: Container(
                                                alignment: Alignment.topLeft,
                                                padding:
                                                    EdgeInsets.only(left: 10.0),
                                                child: new Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: new Text(
                                                          '${buyingaddressList[position].name}',
                                                          style: TextStyle(
                                                              fontSize: 17.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5.0),
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      padding: EdgeInsets.only(
                                                          left: 5.0),
                                                      child: Text(
                                                        '${buyingaddressList[position].address_line_1}',
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5.0),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 5.0),
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        '${buyingaddressList[position].address_line_2}',
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5.0),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 5.0),
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        '${buyingaddressList[position].city}',
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5.0),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 5.0),
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        '${buyingaddressList[position].state}' +
                                                            "  " +
                                                            '${buyingaddressList[position].zip_code}',
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                    ),
                                                    new Container(
                                                        margin: const EdgeInsets
                                                                .only(
                                                            top: 5,
                                                            bottom: 5.0),
                                                        child: Divider(
                                                            color: Colors
                                                                .black26)),
                                                  ],
                                                )),
                                          )
                                        ],
                                      ),
                                      // photo and title
                                    ),
                                    onTap: () async {
*/ /*

                              setState(() {
                                _isInAsyncCall = true;
                              });




                              CollectionReference ref = Firestore.instance.collection('shipping_address');
                              QuerySnapshot eventsQuery =
                              await ref.where("user_id", isEqualTo: user_id).getDocuments();

                              if (eventsQuery.documents.isEmpty) {
                                setState(() {
                                  _isInAsyncCall = false;
                                });
                              } else {

                                var da = eventsQuery.documents;

                                for(int i=0;i<da.length;i++) {
                                  String shipp_id = da[i].data['shipping_add_id'];
                                  var up = {'id_default': '0'};
                                  var db = Firestore.instance;
                                  db.collection("shipping_address").document(shipp_id)
                                      .updateData(up)
                                      .then((val) {
                                    print("sucess");
                                  }).catchError((err) {
                                    print(err);
                                  });
                                }

                                var db1 = Firestore.instance;

                                var docId = buyingaddressList[position].shipping_add_id;
                                var updateId = {"id_default":"1"};

                                db1.collection("shipping_address")
                                    .document(docId)
                                    .updateData(updateId)
                                    .then((val) {

                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Secure_Checkout_Screen()));

                                  print("sucess");
                                }).catchError((err) {
                                  print(err);
                                  _isInAsyncCall = false;
                                });


                                setState(() {
                                  _isInAsyncCall = false;
                                });
                              }




                            },*/ /*
                                    });
                              }),
                        )
                      : Container(
                          child: GestureDetector(
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      IconButton(
                                          icon: Icon(
                                            Icons.shopping_basket,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: null),
                                      Text(
                                        'Add Buying Address',
                                        style: TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 15.0),
                                    child: Text(
                                      'This is where we sand your purchases when you buy an item.',
                                      style: TextStyle(color: Colors.black26),
                                    ),
                                  )
                                ],
                              ),
                              onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Add_Address_Screen(
                                            appbar_name: 'Selling Address',
                                            Flag: 1,
                                            exit_Flag: 2,
                                          ))))),
                ),
              ),
            ],
          ),*/
            ),
        inAsyncCall: _isInAsyncCall,
        opacity: 1,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Add_Address_Screen(
                      appbar_name: 'Selling Address',
                      Flag: 1,
                      exit_Flag: 2,
                    ))),
        tooltip: '',
        elevation: 10.0,
        backgroundColor: Colors.redAccent,
        child: new Icon(
          Icons.add,
          color: Colors.white,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

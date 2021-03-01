import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
// import 'package:custom_multi_image_picker/asset.dart';

import 'package:flutter/material.dart';
// ignore: uri_does_not_exist
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Open_Sale.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/model/Shipping.dart';
import 'package:threadon/pages/Add_Item_Screen_4_Listing_details.dart';
import 'package:threadon/pages/Edit_Drafts_Listing_details.dart';
import 'package:threadon/pages/ItemDetails_Screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:flutter/services.dart';

import 'package:multi_image_picker/multi_image_picker.dart';

class Drafts_Screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => drafts_screen();
}

class drafts_screen extends State<Drafts_Screen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String Name = "",
      email_id = "",
      profile_image = "",
      facebook_id = "",
      user_id = "",
      about_me = "",
      country = "",
      cover_picture = "",
      password = "",
      username = "@",
      followers = "",
      following = "",
      device_id = "";
  TabController controller;
  List<Shell_Product_Model> item_list;
  List<Shell_Product_Model> final_item_list = new List<Shell_Product_Model>();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  String status = "3";
  bool _isInAsyncCall = true;
  SharedPreferences sharedPreferences;
  List<Asset> images = new List<Asset>();
  List<Shipping_model> shipping_list;
  int _originalHeight;

  String _identifier = '';
  String Product_Id = '';
  int _originalWidth;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();
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
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getCredential();
    item_list = new List();

    noteSub?.cancel();
    final_item_list.clear();
    noteSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Shell_Product_Model> notes = snapshot.documents
          .map((documentSnapshot) =>
              Shell_Product_Model.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        for (int i = 0; i < notes.length; i++) {
          if (user_id == notes[i].user_id) {
            if (status == notes[i].status) {
              final_item_list.add(Shell_Product_Model(
                notes[i].any_sign_wear,
                notes[i].category,
                notes[i].category_id,
                notes[i].country,
                notes[i].date,
                notes[i].favourite_count,
                notes[i].is_cart,
                notes[i].is_favorite_count,
                notes[i].item_Ounces,
                notes[i].item_brand,
                notes[i].item_color,
                notes[i].item_description,
                notes[i].item_measurements,
                notes[i].item_picture,
                notes[i].item_pound,
                notes[i].item_price,
                notes[i].item_sale_price,
                notes[i].item_size,
                notes[i].item_sold,
                notes[i].item_sub_title,
                notes[i].item_title,
                notes[i].item_type,
                notes[i].packing_type,
                notes[i].picture,
                notes[i].product_id,
                notes[i].retail_tag,
                notes[i].shipping_charge,
                notes[i].shipping_id,
                notes[i].status,
                notes[i].sub_category,
                notes[i].sub_category_id,
                notes[i].user_id,
                notes[i].tracking_id,
                notes[i].order_id,
                notes[i].brand_new,
              ));
            }
          }
        }
        _isInAsyncCall = false;
        this.item_list = final_item_list;
        noteSub?.cancel();
        noteSub = db.getShippingList().listen((QuerySnapshot snapshot) {
          final List<Shipping_model> notes = snapshot.documents
              .map((documentSnapshot) =>
                  Shipping_model.fromMap(documentSnapshot.data))
              .toList();
          setState(() {
            this.shipping_list = notes;
          });
        });
      });
    });
    setState(() {
      _isInAsyncCall = false;
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

  @override
  void dispose() {
    noteSub?.cancel();
    super.dispose();
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: Colors.white70,
        title: Text('Edit Drafts' + '(' + item_list.length.toString() + ')'),
      ),
      body: ModalProgressHUD(
        child: ListView.builder(
            itemCount: item_list.length,
            itemBuilder: (context, position) {
              return GestureDetector(
                child: Card(
                    elevation: 2.0,
                    child: Column(children: <Widget>[
                      Container(
                        height: 100.0,
                        color: Colors.white,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: 20.0, left: 5.0, right: 5.0),

                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'images/tonlogo.png',
                                    image: item_list[position].picture,
                                    fit: BoxFit.contain,
                                  ),

                                  //),
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        margin: EdgeInsets.only(
                                            top: 20.0, left: 5.0),
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          item_list[position].item_title,
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                          maxLines: 1,
                                        )),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      margin:
                                          EdgeInsets.only(top: 3.0, left: 5.0),
                                      child: Text(
                                        item_list[position].sub_category,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                      ),
                      Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              new RaisedButton(
                                padding: const EdgeInsets.all(5.0),
                                textColor: Colors.white,
                                color: Colors.black,
                                onPressed: () {
                                  sharedPreferences.setString(
                                      item_list[position].user_id, 'user_id');
                                  // sharedPreferences.setString(item_list[position].product_id,'product_id_user');
                                  sharedPreferences.setString(
                                      item_list[position].product_id,
                                      'product_id_user');

                                  sharedPreferences.setInt('cameraflag', 1);
                                  sharedPreferences.setInt('view_flag', 1);

                                  Product_Id = item_list[position].product_id;

                                  if (Product_Id == "" && Product_Id == null) {
                                    showInSnackBar("No product found");
                                  } else {
                                    sharedPreferences.setString(
                                        'product_id', Product_Id);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ItemDetails(Product_Id)));
                                  }
                                  // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>ItemDetails(item_list[position].product_id)));
                                },
                                child: new Text("VIEW"),
                              ),
                              new RaisedButton(
                                onPressed: () async {
                                  // print(
                                  //     'call : ${item_list[position].item_picture}');
                                  sharedPreferences.setString('user_id',
                                      item_list[position].user_id.toString());
                                  sharedPreferences.setString(
                                      'product_id_user',
                                      item_list[position]
                                          .product_id
                                          .toString());
                                  sharedPreferences.setInt('cameraflag', 1);
                                  sharedPreferences.setInt('view_flag', 1);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Add_Item_4_Listing_details(
                                                appbar_name: 'Listing Details',
                                                listOfCameraImage: new List(),
                                                Dname: item_list[position]
                                                    .product_id,
                                                listOfGalleryimage: new List(),
                                                Size: '2',
                                              )));

                                  ///
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) =>Edit_Drafts_Listing_details(appbar_name:'Edit Item'
                                  // ,ListOfCameraImage: item_list[position].item_picture.toList(),ListOfGalleryimage: images,Dname: item_list[position].product_id,Size: "0",shipping_list: shipping_list,
                                  // )));
                                },
                                textColor: Colors.white,
                                color: Colors.black,
                                padding: const EdgeInsets.all(5.0),
                                child: new Text(
                                  "EDIT",
                                ),
                              ),
                              new RaisedButton(
                                onPressed: () {
                                  setState(() {
                                    _isInAsyncCall = true;
                                    print(
                                        "call : ${item_list[position].product_id}");
                                  });

                                  noteSub?.cancel();
                                  // setState(() {
                                  //product
                                  //   print("call");
                                  //   _isInAsyncCall = false;
                                  // });
                                  db
                                      .deleteProduct(
                                          item_list[position].product_id)
                                      .then((share_list_item) async {
                                    setState(() {
                                      // print("calls");
                                      _isInAsyncCall = false;
                                    });

                                    item_list.remove(item_list[position]);

                                    sharedPreferences.setString(
                                        item_list[position].user_id, 'user_id');
                                    sharedPreferences.setString(
                                        item_list[position].product_id,
                                        'product_id_user');
                                    sharedPreferences.setInt('cameraflag', 1);
                                    sharedPreferences.setInt('view_flag', 1);

                                    showInSnackBar(
                                        'Draft product successfully deleted');
                                    Navigator.of(context).push(
                                        new MaterialPageRoute(
                                            builder: (BuildContext context) {
                                      return new Drafts_Screen();
                                    }));
                                  });
                                },
                                textColor: Colors.white,
                                color: Colors.red,
                                padding: const EdgeInsets.all(5.0),
                                child: new Text(
                                  "DELETE",
                                ),
                              ),
                            ],
                          ))
                    ])),
                onTap: null,
              );
            }),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.7,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }
}

/*


class OderList extends StatelessWidget {

  final List<Shell_Product_Model> product;

  OderList({Key key, this.product}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return
  }


}


*/

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Category.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/Add_Item_Screen_2.dart';
import 'package:threadon/pages/Constant.dart';
import 'package:threadon/pages/Drafts_Screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:flutter/services.dart';

String Cat_id = '';

class Add_Item extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => add_item();
}

class add_item extends State<Add_Item> {
  int value = 0;

  List<CategoryModel> categoryList;
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;

  List<Shell_Product_Model> item_list;
  List<Shell_Product_Model> final_item_list = new List<Shell_Product_Model>();
  String status = "3";
  bool _isInAsyncCall = true;
  String user_id = "", user_name = "", profile_image = "", flag = "";

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    user_id = sharedPreferences.getString("user_id");
    user_name = sharedPreferences.getString("UserName");
    profile_image = sharedPreferences.getString("profile_image");
    flag = sharedPreferences.getString("flag1");

    noteSub?.cancel();

    noteSub = db.getCategoryList().listen((QuerySnapshot snapshot) {
      final List<CategoryModel> notes = snapshot.documents
          .map((documentSnapshot) =>
              CategoryModel.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        this.categoryList = notes;
        noteSub?.cancel();
        noteSub = db.getProductList().listen((QuerySnapshot snapshot) {
          final List<Shell_Product_Model> notes = snapshot.documents
              .map((documentSnapshot) =>
                  Shell_Product_Model.fromMap(documentSnapshot.data))
              .toList();

          item_list.clear();
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
                      notes[i].brand_new));
                }
              }
            }
            _isInAsyncCall = false;
            this.item_list = final_item_list;
          });
        });
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    categoryList = new List();
    item_list = new List();
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

  @override
  void dispose() {
    noteSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.white70,
          elevation: 0.0,
          leading: GestureDetector(
            child: IconButton(
                icon: Icon(Icons.close),
                color: Colors.black,
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(110.0),
            child: Container(
              padding: EdgeInsets.only(left: 20.0, top: 10.0),
              alignment: Alignment.topCenter,
              child: Text(
                'What do you want...',
                style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey),
                maxLines: 2,
              ),
            ),
          ),
        ),
        body:
            // ModalProgressHUD(
            //   child:
            OderList(category: categoryList),
        // inAsyncCall: _isInAsyncCall,
        // opacity: 0.7,
        // color: Colors.white,
        // progressIndicator: CircularProgressIndicator(),
        // ),

        bottomNavigationBar: GestureDetector(
          child: Container(
            height: 45.0,
            color: Colors.white70,
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Edit Drafts' + '(' + item_list.length.toString() + ')',
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.redAccent),
              maxLines: 2,
            ),
          ),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Drafts_Screen()));
          },
        ));
  }
}

class OderList extends StatelessWidget {
  final List<CategoryModel> category;

  OderList({Key key, this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: category.length,
        itemBuilder: (context, position) {
          return GestureDetector(
              child: Container(
                  height: 80.0,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(left: 30.0),
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: category[position].Cat_image != ""
                                  ? NetworkImage(
                                      '${category[position].Cat_image}')
                                  : Image.asset('images/tonlogo.png'),
                            ),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        margin: EdgeInsets.only(
                            left: 5, top: 5, right: 5, bottom: 5),
                        height: 70,
                        width: 70,
                      ),

                      /* Container(
                           width: 70.0,
                           height:70.0,
                           child:FadeInImage.assetNetwork(
                             placeholder: 'images/t.png',
                             image:category[position].Cat_image,
                             fit: BoxFit.scaleDown,
                           ),
                         ),*/
                      Container(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Text(
                          category[position].Cat_Name,
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.black87),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  )
                  // photo and title

                  ),
              onTap: () async {
                Cat_id = '${category[position].Cat_id}';
                await SharedPreferencesHelper.setcat_id(Cat_id);
                String Cat_name = '${category[position].Cat_Name}';
                await SharedPreferencesHelper.setcat_name(Cat_name);

                if (category[position].is_sub_category == 1) {
                  await SharedPreferencesHelper.setcat_id(Cat_id);
                  await SharedPreferencesHelper.setcat_name(
                      '${category[position].Cat_Name}');
                  //MyNavigator.gotoAdd_item_2Screen(context, Cat_name);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Add_Item_2(
                                appbar_name: Cat_name,
                              )));
                } else {
                  await SharedPreferencesHelper.setcat_id("");
                  await SharedPreferencesHelper.setcat_name('');
                  await SharedPreferencesHelper.setcat_id(Cat_id);
                  await SharedPreferencesHelper.setcat_name(
                      '${category[position].Cat_Name}');
                  Navigator.of(context).pushNamed(CAMERA_SCREEN);
                }
              });
        });
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';

import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/GridItemDetails.dart';
import 'package:threadon/pages/main_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:flutter/services.dart';


class Coman_SearchList extends StatefulWidget {
  // ignore: non_constant_identifier_names

  @override
  _SearchListComanState createState() => new _SearchListComanState();
}

class _SearchListComanState extends State<Coman_SearchList>
    with SingleTickerProviderStateMixin {
  TextEditingController controller = new TextEditingController();
  TextEditingController brand_name = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Shell_Product_Model> item_list = [];
  List<Shell_Product_Model> item_list2 = new List();
  List<Shell_Product_Model> search_item_list = new List();

  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  AlertDialog dialog;

  bool _isInAsyncCall = true;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
// Get json result and convert it to model. Then add

  @override
  void initState() {
    super.initState();

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    setState(() {
      _isInAsyncCall = true;
    });


    noteSub?.cancel();
    noteSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Shell_Product_Model> notes = snapshot.documents
          .map((documentSnapshot) =>
              Shell_Product_Model.fromMap(documentSnapshot.data))
          .toList();

      for (int i = 0; i < notes.length; i++) {
        if (notes[i].status == '0') {
          item_list.add(Shell_Product_Model(
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

      setState(() {
        this.item_list2 = item_list;
        _isInAsyncCall = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(   
        automaticallyImplyLeading: true,     
        title: new Text('Product'),
        backgroundColor: Colors.white70,
       leading: IconButton(icon:Icon(Icons.arrow_back),
          onPressed:() => Navigator.pop(context, false),
        )
      ),
      body:
      //  ModalProgressHUD(
      //   child:
         new Column(
          children: <Widget>[
            new Container(
              color: Theme.of(context).primaryColor,
              child: new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Card(
                  child: new ListTile(
                    leading: new Icon(Icons.search),
                    title: new TextField(
                      controller: controller,
                      decoration: new InputDecoration(
                          hintText: 'Search product', border: InputBorder.none),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: new IconButton(
                      icon: new Icon(Icons.cancel),
                      onPressed: () {
                        controller.clear();
                        onSearchTextChanged('');
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Coman_SearchList()));
                      },
                    ),
                  ),
                ),
              ),
            ),
            new Expanded(
              child: search_item_list.length != 0 || controller.text.isNotEmpty
                  ? new ListView.builder(
                      itemCount: search_item_list.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 3.0),
                              child: Wrap(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: search_item_list[index].picture !=
                                                      ""
                                                  ? NetworkImage(
                                                      '${search_item_list[index].picture}')
                                                  : Image.asset('images/tonlogo.png'),
                                            ),
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                        margin: EdgeInsets.only(
                                            left: 10,
                                            top: 5,
                                            bottom: 5,
                                            right: 10.0),
                                        height: 60,
                                        width: 60,
                                      ),
                                      new Expanded(
                                        child: Text(
                                          search_item_list[index].item_title,
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.black),
                                          maxLines: 1,
                                        ),
                                      ),
                                      new Divider(
                                        color: Colors.black45,
                                      ),
                                    ],
                                  )
                                ],
                              )
                              // photo and title

                              ),
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GridItemDetails(
                                    item: search_item_list[index]),
                              ),
                            );
                          },
                        );
                      },
                    )

                  /* new ListView.builder(
                      itemCount: search_item_list.length,
                      itemBuilder: (context, i) {
                        return new ListTile(
                          title: new Text(search_item_list[i].Item_title),
                          onTap: () async {
                            // Save the user preference
                            // Refresh
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GridItemDetails(item: search_item_list[i]),
                                ),
                              );
                              */ /*  Navigator.of(context).pushAndRemoveUntil(
                        new MaterialPageRoute(
                            builder: (BuildContext context) => new Add_Item_4_Listing_details(appbar_name: name_type,ListOfCameraImage: ListOfCameraImage,ListOfGalleryimage: ListOfGalleryimage,Dname: Dname,Size: Size,shipping_list: shippingList,)),
                            (Route<dynamic> route) => false);*/ /*
                            });
                          },
                        );
                      },
                    )*/
                  : new ListView.builder(
                      itemCount: item_list2.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 3.0),
                              child: Wrap(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: item_list2[index]
                                                          .picture !=
                                                      ""
                                                  ? NetworkImage(
                                                      '${item_list2[index].picture}')
                                                  : Image.asset('images/tonlogo.png'),
                                            ),
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                        margin: EdgeInsets.only(
                                            left: 10,
                                            top: 5,
                                            bottom: 5,
                                            right: 10.0),
                                        height: 60,
                                        width: 60,
                                      ),
                                      new Expanded(
                                        child: Text(
                                          item_list2[index].item_title,
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.black),
                                          maxLines: 1,
                                        ),
                                      ),
                                      new Divider(
                                        color: Colors.black45,
                                      ),
                                    ],
                                  )
                                ],
                              )
                              // photo and title

                              ),
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GridItemDetails(item: item_list2[index]),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
        // inAsyncCall: _isInAsyncCall,
        // opacity: 0.7,
        // color: Colors.white,
        // progressIndicator: CircularProgressIndicator(),),
    );
  }

  @override
  dispose() {
    super.dispose();
  }

  onSearchTextChanged(String text) async {
    search_item_list.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    item_list2.forEach((userDetail) {
      if (userDetail.item_title.toLowerCase().contains(text.toLowerCase()) ||
          userDetail.item_brand.toLowerCase().contains(text.toLowerCase()))
        search_item_list.add(userDetail);
    });

    setState(() {});
  }

  getCredential(String dname) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('dname', dname);
  }
}

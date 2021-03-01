import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
// import 'package:custom_multi_image_picker/asset.dart';

import 'package:flutter/material.dart';
// import 'package:multi_image_picker/asset.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Brand.dart';
import 'package:threadon/model/Shipping.dart';
import 'package:threadon/pages/Add_Item_Screen_4_Listing_details.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class SearchList extends StatefulWidget {
  String appbar_name;
  List<String> ListOfGalleryimage;
  List<String> ListOfCameraImage;
  String Dname;
  String Size;

  // ignore: non_constant_identifier_names
  SearchList({
    Key key,
    this.appbar_name,
    this.ListOfCameraImage,
    this.ListOfGalleryimage,
    this.Dname,
    this.Size,
  }) : super(key: key);
  @override
  _SearchListState createState() => new _SearchListState(
      appbar_name, ListOfCameraImage, ListOfGalleryimage, Dname, Size);
}

class _SearchListState extends State<SearchList>
    with SingleTickerProviderStateMixin {
  String Dname;
  String Size;
  String name_type;
  List<String> ListOfGalleryimage;
  List<String> ListOfCameraImage;
  List<Shipping_model> shippingList;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  _SearchListState(this.name_type, this.ListOfCameraImage,
      this.ListOfGalleryimage, this.Dname, this.Size);

  TextEditingController controller = new TextEditingController();
  TextEditingController brand_name = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<BrandModel> item_list = [];
  List<BrandModel> item_list2 = [];

  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  AlertDialog dialog;
  bool _isInAsyncCall = true;
// Get json result and convert it to model. Then add

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getBrandData();
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

  getBrandData() async {
    CollectionReference ref = Firestore.instance.collection('brand');
    QuerySnapshot eventsQuery =
        await ref.where("status", isEqualTo: "0").getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        item_list.add(BrandModel(
          doc['id'],
          doc['brand_name'],
          doc['status'],
        ));
      });

      setState(() {
        _isInAsyncCall = false;
        item_list = this.item_list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: Colors.white70,
        title: new Text('Designer'),
        leading: GestureDetector(
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ModalProgressHUD(
        child: new Column(
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
                          hintText: 'Search designer',
                          border: InputBorder.none),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: new IconButton(
                      icon: new Icon(Icons.cancel),
                      onPressed: () {
                        controller.clear();
                        onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            new Expanded(
              child: item_list2.length != 0 || controller.text.isNotEmpty
                  ? new ListView.builder(
                      itemCount: item_list2.length,
                      itemBuilder: (context, i) {
                        return new ListTile(
                          title: new Text(item_list2[i].Brand_name),
                          onTap: () async {
                            // Save the user preference
                            await SharedPreferencesHelper.setLanguageCode(
                                item_list2[i].Brand_name);
                            // Refresh
                            setState(() {
                              Navigator.of(context).pushAndRemoveUntil(
                                  new MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          new Add_Item_4_Listing_details(
                                            appbar_name: name_type,
                                            listOfCameraImage:
                                                ListOfCameraImage,
                                            listOfGalleryimage:
                                                ListOfGalleryimage,
                                            Dname: Dname,
                                            Size: Size,
                                          )),
                                  (Route<dynamic> route) => false);
                            });
                          },
                        );
                      },
                    )
                  : new ListView.builder(
                      itemCount: item_list.length,
                      itemBuilder: (context, index) {
                        return new ListTile(
                          title: new Text(item_list[index].Brand_name),
                          onTap: () async {
                            // Save the user preference
                            await SharedPreferencesHelper.setLanguageCode(
                                item_list[index].Brand_name);
                            // Refresh
                            setState(() {
                              Navigator.of(context).pushAndRemoveUntil(
                                  new MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          new Add_Item_4_Listing_details(
                                            appbar_name: name_type,
                                            listOfCameraImage:
                                                ListOfCameraImage,
                                            listOfGalleryimage:
                                                ListOfGalleryimage,
                                            Dname: Dname,
                                            Size: Size,
                                          )),
                                  (Route<dynamic> route) => false);
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.7,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () {
          _openAddUserDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
  }

  onSearchTextChanged(String text) async {
    item_list2.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    item_list.forEach((userDetail) {
      if (userDetail.Brand_name.toLowerCase().contains(text.toLowerCase()))
        item_list2.add(userDetail);
    });

    setState(() {});
  }

  getCredential(String dname) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('dname', dname);

    Navigator.of(context).pushAndRemoveUntil(
        new MaterialPageRoute(
            builder: (BuildContext context) => new Add_Item_4_Listing_details(
                  appbar_name: name_type,
                  listOfCameraImage: ListOfCameraImage,
                  listOfGalleryimage: ListOfGalleryimage,
                  Dname: Dname,
                  Size: Size,
                )),
        (Route<dynamic> route) => false);
  }

  void _openAddUserDialog() {
    dialog = new AlertDialog(
      content: new Container(
        height: 200.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            new Expanded(
              child: new Row(
                children: <Widget>[
                  new Container(
                    // padding: new EdgeInsets.all(10.0),
                    decoration: new BoxDecoration(
                      color: Colors.white,
                    ),
                    child: new Text(
                      'Add Brand',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            TextFormField(
              controller: brand_name,
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black87, style: BorderStyle.solid),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black87, style: BorderStyle.solid),
                  ),
                  hintText: 'Enter brand name',
                  labelText: 'Brand Name',
                  labelStyle: TextStyle(color: Colors.black54)),
              keyboardType: TextInputType.text,
              /* validator: (val) =>
              !val.contains('@') ? 'Not a valid email.' : null,
              onSaved: (val) => _email= val,*/
            ),

            SizedBox(height: 24.0),
            new RaisedButton(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 10.0,
              ),
              child: const Text(
                'SUBMIT',
                style: TextStyle(color: Colors.white, fontSize: 15.0),
              ),
              color: Colors.black,
              elevation: 4.0,
              splashColor: Colors.blueGrey,
              onPressed: () {
                if (brand_name.text != null) {
                  db.add_Brand('', brand_name.text, "0").then((_) {
                    setState(() {
                      //  _isInAsyncCall = false;
                      showInSnackBar('Brand successfully Add');
                      Navigator.pop(context);
                    });
                  });
                } else {
                  showInSnackBar('Brand name is required.');
                }
                // Perform some action
              },
            ),
          ],
        ),
      ),
    );

    showDialog(context: context, child: dialog);
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }
}

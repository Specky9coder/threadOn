import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Brand.dart';
import 'package:threadon/pages/Fliter1_screen.dart';

import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:flutter/services.dart';

class Brand_SearchList extends StatefulWidget {
  // ignore: non_constant_identifier_names

  @override
  _SearchListBrandState createState() => new _SearchListBrandState();
}

class _SearchListBrandState extends State<Brand_SearchList>
    with SingleTickerProviderStateMixin {
  TextEditingController controller = new TextEditingController();
  TextEditingController brand_name = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<BrandModel> item_list = [];
  List<BrandModel> item_list2 = new List();
  List<BrandModel> search_item_list = new List();
  List<String> _selecteCategorys = new List();
  SharedPreferences sharedPreferences;

  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  AlertDialog dialog;

  bool _isInAsyncCall = true;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
// Get json result and convert it to model. Then add

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
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getCredential();
    setState(() {
      _isInAsyncCall = true;
    });

    noteSub?.cancel();
    noteSub = db.getBrandList().listen((QuerySnapshot snapshot) {
      final List<BrandModel> notes = snapshot.documents
          .map((documentSnapshot) => BrandModel.fromMap(documentSnapshot.data))
          .toList();

      for (int i = 0; i < notes.length; i++) {
        if (notes[i].Status == '0') {
          item_list.add(
              BrandModel(notes[i].Id, notes[i].Brand_name, notes[i].Status));
        }
      }

      setState(() {
        this.item_list2 = item_list;
        _isInAsyncCall = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
          backgroundColor: Colors.white70,
          title: new Text('Product'),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(new MaterialPageRoute(
                  builder: (BuildContext context) => Filter1_Screen()));
            },
          )
//          GestureDetector(
//           child:
//            Icon(
//             Icons.arrow_back,
//             color: Colors.black,
//           ),
// //           onTap: () {
// // //            Navigator.pop(context);
// //             Navigator.of(context).pushReplacement(
// //                 new MaterialPageRoute(
// //                     builder: (BuildContext context) =>
// //                         Filter1_Screen()));
// //           },
//         ),
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
                                builder: (context) => Brand_SearchList()));
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
                        return CheckboxListTile(
                          value: _selecteCategorys
                              .contains(search_item_list[index].Brand_name),
//                    onChanged: (bool selected) {
//                      _onCategorySelected(selected,
//                          categoryList[position].Sub_category_id);
//                    },
                          title: Text(search_item_list[index].Brand_name),
                          onChanged: (bool value) {},
                          /* onChanged: (bool selected) {
                      _onCategorySelected(selected,
                          categoryList[position].Sub_category_id);
                    },*/
//                    title: Text(search_item_list[index].Brand_name),
                        );
//
                      },
                    )
                  : new ListView.builder(
                      itemCount: item_list2.length,
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                          value: _selecteCategorys
                              .contains(item_list2[index].Brand_name),
                          onChanged: (bool selected) {
                            _onCategorySelected(
                                selected, item_list2[index].Brand_name);
                          },
                          title: Text(item_list2[index].Brand_name),
                        );
//
                      },
                    ),
            ),
            Container(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 400,
                    height: 50,
                    child: new RaisedButton(
                      child: const Text(
                        'DONE',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18.0,
                        ),
                      ),
                      color: Colors.white,
                      elevation: 4.0,
                      splashColor: Colors.blueGrey,
                      onPressed: () {
                        sharedPreferences.setStringList(
                            "brand_list", _selecteCategorys);
                        Navigator.of(context).pushReplacement(
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    Filter1_Screen()));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.7,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
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
      if (userDetail.Brand_name.toLowerCase().contains(text.toLowerCase()) ||
          userDetail.Brand_name.toLowerCase().contains(text.toLowerCase()))
        search_item_list.add(userDetail);
    });

    setState(() {});
  }

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();
    print("Data : ${sharedPreferences.getStringList('brand_list')}");
    setState(() {
      if (sharedPreferences.getStringList('brand_list') != null) {
        _selecteCategorys =
            sharedPreferences.getStringList('brand_list').toList();
      }
      // _selecteCategorys = sharedPreferences.getStringList('brand_list');
    });
//    sharedPreferences.setString('dname', dname);
  }

  void _onCategorySelected(bool selected, category_id) {
    if (selected == true) {
      setState(() {
        _selecteCategorys.add(category_id);
      });
    } else {
      setState(() {
        _selecteCategorys.remove(category_id);
      });
    }
  }
}

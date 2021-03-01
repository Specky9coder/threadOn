import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Sub_Category.dart';
import 'package:threadon/pages/Add_Item_Screen_4.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/Coman_SearchList_Screen.dart';

import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';

import 'package:flutter/services.dart';

class DepartmentScreen extends StatefulWidget {
  static String tag = 'departments';
  String tool_name;

  DepartmentScreen({Key key, this.tool_name}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>_DepartmentScreenState(tool_name);

//  _DepartmentScreenState createState() => new _DepartmentScreenState(tool_name);
}

class _DepartmentScreenState extends State<DepartmentScreen> {

  List<Sub_CategoryModel> sub_categoryList1;

  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  String Cat_id = '';
  String user_id = '';
  String Cattotle = '';
  String Cat_name='';
  bool _isInAsyncCall = false;
  String Carttotal = "0";

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
    initState();
//    noteSub?.cancel();
    super.dispose();
  }

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Cat_id = await SharedPreferencesHelper.getcat_id();
    Cat_name = await SharedPreferencesHelper.getcat_name();
    setState(() {
      user_id = sharedPreferences.getString("user_id");
      if(user_id == null){
        user_id ="";
      }
    });

    setState(() {
      _isInAsyncCall = true;
    });
    sub_categoryList1 = new List();

    CollectionReference ref = Firestore.instance.collection('sub_category');
    QuerySnapshot eventsQuery =
    await ref.where("is_sub_category_id", isEqualTo: Cat_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        setState(() {
          _isInAsyncCall = false;
        });

      });
    } else {
      eventsQuery.documents.forEach((doc) async {


        sub_categoryList1.add(Sub_CategoryModel(doc['category_id'],
          doc['is_sub_category'],
          doc['is_sub_category_id'] ,
          doc['polybag'].toList(),
          doc['premium_box'].toList(),
          doc['sub_category_id'],
          doc['sub_category_image'],
          doc['sub_category_name'],



        ));
      });

      setState(() {

        _isInAsyncCall = false;
        sub_categoryList1 = this.sub_categoryList1;
      });
    }


  }

  String tool_name;

  _DepartmentScreenState(this.tool_name);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(tool_name),
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
              onPressed: () {
                if (user_id == "") {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignupPage()));
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

          new IconButton(
            icon: new Icon(Icons.perm_identity),
            tooltip: 'Me',
            onPressed: () => MyNavigator.goToProfile(context),
          ),
        ],
      ),
      body:ModalProgressHUD(

          child:sub_categoryList1.length == 0?Showmsg(): ListView.builder(
              itemCount: sub_categoryList1.length,
              itemBuilder: (context, position) {
                return GestureDetector(
                    child: Container(
                        alignment: Alignment.centerRight,
                        padding:
                        EdgeInsets.only(top: 20.0, bottom: 10.0, left: 30.0),
                        color: Colors.white,
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text(
                                '${sub_categoryList1[position].Sub_category_name}',
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
                      SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();

                      int sub_Cat_id = sub_categoryList1[position].Is_sub_category;

                      if(sub_Cat_id == 1){
                        await SharedPreferencesHelper.setsub_cat_id(sub_categoryList1[position].Sub_category_id);
                        await SharedPreferencesHelper.setsub_cat_name(sub_categoryList1[position].Sub_category_name);

                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Add_Item_4(appbar_name: sub_categoryList1[position].Sub_category_name)));
                      }
                      else{
                        await SharedPreferencesHelper.setsub_cat_id(sub_categoryList1[position].Sub_category_id);
                        await SharedPreferencesHelper.setsub_cat_name(sub_categoryList1[position].Sub_category_name);
                        MyNavigator.goToDepartmentss(context);
                        sharedPreferences.setString('type', "");
                        sharedPreferences.setString('cat_name', Cat_name);

                      }



                      /* await SharedPreferencesHelper.setsub_cat_id(Cat_id);
                  await SharedPreferencesHelper.setcat_name(tool_name);
                  await SharedPreferencesHelper.setsub_cat_name(Cat_name);
                  sharedPreferences.setString('cat_name', Cat_name);
                  sharedPreferences.setString('type', "");
                  MyNavigator.goToDepartmentss(context);
*/                }
);
              }),
          inAsyncCall: _isInAsyncCall,
          opacity: 1,
          color: Colors.white,
          progressIndicator: CircularProgressIndicator()
      ),
    );
  }
  Widget Showmsg() {
    return Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset('images/tonlogo.png', color: Colors.black54,
              height: 50.0,
              width: 50.0,),

            new Container(height: 10.0,),

            Text('No category ', style: TextStyle(fontSize: 20.0),),

          ],


        )
    );
  }
}

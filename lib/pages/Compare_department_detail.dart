import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Cart.dart';
import 'package:threadon/model/Favorite.dart';
import 'package:threadon/model/Item.dart';
import 'package:threadon/model/Product.dart';
import 'package:threadon/model/Shell_Product.dart';

import 'package:threadon/pages/ItemList.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class CompareDepartmentsScreen extends StatefulWidget {
  static String tag = 'departmentss';
  String tool_name;
  Shell_Product_Model item;

  CompareDepartmentsScreen({Key key, this.tool_name,this.item}) : super(key: key);

  @override
  _CompareDepartmentsScreenState createState() =>
      new _CompareDepartmentsScreenState(tool_name,item);
}

enum _RadioGroup { foo1, foo2 }

class _CompareDepartmentsScreenState extends State<CompareDepartmentsScreen>
    with TickerProviderStateMixin {
  static const List<IconData> icons = const [Icons.sort, Icons.filter];
  AnimationController _controller;
  Shell_Product_Model item;
  List<Favorite> favoriteList;
  List<Favorite> favoriteList1 = new List<Favorite>();
  List<Cart> cartList;
  List<Cart> cartList1 = new List<Cart>();
  List<Shell_Product_Model> productList;
  List<Shell_Product_Model> productList1 = new List<Shell_Product_Model>();
  List<Shell_Product_Model> productList2 = new List<Shell_Product_Model>();
  List<String> UplodImageList;
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  String user_id = '', Sub_cat_id = '';
  String Category_name = '';

  double itemHeight;
  double itemWidth;
  String toolName;

  int _angle = 90;
  bool _isRotated = true;

  AnimationController _controlle;
  Animation<double> _animation;
  Animation<double> _animation2;
  Animation<double> _animation3;
  int _radioValue = 0, _radioValue1 = 0, _radioValue2 = 0, _radioValue3 = 0, _radioValue4 = 0;

  _CompareDepartmentsScreenState(this.toolName,this.item);


  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  _RadioGroup _itemType = _RadioGroup.foo1;

  double _result = 0.0;

  void changeItemType(_RadioGroup type) {
    setState(() {
      _itemType = type;
    });
  }

  void showDemoDialog<T>({BuildContext context, Widget child}) {
    showDialog<T>(
      context: context,
      child: child,
    );
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;

      switch (_radioValue) {
        case 0:
          _result = 1;
          break;
        case 1:
          _result = 2;
          break;
        case 2:
          _result = 3;
          break;
        case 3:
          _result = 4;
          break;
        case 4:
          _result = 5;
          break;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);


    _controlle = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _animation = new CurvedAnimation(
      parent: _controlle,
      curve: new Interval(0.0, 1.0, curve: Curves.linear),
    );

    _animation2 = new CurvedAnimation(
      parent: _controlle,
      curve: new Interval(0.5, 1.0, curve: Curves.linear),
    );

    _animation3 = new CurvedAnimation(
      parent: _controlle,
      curve: new Interval(0.8, 1.0, curve: Curves.linear),
    );
    _controlle.reverse();

    super.initState();

    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    getCredential();

    productList = new List();
    noteSub?.cancel();
    noteSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Shell_Product_Model> notes = snapshot.documents
          .map((documentSnapshot) => Shell_Product_Model.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        for (int i = 0; i < notes.length; i++) {
          if (Sub_cat_id == notes[i].sub_category_id) {
            if(notes[i].status == "0"){

              productList1.add(Shell_Product_Model(
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
                  notes[i].brand_new
              ));
            }

          }
        }
        this.productList = productList1;
      });
    });

    cartList = new List();
    cartList.clear();
    noteSub = db.getCartList().listen((QuerySnapshot snapshot) {
      final List<Cart> notes = snapshot.documents
          .map((documentSnapshot) => Cart.fromMap(documentSnapshot.data))
          .toList();
      setState(() {
        for (int i = 0; i < notes.length; i++) {
          if (user_id == notes[i].user_id) {
            cartList1.add(Cart(notes[i].cart_id, notes[i].product_id,
                notes[i].status, notes[i].user_id, notes[i].date));
          }
        }
      });
      this.cartList = cartList1;
      print('Child added: ${cartList.length}');
    });

    favoriteList = new List();
    noteSub = db.getFavoriteList().listen((QuerySnapshot snapshot) {
      final List<Favorite> notes = snapshot.documents
          .map((documentSnapshot) => Favorite.fromMap(documentSnapshot.data))
          .toList();
      setState(() {
        for (int i = 0; i < notes.length; i++) {
          if (user_id == notes[i].user_id) {
            favoriteList1.add(Favorite(
              notes[i].favourite_id,
              notes[i].user_id,
              notes[i].product_id,
              notes[i].date,
              notes[i].status,
              notes[i].favourite_name,
            ));
          }
        }
        this.favoriteList = favoriteList1;
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


  void _onSubmit(BuildContext context, message) {
    if (message.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Container(child: Text(message)),
            content: Container(
              height: 300,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                      child: new Column(
                        children: <Widget>[
                          Container(
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Radio(
                                  value: 0,
                                  groupValue: _radioValue,
                                  onChanged: _handleRadioValueChange,
                                ),
                                new Text('Relevance'),
                              ],
                            ),
                          ),

                          Container(
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Radio(
                                  value: 1,
                                  groupValue: _radioValue,
                                  onChanged: _handleRadioValueChange,
                                ),
                                new Text('Recently Listed'),
                              ],
                            ),
                          ),

                          Container(
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Radio(
                                  value: 2,
                                  groupValue: _radioValue,
                                  onChanged: _handleRadioValueChange,
                                ),
                                new Text('Most Loved'),
                              ],
                            ),
                          ),

                          Container(
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Radio(
                                  value: 3,
                                  groupValue: _radioValue,
                                  onChanged: _handleRadioValueChange,
                                ),
                                new Text('Lowest Price'),
                              ],
                            ),
                          ),

                          Container(
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Radio(
                                  value: 4,
                                  groupValue: _radioValue,
                                  onChanged: _handleRadioValueChange,
                                ),
                                new Text('Highest Price'),
                              ],
                            ),
                          ),
                        ],
//
                      )),
                  new Container(
                      child: new Row(
                        children: <Widget>[
                          FlatButton(
                              child: Text(
                                'CANCEL',
                                style: new TextStyle(
                                    color: const Color(0xFFE57373),
                                    fontSize: 16.0,
                                    letterSpacing: 0.3,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          FlatButton(
                              child: Text(
                                'APPLY',
                                style: new TextStyle(
                                    color: const Color(0xFFE57373),
                                    fontSize: 16.0,
                                    letterSpacing: 0.3,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                        ],
//
                      ))
                ],
              ),
            ),
          );
        },
      );
    }
  }

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    user_id = sharedPreferences.getString("user_id");
    sharedPreferences.setString('flag1', '0');
    Sub_cat_id = await SharedPreferencesHelper.getsubcat_id();
    Category_name = await SharedPreferencesHelper.getcat_name();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.black;
    Color foregroundColor = Colors.white70;
    var size = MediaQuery.of(context).size;
    itemHeight = (size.height - kToolbarHeight - 24) / 2;
    itemWidth = size.width / 2;

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(toolName),
          backgroundColor: Colors.white70,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.clear),
              tooltip: 'Action Tool Tip',
              onPressed: () {
                print("onPressed");
              },
            ),

          ],
        ),
        body: new Stack(children: <Widget>[
          _gridView(),

        ]));
  }

  void _rotate() {
    setState(() {
      if (_isRotated) {
        _angle = 45;
        _isRotated = false;
        _controlle.forward();
      } else {
        _angle = 90;
        _isRotated = true;
        _controlle.reverse();
      }
    });
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Alert Dialog title"),
          content: new Text("Alert Dialog body"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _gridView() {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(4.0),
      childAspectRatio: 8.0 / 13.0,
      children: productList
          .map((Shell_Product_Model) => ItemList(item: Shell_Product_Model),).toList(),
    );
  }
}

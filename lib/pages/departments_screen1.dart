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
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/Coman_SearchList_Screen.dart';

import 'package:threadon/pages/ItemList.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/pages/splesh_screen.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class DepartmentsScreen1 extends StatefulWidget {
  static String tag = 'departmentss';
  String tool_name;

  DepartmentsScreen1({Key key, this.tool_name}) : super(key: key);

  @override
  _DepartmentsScreenState1 createState() =>
      new _DepartmentsScreenState1(tool_name);
}

enum _RadioGroup { foo1, foo2 }

class _DepartmentsScreenState1 extends State<DepartmentsScreen1>
    with TickerProviderStateMixin {
  static const List<IconData> icons = const [Icons.sort, Icons.filter];
  AnimationController _controller;

  List<String> editorList;

  List<Favorite> favoriteList;
  List<Favorite> favoriteList1 = new List<Favorite>();
  List<Cart> cartList;
  List<Cart> cartList1 = new List<Cart>();
  List<Shell_Product_Model> productList;
  List<Shell_Product_Model> productList1 = new List<Shell_Product_Model>();
  List<Shell_Product_Model> productList2 = new List<Shell_Product_Model>();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  String user_id = '', Sub_cat_id = '';
  String Category_name = '';

  double itemHeight;
  double itemWidth;
  String toolName;

  int _angle = 90;
  bool _isRotated = true;

  String valuee = "";
  double _result = 0.0;

  AnimationController _controlle;
  Animation<double> _animation;
  Animation<double> _animation2;
  Animation<double> _animation3;
  bool _isInAsyncCall = true;
  int _radioValue = 0;
  String Carttotal = '';

  _DepartmentsScreenState1(this.toolName);

  _RadioGroup _itemType = _RadioGroup.foo1;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

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
          valuee = "1";
          break;
        case 1:
          _result = 2;
          valuee = "2";
          break;
        case 2:
          _result = 3;
          valuee = "3";
          break;
        case 3:
          _result = 4;
          valuee = "4";
          break;
        case 4:
          _result = 5;
          valuee = "5";
          break;
      }
      Navigator.of(context).pop();
      _onSubmit(context, 'Sort by');
    });
  }

//   void _handleRadioValueChange(int value) {
//     setState(() {
//       _radioValue = value;

//       switch (_radioValue) {
//         case 0:
// //          _result = _currencyCalculate(_currencyController.text, EURO_MUL);

//           break;
//         case 1:
// //          _result = _currencyCalculate(_currencyController.text, POUND_MUL);

//           break;
//         case 2:
// //          _result = _currencyCalculate(_currencyController.text, YEN_MUL);

//           break;
//       }
//     });
//   }

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

    cartList = new List();
    cartList.clear();
    noteSub = db.getCartList().listen((QuerySnapshot snapshot) {
      final List<Cart> notes = snapshot.documents
          .map((documentSnapshot) => Cart.fromMap(documentSnapshot.data))
          .toList();
      if (this.mounted) {
        setState(() {
          for (int i = 0; i < notes.length; i++) {
            if (user_id == notes[i].user_id) {
              cartList1.add(Cart(notes[i].cart_id, notes[i].product_id,
                  notes[i].status, notes[i].user_id, notes[i].date));
            }
          }
        });
      }
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

  void _onSubmit(BuildContext context, message) {
    if (message.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
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
                      // FlatButton(
                      //     child: Text(
                      //       'APPLY',
                      //       style: new TextStyle(
                      //           color: const Color(0xFFE57373),
                      //           fontSize: 16.0,
                      //           letterSpacing: 0.3,
                      //           fontWeight: FontWeight.bold),
                      //     ),
                      //     onPressed: () {
                      //       Navigator.of(context).pop();
                      //     }),
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
                            if (valuee == "1") {
                              getData1();
                              Navigator.of(context).pop();
                            } else if (valuee == "2") {
                              getData2();
                              Navigator.of(context).pop();
                            } else if (valuee == "3") {
                              getData3();
                              Navigator.of(context).pop();
                            } else if (valuee == "4") {
                              getData4();
                              Navigator.of(context).pop();
                            } else if (valuee == "5") {
                              getData5();
                              Navigator.of(context).pop();
                            }
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

// -------------------------------------- Sort By --------------------------

  getData1() async {
    productList.clear();
    _rotate();
    productList = new List();
    noteSub?.cancel();
    noteSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Shell_Product_Model> notes = snapshot.documents
          .map((documentSnapshot) =>
              Shell_Product_Model.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        for (int i = 0; i < notes.length; i++) {
          if (Sub_cat_id == notes[i].sub_category_id) {
            if (notes[i].status == "0") {
              if (notes[i].user_id != user_id) {
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
                  notes[i].brand_new,
                ));
              }
            }
          }
        }
        this.productList = productList1;
      });
    });
  }

  getData2() async {
    productList.clear();
    _rotate();
    Firestore.instance
        .collection('product')
        .orderBy("date", descending: true)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) async {
        setState(() {
          if (doc["sub_category_id"] == Sub_cat_id) {
            if (doc["status"] == "0") {
              if (doc['user_id'] != user_id) {
                productList1.add(Shell_Product_Model(
                  doc['Any_sign_wear'],
                  doc['category'],
                  doc['category_id'],
                  doc['country'],
                  doc['date'].toDate(),
                  doc['favourite_count'],
                  doc['is_cart'],
                  doc['is_favorite_count'],
                  doc['item_Ounces'],
                  doc['item_brand'],
                  doc['item_color'],
                  doc['item_description'],
                  doc['item_measurements'],
                  doc['item_picture'],
                  doc['item_pound'],
                  doc['item_price'],
                  doc['item_sale_price'],
                  doc['item_size'],
                  doc['item_sold'],
                  doc['item_sub_title'],
                  doc['item_title'],
                  doc['item_type'],
                  doc['packing_type'],
                  doc['picture'],
                  doc['product_id'],
                  doc['retail_tag'],
                  doc['shipping_charge'],
                  doc['shipping_id'],
                  doc['status'],
                  doc['sub_category'],
                  doc['sub_category_id'],
                  doc['user_id'],
                  doc['tracking_id'],
                  doc['order_id'],
                  doc['brand_new'],
                ));
              }
            }
          }
        });
      });
    }, onDone: () {
      print("Task Done");
    }, onError: (error) {
      print("Some Error");
    });
  }

  getData3() async {
    productList.clear();
    _rotate();
    Firestore.instance
        .collection('product')
//        .where("Sub_category_id", isEqualTo: Sub_cat_id)
        .orderBy("favourite_count", descending: true)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) async {
        setState(() {
          if (doc["sub_category_id"] == Sub_cat_id) {
            if (doc["status"] == "0") {
              if (doc['user_id'] != user_id) {
                productList1.add(Shell_Product_Model(
                  doc['Any_sign_wear'],
                  doc['category'],
                  doc['category_id'],
                  doc['country'],
                  doc['date'].toDate(),
                  doc['favourite_count'],
                  doc['is_cart'],
                  doc['is_favorite_count'],
                  doc['item_Ounces'],
                  doc['item_brand'],
                  doc['item_color'],
                  doc['item_description'],
                  doc['item_measurements'],
                  doc['item_picture'],
                  doc['item_pound'],
                  doc['item_price'],
                  doc['item_sale_price'],
                  doc['item_size'],
                  doc['item_sold'],
                  doc['item_sub_title'],
                  doc['item_title'],
                  doc['item_type'],
                  doc['packing_type'],
                  doc['picture'],
                  doc['product_id'],
                  doc['retail_tag'],
                  doc['shipping_charge'],
                  doc['shipping_id'],
                  doc['status'],
                  doc['sub_category'],
                  doc['sub_category_id'],
                  doc['user_id'],
                  doc['tracking_id'],
                  doc['order_id'],
                  doc['brand_new'],
                ));
              }
            }
          }
        });
      });
    }, onDone: () {
      print("Task Done");
    }, onError: (error) {
      print("Some Error");
    });
  }

  getData4() async {
    productList.clear();
    _rotate();
    Firestore.instance
        .collection('product')
//        .where("Sub_category_id", isEqualTo: Sub_cat_id)
        .orderBy("item_price", descending: false)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) async {
        setState(() {
          if (doc["sub_category_id"] == Sub_cat_id) {
            if (doc["status"] == "0") {
              if (doc['user_id'] != user_id) {
                productList1.add(Shell_Product_Model(
                  doc['Any_sign_wear'],
                  doc['category'],
                  doc['category_id'],
                  doc['country'],
                  doc['date'].toDate(),
                  doc['favourite_count'],
                  doc['is_cart'],
                  doc['is_favorite_count'],
                  doc['item_Ounces'],
                  doc['item_brand'],
                  doc['item_color'],
                  doc['item_description'],
                  doc['item_measurements'],
                  doc['item_picture'],
                  doc['item_pound'],
                  doc['item_price'],
                  doc['item_sale_price'],
                  doc['item_size'],
                  doc['item_sold'],
                  doc['item_sub_title'],
                  doc['item_title'],
                  doc['item_type'],
                  doc['packing_type'],
                  doc['picture'],
                  doc['product_id'],
                  doc['retail_tag'],
                  doc['shipping_charge'],
                  doc['shipping_id'],
                  doc['status'],
                  doc['sub_category'],
                  doc['sub_category_id'],
                  doc['user_id'],
                  doc['tracking_id'],
                  doc['order_id'],
                  doc['brand_new'],
                ));
              }
            }
          }
        });
      });
    }, onDone: () {
      print("Task Done");
    }, onError: (error) {
      print("Some Error");
    });
  }

  getData5() async {
    productList.clear();
    _rotate();
    Firestore.instance
        .collection('product')
//        .where("Sub_category_id", isEqualTo: Sub_cat_id)
        .orderBy("item_price", descending: true)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) async {
        setState(() {
          if (doc["sub_category_id"] == Sub_cat_id) {
            if (doc["status"] == "0") {
              if (doc['user_id'] != user_id) {
                productList1.add(Shell_Product_Model(
                  doc['Any_sign_wear'],
                  doc['category'],
                  doc['category_id'],
                  doc['country'],
                  doc['date'].toDate(),
                  doc['favourite_count'],
                  doc['is_cart'],
                  doc['is_favorite_count'],
                  doc['item_Ounces'],
                  doc['item_brand'],
                  doc['item_color'],
                  doc['item_description'],
                  doc['item_measurements'],
                  doc['item_picture'],
                  doc['item_pound'],
                  doc['item_price'],
                  doc['item_sale_price'],
                  doc['item_size'],
                  doc['item_sold'],
                  doc['item_sub_title'],
                  doc['item_title'],
                  doc['item_type'],
                  doc['packing_type'],
                  doc['picture'],
                  doc['product_id'],
                  doc['retail_tag'],
                  doc['shipping_charge'],
                  doc['shipping_id'],
                  doc['status'],
                  doc['sub_category'],
                  doc['sub_category_id'],
                  doc['user_id'],
                  doc['tracking_id'],
                  doc['order_id'],
                  doc['brand_new'],
                ));
              }
            }
          }
        });
      });
    }, onDone: () {
      print("Task Done");
    }, onError: (error) {
      print("Some Error");
    });
  }

// ------------------------------------------Sort By -----------------------------------

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    user_id = sharedPreferences.getString("user_id");
    if (user_id == null) {
      user_id = "";
    }
    Sub_cat_id = await SharedPreferencesHelper.getcat_id();
    Category_name = await SharedPreferencesHelper.getcat_name();
    editorList = sharedPreferences.getStringList('editor_list');

    productList = new List();

    setState(() {
      for (int j = 0; j < editorList.length; j++) {
        Firestore.instance
            .collection('product')
            .where("product_id", isEqualTo: editorList[j].toString())
            .where('status', isEqualTo: "0")
            .snapshots()
            .listen((data) {
          data.documents.forEach((doc) async {
            productList1.add(Shell_Product_Model(
              doc['Any_sign_wear'],
              doc['category'],
              doc['category_id'],
              doc['country'],
              doc['date'].toDate(),
              doc['favourite_count'],
              doc['is_cart'],
              doc['is_favorite_count'],
              doc['item_Ounces'],
              doc['item_brand'],
              doc['item_color'],
              doc['item_description'],
              doc['item_measurements'],
              doc['item_picture'],
              doc['item_pound'],
              doc['item_price'],
              doc['item_sale_price'],
              doc['item_size'],
              doc['item_sold'],
              doc['item_sub_title'],
              doc['item_title'],
              doc['item_type'],
              doc['packing_type'],
              doc['picture'],
              doc['product_id'],
              doc['retail_tag'],
              doc['shipping_charge'],
              doc['shipping_id'],
              doc['status'],
              doc['sub_category'],
              doc['sub_category_id'],
              doc['user_id'],
              doc['tracking_id'],
              doc['order_id'],
              doc['brand_new'],
            ));
            this.productList = productList1;

            setState(() {
              _isInAsyncCall = false;
            });
          });
        });
        /*       for (int i = 0; i < notes.length; i++) {


            if (editorList[j].toString() == notes[i].product_id) {
              productList1.add(Product(
                  notes[i].Category,
                  notes[i].Country,
                  notes[i].Is_cart,
                  notes[i].Item_brand,
                  notes[i].Item_color,
                  notes[i].Item_description,
                  notes[i].Item_measurements,
                  notes[i].Item_price,
                  notes[i].Item_sale_price,
                  notes[i].Item_size,
                  notes[i].Item_sold,
                  notes[i].Item_sub_title,
                  notes[i].Item_title,
                  notes[i].Item_type,
                  notes[i].Picture,
                  notes[i].Product_id,
                  notes[i].status,
                  notes[i].Sub_category,
                  notes[i].Sub_category_id,
                  notes[i].User_id,
                  '0'));
            }
          }
*/
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.black;
    Color foregroundColor = Colors.white70;
    var size = MediaQuery.of(context).size;
    itemHeight = (size.height - kToolbarHeight - 24);
    itemWidth = size.width / 2;

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(toolName),
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
              onPressed: () => MyNavigator.gotoAddItemScreen(context),
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
                      stream: Firestore.instance
                          .collection("cart")
                          .where("user_id", isEqualTo: user_id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Container();
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
        body: new Stack(children: <Widget>[
          _gridView(),
          new Positioned(
              bottom: 144.0,
              right: 24.0,
              child: new Container(
                child: new Row(
                  children: <Widget>[
                    new ScaleTransition(
                      scale: _animation2,
                      alignment: FractionalOffset.center,
                      child: new Container(
                        margin: new EdgeInsets.only(right: 16.0),
                        child: new Text(
                          'Sort',
                          style: new TextStyle(
                            fontSize: 13.0,
                            fontFamily: 'Roboto',
                            color: new Color(0xFF9E9E9E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    new ScaleTransition(
                      scale: _animation2,
                      alignment: FractionalOffset.center,
                      child: new Material(
                          color: Colors.black,
                          type: MaterialType.circle,
                          elevation: 6.0,
                          child: new GestureDetector(
                            child: new Container(
                                width: 40.0,
                                height: 40.0,
                                child: new InkWell(
                                  onTap: () {
                                    if (_angle == 45.0) {
                                      _onSubmit(context, 'Sort by');
                                    }
                                  },
                                  child: new Center(
                                    child: new Icon(
                                      Icons.sort,
                                      color: new Color(0xFFFFFFFF),
                                    ),
                                  ),
                                )),
                          )),
                    ),
                  ],
                ),
              )),
          new Positioned(
              bottom: 88.0,
              right: 24.0,
              child: new Container(
                child: new Row(
                  children: <Widget>[
                    new ScaleTransition(
                      scale: _animation,
                      alignment: FractionalOffset.center,
                      child: new Container(
                        margin: new EdgeInsets.only(right: 16.0),
                        child: new Text(
                          'Filter',
                          style: new TextStyle(
                            fontSize: 13.0,
                            fontFamily: 'Roboto',
                            color: new Color(0xFF9E9E9E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    new ScaleTransition(
                      scale: _animation,
                      alignment: FractionalOffset.center,
                      child: new Material(
                          color: Colors.black,
                          type: MaterialType.circle,
                          elevation: 6.0,
                          child: new GestureDetector(
                            child: new Container(
                                width: 40.0,
                                height: 40.0,
                                child: new InkWell(
                                  onTap: () {
                                    if (_angle == 45.0) {
                                      MyNavigator.gotoFilter1_Screen(context);
                                    }
                                  },
                                  child: new Center(
                                    child: new Icon(
                                      Icons.filter,
                                      color: new Color(0xFFFFFFFF),
                                    ),
                                  ),
                                )),
                          )),
                    ),
                  ],
                ),
              )),
          new Positioned(
            bottom: 16.0,
            right: 16.0,
            child: new Material(
                color: new Color(0xFFE57373),
                type: MaterialType.circle,
                elevation: 6.0,
                child: new GestureDetector(
                  child: new Container(
                      width: 56.0,
                      height: 56.00,
                      child: new InkWell(
                        onTap: _rotate,
                        child: new Center(
                            child: new RotationTransition(
                          turns: new AlwaysStoppedAnimation(_angle / 360),
                          child: new Icon(
                            Icons.add,
                            color: new Color(0xFFFFFFFF),
                          ),
                        )),
                      )),
                )),
          ),
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
      childAspectRatio: 8.0 / 13.6,
      children: productList
          .map(
            (shellProductModel) => ItemList(item: shellProductModel),
          )
          .toList(),
    );
  }
}

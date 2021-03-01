import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Favorite.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/Coman_SearchList_Screen.dart';
import 'package:threadon/pages/Fliter1_screen.dart';
import 'package:threadon/pages/ItemList.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:flutter/services.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'dart:math' as math;

class DepartmentsScreen extends StatefulWidget {
  static String tag = 'departmentss';
  String tool_name;

  DepartmentsScreen({Key key, this.tool_name}) : super(key: key);

  @override
  _DepartmentsScreenState createState() =>
      new _DepartmentsScreenState(tool_name);
}

enum _RadioGroup { foo1, foo2 }

class _DepartmentsScreenState extends State<DepartmentsScreen>
    with TickerProviderStateMixin {
  static const List<IconData> icons = const [Icons.sort, Icons.filter];
  AnimationController _controller;
  List<Favorite> favoriteList;
  List<Favorite> favoriteList1 = new List<Favorite>();

  List<Shell_Product_Model> productList = new List<Shell_Product_Model>();
  List<Shell_Product_Model> productList1 = new List<Shell_Product_Model>();
  // List<Shell_Product_Model> productList2 = new List<Shell_Product_Model>();
  List<String> UplodImageList;
  List<String> department_list = List();
  List<String> brand_list = List();
  List<String> condition_list = List();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  String user_id = "",
      Sub_cat_id = "",
      cat_name = "",
      filter_price = "",
      condition1 = "",
      condition2 = "",
      condition3 = "",
      type = "",
      Cat_id = '',
      Cat_name = '';
  String Category_name = "";

  double itemHeight;
  double itemWidth;
  String toolName;
  int _angle = 90;
  bool _isRotated = true;

  AnimationController _controlle;
  Animation<double> _animation;
  Animation<double> _animation2;
  Animation<double> _animation3;
  int _radioValue = 0,
      _radioValue1 = 0,
      _radioValue2 = 0,
      _radioValue3 = 0,
      _radioValue4 = 0;

  String valuee = "";

  _DepartmentsScreenState(this.toolName);

  _RadioGroup _itemType = _RadioGroup.foo1;

  double _result = 0.0;
  String Carttotal = '';

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

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    user_id = sharedPreferences.getString("user_id");
    if (user_id == null) {
      user_id = "";
    }

    filter_price = sharedPreferences.getString("filter_price");
    condition1 = sharedPreferences.getString("condition1");
    condition2 = sharedPreferences.getString("condition2");
    condition3 = sharedPreferences.getString("condition3");
//    department_list = sharedPreferences.getStringList('department_list');
    brand_list = sharedPreferences.getStringList('brand_list');
    condition_list = sharedPreferences.getStringList('condition_list');
    type = sharedPreferences.getString("type");
    Sub_cat_id = await SharedPreferencesHelper.getsubcat_id();
    // Category_name = await SharedPreferencesHelper.getcat_name();
    Cat_id = await SharedPreferencesHelper.getcat_id();
    Cat_name = await SharedPreferencesHelper.getcat_name();

    if (type == "") {
      if (Sub_cat_id == "" || Sub_cat_id == null) {
        getData();
      } else {
        getSubc();
      }
    } else if (type == "1") {
      if (brand_list.length == 0) {
        if (filter_price == "") {
          if (condition_list.length == 0) {
            //  getData();
          } else {
            getFilteronlybrandData();
            //  getFilteronlyconditionData(type);
          }
          if (condition1 == "") {
            getData();
          } else {
            if (condition1 == "Retail Tags") {
              getFilteronlyconditionData("1");
            } else {
              getFilteronlyconditionData("2");
            }
          }
          //  if(condition3 == ""){
          //    getData();
          //  }else{
          //    if(condition3 == "Any sign wear"){
          //      getFilteronlyconditionData("1");
          //    }else{
          //      getFilteronlyconditionData("2");
          //    }
          //  }
          // if(condition2 == ""){
          //    getData();
          //  }else{
          //    if(condition2 == "Like New"){
          //      getFilteronlyconditionData("1");
          //    }else{
          //      getFilteronlyconditionData("2");
          //    }
          //  }
          //
          //
        } else {
          if (condition1 == "") {
            if (filter_price == "Under \$25") {
              getFilteronlypriceData("1");
            } else if (filter_price == "\$25 - \$50") {
              getFilteronlypriceData("2");
            } else if (filter_price == "\$50 - \$100") {
              getFilteronlypriceData("3");
            } else if (filter_price == "\$100 - \$200") {
              getFilteronlypriceData("4");
            } else if (filter_price == "\$200 and up") {
              getFilteronlypriceData("5");
            }
          } else {
            if (filter_price == "Under \$25") {
              if (condition1 == "Retail Tags") {
                getFilterbothpriceandconData("1", "1");
              } else {
                getFilterbothpriceandconData("1", "2");
              }
            } else if (filter_price == "\$25 - \$50") {
              if (condition1 == "Retail Tags") {
                getFilterbothpriceandconData("2", "1");
              } else {
                getFilterbothpriceandconData("2", "2");
              }
            } else if (filter_price == "\$50 - \$100") {
              if (condition1 == "Retail Tags") {
                getFilterbothpriceandconData("3", "1");
              } else {
                getFilterbothpriceandconData("3", "2");
              }
            } else if (filter_price == "\$100 - \$200") {
              if (condition1 == "Retail Tags") {
                getFilterbothpriceandconData("4", "1");
              } else {
                getFilterbothpriceandconData("4", "2");
              }
            } else if (filter_price == "\$200 and up") {
              if (condition1 == "Retail Tags") {
                getFilterbothpriceandconData("5", "1");
              } else {
                getFilterbothpriceandconData("5", "2");
              }
            }
          }
//          getFilterData();
        }
      } else {
        if (filter_price == "") {
          if (condition1 == "") {
            getFilteronlybrandData();
          } else {
            if (condition1 == "Retail Tags") {
              getFilterbothbrandandconData("1");
            } else {
              getFilterbothbrandandconData("2");
            }
          }
        } else {
          if (condition1 == "") {
            if (filter_price == "Under \$25") {
              getFilterbothbrandandpriceData("1");
            } else if (filter_price == "\$25 - \$50") {
              getFilterbothbrandandpriceData("2");
            } else if (filter_price == "\$50 - \$100") {
              getFilterbothbrandandpriceData("3");
            } else if (filter_price == "\$100 - \$200") {
              getFilterbothbrandandpriceData("4");
            } else if (filter_price == "\$200 and up") {
              getFilterbothbrandandpriceData("5");
            }
          } else {
            if (filter_price == "Under \$25") {
              if (condition1 == "Retail Tags") {
                getFilterthreebrandandpriceandconData("1", "1");
              } else {
                getFilterthreebrandandpriceandconData("1", "2");
              }
            } else if (filter_price == "\$25 - \$50") {
              if (condition1 == "Retail Tags") {
                getFilterthreebrandandpriceandconData("2", "1");
              } else {
                getFilterthreebrandandpriceandconData("2", "2");
              }
            } else if (filter_price == "\$50 - \$100") {
              if (condition1 == "Retail Tags") {
                getFilterthreebrandandpriceandconData("3", "1");
              } else {
                getFilterthreebrandandpriceandconData("3", "2");
              }
            } else if (filter_price == "\$100 - \$200") {
              if (condition1 == "Retail Tags") {
                getFilterthreebrandandpriceandconData("4", "1");
              } else {
                getFilterthreebrandandpriceandconData("4", "2");
              }
            } else if (filter_price == "\$200 and up") {
              if (condition1 == "Retail Tags") {
                getFilterthreebrandandpriceandconData("5", "1");
              } else {
                getFilterthreebrandandpriceandconData("5", "2");
              }
            }
          }
//          getFilterData();
        }
      }
    }
  }

  /*--------------------------------------filter_only_brand_data------------------------------*/
  getFilteronlybrandData() async {
    productList = new List();
    noteSub?.cancel();
    noteSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Shell_Product_Model> notes = snapshot.documents
          .map((documentSnapshot) =>
              Shell_Product_Model.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        for (int j = 0; j < brand_list.length; j++) {
          for (int i = 0; i < notes.length; i++) {
            if (Sub_cat_id == notes[i].sub_category_id) {
              if (notes[i].status == "0") {
                if (notes[i].item_brand == brand_list[j]) {
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
                        notes[i].brand_new));
                  }
                }
              }
            }
          }
        }
        this.productList = productList1;
      });
    });
  }

  /*--------------------------------------filter_both_brand_and_con_data------------------------------*/
  getFilterbothbrandandconData(String contype) async {
    productList = new List();
    noteSub?.cancel();
    noteSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Shell_Product_Model> notes = snapshot.documents
          .map((documentSnapshot) =>
              Shell_Product_Model.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        for (int j = 0; j < brand_list.length; j++) {
          for (int i = 0; i < notes.length; i++) {
            if (Sub_cat_id == notes[i].sub_category_id) {
              if (notes[i].status == "0") {
                if (notes[i].item_brand == brand_list[j]) {
                  if (type == "1") {
                    if (notes[i].retail_tag == "yes") {
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
                            notes[i].brand_new));
                      }
                    }
                  } else {
                    if (notes[i].any_sign_wear == "yes") {
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
                            notes[i].brand_new));
                      }
                    }
                  }
                }
              }
            }
          }
        }
        this.productList = productList1;
      });
    });
  }

  //new

  /*--------------------------------------filter_only_condition_data------------------------------*/
  getFilteronlyconditionData(String type) async {
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
              if (type == "1") {
                if (notes[i].retail_tag == "yes") {
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
                        notes[i].brand_new));
                  }
                }
              } else {
                if (notes[i].any_sign_wear == "yes") {
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
                        notes[i].brand_new));
                  }
                }
              }
            }
          }
        }
        this.productList = productList1;
      });
    });
  }

  // old

  /*--------------------------------------filter_only_condition_data------------------------------*/
  // getFilteronlyconditionData(String type) async {
  //   productList = new List();
  //   noteSub?.cancel();
  //   noteSub = db.getProductList().listen((QuerySnapshot snapshot) {
  //     final List<Shell_Product_Model> notes = snapshot.documents
  //         .map((documentSnapshot) =>
  //         Shell_Product_Model.fromMap(documentSnapshot.data))
  //         .toList();

  //     setState(() {
  //       for (int i = 0; i < notes.length; i++) {
  //         if (Sub_cat_id == notes[i].sub_category_id) {
  //           if (notes[i].status == "0") {
  //             if (type == "1") {
  //               if (notes[i].retail_tag == "yes") {
  //                 if (notes[i].user_id != user_id) {
  //                   productList1.add(Shell_Product_Model(
  //                       notes[i].any_sign_wear,
  //                       notes[i].category,
  //                       notes[i].category_id,
  //                       notes[i].country,
  //                       notes[i].date,
  //                       notes[i].favourite_count,
  //                       notes[i].is_cart,
  //                       notes[i].is_favorite_count,
  //                       notes[i].item_Ounces,
  //                       notes[i].item_brand,
  //                       notes[i].item_color,
  //                       notes[i].item_description,
  //                       notes[i].item_measurements,
  //                       notes[i].item_picture,
  //                       notes[i].item_pound,
  //                       notes[i].item_price,
  //                       notes[i].item_sale_price,
  //                       notes[i].item_size,
  //                       notes[i].item_sold,
  //                       notes[i].item_sub_title,
  //                       notes[i].item_title,
  //                       notes[i].item_type,
  //                       notes[i].packing_type,
  //                       notes[i].picture,
  //                       notes[i].product_id,
  //                       notes[i].retail_tag,
  //                       notes[i].shipping_charge,
  //                       notes[i].shipping_id,
  //                       notes[i].status,
  //                       notes[i].sub_category,
  //                       notes[i].sub_category_id,
  //                       notes[i].user_id,
  //                       notes[i].tracking_id,
  //                       notes[i].order_id
  //                   ));
  //                 }
  //               }
  //             } else {
  //               if (notes[i].any_sign_wear == "yes") {
  //                 if (notes[i].user_id != user_id) {
  //                   productList1.add(Shell_Product_Model(
  //                       notes[i].any_sign_wear,
  //                       notes[i].category,
  //                       notes[i].category_id,
  //                       notes[i].country,
  //                       notes[i].date,
  //                       notes[i].favourite_count,
  //                       notes[i].is_cart,
  //                       notes[i].is_favorite_count,
  //                       notes[i].item_Ounces,
  //                       notes[i].item_brand,
  //                       notes[i].item_color,
  //                       notes[i].item_description,
  //                       notes[i].item_measurements,
  //                       notes[i].item_picture,
  //                       notes[i].item_pound,
  //                       notes[i].item_price,
  //                       notes[i].item_sale_price,
  //                       notes[i].item_size,
  //                       notes[i].item_sold,
  //                       notes[i].item_sub_title,
  //                       notes[i].item_title,
  //                       notes[i].item_type,
  //                       notes[i].packing_type,
  //                       notes[i].picture,
  //                       notes[i].product_id,
  //                       notes[i].retail_tag,
  //                       notes[i].shipping_charge,
  //                       notes[i].shipping_id,
  //                       notes[i].status,
  //                       notes[i].sub_category,
  //                       notes[i].sub_category_id,
  //                       notes[i].user_id,
  //                       notes[i].tracking_id,
  //                       notes[i].order_id
  //                   ));
  //                 }
  //               }
  //             }
  //           }
  //         }
  //       }
  //       this.productList = productList1;
  //     });
  //   });
  // }

  /*--------------------------------------filter_both_brandandprice_data------------------------------*/
  getFilterbothbrandandpriceData(String type) async {
    productList = new List();
    noteSub?.cancel();
    noteSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Shell_Product_Model> notes = snapshot.documents
          .map((documentSnapshot) =>
              Shell_Product_Model.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        for (int j = 0; j < brand_list.length; j++) {
          for (int i = 0; i < notes.length; i++) {
            var value = int.tryParse(notes[i].item_price);
            if (Sub_cat_id == notes[i].sub_category_id) {
              if (notes[i].status == "0") {
                if (notes[i].item_brand == brand_list[j]) {
                  if (type == "1") {
                    if (value <= 25) {
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
                            notes[i].brand_new));
                      }
                    }
                  } else if (type == "2") {
                    if (value >= 25 && value <= 50) {
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
                            notes[i].brand_new));
                      }
                    }
                  } else if (type == "3") {
                    if (value >= 50 && value <= 100) {
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
                            notes[i].brand_new));
                      }
                    }
                  } else if (type == "4") {
                    if (value >= 100 && value <= 200) {
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
                            notes[i].brand_new));
                      }
                    }
                  } else if (type == "5") {
                    if (value >= 200) {
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
                            notes[i].brand_new));
                      }
                    }
                  }
                }
              }
            }
          }
        }
        this.productList = productList1;
      });
    });
  }

  /*--------------------------------------filter_three_brand_and_price_and_con_data------------------------------*/
  getFilterthreebrandandpriceandconData(
      String pricetype, String contype) async {
    productList = new List();
    noteSub?.cancel();
    noteSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Shell_Product_Model> notes = snapshot.documents
          .map((documentSnapshot) =>
              Shell_Product_Model.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        for (int j = 0; j < brand_list.length; j++) {
          for (int i = 0; i < notes.length; i++) {
            var value = int.tryParse(notes[i].item_price);
            if (Sub_cat_id == notes[i].sub_category_id) {
              if (notes[i].status == "0") {
                if (notes[i].item_brand == brand_list[j]) {
                  if (pricetype == "1") {
                    if (value <= 25) {
                      if (contype == "1") {
                        if (notes[i].retail_tag == "yes") {
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
                                notes[i].brand_new));
                          }
                        }
                      } else {
                        if (notes[i].any_sign_wear == "yes") {
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
                                notes[i].brand_new));
                          }
                        }
                      }
                    }
                  } else if (pricetype == "2") {
                    if (value >= 25 && value <= 50) {
                      if (contype == "1") {
                        if (notes[i].retail_tag == "yes") {
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
                                notes[i].brand_new));
                          }
                        }
                      } else {
                        if (notes[i].any_sign_wear == "yes") {
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
                                notes[i].brand_new));
                          }
                        }
                      }
                    }
                  } else if (pricetype == "3") {
                    if (value >= 50 && value <= 100) {
                      if (contype == "1") {
                        if (notes[i].retail_tag == "yes") {
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
                                notes[i].brand_new));
                          }
                        }
                      } else {
                        if (notes[i].any_sign_wear == "yes") {
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
                                notes[i].brand_new));
                          }
                        }
                      }
                    }
                  } else if (pricetype == "4") {
                    if (value >= 100 && value <= 200) {
                      if (contype == "1") {
                        if (notes[i].retail_tag == "yes") {
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
                                notes[i].brand_new));
                          }
                        }
                      } else {
                        if (notes[i].any_sign_wear == "yes") {
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
                                notes[i].brand_new));
                          }
                        }
                      }
                    }
                  } else if (pricetype == "5") {
                    if (value >= 200) {
                      if (contype == "1") {
                        if (notes[i].retail_tag == "yes") {
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
                                notes[i].brand_new));
                          }
                        }
                      } else {
                        if (notes[i].any_sign_wear == "yes") {
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
                                notes[i].brand_new));
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        this.productList = productList1;
      });
    });
  }

  /*--------------------------------------filter_only_price_data------------------------------*/
  getFilteronlypriceData(String type) async {
    productList = new List();
    noteSub?.cancel();
    noteSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Shell_Product_Model> notes = snapshot.documents
          .map((documentSnapshot) =>
              Shell_Product_Model.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        for (int i = 0; i < notes.length; i++) {
          var value = int.tryParse(notes[i].item_price);
//             int price = notes[i].Item_price.toString() as int;
          if (Sub_cat_id == notes[i].sub_category_id) {
            if (notes[i].status == "0") {
              if (type == "1") {
                if (value <= 25) {
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
                        notes[i].brand_new));
                  }
                }
              } else if (type == "2") {
                if (value >= 25 && value <= 50) {
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
                        notes[i].brand_new));
                  }
                }
              } else if (type == "3") {
                if (value >= 50 && value <= 100) {
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
                        notes[i].brand_new));
                  }
                }
              } else if (type == "4") {
                if (value >= 100 && value <= 200) {
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
                        notes[i].brand_new));
                  }
                }
              } else if (type == "5") {
                if (value >= 200) {
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
                        notes[i].brand_new));
                  }
                }
              }
            }
          }
        }
        this.productList = productList1;
      });
    });
  }

  /*--------------------------------------filter_both_price_and_condition_data------------------------------*/
  getFilterbothpriceandconData(String pricetype, String contype) async {
    productList = new List();
    noteSub?.cancel();
    noteSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Shell_Product_Model> notes = snapshot.documents
          .map((documentSnapshot) =>
              Shell_Product_Model.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        for (int i = 0; i < notes.length; i++) {
          var value = int.tryParse(notes[i].item_price);
//             int price = notes[i].Item_price.toString() as int;
          if (Sub_cat_id == notes[i].sub_category_id) {
            if (notes[i].status == "0") {
              if (pricetype == "1") {
                if (value <= 25) {
                  if (contype == "1") {
                    if (notes[i].retail_tag == "yes") {
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
                            notes[i].brand_new));
                      }
                    }
                  } else {
                    if (notes[i].any_sign_wear == "yes") {
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
                            notes[i].brand_new));
                      }
                    }
                  }
                }
              } else if (pricetype == "2") {
                if (value >= 25 && value <= 50) {
                  if (contype == "1") {
                    if (notes[i].retail_tag == "yes") {
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
                            notes[i].brand_new));
                      }
                    }
                  } else {
                    if (notes[i].any_sign_wear == "yes") {
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
                            notes[i].brand_new));
                      }
                    }
                  }
                }
              } else if (pricetype == "3") {
                if (value >= 50 && value <= 100) {
                  if (contype == "1") {
                    if (notes[i].retail_tag == "yes") {
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
                            notes[i].brand_new));
                      }
                    }
                  } else {
                    if (notes[i].any_sign_wear == "yes") {
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
                            notes[i].brand_new));
                      }
                    }
                  }
                }
              } else if (pricetype == "4") {
                if (value >= 100 && value <= 200) {
                  if (contype == "1") {
                    if (notes[i].retail_tag == "yes") {
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
                            notes[i].brand_new));
                      }
                    }
                  } else {
                    if (notes[i].any_sign_wear == "yes") {
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
                            notes[i].brand_new));
                      }
                    }
                  }
                }
              } else if (pricetype == "5") {
                if (value >= 200) {
                  if (contype == "1") {
                    if (notes[i].retail_tag == "yes") {
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
                            notes[i].brand_new));
                      }
                    }
                  } else {
                    if (notes[i].any_sign_wear == "yes") {
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
                            notes[i].brand_new));
                      }
                    }
                  }
                }
              }
            }
          }
        }
        this.productList = productList1;
      });
    });
  }

  getData() async {
    productList = new List();

    CollectionReference ref = Firestore.instance.collection('product');
    QuerySnapshot eventsQuery = await ref
        .where("category_id", isEqualTo: Cat_id)
        .where('status', isEqualTo: "0")
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {});
    } else {
      eventsQuery.documents.forEach((doc) async {
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
      });

      setState(() {
        this.productList = productList1;
      });
    }
  }

  getSubc() async {
    productList = new List();

    CollectionReference ref = Firestore.instance.collection('product');
    QuerySnapshot eventsQuery = await ref
        .where("sub_category_id", isEqualTo: Sub_cat_id)
        .where('status', isEqualTo: "0")
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {});
    } else {
      eventsQuery.documents.forEach((doc) async {
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
      });
      if (this.mounted) {
        setState(() {
          this.productList = productList1;
        });
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.black;
    Color foregroundColor = Colors.white70;
    var size = MediaQuery.of(context).size;
    itemHeight = (size.height - kToolbarHeight - 24) / 2;
    itemWidth = size.width / 2;
    final double shortTestsize = MediaQuery.of(context).size.shortestSide;
    final bool mobilesize = shortTestsize < 600;

    final Orientation orientation = MediaQuery.of(context).orientation;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Cat_name),
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
                    stream: Firestore.instance
                        .collection("cart")
                        .where("user_id", isEqualTo: user_id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      } else {
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
        Container(
          child: mobilesize
              ? _gridViewMobile(orientation: orientation)
              : _gridViewTablet(orientation: orientation),
        ),
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
//                                      MyNavigator.gotoFilter1_Screen(context);
                                    Navigator.of(context).pushReplacement(
                                        new MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                Filter1_Screen()));
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
      ]),
    );
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

  Widget _gridViewMobile({@required Orientation orientation}) {
    return GridView.count(
      crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
      padding: const EdgeInsets.all(2.0),
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
      childAspectRatio: orientation == Orientation.portrait ? 0.6 : 0.7,
      children: productList
          .map(
            (shellProductModel) => ItemList(item: shellProductModel),
          )
          .toList(),
    );
  }

  Widget _gridViewTablet({@required Orientation orientation}) {
    return GridView.count(
      crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
      padding: const EdgeInsets.all(2.0),
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
      childAspectRatio: orientation == Orientation.portrait ? 0.7 : 0.8,
      children: productList
          .map((shellProductModel) => ItemList(item: shellProductModel))
          .toList(),
    );
  }
}

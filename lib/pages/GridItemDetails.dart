import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Cart.dart';
import 'package:threadon/model/Share.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/Coman_SearchList_Screen.dart';
import 'package:threadon/pages/Compare_department_detail.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';

import 'package:flutter/services.dart';

class CartAdd {
  String id;
  String productid;
  String status;
  String user_id;
  DateTime date;

  CartAdd(this.id, this.productid, this.status, this.user_id, this.date);
  CartAdd.map(dynamic obj) {
    this.id = obj['id'];
    this.productid = obj['productid'];
    this.status = obj['status'];
    this.user_id = obj['user_id'];
    this.date = obj['date'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['productid'] = productid;
    map['status'] = status;
    map['user_id'] = user_id;
    map['date'] = date;
    return map;
  }

  CartAdd.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.productid = map['productid'];
    this.status = map['status'];
    this.user_id = map['user_id'];
    this.date = map['date'];
  }
}

class GridItemDetails extends StatefulWidget {
  final Shell_Product_Model item;

  const GridItemDetails({this.item});

  @override
  State<StatefulWidget> createState() => new griditemdetail(this.item);
// TODO: implement createState
}

class griditemdetail extends State<GridItemDetails> {
  List<CartAdd> cartAddItemList;
  List<CartAdd> cartAddItemList1 = new List<CartAdd>();

  List<Shell_Product_Model> productList1 = new List<Shell_Product_Model>();
  List<Shell_Product_Model> similerproductList =
      new List<Shell_Product_Model>();

  final Shell_Product_Model item;
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;

  bool _isInAsyncCall = true;
  String user_id = '',
      user_name = '',
      profile_image = '',
      Share_id = '',
      flag = '0',
      sheller_name = '',
      sheller_profileImage = '',
      sub_cat_id = "",
      cat_id = "",
      follower = "0",
      following = "0";

  String Carttotal = "0";
  List UplodImageList = new List();
  List<Cart> cart_list;
  List<Cart> cartList;
  int cart_count;
  List<Cart> cartList1 = new List<Cart>();

  String item_list = "0";
  String fav_id = '';
  List<Share> shareList1 = new List();

  final myController = TextEditingController();
  List<Share> shareList;
  List itemPicher = new List();

  griditemdetail(this.item);

  bool favourite = false;
  bool pressAttention = false;
  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  String date;
  String Favourit = "0";
  List<String> favlist_id = new List();
  List<String> favid = new List();
  String profile_userid = "";
  int _current = 0;
  List share_product_id;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    getCredential();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    UplodImageList = item.item_picture.toList();
    profile_userid = item.user_id;
    share_product_id = new List();
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

  /*----------------------------------------snackbar-------------------------------*/

  void showInSnackBar(String value) {
    _scaffold.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  _showSnackBar(String messageString) {
    print(messageString);
    final snackBar = new SnackBar(
      content: new Text(
        messageString,
        style: new TextStyle(fontWeight: FontWeight.normal, fontSize: 15.0),
      ),
//      duration: new Duration(seconds: 20),
      backgroundColor: Colors.black,
      action: new SnackBarAction(
          label: "BAG",
          textColor: Colors.red,
          onPressed: () {
            print("Action from Click SnackBar");
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => CartScreen()));
          }),
    );
    _scaffold.currentState.showSnackBar(snackBar);
  }

  /*----------------------------------------favourite_submit-------------------------------*/

  /*----------------------------------------cart_submit-------------------------------*/

  void cartsubmit(String productid) async {
    CollectionReference ref = Firestore.instance.collection('cart');
    QuerySnapshot eventsQuery = await ref
        .where("product_id", isEqualTo: productid)
        .where("user_id", isEqualTo: user_id)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      DateTime date = DateTime.now();
      //String datea = date.toString();

      Firestore.instance.collection('cart').add({
        'cart_id': '',
        'product_id': productid,
        'status': '0',
        'user_id': user_id,
        'date': date
      }).then((val) {
        var docId = val.documentID;
        var updateId = {"cart_id": docId};

        Firestore.instance
            .collection("cart")
            .document(docId)
            .updateData(updateId)
            .then((val) {
          setState(() {
            _isInAsyncCall = false;
          });
          print("cart item added sucess");
        }).catchError((err) {
          print(err);
        });
      });

      // noteSub?.cancel();
      // db.cartItem('', productid, '0', user_id, DateTime.now()).then((_) {
      //   print("Debuge : call");
      //   setState(() {
      //     _isInAsyncCall = false;
      //   });
      // });

      _showSnackBar('Item Added to Bag');
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      /*DateTime date = DateTime.now();
      String datea = date.toString();
      db.updateCart(Cart('', productid, '0', userId, datea));*/
      setState(() {
        _isInAsyncCall = false;
      });
      _showSnackBar('Product is already Added.');
    }
  }

  /*----------------------------------------get_cart_-------------------------------*/

  /*-----------------------------------------------------------------------*/

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // sub_cat_id = await SharedPreferencesHelper.getsubcat_id();
    // cat_id = await SharedPreferencesHelper.getcat_id();
    user_id = sharedPreferences.getString("user_id");
    cat_id = item.category_id;
    sub_cat_id = item.sub_category_id;

    if (user_id == null) {
      user_id = "";
    }
    user_name = sharedPreferences.getString("UserName");
    profile_image = sharedPreferences.getString("profile_image");
    flag = sharedPreferences.getString("flag1");
    String sellarId = item.user_id;

    sharedPreferences.setString('seller_id', sellarId);

    CollectionReference ref = Firestore.instance.collection('users');

    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: sellarId).getDocuments();

    eventsQuery.documents.forEach((doc) async {
      sheller_profileImage = doc["profile_picture"];
      sheller_name = doc['name'];
      follower = doc['followers'];

      following = doc['following'];
    });

    getItemDAta(sellarId);
  }

  Widget build(BuildContext context) {
    if (item.status == '2') {
      pressAttention = true;
    } else {}

    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffold,
      primary: true,
      appBar: AppBar(
        title: Text(item.item_title),
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
      body: ModalProgressHUD(
        child: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10.0),
              color: Colors.white,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                        alignment: Alignment.topCenter,
                        child: item.item_picture.length != 0 &&
                                item.item_picture.length != null
                            ? new CarouselSlider(
                                items: item.item_picture.map((i) {
                                  return new Builder(
                                    builder: (BuildContext context) {
                                      return new GestureDetector(
                                        child: Container(

                                            /*decoration: new BoxDecoration(
                                        image: NetworkImage('$i')
                                    ),*/

                                            /* child: CachedNetworkImage(
                                    imageUrl: ('$i'),
                                    placeholder: new CircularProgressIndicator(),
                                    errorWidget: new Icon(Icons.error),
                                  ),*/
                                            child: Center(
                                          // child: new Hero(
                                          //   tag: "preview",
                                          child: new Container(
                                              alignment:
                                                  FractionalOffset.center,
                                              child: FadeInImage.assetNetwork(
                                                placeholder:
                                                    'assets/image_pro1.gif',
                                                image: ('$i'),
                                                fit: BoxFit.contain,
                                              )),
                                          // ),
                                        )
                                            /*child:FadeInImage.assetNetwork(
                                          placeholder: 'assets/image_pro1.gif',
                                          image: ('$i'),
                                          fit: BoxFit.contain,

                                        ),*/
                                            ),
                                        onTap: () {
/*
                                          showDialog(
                                            context: context,
                                            child: new AlertDialog(
                                              backgroundColor: Colors.transparent,
                                              content: new Hero(
                                                tag: "preview",
                                                child: Container(
                                                  height: 350.0,
                                                    child: PhotoView(
                                                      imageProvider: NetworkImage('$i'),backgroundDecoration: BoxDecoration(
                                                      color: Colors.transparent
                                                    ),
                                                    )
                                                )
                                              ),
                                            ),
                                          );*/
                                          //_buildCustomButton("Hero on Dialog", _buildPopUp(context), isPopup: true);

                                          // Navigator.push(context, MaterialPageRoute(builder: (context) => ImageZoomScreen(item.item_title,)));
                                        },
                                      );
                                    },
                                  );
                                }).toList(),
                                autoPlay: true,
                                height: 380.0,
                                viewportFraction: 1.0,
                                onPageChanged: (index) {
                                  setState(() {
                                    _current = index;
                                  });
                                },
                              )
                            : new CarouselSlider(
                                items: [
                                  'images/tonlogo.png',
                                  'images/tonlogo.png',
                                  'images/tonlogo.png'
                                ].map((i) {
                                  return new Builder(
                                    builder: (BuildContext context) {
                                      return new Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: new EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        /*decoration: new BoxDecoration(
                                        image: NetworkImage('$i')
                                    ),*/

                                        /* child: CachedNetworkImage(
                                    imageUrl: ('$i'),
                                    placeholder: new CircularProgressIndicator(),
                                    errorWidget: new Icon(Icons.error),
                                  ),*/
                                        child: FadeInImage.assetNetwork(
                                          placeholder: 'images/tonlogo.png',
                                          image: ('$i'),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                                autoPlay: true,
                                height: 380.0,
                                viewportFraction: 1.0,
                                onPageChanged: (index) {
                                  setState(() {
                                    _current = index;
                                  });
                                },
                              )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: map<Widget>(
                        item.item_picture,
                        (index, url) {
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: EdgeInsets.only(
                                top: 20.0, bottom: 10.0, left: 3.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _current == index
                                    ? Color.fromRGBO(0, 0, 0, 0.9)
                                    : Color.fromRGBO(0, 0, 0, 0.4)),
                          );
                        },
                      ),
                    ),
                  ]),
            ),
//          GetTags(),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 5.0),
              child: Text(
                item.item_title,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
//          Container(
//            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
//            child: Text(
//              'not',
//              style: TextStyle(
//                fontSize: 13.0,
//                color: Colors.black,
//              ),
//            ),
//          ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: new Row(
                children: <Widget>[
                  Text(
                    "Size :    ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.0,
                    ),
                  ),
                  Text(
                    item.item_size,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              alignment: Alignment.topLeft,
              child: new RichText(
                textAlign: TextAlign.left,
                text: new TextSpan(
                  text: 'Sale Price: ',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    new TextSpan(
                      text: '\$' + item.item_sale_price,
                      style: new TextStyle(
                        fontSize: 18.0,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                alignment: Alignment.topLeft,
                child: new Column(children: <Widget>[
                  new RichText(
                    textAlign: TextAlign.left,
                    text: new TextSpan(
                      text: 'Product Price: ',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black26,
                        fontWeight: FontWeight.bold,
                      ),
                      children: <TextSpan>[
                        new TextSpan(
                          text: '\$' + item.item_price,
                          style: new TextStyle(
                              fontSize: 16.0,
                              color: Colors.black26,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.lineThrough),
                        ),
                      ],
                    ),
                  ),
                ])),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
              child: item.shipping_charge == "" || item.shipping_charge == null
                  ? Text(
                      "Shipping charge  " + "---",
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.black45,
                      ),
                    )
                  : Text(
                      "Shipping charge  " + "\$" + item.shipping_charge,
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.black45,
                      ),
                    ),
            ),

            Container(
              margin: EdgeInsets.only(
                  top: 20.0, left: 10.0, right: 10.0, bottom: 0.0),
              child: item.status == "0"
                  ? new RaisedButton(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 15.0,
                      ),
                      child: new Text('Add to Bag',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.white, fontSize: 18.0)),
                      textColor: Colors.white,
                      color: Colors.black,
                      onPressed: () async {
                        if (user_id != item.user_id) {
                          if (user_id == "") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignupPage()));
                          } else {
                            cartsubmit(item.product_id);
                            setState(() {
                              _isInAsyncCall = true;
                            });
                          }
                        } else {
                          showInSnackBar('It\'s your own product!');
                        }
                      })
                  : new RaisedButton(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 15.0,
                      ),
                      child: new Text('Sold Out',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.white, fontSize: 18.0)),
                      textColor: Colors.white,
                      color: Colors.black,
                      onPressed:
                          null /*async {
                    if (user_id == null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupPage()));
                    } else {
                      cartsubmit(item.product_id);
                      setState(() {
                        _isInAsyncCall = true;
                      });
                    }
                  }*/
                      ),
            ),

            Container(
              margin: EdgeInsets.only(
                  top: 5.0, left: 10.0, right: 10.0, bottom: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Container(
                        child: Card(
                      elevation: 4.0,
                      shape: new RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black)),
                      child: FlatButton.icon(
//                        onPressed: () => _openAddUserDialog(),
                        onPressed: () {
                          getfavProduct(item.product_id);
                          if (user_id == "") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignupPage()));
                          } else {
                            _openAddUserDialog('');
                          }
                        },
                        icon: favourite
                            ? new Icon(Icons.favorite)
                            : new Icon(
                                Icons.favorite_border,
                              ),
                        label: Text(
                          'Favorite',
                          style: TextStyle(color: Colors.black, fontSize: 17.0),
                        ),
                      ),
                    )),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                        child: Card(
                      elevation: 4.0,
                      shape: new RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black)),
                      child: FlatButton.icon(
                        onPressed: () async {
                          if (user_id == "") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignupPage()));
                          } else {
                            SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();

                            // if(flag == null || flag == "0") {
                            sharedPreferences.setString(
                                'Title', item.item_title);
                            sharedPreferences.setString('Image', item.picture);
                            sharedPreferences.setString('Size', item.item_size);
                            sharedPreferences.setString(
                                'Price', item.item_price);
                            sharedPreferences.setString('Type', 'Not');
                            sharedPreferences.setString(
                                'Color', item.item_color);
                            sharedPreferences.setString(
                                'Brand', item.item_brand);
                            sharedPreferences.setString('pid', item.product_id);
                            //sharedPreferences.setString('flag1', '1');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CompareDepartmentsScreen(
                                            tool_name: 'Compare product')));
                          }
                        },
                        icon: Icon(
                          Icons.compare,
                          color: Colors.black,
                        ),
                        label: Text(
                          'Compare',
                          style: TextStyle(color: Colors.black, fontSize: 17.0),
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "20 people saved this item",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 13.0,
                    ),
                  ),
                ],
              ),
            ),

            new Divider(color: Colors.black26),

            new GestureDetector(
              onTap: () {
                if (user_id == profile_userid) {
                  MyNavigator.gotoEditProfile(context);
                } else {
                  MyNavigator.gotoSeller_Profile_Screen(context);
                }
              },
              child: new Row(
                children: <Widget>[
                  new GestureDetector(
                      //
                      // onTap: () {
                      //   if (user_id == profile_userid) {
                      //     MyNavigator.gotoEditProfile(context);
                      //   } else {
                      //     MyNavigator.gotoSeller_Profile_Screen(context);
                      //   }
                      // },
                      child: sheller_profileImage == ""
                          ? new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                  new Container(
                                    height: 70.0,
                                    width: 70.0,
                                    margin:
                                        EdgeInsets.only(left: 10.0, top: 10),
                                    decoration: new BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black54, width: 2.0),
                                      borderRadius: new BorderRadius.all(
                                          const Radius.circular(70.0)),
                                    ),
                                    child: new CircleAvatar(
                                      radius: 60.0,
                                      backgroundColor: Colors.white,
                                      backgroundImage: AssetImage(
                                          'images/placeholder_face.png'),
                                    ),
                                  )
                                ])
                          : new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Container(
                                  alignment: Alignment.topLeft,
                                  height: 70.0,
                                  width: 70.0,
                                  margin: EdgeInsets.only(left: 10.0, top: 10),
                                  decoration: new BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black54, width: 2.0),
                                    borderRadius: new BorderRadius.all(
                                        const Radius.circular(70.0)),
                                  ),
                                  child: new CircleAvatar(
                                    radius: 60.0,
                                    backgroundColor: Colors.white,
                                    backgroundImage:
                                        NetworkImage(sheller_profileImage),
                                  ),
                                ),
                                /* new Center(
                        //  child: new Image.asset("assets/photo_camera.png"),
                        child: Icon(Icons.perm_identity),
                      ),*/
                              ],
                            )),
                  /*  new Container(
                      margin: const EdgeInsets.only(
                          left: 10.0, right: 0.0, top: 0.0, bottom: 0.0),
                      width: 60.0,
                      height: 60.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new NetworkImage(sheller_profileImage)))),*/
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 20.0, right: 0.0, top: 0.0, bottom: 0.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Listed by: ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13.0,
                            ),
                          ),
                          Text(
                            sheller_name,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),

            new Divider(color: Colors.black26),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: Text(
                "Item Description",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
              child:
                  item.item_description != "" && item.item_description != null
                      ? Text(
                          item.item_description,
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          "----",
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Colors.black,
                          ),
                        ),
            ),

            new Divider(color: Colors.black26),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: Text(
                "Item Details",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: new Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Type",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Text(
                      '' + 'not',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: new Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Size",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: item.item_size != "" && item.item_size != null
                        ? Text(
                            item.item_size,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            "----",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: new Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Color",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: item.item_color != "" && item.item_color != null
                        ? Text(
                            item.item_color,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            "----",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: new Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Brand",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: item.item_brand != "" && item.item_brand != null
                        ? Text(
                            item.item_brand,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            "----",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(
                  left: 10.0, right: 30.0, top: 0.0, bottom: 10.0),
              alignment: Alignment.center,
              decoration: new BoxDecoration(color: Colors.white),
              child: new Row(
                children: <Widget>[
                  Container(
                      child: Card(
                    elevation: 4.0,
                    shape: new RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black)),
                    child: FlatButton.icon(
                      onPressed: () async {
                        if (user_id == "") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupPage()));
                        } else {
                          await SharedPreferencesHelper.setproduct_id(
                              item.product_id);
                          MyNavigator.gotoReport_Screen(context);
                        }
                      },
                      icon: Icon(
                        Icons.report,
                        color: Colors.black,
                      ),
                      label: Text(
                        'Report this item',
                        style: TextStyle(color: Colors.black, fontSize: 17.0),
                      ),
                    ),
                  )),
                ],
              ),
            ),

            // Container(
            //   padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
            //   child: Text(
            //     'Similar Items',
            //     style: TextStyle(
            //       fontSize: 16.0,
            //       color: Colors.black,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            Container(
              child: getSimilerProduct(),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
              child: Text(
                "Returns",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
              child: Text(
                "Return this item for any reason and get Threadon Site Credit. \n Submit a simple return request within 4 days of delivery. \n Free return shipping included.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13.0,
                ),
              ),
            ),

            Container(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                child: GestureDetector(
                  onTap: () => MyNavigator.gotoWebViewScreen(
                      context, 'Item Returns Policy', "threadon.com/return"),
                  child: Text(
                    "LEARN MORE",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold),
                  ),
                )),

            new Divider(color: Colors.black26),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
              child: Text(
                "Our Guarantee",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
              child: Text(
                "Get what you ordered, or your money back. we 'll give you a full refund if the authenticity, condition, or style of the item are in any way misrepresented in this listing.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13.0,
                ),
              ),
            ),

            Container(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                child: GestureDetector(
                  onTap: () => MyNavigator.gotoWebViewScreen(
                      context, 'Our Guarantee', "threadon.com/gaurantee"),
                  child: Text(
                    "LEARN MORE",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold),
                  ),
                )),

            new Divider(color: Colors.black26),

            ListTile(
              leading: Icon(Icons.email),
              title: Text('Help & Support'),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(70.0, 0.0, 10.0, 10.0),
              child: Text(
                "Get Instant answers to your questions Or contact us so we can help",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13.0,
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(70.0, 0.0, 10.0, 10.0),
                child: GestureDetector(
                  onTap: () => MyNavigator.gotoWebViewScreen(
                      context, 'Help & Support', "threadon.com/helpsupport"),
                  child: Text(
                    "LEARN MORE",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold),
                  ),
                )),

            new Divider(color: Colors.black26),

            new Divider(color: Colors.black26),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
//            margin: const EdgeInsets.only(left: 20.0, right: 0.0, top: 0.0, bottom: 0.0),
              child: new GestureDetector(
                onTap: () {
                  if (user_id == profile_userid) {
                    MyNavigator.gotoEditProfile(context);
                  } else {
                    MyNavigator.gotoSeller_Profile_Screen(context);
                  }
                },
                child: new Row(
                  children: <Widget>[
                    new GestureDetector(
                        //
                        // onTap: () {
                        //   if (user_id == profile_userid) {
                        //     MyNavigator.gotoEditProfile(context);
                        //   } else {
                        //     MyNavigator.gotoSeller_Profile_Screen(context);
                        //   }
                        // },
                        child: sheller_profileImage == ""
                            ? new Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                    new Container(
                                      height: 70.0,
                                      width: 70.0,
                                      margin:
                                          EdgeInsets.only(left: 10.0, top: 10),
                                      decoration: new BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black54, width: 2.0),
                                        borderRadius: new BorderRadius.all(
                                            const Radius.circular(70.0)),
                                      ),
                                      child: new CircleAvatar(
                                        radius: 60.0,
                                        backgroundColor: Colors.white,
                                        backgroundImage: AssetImage(
                                            'images/placeholder_face.png'),
                                      ),
                                    )
                                  ])
                            : new Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  new Container(
                                    alignment: Alignment.topLeft,
                                    height: 70.0,
                                    width: 70.0,
                                    margin:
                                        EdgeInsets.only(left: 10.0, top: 10),
                                    decoration: new BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black54, width: 2.0),
                                      borderRadius: new BorderRadius.all(
                                          const Radius.circular(70.0)),
                                    ),
                                    child: new CircleAvatar(
                                      radius: 60.0,
                                      backgroundColor: Colors.white,
                                      backgroundImage:
                                          NetworkImage(sheller_profileImage),
                                    ),
                                  ),
                                  /* new Center(
                        //  child: new Image.asset("assets/photo_camera.png"),
                        child: Icon(Icons.perm_identity),
                      ),*/
                                ],
                              )),
                    /* new Container(
                        margin: const EdgeInsets.only(
                            left: 10.0, right: 0.0, top: 0.0, bottom: 0.0),
                        width: 75.0,
                        height: 75.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                                fit: BoxFit.fill,
                                image:
                                    new NetworkImage(sheller_profileImage)))),*/
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 20.0, right: 0.0, top: 0.0, bottom: 0.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Listed by: ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                              ),
                            ),
                            Text(
                              sheller_name,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            Container(
              //  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),

              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        item_list,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "ITEMS",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                          child: Favourit != "0"
                              ? Text(
                                  Favourit,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  Favourit,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                      Text(
                        "FAVORITES",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        follower != "" ? follower : '0',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "FOLLOWERS",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        following != "" ? following : '0',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "FOLLOWING",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            new Divider(color: Colors.black26),

            new Divider(color: Colors.black26),

            // Container(
            //     padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: <Widget>[
            //        Expanded(child: Text(
            //           "More from " + sheller_name,
            //           style: TextStyle(
            //             color: Colors.black,
            //             fontSize: 18.0,
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //        ),
            //         GestureDetector(
            //           onTap: () {
            //             if (user_id == profile_userid) {
            //               MyNavigator.gotoEditProfile(context);
            //             } else {
            //               MyNavigator.gotoSeller_Profile_Screen(context);
            //             }
            //           },
            //           child: Text(
            //             "See All",
            //             style: TextStyle(
            //               color: Colors.black,
            //               fontSize: 16.0,
            //               fontWeight: FontWeight.normal,
            //             ),
            //           ),
            //         )
            //       ],
            //     )),
            Container(
              child: getMoreItems(),
            ),

//            GetTrailers(this.productList),
          ],
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.7,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }

  Widget getMoreItems() {
    if (productList1.length > 1) {
      return Column(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "More from " + sheller_name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (user_id == profile_userid) {
                        MyNavigator.gotoEditProfile(context);
                      } else {
                        MyNavigator.gotoSeller_Profile_Screen(context);
                      }
                    },
                    child: Text(
                      "See All",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  )
                ],
              )),
          Container(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productList1.length,
                itemBuilder: (context, position) {
                  return GestureDetector(
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 15.0),
                        alignment: Alignment.centerRight,
                        color: Colors.white,
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 200,
                              padding: EdgeInsets.only(top: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  /*GestureDetector(
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 120.0, right: 30.0, top: 0.0),
                                      alignment: Alignment.centerRight,
                                      child: ListTile(
                                        leading: Icon(Icons.favorite_border),
                                      ),
                                    ),
//                onTap:() => _openAddUserDialog ,
                                    onTap: () {
                                      _openAddUserDialog();
                                    },
                                  ),*/
                                  AspectRatio(
                                    aspectRatio: 18.0 / 12.0,
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'images/tonlogo.png',
                                      image: productList1[position].picture,
                                      width: 100.0,
                                      height: 100.0,
                                      fit: BoxFit.scaleDown,
                                    ),
                                    /*child: Image.network(
                                      productList1[position].Picture,
                                    ),*/
                                  ),
                                  new Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        10.0, 10.0, 4.0, 0.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        new Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Text(
                                            productList1[position].item_title,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        new Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Text(
                                            productList1[position].category,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: 0.0),
//                  GetRatings(),
                                        SizedBox(height: 2.0),

                                        new Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Text(
                                            "\$" +
                                                productList1[position]
                                                    .item_price,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: 0.0),
//                  GetRatings(),
                                        SizedBox(height: 2.0),

                                        new Container(
                                            child: Text(
                                          productList1[position].item_size,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            new Divider(color: Colors.black26),
                          ],
                        ),
                        // photo and title
                      ),
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GridItemDetails(item: productList1[position]),
                          ),
                        );
                      });
                },
              )),
        ],
      );
    }
  }

  getSimilerDAta() async {
    CollectionReference ref = Firestore.instance.collection('product');

    QuerySnapshot eventsQuery = await ref
        .where("status", isEqualTo: '0')
        .where("category_id", isEqualTo: cat_id)
        .limit(6)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
          return favourite = false;
        });
      }
    } else {
      eventsQuery.documents.forEach((doc) async {
        if (item.product_id != doc['product_id']) {
          similerproductList.add(Shell_Product_Model(
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
              doc['like_new']));
        }
      });
      if (!mounted) return;
      setState(() {
        similerproductList = this.similerproductList;
      });
    }

    getSellerDAta();
  }

  Future getSellerDAta() async {
    CollectionReference ref = Firestore.instance.collection('product');
    QuerySnapshot eventsQuery = await ref
        .where("status", isEqualTo: '0')
        .where("user_id", isEqualTo: profile_userid)
        .limit(6)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
          return favourite = false;
        });
      }
    } else {
      eventsQuery.documents.forEach((doc) async {
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
            doc['like_new']));
      });
      if (this.mounted) {
        setState(() {
          productList1 = this.productList1;
        });
      }
    }
    getFavCount();
  }

  Widget getSimilerProduct() {
    if (similerproductList.length != 0 && similerproductList.length != null) {
      return Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: Text(
              'Similar Items',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 270,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: similerproductList.length,
                itemBuilder: (context, position) {
                  return GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 5.0, right: 5.0, top: 15.0),
                      alignment: Alignment.centerRight,
                      color: Colors.white,
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 10.0),
                            width: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                AspectRatio(
                                  aspectRatio: 18.0 / 12.0,
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'images/tonlogo.png',
                                    image: similerproductList[position].picture,
                                    width: 100.0,
                                    height: 100.0,
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                                new Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(10.0, 10.0, 4.0, 0.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          similerproductList[position]
                                              .item_title,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      new Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          similerproductList[position].category,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 0.0),
//                  GetRatings(),
                                      SizedBox(height: 2.0),

                                      new Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          "\$" +
                                              similerproductList[position]
                                                  .item_price,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 0.0),
//                  GetRatings(),
                                      SizedBox(height: 2.0),

                                      new Container(
                                          child: Text(
                                        similerproductList[position].item_size,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          new Divider(color: Colors.black26),
                        ],
                      ),
                      // photo and title
                    ),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GridItemDetails(
                              item: similerproductList[position]),
                        ),
                      );
                    },
                  );
                }),
          )
        ],
      );
    }
  }

  Future getItemDAta(String id) async {
    CollectionReference ref = Firestore.instance.collection('product');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
        return favourite = false;
      });
    } else {
      item_list = eventsQuery.documents.length.toString();
      eventsQuery.documents.forEach((doc) async {
        favlist_id.add(doc['favourite_id']);
        return favourite = true;
      });
    }

    getData();
  }

  Future getData() async {
    CollectionReference ref = Firestore.instance.collection('favourite_item');
    QuerySnapshot eventsQuery = await ref
        .where("product_id", isEqualTo: item.product_id)
        .where("user_id", isEqualTo: user_id)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      /* DateTime date = DateTime.now();
        String datea = date.toString();
        noteSub?.cancel();
        db.cartItem('', productid, '0', userId, datea).then((_) {
          geetcart();
        });
        sharedPreferences.setString('pid', '');*/
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
          return favourite = false;
        });
      }
    } else {
      eventsQuery.documents.forEach((doc) async {
        favlist_id.add(doc['favourite_id']);
        return favourite = true;
      });
    }

    getSimilerDAta();
  }

  Future getfavProduct(String pid) async {
    CollectionReference ref = Firestore.instance.collection('favourite_item');
    QuerySnapshot eventsQuery = await ref
        .where("product_id", isEqualTo: pid)
        .where("user_id", isEqualTo: user_id)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      /* DateTime date = DateTime.now();
        String datea = date.toString();
        noteSub?.cancel();
        db.cartItem('', productid, '0', userId, datea).then((_) {
          geetcart();
        });
        sharedPreferences.setString('pid', '');*/
      setState(() {
        _isInAsyncCall = false;
        return favourite = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        favid.add(doc['favourite_id']);
        return favourite = true;

        _isInAsyncCall = false;
      });
    }
    setState(() {
      _isInAsyncCall = false;
      // _isInAsyncCall = false;
    });
  }

  /*----------------------------------------favorite_dialog-------------------------------*/

  Future _openAddUserDialog(String id) async {
    shareList = new List();
    shareList1.clear();
    AlertDialog dialog;

    CollectionReference ref = Firestore.instance.collection('share_list');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
    } else {
      eventsQuery.documents.forEach((doc) async {
        shareList.add(Share(
            doc['share_id'],
            doc['user_id'],
            doc['date'].toDate(),
            doc['share_list_name'],
            doc['share_product_id']));

        _isInAsyncCall = false;
      });
    }
    setState(() {
      this.shareList1 = shareList;
    });

    dialog = new AlertDialog(
      content: new Container(
        width: 260.0,
        height: 300.0,
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
                      'Add Item to your',
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

            Container(
                child: Card(
              elevation: 4.0,
              shape: new RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black)),
//                  color: Colors.black,
              child: FlatButton.icon(
                onPressed: () => (setState(() {
                  if (user_id == "") {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignupPage()));
                  } else {
                    if (favourite) {
                      id = favid[0].toString();
                      unfavouritesubmit(id);
                    } else {
                      favourite = true;
                      favouritesubmit();
                    }
                  }
                })),
                icon: favourite
                    ? new Icon(Icons.favorite)
                    : new Icon(
                        Icons.favorite_border,
                      ),
//                    icon: Icon(Icons.favorite_border, color: Colors.black,),
                label: Text(
                  'Favorite',
                  style: TextStyle(color: Colors.black, fontSize: 17.0),
                ),
              ),
            )),

            Container(
              height: 150,
              child: ListView.builder(
                itemCount: shareList.length,
                itemBuilder: (context, position) {
                  return GestureDetector(
                      child: Container(
                        margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                        height: 50.0,
                        alignment: Alignment.centerRight,
                        color: Colors.white,
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Text(
                                '${shareList[position].share_list_name}',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black87),
                                maxLines: 1,
                              ),
                            ),
                            new Divider(color: Colors.black26),
                          ],
                        ),
                        // photo and title
                      ),
                      onTap: () async {
                        Share_id = '${shareList[position].share_id}';
                        submit(Share_id);
                      });
                },
              ),
            ),

            Container(
                child: Card(
              elevation: 4.0,
              shape: new RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black)),
              color: Colors.black,
              child: FlatButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openAddUserDialog1();
                },
                icon: Icon(null),
                label: Text(
                  'Add new Share List',
                  style: TextStyle(color: Colors.white, fontSize: 14.0),
                ),
              ),
            )),
          ],
        ),
      ),
    );
    showDialog(context: context, child: dialog);
  }

  _openAddUserDialog1() {
    AlertDialog dialog = new AlertDialog(
      content: ModalProgressHUD(
        child: new Container(
          width: 260.0,
          height: 250.0,
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
                        'Name of Share List',
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
              Container(
                margin: const EdgeInsets.only(bottom: 50.0),
                child: new TextFormField(
                  controller: myController,
                  decoration: new InputDecoration(
                    hintText: 'Add name',
                  ),
                ),
              ),

              Container(
                  child: Card(
                elevation: 4.0,
                shape: new RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black)),
                color: Colors.black,
                child: FlatButton.icon(
                  onPressed: () => handleSubmit(),
                  icon: Icon(null),
                  label: Text(
                    'Add Item to new Share List',
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ),
              )),
            ],
          ),
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.5,
        color: Colors.black,
        progressIndicator: CircularProgressIndicator(),
      ),
    );

    showDialog(context: context, child: dialog);
  }

  favouritesubmit() async {
    setState(() {
      _isInAsyncCall = true;
    });

    noteSub?.cancel();

    var db = Firestore.instance;
    db.collection("favourite_item").add({
      "date": DateTime.now(),
      "favourite_name": item.item_title,
      "product_id": item.product_id,
      "status": "1",
      "user_id": user_id,
    }).then((val) {
      var docId = val.documentID;
      var updateId = {"favourite_id": docId};

      db
          .collection("favourite_item")
          .document(docId)
          .updateData(updateId)
          .then((val) async {
        CollectionReference ref = Firestore.instance.collection('product');
        QuerySnapshot eventsQuery = await ref
            .where("product_id", isEqualTo: item.product_id)
            .getDocuments();

        if (eventsQuery.documents.isEmpty) {
        } else {
          eventsQuery.documents.forEach((doc) async {
            String docId = doc['product_id'];
            String is_fav_count = doc['is_favorite_count'];

            var is_favorite_count = int.tryParse(is_fav_count);

            var total_favorite_count = is_favorite_count + 1;

            var up1 = {'is_favorite_count': total_favorite_count.toString()};

            db
                .collection("product")
                .document(docId)
                .updateData(up1)
                .then((val) {
              setState(() {
                _isInAsyncCall = false;
              });
              Navigator.of(context).pop();
              print("sucess");
            }).catchError((err) {
              print(err);
              _isInAsyncCall = false;
            });
          });
        }

        print("sucess");
      }).catchError((err) {
        print(err);
        _isInAsyncCall = false;
      });

      print("sucess");
    }).catchError((err) {
      _isInAsyncCall = false;
      print(err);
    });
  }

  unfavouritesubmit(String fav_id) async {
    favid = new List();
    setState(() {
      _isInAsyncCall = true;
    });

    CollectionReference ref = Firestore.instance.collection('product');
    QuerySnapshot eventsQuery = await ref
        .where("product_id", isEqualTo: item.product_id)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
    } else {
      eventsQuery.documents.forEach((doc) async {
        String docId = doc['product_id'];
        String is_fav_count = doc['is_favorite_count'];

        var is_favorite_count = int.tryParse(is_fav_count);

        var total_favorite_count = is_favorite_count - 1;

        var up1 = {'is_favorite_count': total_favorite_count.toString()};

        var db1 = Firestore.instance;
        db1.collection("product").document(docId).updateData(up1).then((val) {
          db.deleteFavorit(fav_id).then((Favorite) async {
            setState(() {
              Navigator.of(context)
                  .pop(); // here I pop to avoid multiple Dialogs
              //here i call the same function

              setState(() {
                favourite = false;
                _isInAsyncCall = false;
              });
            });
          });
          print("sucess");
        }).catchError((err) {
          print(err);
          _isInAsyncCall = false;
        });
      });
    }
  }

  getFavCount() async {
    CollectionReference ref = Firestore.instance.collection('favourite_item');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: item.user_id).getDocuments();
    if (mounted == true) {
      setState(() {
        Favourit = eventsQuery.documents.length.toString();
      });
    }
    if (eventsQuery.documents.isEmpty) {
    } else {
      eventsQuery.documents.forEach((doc) async {});
    }
    if (mounted == true) {
      setState(() {
        _isInAsyncCall = false;
        // _isInAsyncCall = false;
      });
    }
  }

  handleSubmit() async {
    String submit = myController.text;
    setState(() {
      _isInAsyncCall = true;
    });

    noteSub?.cancel();
    db
        .createShareList('', user_id, DateTime.now(), submit, share_product_id)
        .then((_) {
      setState(() {
        _isInAsyncCall = false;
      });

      Navigator.of(context).pop();
      _openAddUserDialog('');
    });
  }

  /*----------------------------------------submit-------------------------------*/

  /*----------------------------------------submit-------------------------------*/

  submit(String Share_id) async {
    CollectionReference ref = Firestore.instance.collection('share_list');
    QuerySnapshot eventsQuery =
        await ref.where('share_id', isEqualTo: Share_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        share_product_id = doc['share_product_id'].toList();

        if (share_product_id.contains(item.product_id)) {
          showInSnackBar('Product already added to shared list.');
        } else {
          var db1 = Firestore.instance;
          share_product_id.add(item.product_id);
          var update = {'share_product_id': share_product_id};

          db1
              .collection("share_list")
              .document(Share_id)
              .updateData(update)
              .then((val) {
            Navigator.pop(context);
            share_product_id.clear();
            setState(() {
              _isInAsyncCall = false;
              showInSnackBar('product successfully add to share list.');
            });

            print("sucess");
          }).catchError((err) {
            print(err);
            _isInAsyncCall = false;
          });
        }

        //userList1.add(Login_Modle(doc['user_id'], doc['username'], doc['password'], doc['name'], doc['status'], doc['profile_picture'], doc['latlong'].toString(), doc['following'],doc['followers'],doc['facebook_id'] , doc['device_id'], doc['device_id'], doc['device'], doc['cover_picture'], doc['country'], doc['about_me'], doc['refer_code'],doc['token_id']));
      });
    }
  }

  _verticalD() => Container(
        margin: EdgeInsets.only(left: 30.0, right: 0.0, top: 0.0, bottom: 0.0),
      );
}

/* final List child = map<Widget>(
    item.item_picture.toList(),
        (index, i) {
      return Container(
        margin: EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: Stack(children: <Widget>[
            Image.network(i, fit: BoxFit.cover, width: 1000.0),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(200, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  'No. $index image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ]),
        ),
      );
    },
  ).toList();

}



class CarouselWithIndicator extends StatefulWidget {
  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CarouselSlider(
        items: child,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 2.0,
        onPageChanged: (index) {
          setState(() {
            _current = index;
          });
        },
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: map<Widget>(
          imgList,
              (index, url) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == index
                      ? Color.fromRGBO(0, 0, 0, 0.9)
                      : Color.fromRGBO(0, 0, 0, 0.4)),
            );
          },
        ),
      ),
    ]);
  }
}
*/

import 'dart:async';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Cart.dart';
import 'package:threadon/model/GetProduct.dart';
import 'package:threadon/model/Product.dart';
import 'package:threadon/model/Sales_Text.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/ChatMessage.dart';
import 'package:threadon/pages/Coman_SearchList_Screen.dart';
import 'package:threadon/pages/main_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';
//import 'package:quiver/async.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class CartScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new cart_screen();
// TODO: implement createState
}

class cart_screen extends State<CartScreen> with TickerProviderStateMixin {
  String user_id = '', cat_name = '';

  List<Cart> cartList1 = new List<Cart>();
  List<Shell_Product_Model> productList;
  List<Shell_Product_Model> productList1 = new List<Shell_Product_Model>();
  StreamSubscription<QuerySnapshot> noteSub;
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  bool pressAttention = false;
  String total = '';
  String price = '0';

  AnimationController animationController;

  SharedPreferences prefs;
  String timeLeft = "";
  bool running = true;
  String formattedDate;
  bool _isInAsyncCall = true;
  int cart_count;
  List<String> UplodImageList;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  List<Sales_Text> salesText = new List();

  var db1;

  @override
  void initState() {
    super.initState();

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getCredential();

    db1 = Firestore.instance;
  }

  void _deleteNote(BuildContext context, Cart note, Shell_Product_Model product,
      int position) async {
    db.deleteCart(note.cart_id).then((cart) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => CartScreen()));
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
        if (this.mounted) {
          setState(() {
            _connectionStatus = '$result\n'
                'Wifi Name: $wifiName\n'
                'Wifi BSSID: $wifiBSSID\n'
                'Wifi IP: $wifiIP\n';
          });
        }
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

  /*----------------------------------------get_cart_-------------------------------*/

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    user_id = sharedPreferences.getString("user_id");

    CollectionReference ref = Firestore.instance.collection('cart');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      cartList1 = new List();
      eventsQuery.documents.forEach((doc) async {
        cartList1.add(Cart(doc['cart_id'], doc['product_id'], doc['status'],
            doc['user_id'], doc['date'].toDate()));

        String productid = doc['product_id'];
        CollectionReference ref = Firestore.instance.collection('product');
        QuerySnapshot eventsQuery =
            await ref.where("product_id", isEqualTo: productid).getDocuments();

        if (eventsQuery.documents.isEmpty) {
          setState(() {
            _isInAsyncCall = false;
          });
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

            this.productList = productList1;

            var value = double.tryParse(price);
            var ss = doc['item_sale_price'];
            double one = double.parse(ss);
            value = value + one;
            price = value.toString();

            setState(() {
              _isInAsyncCall = false;
            });
          });
        }
      });
    }

//      cat_name = sharedPreferences.getString("cat_name");
  }

  @override
  Widget build(BuildContext context) {
    if (productList1.length == 0) {
      pressAttention = true;
    } else {
      pressAttention = false;
    }

    // TODO: implement build
    return Scaffold(
        appBar: new AppBar(
          title: Text("Cart"),
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
            IconButton(
              icon: new Icon(Icons.chat_bubble_outline),
              tooltip: 'MessageList',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatMessageList()));
              },
            ),
            new IconButton(
              icon: new Icon(Icons.perm_identity),
              tooltip: 'Me',
              onPressed: () => MyNavigator.goToProfile(context),
            ),
          ],
        ),
        body: ModalProgressHUD(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: productList1.length,
                  itemBuilder: (context, position) {
                    return Dismissible(
                      key: Key(productList1[position].user_id.toString()),
//                      onDismissed: (direction) {
//                        setState(() {
//                          _deleteNote(context, cart_list[position], productList[position], position);
//                          db.updateNote(
//                              Product(productList[position].category, productList[position].country, productList[position].is_cart, productList[position].item_brand, productList[position].item_color
//                                  , productList[position].item_description, productList[position].item_measurements, productList[position].item_price, productList[position].item_sale_price, productList[position].item_size
//                                  , productList[position].item_sold, productList[position].item_sub_title, productList[position].item_title, productList[position].item_type, productList[position].picture, productList[position].product_id
//                                  , '3', productList[position].sub_category, productList[position].sub_category_id, productList[position].user_id, productList[position].flag));
//                        });
//                      },
//                      background: Container(
//                        color: Colors.redAccent,
//                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 0.0, right: 0.0),
                        child: Card(
                          elevation: 3.0,
                          color: Colors.white,
                          child: new Row(
                            children: <Widget>[
//                              Expanded(
//                                flex: 3,
//                                child: Container(
//
//                                  padding: EdgeInsets.only(left: 10.0),
//                                    child: FadeInImage.assetNetwork(
//                                    placeholder: 'images/t.png',
//                                    image:'${productList1[position].Picture}',
//                                    fit: BoxFit.fill,
//                                  )
//                                )
//                              ),
                              Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          '${productList1[position].picture}'),
                                    ),
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                margin: EdgeInsets.only(
                                    left: 5, top: 5, right: 5, bottom: 5),
                                height: 130,
                                width: 130,
                              ),
                              Expanded(
                                flex: 5,
                                child: new Container(
                                  margin: const EdgeInsets.only(
                                    left: 10.0,
                                    top: 10.0,
                                  ),
                                  child: new Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '${productList1[position].item_title}',
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
/*                                      Container(
                                        margin: const EdgeInsets.only(
                                            left: 0.0,
                                            right: 0.0,
                                            top: 5.0,
                                            bottom: 0.0),
                                        child: new Text(
                                          'Listed by ' +
                                              '${productList1[position].item_title}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13.0,
                                          ),
                                        ),
                                      ),*/
                                      Container(
                                        margin: const EdgeInsets.only(
                                            left: 0.0,
                                            right: 0.0,
                                            top: 10.0,
                                            bottom: 0.0),
                                        child: new Text(
                                          'Price:' +
                                              ' \$' +
                                              '${productList1[position].item_sale_price}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13.0,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                            left: 0.0,
                                            right: 0.0,
                                            top: 5.0,
                                            bottom: 0.0),
                                        child: new Text(
                                          'Shipping charges applicable',
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13.0,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                            left: 0.0,
                                            right: 0.0,
                                            top: 10.0,
                                            bottom: 0.0),
                                        child: new Text(
                                          'Returnable for site credit',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13.0,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                left: 0.0,
                                                right: 0.0,
                                                top: 5.0,
                                                bottom: 10.0),
                                            child: new Text(
                                              'See Policy Details',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 13.0,
                                              ),
                                            ),
                                          ),
                                          onTap: () async {
                                            showModalBottomSheet<void>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Container(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                  10.0),
                                                          child: Text(
                                                              'You can request a return for Threadon Site Credit on this item within 4 days of delivery. All shipping on returns is FREE. \n\n If your item was misrepresented in any way, you can file a misrepresentation claim. Threadon will investigate and you will be eligible for a full refund.',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .accentColor,
                                                                  fontSize:
                                                                      12.0))));
                                                });
                                          }),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          db1
                                              .collection("cart")
                                              .document(
                                                  cartList1[position].cart_id)
                                              .delete()
                                              .then((val) {
                                            cartList1.clear();
                                            productList1.clear();
                                            price = "0";

                                            setState(() {
                                              getCredential();
                                            });

                                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CartScreen()));
                                            print("sucess");
                                          }).catchError((err) {
                                            print(err);
                                          });
                                        }),
                                  ) /*Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    InkWell(
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 0.0,
                                            right: 20.0,
                                            top: 0.0,
                                            bottom: 100.0),
                                        child: new Icon(
                                          Icons.close,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      onTap: () async {
                                        setState(() {





                                        });
                                      },
                                    ),
                                  ],
                                ),*/
                                  ),
                            ],
                          ),
                        ),
                        // photo and title
                      ),
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
        bottomNavigationBar: GestureDetector(
          child: Container(
            margin:
                EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0, bottom: 0.0),
            height: 120.0,
            color: Colors.white70,
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: new Text(
                          'Subtotal (' +
                              productList1.length.toString() +
                              ' item)',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                          maxLines: 2,
                        ),
                      ),
                      Expanded(
                        child: new Text(
                          '\$' + price,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 610,
                  margin: EdgeInsets.only(
                      top: 15.0, left: 0.0, right: 0.0, bottom: 0.0),
                  child: new RaisedButton(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 11.0,
                      ),
                      child: new Text(
                          pressAttention
                              ? 'Continue to Checkout'
                              : 'Continue to Checkout',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.white, fontSize: 18.0)),
                      textColor: Colors.white,
                      color: pressAttention ? Colors.grey : Colors.black,
                      onPressed: () async {
                        if (pressAttention == false) {
                          setState(() => pressAttention = !pressAttention);

                          SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          sharedPreferences.setString(
                              'total_item', cartList1.length.toString());
                          sharedPreferences.setString('total_price', price);
                          MyNavigator.gotoCheckout_Screen(
                              context, "Shipping Address");
                        } else {}
                      }),
                ),

//                Container(
//                  width: 600,
//                  margin: EdgeInsets.only(
//                      top: 20.0, left: 0.0, right: 10.0, bottom: 0.0),
//                  child: new RaisedButton(
//                      padding: const EdgeInsets.symmetric(
//                        vertical: 15.0,
//                        horizontal: 15.0,
//                      ),
//                      child: new Text(
//                          pressAttention
//                              ? 'Continue to Checkout'
//                              : 'Continue to Checkout',
//                          textAlign: TextAlign.center,
//                          style:
//                              TextStyle(color: Colors.white, fontSize: 16.0)),
//                      textColor: Colors.white,
//                      color: pressAttention ? Colors.grey : Colors.black,
//
//                      onPressed:  () async {
//                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//                        sharedPreferences.setString('total_item', cart_list.length.toString());
//                        sharedPreferences.setString('total_price', price);
//                        MyNavigator.gotoCheckout_Screen(context, "Shipping Address");
//                      },
//
//                  ),
//                ),
              ],
            ),
          ),
          onTap: () {},
        ));
  }
}

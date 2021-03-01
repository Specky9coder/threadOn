import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:threadon/pages/ErrorRedeemConfirmationScreen.dart';
import 'package:threadon/pages/RedeemConfirmationScreen.dart';
import 'package:threadon/pages/splesh_screen.dart';
import 'package:xml/xml.dart' as xml;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Item_Order.dart';
import 'package:threadon/model/PaymentBill.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/main_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/flutter_masked_text.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:http/http.dart' as http;
import 'dart:core';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class Payments_Methods extends StatefulWidget {
  String tool_name;
  List<String> shippingAdd;

  Payments_Methods({Key key, this.tool_name, this.shippingAdd})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      payment_methods(tool_name, shippingAdd);
}

class payment_methods extends State<Payments_Methods> {
  String appbar_name;
  String user_id = '';
  bool _isInAsyncCall = false;

  List<String> shippingAdd;
  List<String> sellerAddress = new List();

  payment_methods(this.appbar_name, this.shippingAdd);

  var Respons;

  List<PaymentBillModel> paymentcard;
  List<PaymentBillModel> paymentcard1;
  List<Pickup_order> p_order;
  String cardNumber = '',
      cardType = '',
      expMonth = '',
      expYear = '',
      cnameMask = '',
      address1Mask = '',
      custmorId = '';
  final postUrl = 'https://fcm.googleapis.com/fcm/send';

  String address, ttl_item = '', ttl_price = '';
  FirebaseFirestoreService db3 = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;

  String AccessToken = '';
  String site_credit = '';
  String sellerId = '';
  String avi_amount = '';
  int PopupFlag = 0;
  String user_email;

  MaskedTextController cvvMask = MaskedTextController(mask: "000");

  final flutterWebViewPlugin = FlutterWebviewPlugin();

  // On destroy stream
  StreamSubscription _onDestroy;

  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;

  // On urlChanged stream
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  StreamSubscription<WebViewHttpError> _onHttpError;

  StreamSubscription<double> _onScrollYChanged;

  StreamSubscription<double> _onScrollXChanged;

  static const kAndroidUserAgent =
      // 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';
      'Mozilla/5.0 (Linux; Android 8.0.0; SM-N9500 Build/R16NW; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/63.0.3239.83 Mobile Safari/537.36 T7/10.13 baiduboxapp/10.13.0.11 (Baidu; P1 8.0.0)';
  var selectedUrl =
      "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_xclick&";

  final _codeCtrl = TextEditingController(text: 'window.navigator.userAgent');

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String order_id_1;

  final _history = [];
  SharedPreferences prf;
  int Payment = 0;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    setState(() {
      _isInAsyncCall = true;
    });

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getCredential();
    flutterWebViewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebViewPlugin.onDestroy.listen((_) {
      if (mounted) {
        // Actions like show a info toast.
        if (Payment == 1) {
        } else {
          flutterWebViewPlugin.cleanCookies();
          //_launchPlatformCount();
          orderPost();
        }

        /* _scaffoldKey.currentState.showSnackBar(
            const SnackBar(content: const Text('Webview Destroyed')));
     */
      }
    });

    // Add a listener to on url changed
    _onUrlChanged =
        flutterWebViewPlugin.onUrlChanged.listen((String url) async {
      prf = await SharedPreferences.getInstance();
      print("print SetInt : ${prf.setInt}");
      if (mounted) {
        setState(() {
          _history.add('onUrlChanged: $url');

          if (url.endsWith("checkout/done")) {
            print('Done');
            flutterWebViewPlugin.cleanCookies();
            // dispose();
            prf.setInt('payment', 1);

            flutterWebViewPlugin.close();

            //orderPost();
            OrderPostStart();
            // _launchPlatformCount();
          } else {
            if (url.endsWith('checkout/error')) {
              flutterWebViewPlugin.cleanCookies();
              // dispose();
              prf.setInt('payment', 0);

              flutterWebViewPlugin.close();
              //  orderPost();
              // OrderPostStart();
              _paymentFaild(context);
              //_launchPlatformCount();
            }
          }
        });
      }
    });

    _onScrollYChanged =
        flutterWebViewPlugin.onScrollYChanged.listen((double y) {
      if (mounted) {
        setState(() {
          _history.add('Scroll in Y Direction: $y');
        });
      }
    });

    _onScrollXChanged =
        flutterWebViewPlugin.onScrollXChanged.listen((double x) {
      if (mounted) {
        setState(() {
          _history.add('Scroll in X Direction: $x');
        });
      }
    });

    _onStateChanged =
        flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (mounted) {
        setState(() {
          _history.add('onStateChanged: ${state.type} ${state.url}');
        });
      }
    });

    _onHttpError =
        flutterWebViewPlugin.onHttpError.listen((WebViewHttpError error) {
      if (mounted) {
        setState(() {
          flutterWebViewPlugin.cleanCookies();
          // dispose();
          prf.setInt('payment', 0);

          flutterWebViewPlugin.close();

          orderPost();
          //_launchPlatformCount();
          _history.add('onHttpError: ${error.code} ${error.url}');
        });
      }
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

  // void _showDialog() {
  //   // flutter defined function
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       // return object of type Dialog
  //       return AlertDialog(
  //         title: new Text("Could not complete order"),
  //         content: new Text(""),
  //         actions: <Widget>[
  //           // usually buttons at the bottom of the dialog

  //           new FlatButton(
  //             child: new Text("Back to Home"),
  //             onPressed: () {
  //               setState(() {
  //                  Navigator.pushReplacement(
  //               context, MaterialPageRoute(builder: (context) => MyHome()));
  //                 Navigator.pop(context);
  //               });
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    _onHttpError.cancel();
    _onScrollXChanged.cancel();
    _onScrollYChanged.cancel();

    flutterWebViewPlugin.dispose();

    super.dispose();
  }

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    user_id = sharedPreferences.getString("user_id");
    ttl_item = sharedPreferences.getString("total_item");
    ttl_price = sharedPreferences.getString("total_price");
    site_credit = sharedPreferences.getString('site_c');
    avi_amount = sharedPreferences.getString('av_c');
    user_email = sharedPreferences.getString('user_email');

    setState(() {
      getData();
    });
  }

  _onAlertWithStylePressed(context) {
    // Reusable alert style
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromTop,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: TextStyle(
        color: Colors.green,
      ),
    );

    // Alert dialog using custom alert style
    Alert(
      context: context,
      style: alertStyle,
      type: AlertType.success,
      title: "Awesome!",
      desc: "Your order has been successfully placed!",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            PopupFlag = 0;
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MyHome()));
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }

  _paymentFaild(context) {
    // Reusable alert style
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromTop,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: TextStyle(
        color: Colors.red,
      ),
    );

    // Alert dialog using custom alert style
    Alert(
      context: context,
      style: alertStyle,
      type: AlertType.error,
      title: "Failed!",
      desc: "Your transaction has been failed",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
          color: Color.fromRGBO(0, 179, 134, 1.0),
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }

  Future getData() async {
    setState(() {
      _isInAsyncCall = true;
    });
    paymentcard = new List();
    paymentcard1 = new List();
    CollectionReference ref =
        Firestore.instance.collection('billing_card_details');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        paymentcard1.add(PaymentBillModel(
          doc['key'],
          doc['id'],
          doc['date'].toDate(),
          doc['external_customer_id'],
          doc['type'],
          doc['number'],
          doc['expire_month'],
          doc['expire_year'],
          doc['first_name'],
          doc['last_name'],
          doc['billing_address'],
          doc['valid_until'],
          doc['create_time'],
          doc['update_time'],
          doc['user_id'],
          doc['access_token'],
        ));

        setState(() {
          this.paymentcard = paymentcard1;
          _isInAsyncCall = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: new AppBar(
        title: new Text(appbar_name),
        backgroundColor: Colors.white70,
      ),

      body: ModalProgressHUD(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                child: paymentcard == null || paymentcard.length > 0
                    ? Container(
                        height: 200.0,
                        child: paymentcard == null || paymentcard.length > 0
                            ? ListView.builder(
                                itemCount: paymentcard.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, position) {
                                  return Container(
                                    width: width,
                                    child: GestureDetector(
                                      child: creditCardWidget(
                                          paymentcard, position),
                                      onTap: () {
                                        print("paymentcard : $paymentcard");
                                        cardNumber = paymentcard[position].id;
                                        custmorId = paymentcard[position]
                                            .external_customer_id;

                                        setState(() {
                                          _isInAsyncCall = true;
                                        });
                                        post();
                                      },
                                    ),
                                  );
                                })
                            : Container())
                    : new Container(),
              ),
              new Container(
                height: 10.0,
              ),
              Divider(),
              new Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(top: 5.0, left: 5.0),
                child: Text(
                  'Check out with :',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400),
                ),
              ),
              new GestureDetector(
                child: Card(
                  elevation: 2.0,
                  child: Container(
                      padding:
                          EdgeInsets.only(left: 10.0, top: 0.0, right: 10.0),
                      alignment: Alignment.centerLeft,
                      height: 70.0,
                      width: width,
                      child: Image.asset('images/pay.png')),

                  //
                ),
                onTap: () {
                  print("ttl_price : $selectedUrl");
                  String emile = "your@email.tld";
                  selectedUrl = selectedUrl +
                      "business=" +
                      emile +
                      "&amount=" +
                      ttl_price +
                      "&currency_code=USD";

                  flutterWebViewPlugin.launch(selectedUrl,
                      userAgent: kAndroidUserAgent);
                  print("call");
                },
              )
            ],
          ),
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 1,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => MyNavigator.gotoAddPaymentMethodsScreen(
            context, "Add Payment Method"),
        tooltip: '',
        elevation: 10.0,
        backgroundColor: Colors.redAccent,
        child: new Icon(
          Icons.add,
          color: Colors.white,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future OrderPostStart() async {
    Payment = prf.getInt('payment');

    if (Payment == 1) {
      setState(() {
        _isInAsyncCall = true;
      });

      var db = Firestore.instance;
      db
          .collection("cart")
          .where("user_id", isEqualTo: user_id)
          .getDocuments()
          .then((val) {
        if (val.documents.isEmpty) {
        } else {
          val.documents.forEach((doc) {
            String cartid = doc['cart_id'];
            String productid = doc['product_id'];

            db
                .collection("product")
                .where("product_id", isEqualTo: productid)
                .getDocuments()
                .then((val1) {
              if (val1.documents.isEmpty) {
              } else {
                val1.documents.forEach((doc1) {
                  String sellerid = doc1['user_id'];
                  String productPrice = doc1['item_price'];
                  String wight = doc1['item_pound'].toString() +
                      "." +
                      doc1['item_Ounces'].toString();
                  double wight1 = double.parse(wight);
                  int t_wight = wight1.round();
                  if (t_wight == 0) {
                    t_wight = 1;
                  }

                  db
                      .collection("users")
                      .where("user_id", isEqualTo: sellerid)
                      .getDocuments()
                      .then((val2) {
                    if (val2.documents.isEmpty) {
                    } else {
                      val2.documents.forEach((doc2) {
                        String email_id = doc2['email_id'];
                        String token_id = doc2['token_id'];

                        db
                            .collection("shipping_address")
                            .where("user_id", isEqualTo: sellerid)
                            .where("status", isEqualTo: "0")
                            .getDocuments()
                            .then((val3) {
                          if (val3.documents.isEmpty) {
                          } else {
                            val3.documents.forEach((doc3) async {
                              sellerAddress = new List();
                              sellerAddress.add(doc3['name']);
                              sellerAddress.add(doc3['address_line_1']);
                              sellerAddress.add(doc3['address_line_2']);
                              sellerAddress.add(doc3['city']);
                              sellerAddress.add(doc3['state']);
                              sellerAddress.add(doc3['zipcode']);
                              sellerAddress.add(doc3['zip4']);
                              sellerAddress.add(doc3['phone']);
                              sellerAddress.add(email_id);

                              var map = {
                                "day_week": '',
                                "label": "",
                                "pickup_date": '',
                                "seller_id": sellerid,
                                "status": "0"
                              };

                              var db = Firestore.instance;
                              db.collection("item_order").add({
                                "date": DateTime.now(),
                                "item_id": productid,
                                "order_date": DateTime.now(),
                                "order_status": "0",
                                "payment_method": "PAYPAL",
                                'pickup_order': map,
                                'promo_code': "",
                                "purchase_price": productPrice,
                                "shipping_address": shippingAdd.toList(),
                                "shipping_charge": "",
                                "shipping_date": DateTime.now(),
                                "shipping_status": "0",
                                'user_id': user_id,
                                "seller_id": sellerid,
                                "tracking_id": "",
                              }).then((val) {
                                String id = val.documentID;

                                var order_id = {
                                  'order_id': id,
                                };
                                db
                                    .collection("item_order")
                                    .document(id)
                                    .updateData(order_id)
                                    .then((val) {
                                  print("sucess");

                                  order_id_1 = id;

                                  db3
                                      .updateProduct(Shell_Product_Model(
                                          doc1['Any_sign_wear'],
                                          doc1['category'],
                                          doc1['category_id'],
                                          doc1['country'],
                                          doc1['date'],
                                          doc1['favourite_count'],
                                          doc1['is_cart'],
                                          doc1['is_favorite_count'],
                                          doc1['item_Ounces'],
                                          doc1['item_brand'],
                                          doc1['item_color'],
                                          doc1['item_description'],
                                          doc1['item_measurements'],
                                          doc1['item_picture'],
                                          doc1['item_pound'],
                                          doc1['item_price'],
                                          doc1['item_sale_price'],
                                          doc1['item_size'],
                                          doc1['item_sold'],
                                          doc1['item_sub_title'],
                                          doc1['item_title'],
                                          doc1['item_type'],
                                          doc1['packing_type'],
                                          doc1['picture'],
                                          doc1['product_id'],
                                          doc1['retail_tag'],
                                          doc1['shipping_charge'],
                                          doc1['shipping_id'],
                                          "2",
                                          doc1['sub_category'],
                                          doc1['sub_category_id'],
                                          doc1['user_id'],
                                          doc1['tracking_id'],
                                          doc1['order_id'],
                                          doc['like_new']))
                                      .then((_) {
                                    makeCall(token_id);

                                    db3.deleteCart(cartid).then((cart) {
                                      prf.setInt('payment', 0);

                                      db
                                          .collection("wallet")
                                          .where("user_id", isEqualTo: sellerid)
                                          .getDocuments()
                                          .then((val4) {
                                        if (val4.documents.isEmpty) {
                                        } else {
                                          val4.documents.forEach((doc4) {
                                            String docId = doc4['wallet_id'];
                                            String available_amount =
                                                doc4['available_amount'];

                                            String lifetime_earning =
                                                doc4['lifetime_earning'];

                                            var payamount =
                                                double.parse(productPrice);

                                            var value_available =
                                                double.tryParse(
                                                    available_amount);
                                            value_available =
                                                value_available; //+ payamount;
                                            var total_available_amount =
                                                value_available.toString();

                                            var value_lifetime =
                                                double.tryParse(
                                                    lifetime_earning);
                                            value_lifetime =
                                                value_lifetime + payamount;
                                            var total_lifetime_amount =
                                                value_lifetime.toString();
                                            var up1 = {
                                              'available_amount':
                                                  total_available_amount,
                                              'lifetime_earning':
                                                  total_lifetime_amount
                                            };

                                            db
                                                .collection("wallet")
                                                .document(docId)
                                                .updateData(up1)
                                                .then((val) async {
                                              var payout = {
                                                "batch_status": "",
                                                "payout_batch_id": "",
                                                "sender_batch_id": "",
                                                "user_id": "",
                                                "withdraw_amount": "",
                                                "payout_email_id": "",
                                                "date": ""
                                              };

                                              var db = Firestore.instance;
                                              db
                                                  .collection("payment_history")
                                                  .add({
                                                "amount": productPrice,
                                                "currency_code": "USD",
                                                "date": DateTime.now(),
                                                "intent": "sale",
                                                'short_description': ttl_item,
                                                'state': "approved",
                                                'user_id': user_id,
                                                'order_id': order_id_1
                                              }).then((val) {
                                                String id = val.documentID;

                                                var updateid = {'id': id};

                                                db
                                                    .collection(
                                                        "payment_history")
                                                    .document(id)
                                                    .updateData(updateid)
                                                    .then((val) {
                                                  print("sucess");

                                                  db
                                                      .collection(
                                                          "payment_transaction")
                                                      .add({
                                                    "amount": productPrice,
                                                    "currency_code": "USD",
                                                    "refund_id": "",
                                                    "state": "completed",
                                                    "date": DateTime.now(),
                                                    "payment_status": "0",
                                                    'status': "0",
                                                    'user_id': user_id,
                                                    'payout_details': payout,
                                                    'order_id': order_id_1
                                                  }).then((val) async {
                                                    var docId = val.documentID;
                                                    var updateId = {
                                                      "pay_id": 'PAY' + docId
                                                    };

                                                    db
                                                        .collection(
                                                            "payment_transaction")
                                                        .document(docId)
                                                        .updateData(updateId)
                                                        .then((val) async {
                                                      CollectionReference ref =
                                                          Firestore.instance
                                                              .collection(
                                                                  'wallet');
                                                      QuerySnapshot
                                                          eventsQuery =
                                                          await ref
                                                              .where("user_id",
                                                                  isEqualTo:
                                                                      user_id)
                                                              .getDocuments();

                                                      if (eventsQuery
                                                          .documents.isEmpty) {
                                                      } else {
                                                        eventsQuery.documents
                                                            .forEach(
                                                                (doc) async {
                                                          String docId =
                                                              doc['wallet_id'];
                                                          String
                                                              available_amount =
                                                              doc['available_amount'];
                                                          String
                                                              lifetime_earning =
                                                              doc['site_credit'];

                                                          /*  var payamount = int.parse(Sub_totalamount);

            var value_available = int.tryParse(available_amount);
            value_available = value_available +payamount;
            var total_available_amount =  value_available.toString();

            var value_lifetime = int.tryParse(lifetime_earning);
            value_lifetime = value_lifetime + payamount;
            var total_lifetime_amount =  value_lifetime.toString();*/

                                                          var up1 = {
                                                            'available_amount':
                                                                available_amount,
                                                            'site_credit':
                                                                lifetime_earning
                                                          };

                                                          db
                                                              .collection(
                                                                  "wallet")
                                                              .document(docId)
                                                              .updateData(up1)
                                                              .then(
                                                                  (val) async {
                                                            print("sucess");

                                                            var body = {
                                                              "order_id":
                                                                  order_id_1
                                                            };
                                                            http.Response
                                                                response =
                                                                await http.post(
                                                                    "https://threadon-86254.firebaseapp.com/order-email-notification-to-seller",
                                                                    body: body);

                                                            if (response
                                                                    .statusCode ==
                                                                200) {
                                                              print(
                                                                  'Order Email Success send');
                                                              var res1 =
                                                                  json.decode(
                                                                      response
                                                                          .body);
                                                              var stcode = res1[
                                                                  'status'];

                                                              if (stcode ==
                                                                  200) {
                                                                String msg = res1[
                                                                    'message'];
                                                                // _showDialog('Password Reset',msg,0);

                                                                http.Response
                                                                    response1 =
                                                                    await http.post(
                                                                        "https://threadon-86254.firebaseapp.com/order-email-notification-to-buyer",
                                                                        body:
                                                                            body);

                                                                if (response1
                                                                        .statusCode ==
                                                                    200) {
                                                                  print(
                                                                      'Order Email Success send');
                                                                  var res1 = json
                                                                      .decode(response1
                                                                          .body);
                                                                  var stcode = res1[
                                                                      'status'];

                                                                  if (stcode ==
                                                                      200) {
                                                                    String msg =
                                                                        res1[
                                                                            'message'];
                                                                    // _showDialog('Password Reset',msg,0);
                                                                  } else {
                                                                    String msg =
                                                                        res1[
                                                                            'message'];
                                                                    //     _showDialog('Error',msg,1);
                                                                  }
                                                                } else {
                                                                  //    showTost('Error');
                                                                  print(
                                                                      'Error');
                                                                  //        _showDialog('Error','Order Email not send',1);
                                                                  setState(() {
                                                                    _isInAsyncCall =
                                                                        false;
                                                                  });
                                                                }
                                                              } else {
                                                                String msg = res1[
                                                                    'message'];
                                                                //      _showDialog('Error',msg,1);
                                                              }
                                                            } else {
                                                              //    showTost('Error');
                                                              print('Error');
                                                              //  _showDialog('Error','Order Email not send',1);
                                                              setState(() {
                                                                _isInAsyncCall =
                                                                    false;
                                                              });
                                                            }

                                                            setState(() {
                                                              _isInAsyncCall =
                                                                  false;
                                                            });

                                                            if (PopupFlag ==
                                                                0) {
                                                              PopupFlag = 1;
                                                              Navigator.of(
                                                                      context)
                                                                  .push(PageRouteBuilder(
                                                                      opaque:
                                                                          false,
                                                                      pageBuilder: (BuildContext context,
                                                                              _,
                                                                              __) =>
                                                                          RedeemConfirmationScreen()));
                                                              //_onAlertWithStylePressed(context);
                                                            }
                                                          }).catchError((err) {
                                                            print(err);

                                                            Navigator.of(
                                                                    context)
                                                                .push(PageRouteBuilder(
                                                                    opaque:
                                                                        false,
                                                                    pageBuilder: (BuildContext
                                                                                context,
                                                                            _,
                                                                            __) =>
                                                                        ErrorRedeemConfirmationScreen()));
                                                            _isInAsyncCall =
                                                                false;
                                                          });
                                                        });
                                                      }

                                                      print("sucess");
                                                    }).catchError((err) {
                                                      _isInAsyncCall = false;

                                                      Navigator.of(context).push(
                                                          PageRouteBuilder(
                                                              opaque: false,
                                                              pageBuilder: (BuildContext
                                                                          context,
                                                                      _,
                                                                      __) =>
                                                                  ErrorRedeemConfirmationScreen()));
                                                      print(err);
                                                      // _isInAsyncCall = false;
                                                    });

                                                    print("sucess");
                                                  }).catchError((err) {
                                                    print(err);

                                                    Navigator.of(context).push(
                                                        PageRouteBuilder(
                                                            opaque: false,
                                                            pageBuilder: (BuildContext
                                                                        context,
                                                                    _,
                                                                    __) =>
                                                                ErrorRedeemConfirmationScreen()));
                                                    _isInAsyncCall = false;
                                                  });
                                                }).catchError((err) {
                                                  _isInAsyncCall = false;

                                                  Navigator.of(context).push(
                                                      PageRouteBuilder(
                                                          opaque: false,
                                                          pageBuilder: (BuildContext
                                                                      context,
                                                                  _,
                                                                  __) =>
                                                              ErrorRedeemConfirmationScreen()));
                                                  print(err);
                                                  // _isInAsyncCall = false;
                                                });

                                                print("sucess");
                                              }).catchError((err) {
                                                Navigator.of(context).push(
                                                    PageRouteBuilder(
                                                        opaque: false,
                                                        pageBuilder: (BuildContext
                                                                    context,
                                                                _,
                                                                __) =>
                                                            ErrorRedeemConfirmationScreen()));
                                                _isInAsyncCall = false;
                                                print(err);
                                              });

                                              print("sucess");
                                            }).catchError((err) {
                                              print(err);
                                              _isInAsyncCall = false;
                                            });
                                          });
                                        }

                                        print("sucess");
                                      }).catchError((err) {
                                        _isInAsyncCall = false;

                                        Navigator.of(context).push(PageRouteBuilder(
                                            opaque: false,
                                            pageBuilder: (BuildContext context,
                                                    _, __) =>
                                                ErrorRedeemConfirmationScreen()));
                                        print(err);
                                        // _isInAsyncCall = false;
                                      });

                                      //OrderPlace();
                                    });
                                  });
                                }).catchError((err) {
                                  print(err);

                                  Navigator.of(context).push(PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder:
                                          (BuildContext context, _, __) =>
                                              ErrorRedeemConfirmationScreen()));
                                  _isInAsyncCall = false;
                                });

                                print("sucess");
                              }).catchError((err) {
                                _isInAsyncCall = false;

                                Navigator.of(context).push(PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder:
                                        (BuildContext context, _, __) =>
                                            ErrorRedeemConfirmationScreen()));
                                print(err);
                                // _isInAsyncCall = false;
                              });
                              //}
                            });
                          }

                          print("sucess");
                        }).catchError((err) {
                          _isInAsyncCall = false;

                          Navigator.of(context).push(PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (BuildContext context, _, __) =>
                                  ErrorRedeemConfirmationScreen()));
                          print(err);
                          // _isInAsyncCall = false;
                        });
                      });
                    }

                    print("sucess");
                  }).catchError((err) {
                    _isInAsyncCall = false;

                    Navigator.of(context).push(PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) =>
                            ErrorRedeemConfirmationScreen()));
                    print(err);
                    // _isInAsyncCall = false;
                  });
                });
              }

              print("sucess");
            }).catchError((err) {
              _isInAsyncCall = false;

              Navigator.of(context).push(PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (BuildContext context, _, __) =>
                      ErrorRedeemConfirmationScreen()));
              print(err);
              // _isInAsyncCall = false;
            });
          });
        }

        print("sucess");
      }).catchError((err) {
        _isInAsyncCall = false;

        Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) =>
                ErrorRedeemConfirmationScreen()));
        print(err);
        // _isInAsyncCall = false;
      });
    }
  }

  Future FindProduct(String cart_id, String product_id) async {
    CollectionReference ref2 = Firestore.instance.collection('product');
    QuerySnapshot eventsQuery =
        await ref2.where("product_id", isEqualTo: product_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc1) async {
        String sellerid = doc1['user_id'];
        String productPrice = doc1['item_price'];

        String wight = doc1['item_pound'].toString() +
            "." +
            doc1['item_Ounces'].toString();
        double wight1 = double.parse(wight);
        int t_wight = wight1.round();
        if (t_wight == 0) {
          t_wight = 1;
        }

        FindSeller(cart_id, product_id, sellerid, productPrice);
      });
    }
  }

  Future FindSeller(String cart_id, String product_id, String sellerid,
      String productPrice) async {
    CollectionReference ref3 = Firestore.instance.collection('users');
    QuerySnapshot eventsQuery =
        await ref3.where("user_id", isEqualTo: sellerid).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc3) async {
        String email_id = doc3['email_id'];
        String token_id = doc3['token_id'];

        FindSeller(cart_id, product_id, sellerid, productPrice);
      });
    }
  }

  orderPost() async {
/*

    db.collection("product").where("product_id",isEqualTo: productid ).getDocuments().then((val1) {

      if(val1.documents.isEmpty){

      }
      else{

        val1.documents.forEach((doc1){

          String cartid = doc['cart_id'];
          String productid = doc['product_id'];


          String sellerid = doc1['user_id'];
          String productPrice = doc1['item_price'];
          String wight = doc1['item_pound'].toString()+ "." + doc1['item_Ounces'].toString();
          double wight1 = double.parse(wight);
          int t_wight = wight1.round();
          if(t_wight == 0){
            t_wight =1;
          }




        });
      }

      print("sucess");
    }).catchError((err) {
      _isInAsyncCall = false;
      _onAlertWithStyleError(context);
      print(err);
      // _isInAsyncCall = false;
    });

*/

    Payment = prf.getInt('payment');

    if (Payment == 1) {
      setState(() {
        _isInAsyncCall = true;
      });
      CollectionReference ref1 = Firestore.instance.collection('cart');
      QuerySnapshot eventsQuery =
          await ref1.where("user_id", isEqualTo: user_id).getDocuments();

      if (eventsQuery.documents.isEmpty) {
        setState(() {
          _isInAsyncCall = false;
        });
      } else {
        eventsQuery.documents.forEach((doc) async {
          /*   cartList1.add(Cart(
           doc['cart_id'], doc['product_id'], doc['status'], doc['user_id'],
           doc['date']));*/
          String cartid = doc['cart_id'];
          String productid = doc['product_id'];

          CollectionReference ref2 = Firestore.instance.collection('product');
          QuerySnapshot eventsQuery = await ref2
              .where("product_id", isEqualTo: productid)
              .getDocuments();

          if (eventsQuery.documents.isEmpty) {
            setState(() {
              _isInAsyncCall = false;
            });
          } else {
            eventsQuery.documents.forEach((doc1) async {
              String sellerid = doc1['user_id'];
              String productPrice = doc1['item_price'];
              String wight = doc1['item_pound'].toString() +
                  "." +
                  doc1['item_Ounces'].toString();
              double wight1 = double.parse(wight);
              int t_wight = wight1.round();
              if (t_wight == 0) {
                t_wight = 1;
              }

              CollectionReference ref3 = Firestore.instance.collection('users');
              QuerySnapshot eventsQuery = await ref3
                  .where("user_id", isEqualTo: sellerid)
                  .getDocuments();

              if (eventsQuery.documents.isEmpty) {
                setState(() {
                  _isInAsyncCall = false;
                });
              } else {
                eventsQuery.documents.forEach((doc3) async {
                  String email_id = doc3['email_id'];
                  String token_id = doc3['token_id'];

                  CollectionReference ref4 =
                      Firestore.instance.collection('shipping_address');
                  QuerySnapshot eventsQuery = await ref4
                      .where("user_id", isEqualTo: sellerid)
                      .where("status", isEqualTo: "0")
                      .getDocuments();

                  if (eventsQuery.documents.isEmpty) {
                    setState(() {
                      _isInAsyncCall = false;
                    });
                  } else {
                    eventsQuery.documents.forEach((doc2) async {
                      sellerAddress.add(doc2['name']);
                      sellerAddress.add(doc2['address_line_1']);
                      sellerAddress.add(doc2['address_line_2']);
                      sellerAddress.add(doc2['city']);
                      sellerAddress.add(doc2['state']);
                      sellerAddress.add(doc2['zipcode']);
                      sellerAddress.add(doc2['zip4']);
                      sellerAddress.add(doc2['phone']);
                      sellerAddress.add(email_id);

                      var db1 = Firestore.instance;

                      CollectionReference ref5 =
                          Firestore.instance.collection('wallet');
                      QuerySnapshot eventsQuery = await ref5
                          .where("user_id", isEqualTo: sellerid)
                          .getDocuments();

                      if (eventsQuery.documents.isEmpty) {
                        setState(() {
                          _isInAsyncCall = false;
                        });
                      } else {
                        eventsQuery.documents.forEach((doc) async {
                          String docId = doc['wallet_id'];
                          String available_amount = doc['available_amount'];

                          String lifetime_earning = doc['lifetime_earning'];

                          var payamount = double.parse(productPrice);

                          var value_available =
                              double.tryParse(available_amount);
                          value_available = value_available; //+ payamount;
                          var total_available_amount =
                              value_available.toString();

                          var value_lifetime =
                              double.tryParse(lifetime_earning);
                          value_lifetime = value_lifetime + payamount;
                          var total_lifetime_amount = value_lifetime.toString();
                          var up1 = {
                            'available_amount': total_available_amount,
                            'lifetime_earning': total_lifetime_amount
                          };

                          db1
                              .collection("wallet")
                              .document(docId)
                              .updateData(up1)
                              .then((val) async {
                            var map = {
                              "day_week": '',
                              "label": "",
                              "pickup_date": '',
                              "seller_id": sellerid,
                              "status": "0"
                            };

                            var db = Firestore.instance;
                            db.collection("item_order").add({
                              "date": DateTime.now(),
                              "item_id": productid,
                              "order_date": DateTime.now(),
                              "order_status": "0",
                              "payment_method": "PAYPAL",
                              'pickup_order': map,
                              'promo_code': "",
                              "purchase_price": productPrice,
                              "shipping_address": shippingAdd.toList(),
                              "shipping_charge": "",
                              "shipping_date": DateTime.now(),
                              "shipping_status": "0",
                              'user_id': user_id,
                              "seller_id": sellerid,
                              "tracking_id": "",
                            }).then((val) {
                              String id = val.documentID;

                              var order_id = {
                                'order_id': id,
                              };
                              db
                                  .collection("item_order")
                                  .document(id)
                                  .updateData(order_id)
                                  .then((val) {
                                print("sucess");

                                order_id_1 = id;

                                db3
                                    .updateProduct(Shell_Product_Model(
                                        doc1['Any_sign_wear'],
                                        doc1['category'],
                                        doc1['category_id'],
                                        doc1['country'],
                                        doc1['date'],
                                        doc1['favourite_count'],
                                        doc1['is_cart'],
                                        doc1['is_favorite_count'],
                                        doc1['item_Ounces'],
                                        doc1['item_brand'],
                                        doc1['item_color'],
                                        doc1['item_description'],
                                        doc1['item_measurements'],
                                        doc1['item_picture'],
                                        doc1['item_pound'],
                                        doc1['item_price'],
                                        doc1['item_sale_price'],
                                        doc1['item_size'],
                                        doc1['item_sold'],
                                        doc1['item_sub_title'],
                                        doc1['item_title'],
                                        doc1['item_type'],
                                        doc1['packing_type'],
                                        doc1['picture'],
                                        doc1['product_id'],
                                        doc1['retail_tag'],
                                        doc1['shipping_charge'],
                                        doc1['shipping_id'],
                                        "2",
                                        doc1['sub_category'],
                                        doc1['sub_category_id'],
                                        doc1['user_id'],
                                        doc1['tracking_id'],
                                        doc1['order_id'],
                                        doc['like_new']))
                                    .then((_) {
                                  makeCall(token_id);

                                  db3.deleteCart(cartid).then((cart) {
                                    prf.setInt('payment', 0);

                                    var payout = {
                                      "batch_status": "",
                                      "payout_batch_id": "",
                                      "sender_batch_id": "",
                                      "user_id": "",
                                      "withdraw_amount": "",
                                      "payout_email_id": "",
                                      "date": ""
                                    };

                                    var db = Firestore.instance;
                                    db.collection("payment_history").add({
                                      "amount": productPrice,
                                      "currency_code": "USD",
                                      "date": DateTime.now(),
                                      "intent": "sale",
                                      'short_description': ttl_item,
                                      'state': "approved",
                                      'user_id': user_id,
                                      'order_id': order_id_1
                                    }).then((val) {
                                      String id = val.documentID;

                                      var updateid = {'id': id};

                                      db
                                          .collection("payment_history")
                                          .document(id)
                                          .updateData(updateid)
                                          .then((val) {
                                        print("sucess");

                                        db
                                            .collection("payment_transaction")
                                            .add({
                                          "amount": productPrice,
                                          "currency_code": "USD",
                                          "refund_id": "",
                                          "state": "completed",
                                          "date": DateTime.now(),
                                          "payment_status": "0",
                                          'status': "0",
                                          'user_id': user_id,
                                          'payout_details': payout,
                                          'order_id': order_id_1
                                        }).then((val) async {
                                          var docId = val.documentID;
                                          var updateId = {
                                            "pay_id": 'PAY' + docId
                                          };

                                          db
                                              .collection("payment_transaction")
                                              .document(docId)
                                              .updateData(updateId)
                                              .then((val) async {
                                            CollectionReference ref = Firestore
                                                .instance
                                                .collection('wallet');
                                            QuerySnapshot eventsQuery =
                                                await ref
                                                    .where("user_id",
                                                        isEqualTo: user_id)
                                                    .getDocuments();

                                            if (eventsQuery.documents.isEmpty) {
                                            } else {
                                              eventsQuery.documents
                                                  .forEach((doc) async {
                                                String docId = doc['wallet_id'];
                                                String available_amount =
                                                    doc['available_amount'];
                                                String lifetime_earning =
                                                    doc['site_credit'];

                                                /*  var payamount = int.parse(Sub_totalamount);

            var value_available = int.tryParse(available_amount);
            value_available = value_available +payamount;
            var total_available_amount =  value_available.toString();

            var value_lifetime = int.tryParse(lifetime_earning);
            value_lifetime = value_lifetime + payamount;
            var total_lifetime_amount =  value_lifetime.toString();*/

                                                var up1 = {
                                                  'available_amount':
                                                      available_amount,
                                                  'site_credit':
                                                      lifetime_earning
                                                };

                                                db
                                                    .collection("wallet")
                                                    .document(docId)
                                                    .updateData(up1)
                                                    .then((val) async {
                                                  print("sucess");

                                                  var body = {
                                                    "order_id": order_id_1
                                                  };
                                                  http.Response response =
                                                      await http.post(
                                                          "https://threadon-86254.firebaseapp.com/order-email-notification-to-seller",
                                                          body: body);

                                                  if (response.statusCode ==
                                                      200) {
                                                    print(
                                                        'Order Email Success send');
                                                    var res1 = json
                                                        .decode(response.body);
                                                    var stcode = res1['status'];

                                                    if (stcode == 200) {
                                                      String msg =
                                                          res1['message'];
                                                      // _showDialog('Password Reset',msg,0);

                                                      http.Response response1 =
                                                          await http.post(
                                                              "https://threadon-86254.firebaseapp.com/order-email-notification-to-buyer",
                                                              body: body);

                                                      if (response1
                                                              .statusCode ==
                                                          200) {
                                                        print(
                                                            'Order Email Success send');
                                                        var res1 = json.decode(
                                                            response1.body);
                                                        var stcode =
                                                            res1['status'];

                                                        if (stcode == 200) {
                                                          String msg =
                                                              res1['message'];
                                                          // _showDialog('Password Reset',msg,0);
                                                        } else {
                                                          String msg =
                                                              res1['message'];
                                                          //     _showDialog('Error',msg,1);
                                                        }
                                                      } else {
                                                        //    showTost('Error');
                                                        print('Error');
                                                        //        _showDialog('Error','Order Email not send',1);
                                                        setState(() {
                                                          _isInAsyncCall =
                                                              false;
                                                        });
                                                      }
                                                    } else {
                                                      String msg =
                                                          res1['message'];
                                                      //      _showDialog('Error',msg,1);
                                                    }
                                                  } else {
                                                    //    showTost('Error');
                                                    print('Error');
                                                    //  _showDialog('Error','Order Email not send',1);
                                                    setState(() {
                                                      _isInAsyncCall = false;
                                                    });
                                                  }

                                                  setState(() {
                                                    _isInAsyncCall = false;
                                                  });

                                                  if (PopupFlag == 0) {
                                                    PopupFlag = 1;
                                                    _onAlertWithStylePressed(
                                                        context);
                                                  }
                                                }).catchError((err) {
                                                  print(err);

                                                  Navigator.of(context).push(
                                                      PageRouteBuilder(
                                                          opaque: false,
                                                          pageBuilder: (BuildContext
                                                                      context,
                                                                  _,
                                                                  __) =>
                                                              ErrorRedeemConfirmationScreen()));
                                                  _isInAsyncCall = false;
                                                });
                                              });
                                            }

                                            print("sucess");
                                          }).catchError((err) {
                                            _isInAsyncCall = false;

                                            Navigator.of(context).push(
                                                PageRouteBuilder(
                                                    opaque: false,
                                                    pageBuilder: (BuildContext
                                                                context,
                                                            _,
                                                            __) =>
                                                        ErrorRedeemConfirmationScreen()));
                                            print(err);
                                            // _isInAsyncCall = false;
                                          });

                                          print("sucess");
                                        }).catchError((err) {
                                          print(err);

                                          Navigator.of(context).push(
                                              PageRouteBuilder(
                                                  opaque: false,
                                                  pageBuilder: (BuildContext
                                                              context,
                                                          _,
                                                          __) =>
                                                      ErrorRedeemConfirmationScreen()));
                                          _isInAsyncCall = false;
                                        });
                                      }).catchError((err) {
                                        _isInAsyncCall = false;

                                        Navigator.of(context).push(PageRouteBuilder(
                                            opaque: false,
                                            pageBuilder: (BuildContext context,
                                                    _, __) =>
                                                ErrorRedeemConfirmationScreen()));
                                        print(err);
                                        // _isInAsyncCall = false;
                                      });

                                      print("sucess");
                                    }).catchError((err) {
                                      Navigator.of(context).push(PageRouteBuilder(
                                          opaque: false,
                                          pageBuilder: (BuildContext context, _,
                                                  __) =>
                                              ErrorRedeemConfirmationScreen()));
                                      _isInAsyncCall = false;
                                      print(err);
                                    });
                                    //OrderPlace();
                                  });
                                });
                              }).catchError((err) {
                                print(err);

                                Navigator.of(context).push(PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder:
                                        (BuildContext context, _, __) =>
                                            ErrorRedeemConfirmationScreen()));
                                _isInAsyncCall = false;
                              });

                              print("sucess");
                            }).catchError((err) {
                              _isInAsyncCall = false;

                              Navigator.of(context).push(PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (BuildContext context, _, __) =>
                                      ErrorRedeemConfirmationScreen()));
                              print(err);
                              // _isInAsyncCall = false;
                            });

                            print("sucess");
                          }).catchError((err) {
                            print(err);
                            _isInAsyncCall = false;
                          });
                        });
                      }
                    });
                  }
                });
              }
            });
          }
        });
      }
    }
  }

  OrderPlace() {
    var payout = {
      "batch_status": "",
      "payout_batch_id": "",
      "sender_batch_id": "",
      "user_id": "",
      "withdraw_amount": "",
      "payout_email_id": "",
      "date": ""
    };

    var db = Firestore.instance;
    db.collection("payment_history").add({
      "amount": "",
      "currency_code": "USD",
      "date": DateTime.now(),
      "intent": "sale",
      'short_description': ttl_item,
      'state': "approved",
      'user_id': user_id,
      'order_id': order_id_1
    }).then((val) {
      String id = val.documentID;

      var updateid = {'id': id};

      db
          .collection("payment_history")
          .document(id)
          .updateData(updateid)
          .then((val) {
        print("sucess");

        db.collection("payment_transaction").add({
          "amount": "",
          "currency_code": "USD",
          "refund_id": "",
          "state": "completed",
          "date": DateTime.now(),
          "payment_status": "0",
          'status': "0",
          'user_id': user_id,
          'payout_details': payout,
          'order_id': order_id_1
        }).then((val) async {
          var docId = val.documentID;
          var updateId = {"pay_id": 'PAY' + docId};

          db
              .collection("payment_transaction")
              .document(docId)
              .updateData(updateId)
              .then((val) async {
            CollectionReference ref = Firestore.instance.collection('wallet');
            QuerySnapshot eventsQuery =
                await ref.where("user_id", isEqualTo: user_id).getDocuments();

            if (eventsQuery.documents.isEmpty) {
            } else {
              eventsQuery.documents.forEach((doc) async {
                String docId = doc['wallet_id'];
                String available_amount = doc['available_amount'];
                String lifetime_earning = doc['site_credit'];

                /*  var payamount = int.parse(Sub_totalamount);

            var value_available = int.tryParse(available_amount);
            value_available = value_available +payamount;
            var total_available_amount =  value_available.toString();

            var value_lifetime = int.tryParse(lifetime_earning);
            value_lifetime = value_lifetime + payamount;
            var total_lifetime_amount =  value_lifetime.toString();*/

                var up1 = {
                  'available_amount': available_amount,
                  'site_credit': lifetime_earning
                };

                db
                    .collection("wallet")
                    .document(docId)
                    .updateData(up1)
                    .then((val) async {
                  print("sucess");

                  var body = {"order_id": order_id_1};
                  http.Response response = await http.post(
                      "https://threadon-86254.firebaseapp.com/order-email-notification-to-seller",
                      body: body);

                  if (response.statusCode == 200) {
                    print('Order Email Success send');
                    var res1 = json.decode(response.body);
                    var stcode = res1['status'];

                    if (stcode == 200) {
                      String msg = res1['message'];
                      // _showDialog('Password Reset',msg,0);

                      http.Response response1 = await http.post(
                          "https://threadon-86254.firebaseapp.com/order-email-notification-to-buyer",
                          body: body);

                      if (response1.statusCode == 200) {
                        print('Order Email Success send');
                        var res1 = json.decode(response1.body);
                        var stcode = res1['status'];

                        if (stcode == 200) {
                          String msg = res1['message'];
                          // _showDialog('Password Reset',msg,0);
                        } else {
                          String msg = res1['message'];
                          //     _showDialog('Error',msg,1);
                        }
                      } else {
                        //    showTost('Error');
                        print('Error');
                        //        _showDialog('Error','Order Email not send',1);
                        setState(() {
                          _isInAsyncCall = false;
                        });
                      }
                    } else {
                      String msg = res1['message'];
                      //      _showDialog('Error',msg,1);
                    }
                  } else {
                    //    showTost('Error');
                    print('Error');
                    //  _showDialog('Error','Order Email not send',1);
                    setState(() {
                      _isInAsyncCall = false;
                    });
                  }

                  setState(() {
                    _isInAsyncCall = false;
                  });

                  if (PopupFlag == 0) {
                    PopupFlag = 1;
                    _onAlertWithStylePressed(context);
                  }
                }).catchError((err) {
                  print(err);

                  Navigator.of(context).push(PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) =>
                          ErrorRedeemConfirmationScreen()));
                  _isInAsyncCall = false;
                });
              });
            }

            print("sucess");
          }).catchError((err) {
            _isInAsyncCall = false;

            Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) =>
                    ErrorRedeemConfirmationScreen()));
            print(err);
            // _isInAsyncCall = false;
          });

          print("sucess");
        }).catchError((err) {
          print(err);

          Navigator.of(context).push(PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) =>
                  ErrorRedeemConfirmationScreen()));
          _isInAsyncCall = false;
        });
      }).catchError((err) {
        _isInAsyncCall = false;

        Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) =>
                ErrorRedeemConfirmationScreen()));
        print(err);
        // _isInAsyncCall = false;
      });

      print("sucess");
    }).catchError((err) {
      Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) =>
              ErrorRedeemConfirmationScreen()));
      _isInAsyncCall = false;
      print(err);
    });
  }

  Future<bool> makeCall(String Seller_device_id) async {
    final data = {
      "notification": {
        "body": "Your item has been sold, Tap to more information.",
        "title": "Congrats!"
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default",
        "id": "1",
        "status": "done",
        "nt": "2",
      },
      "to": Seller_device_id
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAqfgKAe8:APA91bEEwkEhKzOBxsxQMjxF6HJ1g5U7lY7x363dqrSQqfv9CxRV8wxA-m4U9xD77Og423_seN-gyhFtB0uc4Ilw10bwcPv9HzrMlZVh8tb-tbL4QCYOx0Ad5WPawh0BBNbOfLIYGwjL'
    };

    final response = await http.post(postUrl,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // on success do sth
      return true;
    } else {
      // on failure do sth
      return false;
    }
  }

  Widget creditCardWidget(List<PaymentBillModel> paymentcard, int pos) {
    var deviceSize = MediaQuery.of(context).size;
    return Container(
      height: deviceSize.height * 0.3,
      color: Colors.grey.shade300,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 3.0,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: kitGradients)),
              ),
              Opacity(
                opacity: 0.1,
                child: Image.asset(
                  "images/map.png",
                  fit: BoxFit.cover,
                ),
              ),
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? cardEntries(paymentcard, pos)
                  : FittedBox(
                      child: cardEntries(paymentcard, pos),
                    ),
              Positioned(
                  right: 10.0,
                  top: 10.0,
                  child: getIcone(paymentcard[pos].type)),
              Positioned(
                  right: 10.0,
                  bottom: 10.0,
                  child: Container(
                    child: paymentcard[pos].first_name == ""
                        ? Text('Your Name')
                        : Text(
                            paymentcard[pos].first_name,
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                  ) /*StreamBuilder<String>(
                  stream: cardBloc.nameOutputStream,
                  initialData: "Your Name",
                  builder: (context, snapshot) => Text(
                    snapshot.data.length > 0 ? snapshot.data : "Your Name",
                    style: TextStyle(
                        color: Colors.white,

                        fontSize: 20.0),
                  ),
                ),*/
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getIcone(String type) {
    if (type == 'visa') {
      return Icon(
        FontAwesomeIcons.ccVisa,
        size: 30.0,
        color: Colors.white,
      );
    } else if (type == 'mastercard') {
      return Icon(
        FontAwesomeIcons.ccMastercard,
        size: 30.0,
        color: Colors.white,
      );
    } else if (type == 'amex') {
      return Icon(
        FontAwesomeIcons.ccAmex,
        size: 30.0,
        color: Colors.white,
      );
    } else if (type == 'discover') {
      return Icon(
        FontAwesomeIcons.ccDiscover,
        size: 30.0,
        color: Colors.white,
      );
    } else if (type == 'maestro') {
      return Icon(
        FontAwesomeIcons.ccMastercard,
        size: 30.0,
        color: Colors.white,
      );
    }
  }

  static List<Color> kitGradients = [
    // new Color.fromRGBO(103, 218, 255, 1.0),
    // new Color.fromRGBO(3, 169, 244, 1.0),
    // new Color.fromRGBO(0, 122, 193, 1.0),
    Colors.blueGrey.shade800,
    Colors.black87,
  ];
  static List<Color> kitGradients2 = [
    Colors.cyan.shade600,
    Colors.blue.shade900
  ];

  Widget cardEntries(List<PaymentBillModel> paymentcard1, int pos1) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: paymentcard1[pos1].first_name == ""
                  ? Text('**** **** **** ****',
                      style: TextStyle(color: Colors.white, fontSize: 16.0))
                  : Text(
                      paymentcard1[pos1].number,
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    child: Column(
                  children: <Widget>[
                    Text("Expiry",
                        style: TextStyle(color: Colors.white, fontSize: 18.0)),
                    Container(
                      height: 3.0,
                    ),
                    Container(
                      child: paymentcard1[pos1].first_name == ""
                          ? Text('MM/YYYY',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.0))
                          : Text(
                              paymentcard1[pos1].expire_month +
                                  "/" +
                                  paymentcard1[pos1].expire_year,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.0),
                            ),
                    )
                  ],
                )),
                SizedBox(
                  width: 30.0,
                ),
                Column(
                  children: <Widget>[
                    Text("CVV",
                        style: TextStyle(color: Colors.white, fontSize: 18.0)),
                    Container(
                      height: 3.0,
                    ),
                    Container(
                        child: Text('****',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0)))
                  ],
                )
              ],
            ),
          ],
        ),
      );

  Future<dynamic> post() async {
    String username =
        "AVrtqjI938aTqO9zZHOh1Lvm4ku_zUrBA1XJrwk-Ns-yr6o77EuAtq0YyRlkHBUsILFlWlgfYzffVcrb";
    String password =
        "EEoB8DUFd0pCnbh9S_P91Z3VvIEZ5h1PqJlCegr3EXKqg0oLgl3FgmmU2bGx-FEw1r4PnGqlab-zQskB";
    var bytes = utf8.encode("$username:$password");
    var credentials = base64.encode(bytes);
    Map token = {'grant_type': 'client_credentials'};
    var headers = {
      "Accept": "application/json",
      'Accept-Language': 'en_US',
      "Authorization": "Basic $credentials"
    };
    var url = "https://api.sandbox.paypal.com/v1/oauth2/token";
    var requestBody = token;
    http.Response response1 =
        await http.post(url, body: requestBody, headers: headers);
    var responseJson = json.decode(response1.body);
    // var res = fromJson(responseJson);
    AccessToken = responseJson['access_token'];

    HttpClient httpClient = new HttpClient();
    HttpClientRequest request;
    Map map = {
      'id': 'CPPAY-13U46775',
      'intent': 'sale',
      'payer': {
        'payment_method': 'credit_card',
        'funding_instruments': [
          {
            'credit_card_token': {
              'credit_card_id': cardNumber,
              'external_customer_id': custmorId
            }
          }
        ]
      },
      'transactions': [
        {
          'amount': {'total': ttl_price, 'currency': 'USD'},
          'description': 'Payment by vaulted credit card.'
        }
      ]
    };

    var data = '{"id": "CARD-0JR69855UB523752YLTAZ3ZY","intent": "sale",'
        '"payer": {"payment_method": "credit_card","funding_instruments": '
        '[{"credit_card_token":'
        ' {"credit_card_id": "CARD-0JR69855UB523752YLTAZ3ZY","external_customer_id":"CARD-0JR69855UB523752YLTAZ3ZY"}}]},'
        '"transactions":'
        ' [{"amount": {"total": "1.00", "currency": "USD"},'
        '"description": "Payment by vaulted credit card."}]}';

    var jsond = json.encode(map);

    /* Map token = {
      'AZUBLiZfZkWE2CA0cT6tXZIRcd2wQleXh30lc35WL5VS3FfLZSjRnnCqfv1mkp9QgQtcB5anjnKl7dFn':'EBR8A1JNCIwF6zwnVmAUDuoIzo7sL5dsaXfApU2-x8Mxm2eP4CFotb_kTEl_1n_pisejhK6ZaII4tGrC',
      'grant_type': 'client_credentials'
    };*/
    request = await httpClient.postUrl(
        Uri.parse('https://api.sandbox.paypal.com/v1/payments/payment/'));
    request.headers.set('content-type', 'application/json');
    request.headers.set('authorization', 'Bearer ' + AccessToken);

    request.add(utf8.encode(jsond));
    HttpClientResponse response = await request.close();
    // todo - you should check the response.statusCode

    final int statusCode = response.statusCode;
    Respons = await utf8.decoder.bind(response).join();
    // Respons = await response.transform(utf8.decoder).join();
    if (statusCode <= 200 || statusCode >= 299) {
      setState(() {
        _isInAsyncCall = false;
      });
      throw new Exception("Error while fetching data");
    }

    var succData = json.decode(Respons);
    if (succData['state'] == 'failed') {
      _paymentFaild(context);
      _isInAsyncCall = false;
    } else {
      var pay_id = succData['id'];
      var refund_id =
          succData['transactions'][0]['related_resources'][0]['sale']['id'];
      var amount = succData['transactions'][0]['related_resources'][0]['sale']
          ['amount']['total'];
      var state =
          succData['transactions'][0]['related_resources'][0]['sale']['state'];
      var currency = succData['transactions'][0]['related_resources'][0]['sale']
          ['amount']['currency'];

      orderPostByCreditCard(pay_id, refund_id, state, currency);
    }
  }

  orderPostByCreditCard(String pay_id, String refund_id, String state,
      String curancy_code) async {
    var db = Firestore.instance;
    db
        .collection("cart")
        .where("user_id", isEqualTo: user_id)
        .getDocuments()
        .then((val) {
      if (val.documents.isEmpty) {
      } else {
        val.documents.forEach((doc) {
          String cartid = doc['cart_id'];
          String productid = doc['product_id'];

          db
              .collection("product")
              .where("product_id", isEqualTo: productid)
              .getDocuments()
              .then((val1) {
            if (val1.documents.isEmpty) {
            } else {
              val1.documents.forEach((doc1) {
                String sellerid = doc1['user_id'];
                String productPrice = doc1['item_price'];
                String wight = doc1['item_pound'].toString() +
                    "." +
                    doc1['item_Ounces'].toString();
                double wight1 = double.parse(wight);
                int t_wight = wight1.round();
                if (t_wight == 0) {
                  t_wight = 1;
                }

                db
                    .collection("users")
                    .where("user_id", isEqualTo: sellerid)
                    .getDocuments()
                    .then((val2) {
                  if (val2.documents.isEmpty) {
                  } else {
                    val2.documents.forEach((doc2) {
                      String email_id = doc2['email_id'];
                      String token_id = doc2['token_id'];

                      db
                          .collection("shipping_address")
                          .where("user_id", isEqualTo: sellerid)
                          .where("status", isEqualTo: "0")
                          .getDocuments()
                          .then((val3) {
                        if (val3.documents.isEmpty) {
                        } else {
                          val3.documents.forEach((doc3) async {
                            sellerAddress = new List();
                            sellerAddress.add(doc3['name']);
                            sellerAddress.add(doc3['address_line_1']);
                            sellerAddress.add(doc3['address_line_2']);
                            sellerAddress.add(doc3['city']);
                            sellerAddress.add(doc3['state']);
                            sellerAddress.add(doc3['zipcode']);
                            sellerAddress.add(doc3['zip4']);
                            sellerAddress.add(doc3['phone']);
                            sellerAddress.add(email_id);

                            var map = {
                              "day_week": '',
                              "label": "",
                              "pickup_date": '',
                              "seller_id": sellerid,
                              "status": "0"
                            };

                            var db = Firestore.instance;
                            db.collection("item_order").add({
                              "date": DateTime.now(),
                              "item_id": productid,
                              "order_date": DateTime.now(),
                              "order_status": "0",
                              "payment_method": "CREDIT CARD",
                              'pickup_order': map,
                              'promo_code': "",
                              "purchase_price": productPrice,
                              "shipping_address": shippingAdd.toList(),
                              "shipping_charge": "",
                              "shipping_date": DateTime.now(),
                              "shipping_status": "0",
                              'user_id': user_id,
                              "seller_id": sellerid,
                              "tracking_id": "",
                            }).then((val) {
                              String id = val.documentID;

                              var order_id = {
                                'order_id': id,
                              };
                              db
                                  .collection("item_order")
                                  .document(id)
                                  .updateData(order_id)
                                  .then((val) {
                                print("sucess");

                                order_id_1 = id;

                                db3
                                    .updateProduct(Shell_Product_Model(
                                        doc1['Any_sign_wear'],
                                        doc1['category'],
                                        doc1['category_id'],
                                        doc1['country'],
                                        doc1['date'],
                                        doc1['favourite_count'],
                                        doc1['is_cart'],
                                        doc1['is_favorite_count'],
                                        doc1['item_Ounces'],
                                        doc1['item_brand'],
                                        doc1['item_color'],
                                        doc1['item_description'],
                                        doc1['item_measurements'],
                                        doc1['item_picture'],
                                        doc1['item_pound'],
                                        doc1['item_price'],
                                        doc1['item_sale_price'],
                                        doc1['item_size'],
                                        doc1['item_sold'],
                                        doc1['item_sub_title'],
                                        doc1['item_title'],
                                        doc1['item_type'],
                                        doc1['packing_type'],
                                        doc1['picture'],
                                        doc1['product_id'],
                                        doc1['retail_tag'],
                                        doc1['shipping_charge'],
                                        doc1['shipping_id'],
                                        "2",
                                        doc1['sub_category'],
                                        doc1['sub_category_id'],
                                        doc1['user_id'],
                                        doc1['tracking_id'],
                                        doc1['order_id'],
                                        doc['like_new']))
                                    .then((_) {
                                  makeCall(token_id);

                                  db3.deleteCart(cartid).then((cart) {
                                    // prf.setInt('payment', 0);

                                    db
                                        .collection("wallet")
                                        .where("user_id", isEqualTo: sellerid)
                                        .getDocuments()
                                        .then((val4) {
                                      if (val4.documents.isEmpty) {
                                      } else {
                                        val4.documents.forEach((doc4) {
                                          String docId = doc4['wallet_id'];
                                          String available_amount =
                                              doc4['available_amount'];

                                          String lifetime_earning =
                                              doc4['lifetime_earning'];

                                          var payamount =
                                              double.parse(productPrice);

                                          var value_available =
                                              double.tryParse(available_amount);
                                          value_available =
                                              value_available; //+ payamount;
                                          var total_available_amount =
                                              value_available.toString();

                                          var value_lifetime =
                                              double.tryParse(lifetime_earning);
                                          value_lifetime =
                                              value_lifetime + payamount;
                                          var total_lifetime_amount =
                                              value_lifetime.toString();
                                          var up1 = {
                                            'available_amount':
                                                total_available_amount,
                                            'lifetime_earning':
                                                total_lifetime_amount
                                          };

                                          db
                                              .collection("wallet")
                                              .document(docId)
                                              .updateData(up1)
                                              .then((val) async {
                                            var payout = {
                                              "batch_status": "",
                                              "payout_batch_id": "",
                                              "sender_batch_id": "",
                                              "user_id": "",
                                              "withdraw_amount": "",
                                              "payout_email_id": "",
                                              "date": ""
                                            };

                                            var db = Firestore.instance;
                                            db
                                                .collection("payment_history")
                                                .add({
                                              "amount": productPrice,
                                              "currency_code": "USD",
                                              "date": DateTime.now(),
                                              "intent": "sale",
                                              'short_description': ttl_item,
                                              'state': "approved",
                                              'user_id': user_id,
                                              'order_id': order_id_1
                                            }).then((val) {
                                              String id = val.documentID;

                                              var updateid = {'id': id};

                                              db
                                                  .collection("payment_history")
                                                  .document(id)
                                                  .updateData(updateid)
                                                  .then((val) {
                                                print("sucess");

                                                db
                                                    .collection(
                                                        "payment_transaction")
                                                    .add({
                                                  "amount": productPrice,
                                                  "currency_code": curancy_code,
                                                  "refund_id": refund_id,
                                                  "state": state,
                                                  "date": DateTime.now(),
                                                  "payment_status": "0",
                                                  'status': "0",
                                                  'user_id': user_id,
                                                  'payout_details': payout,
                                                  'order_id': order_id_1
                                                }).then((val) async {
                                                  var docId = val.documentID;
                                                  var updateId = {
                                                    "pay_id": 'PAY' + docId
                                                  };

                                                  db
                                                      .collection(
                                                          "payment_transaction")
                                                      .document(docId)
                                                      .updateData(updateId)
                                                      .then((val) async {
                                                    CollectionReference ref =
                                                        Firestore.instance
                                                            .collection(
                                                                'wallet');
                                                    QuerySnapshot eventsQuery =
                                                        await ref
                                                            .where("user_id",
                                                                isEqualTo:
                                                                    user_id)
                                                            .getDocuments();

                                                    if (eventsQuery
                                                        .documents.isEmpty) {
                                                    } else {
                                                      eventsQuery.documents
                                                          .forEach((doc) async {
                                                        String docId =
                                                            doc['wallet_id'];
                                                        String
                                                            available_amount =
                                                            doc['available_amount'];
                                                        String
                                                            lifetime_earning =
                                                            doc['site_credit'];

                                                        /*  var payamount = int.parse(Sub_totalamount);

            var value_available = int.tryParse(available_amount);
            value_available = value_available +payamount;
            var total_available_amount =  value_available.toString();

            var value_lifetime = int.tryParse(lifetime_earning);
            value_lifetime = value_lifetime + payamount;
            var total_lifetime_amount =  value_lifetime.toString();*/

                                                        var up1 = {
                                                          'available_amount':
                                                              available_amount,
                                                          'site_credit':
                                                              lifetime_earning
                                                        };

                                                        db
                                                            .collection(
                                                                "wallet")
                                                            .document(docId)
                                                            .updateData(up1)
                                                            .then((val) async {
                                                          print("sucess");

                                                          var body = {
                                                            "order_id":
                                                                order_id_1
                                                          };
                                                          http.Response
                                                              response =
                                                              await http.post(
                                                                  "https://threadon-86254.firebaseapp.com/order-email-notification-to-seller",
                                                                  body: body);

                                                          if (response
                                                                  .statusCode ==
                                                              200) {
                                                            print(
                                                                'Order Email Success send');
                                                            var res1 = json
                                                                .decode(response
                                                                    .body);
                                                            var stcode =
                                                                res1['status'];

                                                            if (stcode == 200) {
                                                              String msg = res1[
                                                                  'message'];
                                                              // _showDialog('Password Reset',msg,0);

                                                              http.Response
                                                                  response1 =
                                                                  await http.post(
                                                                      "https://threadon-86254.firebaseapp.com/order-email-notification-to-buyer",
                                                                      body:
                                                                          body);

                                                              if (response1
                                                                      .statusCode ==
                                                                  200) {
                                                                print(
                                                                    'Order Email Success send');
                                                                var res1 =
                                                                    json.decode(
                                                                        response1
                                                                            .body);
                                                                var stcode = res1[
                                                                    'status'];

                                                                if (stcode ==
                                                                    200) {
                                                                  String msg = res1[
                                                                      'message'];
                                                                  // _showDialog('Password Reset',msg,0);
                                                                } else {
                                                                  String msg = res1[
                                                                      'message'];
                                                                  //     _showDialog('Error',msg,1);
                                                                }
                                                              } else {
                                                                //    showTost('Error');
                                                                print('Error');
                                                                //        _showDialog('Error','Order Email not send',1);
                                                                setState(() {
                                                                  _isInAsyncCall =
                                                                      false;
                                                                });
                                                              }
                                                            } else {
                                                              String msg = res1[
                                                                  'message'];
                                                              //      _showDialog('Error',msg,1);
                                                            }
                                                          } else {
                                                            //    showTost('Error');
                                                            print('Error');
                                                            //  _showDialog('Error','Order Email not send',1);
                                                            setState(() {
                                                              _isInAsyncCall =
                                                                  false;
                                                            });
                                                          }

                                                          setState(() {
                                                            _isInAsyncCall =
                                                                false;
                                                          });

                                                          if (PopupFlag == 0) {
                                                            PopupFlag = 1;
                                                            //  _onAlertWithStylePressed(context);

                                                            Navigator.of(
                                                                    context)
                                                                .push(PageRouteBuilder(
                                                                    opaque:
                                                                        false,
                                                                    pageBuilder: (BuildContext
                                                                                context,
                                                                            _,
                                                                            __) =>
                                                                        RedeemConfirmationScreen()));
                                                          }
                                                        }).catchError((err) {
                                                          print(err);

                                                          Navigator.of(context).push(
                                                              PageRouteBuilder(
                                                                  opaque: false,
                                                                  pageBuilder: (BuildContext
                                                                              context,
                                                                          _,
                                                                          __) =>
                                                                      ErrorRedeemConfirmationScreen()));
                                                          _isInAsyncCall =
                                                              false;
                                                        });
                                                      });
                                                    }

                                                    print("sucess");
                                                  }).catchError((err) {
                                                    _isInAsyncCall = false;

                                                    Navigator.of(context).push(
                                                        PageRouteBuilder(
                                                            opaque: false,
                                                            pageBuilder: (BuildContext
                                                                        context,
                                                                    _,
                                                                    __) =>
                                                                ErrorRedeemConfirmationScreen()));
                                                    print(err);
                                                    // _isInAsyncCall = false;
                                                  });

                                                  print("sucess");
                                                }).catchError((err) {
                                                  print(err);

                                                  Navigator.of(context).push(
                                                      PageRouteBuilder(
                                                          opaque: false,
                                                          pageBuilder: (BuildContext
                                                                      context,
                                                                  _,
                                                                  __) =>
                                                              ErrorRedeemConfirmationScreen()));
                                                  _isInAsyncCall = false;
                                                });
                                              }).catchError((err) {
                                                _isInAsyncCall = false;

                                                Navigator.of(context).push(
                                                    PageRouteBuilder(
                                                        opaque: false,
                                                        pageBuilder: (BuildContext
                                                                    context,
                                                                _,
                                                                __) =>
                                                            ErrorRedeemConfirmationScreen()));
                                                print(err);
                                                // _isInAsyncCall = false;
                                              });

                                              print("sucess");
                                            }).catchError((err) {
                                              Navigator.of(context).push(
                                                  PageRouteBuilder(
                                                      opaque: false,
                                                      pageBuilder: (BuildContext
                                                                  context,
                                                              _,
                                                              __) =>
                                                          ErrorRedeemConfirmationScreen()));
                                              _isInAsyncCall = false;
                                              print(err);
                                            });

                                            print("sucess");
                                          }).catchError((err) {
                                            print(err);
                                            _isInAsyncCall = false;
                                          });
                                        });
                                      }

                                      print("sucess");
                                    }).catchError((err) {
                                      _isInAsyncCall = false;

                                      Navigator.of(context).push(PageRouteBuilder(
                                          opaque: false,
                                          pageBuilder: (BuildContext context, _,
                                                  __) =>
                                              ErrorRedeemConfirmationScreen()));
                                      print(err);
                                      // _isInAsyncCall = false;
                                    });

                                    //OrderPlace();
                                  });
                                });
                              }).catchError((err) {
                                print(err);

                                Navigator.of(context).push(PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder:
                                        (BuildContext context, _, __) =>
                                            ErrorRedeemConfirmationScreen()));
                                _isInAsyncCall = false;
                              });

                              print("sucess");
                            }).catchError((err) {
                              _isInAsyncCall = false;

                              Navigator.of(context).push(PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (BuildContext context, _, __) =>
                                      ErrorRedeemConfirmationScreen()));
                              print(err);
                              // _isInAsyncCall = false;
                            });
                          });
                        }

                        print("sucess");
                      }).catchError((err) {
                        _isInAsyncCall = false;

                        Navigator.of(context).push(PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) =>
                                ErrorRedeemConfirmationScreen()));
                        print(err);
                        // _isInAsyncCall = false;
                      });
                    });
                  }

                  print("sucess");
                }).catchError((err) {
                  _isInAsyncCall = false;

                  Navigator.of(context).push(PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) =>
                          ErrorRedeemConfirmationScreen()));
                  print(err);
                  // _isInAsyncCall = false;
                });
              });
            }

            print("sucess");
          }).catchError((err) {
            _isInAsyncCall = false;

            Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) =>
                    ErrorRedeemConfirmationScreen()));
            print(err);
            // _isInAsyncCall = false;
          });
        });
      }

      print("sucess");
    }).catchError((err) {
      _isInAsyncCall = false;

      Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) =>
              ErrorRedeemConfirmationScreen()));
      print(err);
      // _isInAsyncCall = false;
    });

    /*








    _isInAsyncCall = true;
      CollectionReference ref1 = Firestore.instance.collection('cart');
      QuerySnapshot eventsQuery =
      await ref1.where("user_id", isEqualTo: user_id).getDocuments();

      if (eventsQuery.documents.isEmpty) {
        setState(() {
          _isInAsyncCall = false;
        });
      } else {
        eventsQuery.documents.forEach((doc) async {
          */ /*   cartList1.add(Cart(
           doc['cart_id'], doc['product_id'], doc['status'], doc['user_id'],
           doc['date']));*/ /*
          String cartid = doc['cart_id'];
          String productid = doc['product_id'];

          CollectionReference ref2 = Firestore.instance.collection('product');
          QuerySnapshot eventsQuery = await ref2.where("product_id", isEqualTo: productid).getDocuments();

          if (eventsQuery.documents.isEmpty) {
            setState(() {
              _isInAsyncCall = false;
            });
          } else {
            eventsQuery.documents.forEach((doc1) async {
              String sellerid = doc1['user_id'];
              String productPrice = doc1['item_price'];
              String wight = doc1['item_pound'].toString()+ "." + doc1['item_Ounces'].toString();
              double wight1 = double.parse(wight);
              int t_wight = wight1.round();
              if(t_wight == 0){
                t_wight =1;
              }



              CollectionReference ref3 = Firestore.instance.collection('users');
              QuerySnapshot eventsQuery =
              await ref3.where("user_id", isEqualTo: sellerid).getDocuments();

              if (eventsQuery.documents.isEmpty) {
                setState(() {
                  _isInAsyncCall = false;
                });
              } else {
                eventsQuery.documents.forEach((doc3) async {
                  String email_id = doc3['email_id'];
                  String token_id = doc3['token_id'];


                  CollectionReference ref4 = Firestore.instance.collection('shipping_address');
                  QuerySnapshot eventsQuery =
                  await ref4.where("user_id" ,isEqualTo: sellerid).where("status", isEqualTo: "0").getDocuments();

                  if (eventsQuery.documents.isEmpty) {
                    setState(() {
                      _isInAsyncCall = false;
                    });
                  } else {
                    eventsQuery.documents.forEach((doc2) async {

                      List<String> sellerAddress = new List();
                      sellerAddress.add(doc2['name']);
                      sellerAddress.add(doc2['address_line_1']);
                      sellerAddress.add(doc2['address_line_2']);
                      sellerAddress.add(doc2['city']);
                      sellerAddress.add(doc2['state']);
                      sellerAddress.add(doc2['zipcode']);
                      sellerAddress.add(doc2['zip4']);
                      sellerAddress.add(doc2['phone']);
                      sellerAddress.add(email_id);


                      var db1 = Firestore.instance;

                      CollectionReference ref5 = Firestore.instance.collection('wallet');
                      QuerySnapshot eventsQuery =
                      await ref5.where("user_id", isEqualTo: sellerid).getDocuments();

                      if (eventsQuery.documents.isEmpty) {
                        setState(() {
                          _isInAsyncCall = false;
                        });
                      } else {
                        eventsQuery.documents.forEach((doc) async {


                          String docId = doc['wallet_id'];
                          String available_amount = doc['available_amount'];

                          String lifetime_earning = doc['lifetime_earning'];

                          var payamount = double.parse(productPrice);

                          var value_available = double.tryParse(available_amount);
                          value_available = value_available + payamount;
                          var total_available_amount = value_available.toString();

                          var value_lifetime = double.tryParse(lifetime_earning);
                          value_lifetime = value_lifetime + payamount;
                          var total_lifetime_amount = value_lifetime.toString();
                          var up1 = {
                            'available_amount': total_available_amount,
                            'lifetime_earning': total_lifetime_amount
                          };

                          db1
                              .collection("wallet")
                              .document(docId)
                              .updateData(up1)
                              .then((val) async {




                            var builder = new xml.XmlBuilder();
                            //builder.processing('xml', 'version="1.0" encoding="iso-8859-9"');
                            builder.element('CarrierPickupScheduleRequest', nest: () {
                              builder.attribute('USERID', '186LOFTY0774');
                              builder.element('FirstName', nest: sellerAddress[0].toString());
                              builder.element('LastName', nest: sellerAddress[0].toString());
                              builder.element('FirmName', nest: "");
                              builder.element('SuiteOrApt', nest: "");


                              builder.element('Address2', nest: sellerAddress[1].toString());
                              builder.element('Urbanization', nest: "");
                              builder.element('City', nest: sellerAddress[3].toString());
                              builder.element('State', nest: sellerAddress[4].toString());
                              builder.element('ZIP5', nest: sellerAddress[5].toString());
                              builder.element('ZIP4', nest: sellerAddress[6].toString());
                              builder.element('Phone', nest: sellerAddress[7].toString());

                              builder.element('Extension', nest:'');
                              builder.element('Package', nest: () {
                                builder.element('ServiceType', nest: "PriorityMailExpress");
                                builder.element('Count', nest: "1");
                              });


                              builder.element('EstimatedWeight', nest: t_wight);
                              builder.element('PackageLocation', nest: 'Knock on Door/Ring Bell');
                              builder.element('SpecialInstructions', nest: "");
                              //builder.element('EmailAddress', nest: sellerAddress[8].toString());
                              builder.element('EmailAddress', nest: "sani3854@gmail.com");

                            });


                            var bookshelfXml = builder.build();

                            String _uriMsj = bookshelfXml.toString();

                            print("_uriMsj: $_uriMsj");

                            String _uri = "https://secure.shippingapis.com/ShippingAPI.dll?API=CarrierPickupSchedule&XML=";

                            HttpClient client = new HttpClient();

                            HttpClientRequest request = await client.postUrl(
                                Uri.parse(_uri + _uriMsj));

                            // request.write(_message);
                            //request.writeln(_message);
                            //request.writeAll(_message);

                            HttpClientResponse response = await request.close();

                            StringBuffer _buffer = new StringBuffer();

                            await for (String a in await response.transform(utf8.decoder)) {
                              _buffer.write(a);
                            }

                            bool error = _buffer.toString().contains('Error');
                            print("_buffer.toString: ${_buffer.toString()}");


                            if (error == false) {
                              var responseJson = xml.parse(_buffer.toString());
                              var DayOfWeek = responseJson
                                  .findAllElements('DayOfWeek')
                                  .single
                                  .text;
                              var pickdate = responseJson
                                  .findAllElements('Date')
                                  .single
                                  .text;
                              var map = {

                                "day_week": DayOfWeek,
                                "label": "",
                                "pickup_date": pickdate,
                                "seller_id": sellerid,
                                "status": "0"
                              };

                              var db = Firestore.instance;
                              db.collection("item_order").add({

                                "date": DateTime.now(),
                                "item_id": productid,
                                "order_date": DateTime.now(),
                                "order_status": "0",
                                "payment_method": "CREDIT CARD",
                                'pickup_order': map,
                                'promo_code': "",
                                "purchase_price": productPrice,
                                "shipping_address": shippingAdd.toList(),
                                "shipping_charge": "",
                                "shipping_date": DateTime.now(),
                                "shipping_status": "0",
                                'user_id': user_id,
                                "seller_id": sellerid,

                              }).then((val) {
                                String id = val.documentID;

                                var order_id = {
                                  'order_id': id,
                                };
                                db.collection("item_order")
                                    .document(id)
                                    .updateData(order_id)
                                    .then((val) {
                                  print("sucess");

                                  order_id_1 = id;


                                  db3.updateProduct(Shell_Product_Model(
                                      doc1['Any_sign_wear'],
                                      doc1['category'],
                                      doc1['category_id'],
                                      doc1['country'],
                                      doc1['date'],
                                      doc1['favourite_count'],
                                      doc1['is_cart'],
                                      doc1['is_favorite_count'],
                                      doc1['item_Ounces'],
                                      doc1['item_brand'],
                                      doc1['item_color'],
                                      doc1['item_description'],
                                      doc1['item_measurements'],
                                      doc1['item_picture'],
                                      doc1['item_pound'],
                                      doc1['item_price'],
                                      doc1['item_sale_price'],
                                      doc1['item_size'],
                                      doc1['item_sold'],
                                      doc1['item_sub_title'],
                                      doc1['item_title'],
                                      doc1['item_type'],
                                      doc1['packing_type'],
                                      doc1['picture'],
                                      doc1['product_id'],
                                      doc1['retail_tag'],
                                      doc1['shipping_charge'],
                                      doc1['shipping_id'],
                                      "2",
                                      doc1['sub_category'],
                                      doc1['sub_category_id'],
                                      doc1['user_id']))
                                      .then((_) {



                                    makeCall(token_id);


                                    db3.deleteCart(cartid).then((cart) {
                                    //  prf.setInt('payment', 0);
                                     // OrderPlaceByCreditCard(pay_id, refund_id, state,curancy_code);
                                    });
                                  });

                                }).catchError((err) {
                                  print(err);
                                  _onAlertWithStyleError(context);
                                  _isInAsyncCall = false;
                                });



                                print("sucess");
                              }).catchError((err) {
                                _isInAsyncCall = false;
                                _onAlertWithStyleError(context);
                                print(err);
                                // _isInAsyncCall = false;
                              });
                            }
                            else if(error){
                              _isInAsyncCall = false;
                              _onAlertWithStyleError(context);
                            }




                            print("sucess");
                          }).catchError((err) {
                            print(err);
                            _isInAsyncCall = false;
                          });
                        });



                      }



                    });
                  }



                });
              }



            });
          }
        });
      }*/
  }

  OrderPlaceByCreditCard(
    String pay_id,
    String refund_id,
    String state,
    String curancy_code,
  ) {
    var payout = {
      "batch_status": "",
      "payout_batch_id": "",
      "sender_batch_id": "",
      "user_id": "",
      "withdraw_amount": "",
      "payout_email_id": "",
      "date": ""
    };

    var db = Firestore.instance;
    db.collection("payment_history").add({
      "amount": "",
      "currency_code": "USD",
      "date": DateTime.now(),
      "intent": "sale",
      'short_description': ttl_item,
      'state': "approved",
      'user_id': user_id,
      'order_id': order_id_1
    }).then((val) {
      String id = val.documentID;

      var updateid = {'id': id};

      db
          .collection("payment_history")
          .document(id)
          .updateData(updateid)
          .then((val) {
        print("sucess");

        db.collection("payment_transaction").add({
          "amount": "",
          "currency_code": curancy_code,
          "refund_id": refund_id,
          "state": state,
          "date": DateTime.now(),
          "payment_status": "0",
          'status': "0",
          'user_id': user_id,
          'payout_details': payout,
          'order_id': order_id_1
        }).then((val) async {
          var docId = val.documentID;
          var updateId = {"pay_id": pay_id};

          db
              .collection("payment_transaction")
              .document(docId)
              .updateData(updateId)
              .then((val) async {
            CollectionReference ref = Firestore.instance.collection('wallet');
            QuerySnapshot eventsQuery =
                await ref.where("user_id", isEqualTo: user_id).getDocuments();

            if (eventsQuery.documents.isEmpty) {
            } else {
              eventsQuery.documents.forEach((doc) async {
                String docId = doc['wallet_id'];
                String available_amount = doc['available_amount'];
                String lifetime_earning = doc['site_credit'];

                /*  var payamount = int.parse(Sub_totalamount);

            var value_available = int.tryParse(available_amount);
            value_available = value_available +payamount;
            var total_available_amount =  value_available.toString();

            var value_lifetime = int.tryParse(lifetime_earning);
            value_lifetime = value_lifetime + payamount;
            var total_lifetime_amount =  value_lifetime.toString();*/

                var up1 = {
                  'available_amount': available_amount,
                  'site_credit': lifetime_earning
                };

                db
                    .collection("wallet")
                    .document(docId)
                    .updateData(up1)
                    .then((val) async {
                  print("sucess");

                  var body = {"order_id": order_id_1};
                  http.Response response = await http.post(
                      "https://threadon-86254.firebaseapp.com/order-email-notification-to-seller",
                      body: body);

                  if (response.statusCode == 200) {
                    print('Order Email Success send');
                    var res1 = json.decode(response.body);
                    var stcode = res1['status'];

                    if (stcode == 200) {
                      String msg = res1['message'];
                      // _showDialog('Password Reset',msg,0);

                      http.Response response1 = await http.post(
                          "https://threadon-86254.firebaseapp.com/order-email-notification-to-buyer",
                          body: body);

                      if (response1.statusCode == 200) {
                        print('Order Email Success send');
                        var res1 = json.decode(response1.body);
                        var stcode = res1['status'];

                        if (stcode == 200) {
                          String msg = res1['message'];
                          // _showDialog('Password Reset',msg,0);
                        } else {
                          String msg = res1['message'];
                          //     _showDialog('Error',msg,1);
                        }
                      } else {
                        //    showTost('Error');
                        print('Error');
                        //        _showDialog('Error','Order Email not send',1);
                        setState(() {
                          _isInAsyncCall = false;
                        });
                      }
                    } else {
                      String msg = res1['message'];
                      //      _showDialog('Error',msg,1);
                    }
                  } else {
                    //    showTost('Error');
                    print('Error');
                    // _showDialog();
                    setState(() {
                      _isInAsyncCall = false;
                    });
                  }

                  setState(() {
                    _isInAsyncCall = false;
                  });

                  if (PopupFlag == 0) {
                    PopupFlag = 1;
                    _onAlertWithStylePressed(context);
                  }
                }).catchError((err) {
                  print(err);

                  Navigator.of(context).push(PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) =>
                          ErrorRedeemConfirmationScreen()));
                  _isInAsyncCall = false;
                });
              });
            }

            print("sucess");
          }).catchError((err) {
            _isInAsyncCall = false;

            Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) =>
                    ErrorRedeemConfirmationScreen()));
            print(err);
            // _isInAsyncCall = false;
          });

          print("sucess");
        }).catchError((err) {
          print(err);

          Navigator.of(context).push(PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) =>
                  ErrorRedeemConfirmationScreen()));
          _isInAsyncCall = false;
        });
      }).catchError((err) {
        _isInAsyncCall = false;

        Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) =>
                ErrorRedeemConfirmationScreen()));
        print(err);
        // _isInAsyncCall = false;
      });

      print("sucess");
    }).catchError((err) {
      Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) =>
              ErrorRedeemConfirmationScreen()));
      _isInAsyncCall = false;
      print(err);
    });
  }
}

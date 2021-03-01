import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:threadon/model/Item_Order.dart';
import 'package:threadon/pages/ErrorRedeemConfirmationScreen.dart';
import 'package:threadon/pages/RedeemConfirmationScreen.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Cart.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/model/shipping_address.dart';
import 'package:threadon/pages/Add_Address_screen.dart';
import 'package:threadon/pages/PaymentMethods_screen.dart';
import 'package:threadon/pages/Shipping_Address_List_Screen.dart';
import 'package:threadon/pages/main_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/services.dart';

class Secure_Checkout_Screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => secure_checkout_screen();
}

class secure_checkout_screen extends State<Secure_Checkout_Screen> {
  String user_id, address, ttl_item = '', ttl_price = '', Sub_totalamount = '';
  List<Shipping_address> addressList;
  List<Shipping_address> addressList1 = new List<Shipping_address>();
  FirebaseFirestoreService db3 = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final postUrl = 'https://fcm.googleapis.com/fcm/send';
  final salesTextUrl = 'https://api.taxjar.com/v2/taxes';
  List<Pickup_order> p_order;

  int StatusCode;
  String address_line_1 = '',
      address_line_2 = '',
      city = '',
      name = '',
      state = '',
      zip_code = '';
  bool _isInAsyncCall = true;
  List<String> ShippingA;
  String site_credit = '0';
  var site_amout;
  bool flagWarranty = false;
  bool payAmount;
  bool PayUse = false;
  var Totle_Amount, Site_Amount, site, av;

  double AddAmount = 0;
  double update_siteCreditAmount = 0.0, update_aviAmount = 0.0;
  SharedPreferences sharedPreferences;

  List<Cart> cartList1 = new List<Cart>();
  List<Shell_Product_Model> productList1 = new List<Shell_Product_Model>();
  List<String> sellerAddress = new List();

  // List<String> selseTextAddress = new List();
  String user_zipcode = "";
  var shipping_charge = "";
  int PopupFlag = 0;
  String user_email;
  String order_id_1;
  String productPrice;
  var availblaAmountD;
  double trxtAMount = 0.0;
  var ss;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  getData() async {
    _isInAsyncCall = true;

    CollectionReference ref = Firestore.instance.collection('shipping_address');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
          //  MyNavigator.gotoAddAddress(context, 'Shipping Address', 1,1);
        });
      }
    } else {
      eventsQuery.documents.forEach((doc) async {
        if (doc['id_default'] == '1') {
          ShippingA = new List();

          ShippingA.add(doc['name']);
          ShippingA.add(doc['address_line_1']);
          ShippingA.add(doc['address_line_2']);
          ShippingA.add(doc['city']);
          ShippingA.add(doc['state']);
          ShippingA.add(doc['zipcode']);
          ShippingA.add(doc['phone']);
          user_zipcode = doc['zipcode'];

          addressList1.add(Shipping_address(
              doc['shipping_add_id'],
              doc['user_id'],
              doc['name'],
              doc['address_line_1'],
              doc['address_line_2'],
              doc['city'],
              doc['zipcode'],
              doc['state'],
              doc['date'].toDate(),
              doc['id_default'],
              doc['status']));
          address = doc['name'] +
              " \n" +
              doc['address_line_1'] +
              "\n" +
              doc['address_line_2'] +
              " " +
              doc['city'] +
              "\n" +
              doc['state'] +
              " - " +
              doc['zipcode'];
        }
      });

      setState(() {});
    }

    getReatCal();
  }

  getReatCal() async {
    productList1 = new List();
    CollectionReference ref = Firestore.instance.collection('cart');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      cartList1 = new List();

      eventsQuery.documents.forEach((doc1) async {
        cartList1.add(Cart(doc1['cart_id'], doc1['product_id'], doc1['status'],
            doc1['user_id'], doc1['date'].toDate()));

        String productid = doc1['product_id'];

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
            this.productList1 = productList1;
            String sellerAddress = doc['user_id'];
            String productAmount = doc['item_sale_price'];
            var db = Firestore.instance;

            String shippAmount = doc['shipping_charge'];

            var tt = double.parse(ttl_price);

            var value = double.tryParse(shipping_charge);

            if (doc['shipping_charge'] == '') {
              ss = 0;
              value = 0;
            } else {
              if (value == null) {
                value = 0;
              }
              ss = double.parse(doc['shipping_charge']);
              value = value + ss;
            }

            shipping_charge = value.toString();

            var t = tt + ss;
            ttl_price = t.toString();
            if (doc['shipping_charge'] == "0") {
              setState(() {
                _isInAsyncCall = true;
              });

              String size = "REGULAR";
              String Width = "0.0";
              String Length = "0.0";
              String Height = "0.0";
              String Girth = "0.0";

              List paking_type = new List<String>.from(doc['packing_type']);

              if (paking_type.length != 0 && paking_type.length != null) {
                // List paking_type =  new List<String>.from(doc['packing_type']);

                if (paking_type[0].toString() == "Polybag") {
                  var inchValue = double.parse(paking_type[1]);
                  var inchValue1 = double.parse(paking_type[2]);

                  double totalValue = inchValue * inchValue1;

                  if (totalValue > 12) {
                    Width = "0.1";
                    Length = "0.1";
                    Height = "0.1";
                    Girth = "0.1";
                    size = "LARGE";
                    Length = paking_type[1].toString();
                    Width = paking_type[2].toString();
                  }
                } else {
                  if (paking_type[0].toString() == "Premium_box") {
                    var inchValue = double.parse(paking_type[1]);
                    var inchValue1 = double.parse(paking_type[2]);
                    var inchValue2 = double.parse(paking_type[3]);

                    double totalValue = inchValue * inchValue1 * inchValue2;

                    if (totalValue > 12) {
                      Width = "0.1";
                      Length = "0.1";
                      Height = "0.1";
                      Girth = "0.1";
                      size = "LARGE";
                      Length = paking_type[1].toString();
                      Width = paking_type[2].toString();
                      Height = paking_type[3].toString();
                    }
                  }
                }

                int pro_Pounds = doc['item_pound'];
                int pro_Ounces = doc['item_Ounces'];

                CollectionReference ref =
                    Firestore.instance.collection('shipping_address');
                QuerySnapshot eventsQuery = await ref
                    .where("user_id", isEqualTo: user_id)
                    .where("status", isEqualTo: "0")
                    .getDocuments();

                if (eventsQuery.documents.isEmpty) {
                  setState(() {
                    _isInAsyncCall = false;
                  });
                } else {
                  eventsQuery.documents.forEach((doc) async {
                    String prod_zipcode = doc['zipcode'];

                    var builder = new xml.XmlBuilder();
                    //builder.processing('xml', 'version="1.0" encoding="iso-8859-9"');
                    builder.element('RateV4Request', nest: () {
                      builder.attribute('USERID', '186LOFTY0774');
                      builder.element('Revision', nest: 2);
                      builder.element('Package', nest: () {
                        builder.attribute('ID', '0');
                        builder.element('Service', nest: 'PRIORITY');
                        builder.element('ZipOrigination', nest: user_zipcode);
                        builder.element('ZipDestination', nest: prod_zipcode);
                        builder.element('Pounds', nest: pro_Pounds.toString());
                        builder.element('Ounces', nest: pro_Ounces.toString());
                        builder.element('Container', nest: "");
                        builder.element('Size', nest: size);
                        builder.element('Width', nest: Width);
                        builder.element('Length', nest: Length);
                        builder.element('Height', nest: Height);
                        builder.element('Girth', nest: "0.1");
                      });
                    });

                    var bookshelfXml = builder.build();

                    String _uriMsj = bookshelfXml.toString();

                    print("_uriMsj: $_uriMsj");

                    String _uri =
                        "http://production.shippingapis.com/ShippingApi.dll?API=RateV4&xml=";

                    HttpClient client = new HttpClient();

                    HttpClientRequest request =
                        await client.postUrl(Uri.parse(_uri + _uriMsj));

                    // request.write(_message);
                    //request.writeln(_message);
                    //request.writeAll(_message);

                    HttpClientResponse response = await request.close();

                    StringBuffer _buffer = new StringBuffer();

                    // await for (String a
                    //     in await response.transform(utf8.decoder)) {
                    //   _buffer.write(a);
                    // }
                    await for (String a in await utf8.decoder.bind(response)) {
                      _buffer.write(a);
                    }
                    bool error = _buffer.toString().contains('Error');
                    print("_buffer.toString: ${_buffer.toString()}");

                    if (error == false) {
                      var responseJson = xml.parse(_buffer.toString());
                      var valid =
                          responseJson.findAllElements('Rate').single.text;

                      var valuerate = double.tryParse(valid);

                      value = value + valuerate;

                      /* double onerate = double.parse(shipping_charge);


                      var total =  valuerate+ onerate;*/

                      db
                          .collection("shipping_address")
                          .where("user_id", isEqualTo: sellerAddress)
                          .where("status", isEqualTo: "0")
                          .getDocuments()
                          .then((val4) {
                        if (val4.documents.isEmpty) {
                        } else {
                          val4.documents.forEach((doc4) async {
                            // String cartid = doc['cart_id'];
                            //  String productid = doc['product_id'];

                            /*  selseTextAddress = new List();

                            selseTextAddress.add(doc4['address_line_1']);
                            selseTextAddress.add(doc4['address_line_2']);
                            selseTextAddress.add(doc4['city']);
                            selseTextAddress.add(doc4['state']);
                            selseTextAddress.add(doc4['zipcode']);*/

                            Map taxes = {
                              'from_country': "US",
                              'from_zip': ShippingA[5].toString(),
                              'from_state':
                                  ShippingA[4].toString().toUpperCase(),
                              'from_city': ShippingA[3].toString(),
                              'from_street': ShippingA[1].toString(),
                              'to_country': 'US',
                              'to_zip': ShippingA[5].toString(),
                              'to_state': ShippingA[4].toString().toUpperCase(),
                              'to_city': ShippingA[3].toString(),
                              'to_street': ShippingA[1].toString(),
                              'amount': productAmount,
                              'shipping': valid,
                              'nexus_addresses': [
                                {
                                  'id': ShippingA[1].toString(),
                                  'country': 'US',
                                  'zip': ShippingA[5].toString(),
                                  'state':
                                      ShippingA[4].toString().toUpperCase(),
                                  'city': ShippingA[3].toString(),
                                  'street': ShippingA[1].toString()
                                },
                              ],
                              'line_items': [
                                {
                                  'id': "1",
                                  'quantity': "1",
                                  'product_tax_code': productid,
                                  'unit_price': productAmount,
                                  'discount': "0",
                                }
                              ]
                            };

                            String datas = json.encode(taxes);

                            HttpClient httpClient = new HttpClient();
                            HttpClientRequest request = await httpClient
                                .postUrl(Uri.parse(salesTextUrl));
                            request.headers.set('Authorization',
                                'Bearer f5108d11ac7cfb62d9ac72607407e3a3');
                            request.headers.set(
                              'Content-Type',
                              'application/json',
                            );

                            request.add(utf8.encode(json.encode(taxes)));
                            HttpClientResponse response = await request.close();
                            // todo - you should check the response.statusCode

                            final int statusCode = response.statusCode;
                            // var Responce =
                            //     await response.transform(utf8.decoder).join();
                            var Responce =
                                await utf8.decoder.bind(response).join();
                            if (statusCode <= 200 || statusCode >= 299) {
                              Map valueMap = json.decode(Responce);
                              var amount_to_collect =
                                  valueMap['tax']['amount_to_collect'];
                              trxtAMount = trxtAMount + amount_to_collect;
                              //   shipping_charge = total.toString();

                              var tt = double.parse(ttl_price);

                              tt = tt + amount_to_collect + valuerate;

                              /* var tt1= double.parse(shipping_charge);
                                var ttfin= tt + tt1 + trxtAMount;*/
                              setState(() {
                                trxtAMount = trxtAMount;
                                shipping_charge = value.toString();
                                ttl_price = tt.toStringAsFixed(2);
                              });

                              httpClient.close();
                            } else {
                              throw new Exception("Error while fetching data");
                            }
                          });
                        }
                      });
                    } else {
                      var responseJson = xml.parse(_buffer.toString());
                      var valid = responseJson
                          .findAllElements('Description')
                          .single
                          .text;

                      // _showDialog(valid);
                    }
                  });
                }
              }
            } else {
              if (this.mounted) {
                setState(() {
                  _isInAsyncCall = true;
                });
              }
              db
                  .collection("shipping_address")
                  .where("user_id", isEqualTo: sellerAddress)
                  .where("status", isEqualTo: "0")
                  .getDocuments()
                  .then((val3) {
                if (val3.documents.isEmpty) {
                } else {
                  val3.documents.forEach((doc3) async {
                    // String cartid = doc['cart_id'];
                    //  String productid = doc['product_id'];

                    /*  selseTextAddress = new List();

                    selseTextAddress.add(doc3['address_line_1']);
                    selseTextAddress.add(doc3['address_line_2']);
                    selseTextAddress.add(doc3['city']);
                    selseTextAddress.add(doc3['state']);
                    selseTextAddress.add(doc3['zipcode']);*/

                    Map taxes = {
                      'from_country': "US",
                      'from_zip': ShippingA[5].toString(),
                      'from_state': ShippingA[4].toString().toUpperCase(),
                      'from_city': ShippingA[3].toString(),
                      'from_street': ShippingA[1].toString(),
                      'to_country': 'US',
                      'to_zip': ShippingA[5].toString(),
                      'to_state': ShippingA[4].toString().toUpperCase(),
                      'to_city': ShippingA[3].toString(),
                      'to_street': ShippingA[1].toString(),
                      'amount': productAmount,
                      'shipping': ss,
                      'nexus_addresses': [
                        {
                          'id': ShippingA[1].toString(),
                          'country': 'US',
                          'zip': ShippingA[5].toString(),
                          'state': ShippingA[4].toString().toUpperCase(),
                          'city': ShippingA[3].toString(),
                          'street': ShippingA[1].toString()
                        },
                      ],
                      'line_items': [
                        {
                          'id': "1",
                          'quantity': "1",
                          'product_tax_code': productid,
                          'unit_price': productAmount,
                          'discount': "0",
                        }
                      ]
                    };

                    String datas = json.encode(taxes);

                    HttpClient httpClient = new HttpClient();
                    HttpClientRequest request =
                        await httpClient.postUrl(Uri.parse(salesTextUrl));
                    request.headers.set('Authorization',
                        'Bearer f5108d11ac7cfb62d9ac72607407e3a3');
                    request.headers.set(
                      'Content-Type',
                      'application/json',
                    );

                    request.add(utf8.encode(json.encode(taxes)));
                    HttpClientResponse response = await request.close();
                    // todo - you should check the response.statusCode
                    print(response.statusCode);
                    final int statusCode = response.statusCode;
                    var Responce = await utf8.decoder.bind(response).join();
                    // var Responce =
                    //     await response.transform(utf8.decoder).join();
                    if (statusCode >= 200 && statusCode <= 299) {
                      Map valueMap = json.decode(Responce);
                      print(Responce);
                      var amount_to_collect =
                          valueMap['tax']['amount_to_collect'];
                      httpClient.close();

                      trxtAMount = trxtAMount + amount_to_collect;

                      double one = double.parse(ttl_price);

                      one = one + amount_to_collect;
                      var ttfin = one;
                      /* value = value + one;
                      shipping_charge = value.toString();
                      var ttfin= tt + value + trxtAMount;
*/
                      ttl_price = ttfin.toStringAsFixed(2);

                      setState(() {
                        _isInAsyncCall = false;
                      });
                    } else {
                      if (this.mounted) {
                        setState(() {
                          _isInAsyncCall = false;
                        });
                      }
                    }
                  });
                }
              });
            }

            /*  var value = double.tryParse(shipping_charge);
            var ss = doc['shipping_charge'];
            double one = double.parse(ss);
            value = value + one;
            shipping_charge = value.toString();

            setState(() {
              var tt = double.parse(ttl_price);
              var tt1 = double.parse(shipping_charge);
              var ttfin = tt + tt1;
              ttl_price = ttfin.toStringAsFixed(2);
            //  _isInAsyncCall = false;
            });*/
          });

          if (this.mounted) {
            setState(() {
              /* var tt = double.parse(ttl_price);
            var tt1 = double.parse(shipping_charge);
            var ttfin = tt + tt1;
            ttl_price = ttfin.toStringAsFixed(2);*/
              //  _isInAsyncCall = false;
            });
          }
        }
      });
    }
  }

  int _selectedIndex;

  @override
  void initState() {
    super.initState();

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getCredential();

    addressList = new List();
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

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = sharedPreferences.getString("user_id");
      ttl_item = sharedPreferences.getString("total_item");
      ttl_price = sharedPreferences.getString("total_price");
      Sub_totalamount = sharedPreferences.getString("total_price");
      user_email = sharedPreferences.getString('user_email');
    });

    Firestore.instance
        .collection('wallet')
        .where("user_id", isEqualTo: user_id)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) async {
        if (doc.exists) {
          setState(() {
            site_credit = doc['site_credit'];
            String avil = doc['available_amount'];

            site = double.parse(site_credit);
            av = double.parse(avil);
            var total = site + av;
            site_credit = total.toString();
          });
        } else {
          // showInSnackBar('No payoutd data found!');

        }
      });
    });

    getData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      primary: true,
      appBar: new AppBar(
        title: new Text('Secure Checkout'),
        backgroundColor: Colors.white70,
      ),
      bottomNavigationBar: GestureDetector(
          child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 15.0,
              ),
              height: 70.0,
              color: Colors.black,
              child: Center(
                  child: Text(
                'Payment',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
                textAlign: TextAlign.center,
              ))),
          onTap: () {
            var totalAmount = double.parse(ttl_price);

            if (addressList1.length > 0) {
              if (totalAmount > 0) {
                AddAmount;

                sharedPreferences.setString('total_price', ttl_price);

                if (flagWarranty) {
                  var TotalAmount_User = double.parse(Sub_totalamount);
                  var Total_Site_amount = double.parse(site_credit);

                  if (TotalAmount_User >= Total_Site_amount) {
                    /* if (Total_Site_amount >= site) {

                    update_siteCreditAmount = site - site;

                    update_aviAmount = TotalAmount_User - site;

                    update_aviAmount = av - update_aviAmount;
                    sharedPreferences.setString(
                        'site_c', update_siteCreditAmount.toString());
                    sharedPreferences.setString(
                        'av_c', update_aviAmount.toString());
                  }
                  else {
                    update_siteCreditAmount = Total_Site_amount - site;

                    update_aviAmount = TotalAmount_User - site;

                    update_aviAmount = av - update_aviAmount;

                    sharedPreferences.setString(
                        'site_c', update_siteCreditAmount.toString());
                    sharedPreferences.setString(
                        'av_c', update_aviAmount.toString());


                    // update_siteCreditAmount = Total_Site_amount - TotalAmount_User;
                  }*/
                  } else {
                    update_siteCreditAmount = 0;
                  }
                  sharedPreferences.setString('site_c', "0");
                  sharedPreferences.setString('av_c', "0");
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Payments_Methods(
                            tool_name: 'Payments Methods',
                            shippingAdd: ShippingA)));
              } else {
                if (flagWarranty) {
                  var TotalAmount_User = double.parse(Sub_totalamount);

                  var Total_Site_amount = double.parse(site_credit);

                  if (Total_Site_amount >= TotalAmount_User) {
                    if (Total_Site_amount >= site) {
                      update_siteCreditAmount = site - site;

                      update_aviAmount = TotalAmount_User - site;

                      update_aviAmount = av - update_aviAmount;
                    } else {
                      update_siteCreditAmount = Total_Site_amount - site;

                      update_aviAmount = TotalAmount_User - site;

                      update_aviAmount = av - update_aviAmount;
                    }
                  } else {
                    update_siteCreditAmount = 0;
                  }
                }
                setState(() {
                  _isInAsyncCall = true;
                });

                getProduct();

                //
              }
            } else {
              showInSnackBar('Please add shipping address.');
            }
          }),
      body:
          //  ModalProgressHUD(
          //   child:
          ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                      left: 10.0, top: 10.0, right: 0.0, bottom: 10.0),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: new Text(
                          "Address",
                          textAlign: TextAlign.start,
                          style: new TextStyle(
                            color: Colors.grey,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 0.0, top: 10.0, right: 0.0, bottom: 0.0),
                        child: address == null
                            ? GestureDetector(
                                child: new Container(
                                    child: Text(
                                  "Add address",
                                  textAlign: TextAlign.start,
                                  style: new TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                )),
                                onTap: () async {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Add_Address_Screen(
                                                appbar_name: 'Shipping Address',
                                                Flag: 0,
                                                exit_Flag: 1,
                                              )));
                                })
                            : new Text(
                                address,
                                textAlign: TextAlign.start,
                                style: new TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: 0.0, top: 10.0, right: 0.0, bottom: 0.0),
                  child: address == null
                      ? new Container(
                          child: Text(
                          "",
                          textAlign: TextAlign.start,
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ))
                      : GestureDetector(
                          child: new Container(
                            margin: const EdgeInsets.only(
                                left: 10.0,
                                top: 0.0,
                                right: 10.0,
                                bottom: 10.0),
                            child: new Column(
                              children: <Widget>[
                                Text(
                                  'Change',
                                  textAlign: TextAlign.end,
                                  style: new TextStyle(
                                    color: Colors.red,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () async {
//                            MyNavigator.gotoAddAddress(
//                                context, 'Shipping Address', 1);

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Shipping_Address_List()));

                            /*  MyNavigator.gotoShipping_Add_List(
                                    context, 'Shipping Address', 1);*/
                          }),
                ),
                Container(
                  height: 0.5,
                  color: Colors.grey,
                  margin: const EdgeInsets.only(
                      left: 00.0, right: 00.0, bottom: 10.0),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 0.0, right: 0.0),
                  child: Card(
                    elevation: 2.0,
                    color: Colors.white,
                    child: new Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(
                              top: 20, left: 20, right: 20, bottom: 10),
                          child: new Center(
                            child: new Text(
                              'ORDER SUMMARY',
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                        new Divider(),
                        Container(
                            margin: const EdgeInsets.only(
                                top: 10, left: 10.0, right: 20.0),
                            child: new Row(children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: new Container(
                                  padding: EdgeInsets.only(left: 5.0),
                                  child: new Text(
                                    'Price (' + ttl_item + ' item)',
                                    //"Subtotal",
                                    textAlign: TextAlign.start,
                                    style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 17.0,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: new Container(
                                  alignment: Alignment.centerRight,
                                  child: new Text(
                                    '\$' + Sub_totalamount,
                                    textAlign: TextAlign.left,
                                    style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              )
                            ])),
                        Container(
                            margin: const EdgeInsets.only(
                                top: 10.0,
                                left: 10.0,
                                right: 20.0,
                                bottom: 10.0),
                            child: new Row(children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: new Container(
                                  padding: EdgeInsets.only(left: 5.0),
                                  child: new Text(
                                    'Tax',
                                    textAlign: TextAlign.start,
                                    style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 17.0,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: new Container(
                                  alignment: Alignment.centerRight,
                                  child: new Text(
                                    "\$" + trxtAMount.toString(),
                                    textAlign: TextAlign.left,
                                    style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              )
                            ])),
                        Container(
                            margin: const EdgeInsets.only(
                                top: 10.0,
                                left: 10.0,
                                right: 20.0,
                                bottom: 10.0),
                            child: new Row(children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: new Container(
                                  padding: EdgeInsets.only(left: 5.0),
                                  child: new Text(
                                    'Delivery Charges',
                                    textAlign: TextAlign.start,
                                    style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 17.0,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: new Container(
                                  alignment: Alignment.centerRight,
                                  child: new Text(
                                    "\$" + shipping_charge.toString(),
                                    textAlign: TextAlign.left,
                                    style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              )
                            ])),
                        Container(
                            margin: const EdgeInsets.only(
                                left: 10.0,
                                top: 5.0,
                                right: 20.0,
                                bottom: 20.0),
                            child: flagWarranty == true
                                ? new Row(children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: new Container(
                                          alignment: Alignment.centerLeft,
                                          child: Checkbox(
                                            onChanged: (bool value) {
                                              setState(() {
                                                if (value) {
                                                  flagWarranty = true;
                                                } else {
                                                  flagWarranty = false;

                                                  //  var totalAmount = int.parse(AddAmount);
                                                  site_amout =
                                                      double.parse(site_credit);

                                                  var totalAmount1 =
                                                      AddAmount + site_amout;
                                                  PayUse = false;
                                                  payAmount = false;

                                                  if (totalAmount1 > 0) {
                                                    ttl_price = totalAmount1
                                                        .toStringAsFixed(2);
                                                  } else {
                                                    ttl_price = '0';
                                                  }
                                                }
                                              });
                                            },
                                            value: flagWarranty,
                                            // title: new Text('Wallet Amount'),
                                          )),
                                    ),
                                    Expanded(
                                        flex: 4,
                                        child: Column(
                                          children: <Widget>[
                                            new Container(
                                              child: new Text(
                                                'Wallet Amount',
                                                textAlign: TextAlign.left,
                                                style: new TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ),
                                            new Container(
                                              padding:
                                                  EdgeInsets.only(left: 5.0),
                                              alignment: Alignment.centerLeft,
                                              child: availblaAmountD == null
                                                  ? new Text(
                                                      'Available Amount  ' +
                                                          '\$' +
                                                          '0',
                                                      textAlign: TextAlign.left,
                                                      style: new TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13.0,
                                                        letterSpacing: 0.3,
                                                      ),
                                                    )
                                                  : new Text(
                                                      'Available Amount  ' +
                                                          '\$' +
                                                          availblaAmountD
                                                              .toString(),
                                                      textAlign: TextAlign.left,
                                                      style: new TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13.0,
                                                        letterSpacing: 0.3,
                                                      ),
                                                    ),
                                            ),
                                          ],
                                        )),
                                    Expanded(
                                      flex: 5,
                                      child: new Container(
                                        alignment: Alignment.centerRight,
                                        child: new Text(
                                          '\$' + site_credit,
                                          textAlign: TextAlign.left,
                                          style: new TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    )
                                  ])
                                : new Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: new Container(
                                              child: Checkbox(
                                            onChanged: (bool value) {
                                              setState(() {
                                                if (value) {
                                                  //   selectedList.add(cmap[course_id]);
                                                  flagWarranty = true;
                                                  var totalAmount =
                                                      double.parse(ttl_price);
                                                  site_amout =
                                                      double.parse(site_credit);

                                                  var totalAmount1;
                                                  if (totalAmount >
                                                      site_amout) {
                                                    totalAmount1 = totalAmount -
                                                        site_amout;
                                                    if (totalAmount1 > 0) {
                                                      ttl_price = totalAmount1
                                                          .toString();
                                                      AddAmount = double.parse(
                                                          totalAmount1
                                                              .toStringAsFixed(
                                                                  2));
                                                    } else {
                                                      AddAmount = double.parse(
                                                          totalAmount1
                                                              .toStringAsFixed(
                                                                  2));
                                                      ttl_price = '0';
                                                    }
                                                  } else {
                                                    totalAmount1 = totalAmount -
                                                        site_amout;
                                                    if (totalAmount1 > 0) {
                                                      ttl_price = totalAmount1
                                                          .toString();
                                                      AddAmount = double.parse(
                                                          totalAmount1
                                                              .toStringAsFixed(
                                                                  2));
                                                    } else {
                                                      AddAmount = double.parse(
                                                          totalAmount1
                                                              .toStringAsFixed(
                                                                  2));
                                                      availblaAmountD =
                                                          AddAmount * -1;
                                                      ttl_price = '0';
                                                    }
                                                  }
                                                  PayUse = true;
                                                  payAmount = true;
                                                } else {
                                                  flagWarranty = false;
                                                  //   site_amout = 0;

                                                  //    selectedList.remove(cmap[course_id]);

                                                }
                                              });
                                            },
                                            value: flagWarranty,
                                            // title: new Text('Wallet Amount'),
                                          )),
                                        ),
                                        Expanded(
                                            flex: 7,
                                            child: Column(
                                              children: <Widget>[
                                                new Container(
                                                  padding: EdgeInsets.only(
                                                      left: 5.0),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: new Text(
                                                    'Wallet Amount',
                                                    textAlign: TextAlign.left,
                                                    style: new TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16.0,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                ),
                                                new Container(
                                                  padding: EdgeInsets.only(
                                                      left: 5.0),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: new Text(
                                                    'Available Amount  ' +
                                                        '\$' +
                                                        site_credit,
                                                    textAlign: TextAlign.left,
                                                    style: new TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13.0,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ])),
                        /* Container(
                              padding: const EdgeInsets.all(20.0),
                              child: new Center(
                                child: new Text(
                                  'ORDER TOTAL',
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),*/

                        new Divider(),
                        Container(
                            margin: const EdgeInsets.only(
                                left: 10.0,
                                right: 20.0,
                                top: 20.0,
                                bottom: 30.0),
                            child: new Row(children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: new Container(
                                  padding: EdgeInsets.only(left: 5.0),
                                  child: new Text(
                                    //'Total(' + ttl_item + ' Item)',
                                    'Amount Payable',
                                    textAlign: TextAlign.start,
                                    style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: new Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '\$' + ttl_price,
                                    textAlign: TextAlign.left,
                                    style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 22.0,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              )
                            ])),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 0.0, right: 0.0),
                  child: Card(
                    elevation: 2.0,
                    color: Colors.white,
                    child: new Column(
                      children: <Widget>[],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // inAsyncCall: _isInAsyncCall,
      // opacity: 1,
      // color: Colors.white,
      // progressIndicator: CircularProgressIndicator(),)
    );
  }

  void _showDialog(String title, String msg, int code) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                if (code == 1) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future getProduct() async {
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
                String shipping_Amount = doc1['shipping_charge'];
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

                            var builder = new xml.XmlBuilder();
                            //builder.processing('xml', 'version="1.0" encoding="iso-8859-9"');
                            builder.element('CarrierPickupScheduleRequest',
                                nest: () {
                              builder.attribute('USERID', '186LOFTY0774');
                              builder.element('FirstName',
                                  nest: sellerAddress[0].toString());
                              builder.element('LastName',
                                  nest: sellerAddress[0].toString());
                              builder.element('FirmName', nest: "");
                              builder.element('SuiteOrApt', nest: "");

                              builder.element('Address2',
                                  nest: sellerAddress[1].toString());
                              builder.element('Urbanization', nest: "");
                              builder.element('City',
                                  nest: sellerAddress[3].toString());
                              builder.element('State',
                                  nest: sellerAddress[4].toString());
                              builder.element('ZIP5',
                                  nest: sellerAddress[5].toString());
                              builder.element('ZIP4',
                                  nest: sellerAddress[6].toString());
                              builder.element('Phone',
                                  nest: sellerAddress[7].toString());

                              builder.element('Extension', nest: '');
                              builder.element('Package', nest: () {
                                builder.element('ServiceType',
                                    nest: "PriorityMailExpress");
                                builder.element('Count', nest: "1");
                              });

                              builder.element('EstimatedWeight', nest: t_wight);
                              builder.element('PackageLocation',
                                  nest: 'Knock on Door/Ring Bell');
                              builder.element('SpecialInstructions', nest: "");
                              //builder.element('EmailAddress', nest: sellerAddress[8].toString());
                              builder.element('EmailAddress',
                                  nest: "sani3854@gmail.com");
                            });

                            var bookshelfXml = builder.build();

                            String _uriMsj = bookshelfXml.toString();

                            print("_uriMsj: $_uriMsj");

                            String _uri =
                                "https://secure.shippingapis.com/ShippingAPI.dll?API=CarrierPickupSchedule&XML=";

                            HttpClient client = new HttpClient();

                            HttpClientRequest request =
                                await client.postUrl(Uri.parse(_uri + _uriMsj));

                            // request.write(_message);
                            //request.writeln(_message);
                            //request.writeAll(_message);

                            HttpClientResponse response = await request.close();

                            StringBuffer _buffer = new StringBuffer();

                            // await for (String a
                            //     in await response.transform(utf8.decoder)) {
                            //   _buffer.write(a);
                            // }

                            await for (String a
                                in await utf8.decoder.bind(response)) {
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
                                "payment_method": "WALLET",
                                'pickup_order': map,
                                'promo_code': "",
                                "purchase_price": productPrice,
                                "shipping_address": ShippingA.toList(),
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
                                      //prf.setInt('payment', 0);

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
                                                value_available + payamount;
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
                                                    "payment_status": "1",
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
                            }
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

  void showInSnackBar(String value) {
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
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
}

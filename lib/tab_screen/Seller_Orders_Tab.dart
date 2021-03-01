import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/model/Item_Order.dart';
import 'package:threadon/model/Open_Sale.dart';
// ignore: uri_does_not_exist
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:flutter/foundation.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/GridItemDetails.dart';
import 'package:threadon/pages/Traking_Screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/pages/Lable_Screen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:convert' show utf8;

class Seller_Orders_Tab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => seller_orders_tab();
}

class seller_orders_tab extends State<Seller_Orders_Tab> {
  String user_id = '';
  //
  ProgressDialog pr;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  String id;
  var Zip = "";
  List<Shell_Product_Model> productdata;
  List<Shell_Product_Model> productdata1 = new List();
  List<Item_OrderModel> orderList;
  List<String> buyerAddress;
  List<String> sellerAddress;
  bool _isInAsyncCall = false;

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    user_id = sharedPreferences.getString("user_id");
    setState(() {
      getData();
    });
  }

  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      _isInAsyncCall = true;
    });

    getCredential();
  }

  Future getData() async {
    orderList = new List();
    sellerAddress = new List();

    CollectionReference ref = Firestore.instance.collection('shipping_address');
    QuerySnapshot eventsQuery = await ref
        .where("user_id", isEqualTo: user_id)
        .where("status", isEqualTo: "1")
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      print("address is empty");
//      setState(() {
//        _isInAsyncCall = false;
//      });
      GetOrderData();
    } else {
      eventsQuery.documents.forEach((doc1) async {
        sellerAddress.add(doc1['name']);
        sellerAddress.add(doc1['address_line_1']);
        sellerAddress.add(doc1['address_line_2']);
        sellerAddress.add(doc1['city']);
        sellerAddress.add(doc1['state']);
        sellerAddress.add(doc1['zipcode']);
        sellerAddress.add(doc1['zip4']);
        sellerAddress.add(doc1['phone']);
      });
      GetOrderData();
    }
  }

// ----------------------- valid Tracking ID ----------------------

  Future validTrackingIDCheck(id, order_id) async {
    var encoded = utf8.encode('Lorem ipsum dolor sit amet, consetetur...');
    var decoded = utf8.decode(encoded);
    final FormState form = _formKey.currentState;

    if (form.validate()) {
      setState(() {
        _isInAsyncCall = true;
      });

      var builder = new xml.XmlBuilder();

      builder.element('TrackRequest', nest: () {
        builder.attribute('USERID', '186LOFTY0774');
        builder.element('TrackID', nest: () {
          builder.attribute('ID', id);
        });
      });

      var bookshelfXml = builder.build();

      String _uriMsj = bookshelfXml.toString();

      print("_uriMsj: $_uriMsj");

      String _uri =
          "http://production.shippingapis.com/ShippingAPI.dll?API=TrackV2&XML=";

      HttpClient client = new HttpClient();

      HttpClientRequest request =
          await client.postUrl(Uri.parse(_uri + _uriMsj));

      HttpClientResponse response = await request.close();

      StringBuffer _buffer = new StringBuffer();

      // await for (String a in await response.transform(utf8.decoder)) {
      //   _buffer.write(a);
      // }

      // await for (String a in await response.transform(utf8.decoder)) {
      //   _buffer.write(a);
      // }

      bool error = _buffer.toString().contains('Error');
      print("_buffer.toString: ${_buffer.toString()}");

      if (error == false) {
        var responseJson = xml.parse(_buffer.toString());

        var valid = responseJson.findAllElements('TrackSummary').single.text;

        if (valid != null &&
            valid !=
                "The Postal Service could not locate the tracking information for your request. Please verify your tracking number and try again later.") {
          // final FormState form = _formKey.currentState;

          if (form.validate()) {
            setState(() {
              _isInAsyncCall = true;
            });
            handleSubmit(id, order_id);
          } else {
            setState(() {
              _isInAsyncCall = false;
            });
            print('Please fix the errors in red before submitting.');
          }
        } else {
          setState(() {
            _isInAsyncCall = false;
          });
          //
          pr.show();
          Future.delayed(Duration(seconds: 2)).then((value) {
            pr.hide().whenComplete(() {
              _showDialog(valid);
            });
          });

          //
        }
      } else {
        var responseJson = xml.parse(_buffer.toString());

        var valid = responseJson.findAllElements('Description').single.text;

        setState(() {
          _isInAsyncCall = false;
        });

        _showDialog(valid);
      }
    } else {
      print('Please fix the errors in red before submitting.');
    }
  }
//--------------------------------

//-------------------------------
  Future handleSubmit(id, order_id) async {
    var db1 = Firestore.instance;
    var up1 = {
      'tracking_id': id,
    };

    db1.collection("item_order").document(order_id).updateData(up1).then((val) {
      print("sucess");
      Navigator.pop(context);
      getCredential();
      setState(() {
        _isInAsyncCall = false;
      });
    }).catchError((err) {
      print(err);
      _isInAsyncCall = false;
    });
  }

  void _showDialog(String msg) {
    // flutter defined function

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Something Went Wrong!"),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// ------------------------------------------------------------------------------

  GetOrderData() async {
    productdata = new List();

    CollectionReference ref = Firestore.instance.collection('item_order');
    QuerySnapshot eventsQuery = await ref
        .where("seller_id", isEqualTo: user_id)
        .where("order_status", isEqualTo: "0")
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      print("empty");
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
        });
      }
    } else {
      orderList = eventsQuery.documents
          .map((documentSnapshot) =>
              Item_OrderModel.fromMap(documentSnapshot.data))
          .toList();

      print(orderList);

      eventsQuery.documents.forEach((doc) async {
        if (doc['order_status'] == "0") {
          String productid = doc['item_id'];
          String order_id = doc['order_id'];
          String tracking_id = doc['tracking_id'];
          String like_new = doc['like_new'];

          CollectionReference ref = Firestore.instance.collection('product');
          QuerySnapshot eventsQuery = await ref
              .where("product_id", isEqualTo: productid)
              .getDocuments();

          if (eventsQuery.documents.isEmpty) {
            setState(() {
              _isInAsyncCall = false;
            });
          } else {
            eventsQuery.documents.forEach((doc) async {
              productdata.add(Shell_Product_Model(
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
                  tracking_id,
                  order_id,
                  like_new));
              if (this.mounted) {
                setState(() {
                  this.productdata1 = productdata;
                  _isInAsyncCall = false;
                });
              }
            });
          }
        } else {
          setState(() {
            _isInAsyncCall = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    pr = new ProgressDialog(context);
    pr.style(
        message: 'Please Wait...',
        borderRadius: 3.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 50.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w700),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    //
    return Scaffold(
        key: scaffoldKey,
        body: ModalProgressHUD(
          child: productdata1.length == 0
              ? Container(
                  child: Center(
                    child: Showmsg(),
                  ),
                )
              : Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                  child: ListData(),
                ),
          inAsyncCall: _isInAsyncCall,
          opacity: 1,
          color: Colors.white,
          progressIndicator: CircularProgressIndicator(),
        ));
  }

  Widget ListData() {
    setState(() {
      _isInAsyncCall = false;
    });
    return ListView.builder(
        itemCount: productdata1.length,
        itemBuilder: (context, position) {
          return GestureDetector(
            child: Card(
                elevation: 2.0,
                child: Container(
                    height: 280.0,
                    alignment: Alignment.topLeft,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text(
                            'Congrats!',
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.green,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.only(top: 5.0),
                          child: Text(
                            'This item has been sold',
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black87,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                        Divider(),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Row(children: <Widget>[
                            Expanded(
                                flex: 7,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.all(5.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              width: 200.0,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                productdata1[position]
                                                    .item_title,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5.0, 5.0, 10.0, 5.0),
                                              child: new RichText(
                                                text: new TextSpan(
                                                  text: '',
                                                  style: TextStyle(
                                                    fontSize: 15.0,
                                                    color: Colors.black,
                                                  ),
                                                  children: <TextSpan>[
                                                    new TextSpan(
                                                      text: '\$' +
                                                          productdata1[position]
                                                              .item_sale_price,
                                                      style: new TextStyle(
                                                        fontSize: 18.0,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

//                                            new Container(
//                                              height: 15.0,
//                                            ),
//                                            Container(
//                                              padding: EdgeInsets.only(left: 5.0),
//                                              child: Text('Pickup Date', style: TextStyle(
//                                                  fontSize: 15.0,
//
//                                                  color: Colors.black), maxLines: 1,),
//                                            ),
//
//                                            Container(
//                                              padding: EdgeInsets.only(left: 5.0,top: 3.0),
//                                              child: Text(orderList[position].pickup_order.pickup_date+ " " + " ("+ orderList[position].pickup_order.day_week +")" , style: TextStyle(
//                                                  fontSize: 15.0,
//                                                  fontWeight: FontWeight.w500,
//                                                  color: Colors.black), maxLines: 1,),
//                                            ),

                                            /*  Container(

                                              padding: const EdgeInsets
                                                  .fromLTRB(
                                                  5.0, 5.0, 10.0, 5.0),
                                              child: new Row(
                                                children: <Widget>[
                                                  Text(
                                                    "Brand : ",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13.0,
                                                    ),
                                                  ),
                                                  Text(
                                                    productdata1[position]
                                                        .item_brand,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13.0,
                                                      fontWeight: FontWeight
                                                          .bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),




                                            Container(
                                                padding: const EdgeInsets
                                                    .fromLTRB(
                                                    5.0, 5.0, 10.0, 5.0),
                                                child: productdata1[position]
                                                    .item_color == null &&
                                                    productdata1[position]
                                                        .item_color == ""
                                                    ? new Row(
                                                  children: <Widget>[
                                                    Text(
                                                      "Color : ",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      productdata1[position]
                                                          .item_color,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13.0,
                                                        fontWeight: FontWeight
                                                            .bold,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                                    : new Row(
                                                  children: <Widget>[
                                                    Text(
                                                      "Color : ",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      "----",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13.0,
                                                        fontWeight: FontWeight
                                                            .bold,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                            ),*/
                                          ],
                                        )),
                                  ],
                                )),
                            Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.all(5.0),
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'images/tonlogo.png',
                                    image: productdata1[position].picture,
                                    width: 80.0,
                                    height: 80.0,
                                    fit: BoxFit.scaleDown,
                                  ),
                                )),
                          ]),
                        ),
                        Divider(),
                        Expanded(
                          child: Container(
                              height: 50.0,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                      child:
                                          productdata1[position].tracking_id ==
                                                      null ||
                                                  productdata1[position]
                                                          .tracking_id ==
                                                      ""
                                              ? RaisedButton(
                                                  color: Colors.black87,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15.0,
                                                      vertical: 10.0),
                                                  child: Container(
                                                    child: Text(
                                                      'ADD TRACKING ID',
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return new AlertDialog(
                                                            content: Form(
                                                              key: _formKey,
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: <
                                                                    Widget>[
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        TextFormField(
                                                                      decoration:
                                                                          InputDecoration(
                                                                        border:
                                                                            UnderlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              color: Colors.black87,
                                                                              style: BorderStyle.solid),
                                                                        ),
                                                                        focusedBorder:
                                                                            UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87, style: BorderStyle.solid)),
                                                                        hintText:
                                                                            'Add Tracking ID',
                                                                        // labelText: 'Add Tracking ID'
                                                                      ),
                                                                      validator:
                                                                          (value) {
                                                                        if (value
                                                                            .isEmpty) {
                                                                          return 'Please enter Tracking ID';
                                                                        }
                                                                      },
                                                                      onSaved:
                                                                          (value) =>
                                                                              id = value,
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: RaisedButton(
                                                                        color: Colors.black87,
                                                                        child: Text("Add", style: TextStyle(color: Colors.white)),
                                                                        onPressed: () {
                                                                          if (_formKey
                                                                              .currentState
                                                                              .validate()) {
                                                                            _formKey.currentState.save();
                                                                            validTrackingIDCheck(id,
                                                                                productdata1[position].order_id);
                                                                          }

                                                                          // if(_formKey.currentState.validate()){
                                                                          //     _formKey.currentState.save();
                                                                          //     validTrackingIDCheck(id, productdata1[position].order_id);
                                                                          // }
                                                                        }

                                                                        // {
                                                                        //   if (_formKey.currentState.validate()) {
                                                                        //     _formKey.currentState.save();
                                                                        //      print(id);
                                                                        //     var db1 = Firestore.instance;
                                                                        //     var up1 = {
                                                                        //       'tracking_id': id,
                                                                        //     };

                                                                        //     db1
                                                                        //         .collection("item_order")
                                                                        //         .document(productdata1[position].order_id)
                                                                        //         .updateData(up1)
                                                                        //         .then((val) {
                                                                        //       print("sucess");
                                                                        //       Navigator.pop(context);
                                                                        //       getCredential();
                                                                        //       setState(() {
                                                                        //         _isInAsyncCall = false;
                                                                        //       });
                                                                        //     }).catchError((err) {
                                                                        //       print(err);
                                                                        //       _isInAsyncCall = false;
                                                                        //     });
                                                                        //   }
                                                                        // }
                                                                        ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  },
                                                )
                                              : RaisedButton(
                                                  color: Colors.black87,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15.0,
                                                      vertical: 10.0),
                                                  child: Container(
                                                    child: Text(
                                                      'TRACK ORDER',
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Tracking_Screen(
                                                                productdata1[
                                                                        position]
                                                                    .product_id,
                                                                productdata1[
                                                                        position]
                                                                    .order_id,
                                                                productdata1[
                                                                        position]
                                                                    .tracking_id),
                                                      ),
                                                    );
                                                  },
                                                )),
                                  //---------------- Remove Print lable button------------------
                                  // Container(
                                  //   child: orderList[position].pickup_order.label == ""? RaisedButton(
                                  //     color: Colors.black87,
                                  //     padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
                                  //     child:  Container(
                                  //       child: Text('PRINT LABEL', style: TextStyle(
                                  //           fontSize: 15.0,
                                  //           fontWeight: FontWeight.bold,
                                  //           color: Colors.white), maxLines: 1,),
                                  //     ),
                                  //     onPressed: () {
                                  //       Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(
                                  //           builder: (context) =>
                                  //               Tracking_Screen(
                                  //                   productdata1[position].product_id),
                                  //         ),
                                  //       );
                                  //     },):RaisedButton(
                                  //     color: Colors.black87,
                                  //     padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
                                  //     child:  Container(
                                  //       child: Text('PRINT LABEL', style: TextStyle(
                                  //           fontSize: 15.0,
                                  //           fontWeight: FontWeight.bold,
                                  //           color: Colors.white), maxLines: 1,),
                                  //     ),
                                  //     onPressed: () {

                                  //       buyerAddress = new List();
                                  //       buyerAddress = orderList[position].shipping_address;

                                  //     },)

                                  // ),
                                  // ------------------------------------TRACK ORDER Button -----------------------
                                  // RaisedButton(
                                  //   color: Colors.black87,
                                  //   padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
                                  //   child:  Container(
                                  //     child: Text('TRACK ORDER', style: TextStyle(
                                  //         fontSize: 15.0,
                                  //         fontWeight: FontWeight.bold,
                                  //         color: Colors.white), maxLines: 1,),
                                  //   ),
                                  //   onPressed: () {
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             Tracking_Screen(
                                  //                 productdata1[position].product_id),
                                  //       ),
                                  //     );
                                  //   },)
                                ],
                              )),
                        )
                      ],
                    ))),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GridItemDetails(item: productdata1[position]),
                ),
              );
            },
          );
        });
  }

  Widget Showmsg() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'images/tonlogo.png',
          color: Colors.black54,
          height: 50.0,
          width: 50.0,
        ),
        new Container(
          height: 10.0,
        ),
        Text(
          'No Order Data',
          style: TextStyle(fontSize: 20.0),
        ),
      ],
    ));
  }
}

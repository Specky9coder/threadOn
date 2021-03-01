import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/model/Item_Order.dart';
import 'package:threadon/model/Open_Sale.dart';

// ignore: uri_does_not_exist
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/GridItemDetails.dart';
import 'package:threadon/pages/Traking_Screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';

class Orders_Tab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => orders_tab();
}

class orders_tab extends State<Orders_Tab> {
  String user_id = '';
  List<Shell_Product_Model> productdata;
  List<Shell_Product_Model> productdata1 = new List();

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
    productdata = new List();
  }

  Future getData() async {
    CollectionReference ref = Firestore.instance.collection('item_order');
    QuerySnapshot eventsQuery = await ref
        .where("user_id", isEqualTo: user_id)
        .where("order_status", isEqualTo: "0")
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
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
            if (this.mounted) {
              setState(() {
                _isInAsyncCall = false;
              });
            }
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
    return Scaffold(
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
                    height: 210.0,
                    alignment: Alignment.topLeft,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
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
                                                  text: 'Price: ',
                                                  style: TextStyle(
                                                    fontSize: 15.0,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
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
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        5.0, 5.0, 10.0, 5.0),
                                                child: productdata1[position]
                                                                .item_color ==
                                                            null &&
                                                        productdata1[position]
                                                                .item_color ==
                                                            ""
                                                    ? new Row(
                                                        children: <Widget>[
                                                          Text(
                                                            "Color : ",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 13.0,
                                                            ),
                                                          ),
                                                          Text(
                                                            productdata1[
                                                                    position]
                                                                .item_color,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 13.0,
                                                              fontWeight:
                                                                  FontWeight
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
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 13.0,
                                                            ),
                                                          ),
                                                          Text(
                                                            "----",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 13.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      )),
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
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.all(10.0),
                            child: FlatButton(
                              padding: EdgeInsets.all(5.0),
                              child: Container(
                                child: Text(
                                  'TRACK ORDER',
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                  maxLines: 1,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Tracking_Screen(
                                        productdata1[position].product_id,
                                        productdata1[position].order_id,
                                        productdata1[position].tracking_id),
                                  ),
                                );
                              },
                            ),
                          ),
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

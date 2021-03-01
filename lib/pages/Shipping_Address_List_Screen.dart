import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/shipping_address.dart';
import 'package:threadon/pages/Add_Address_screen.dart';
import 'package:threadon/pages/Secure_Checkout_Screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:threadon/utils/swipe_widget.dart';

class Shipping_Address_List extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => shipping_address_list();
}

class shipping_address_list extends State<Shipping_Address_List> {
  List<Shipping_address> shellingaddressList;
  List<Shipping_address> buyingaddressList;
  List<Shipping_address> shelling_addressList = new List<Shipping_address>();
  List<Shipping_address> buying_addressList = new List<Shipping_address>();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  bool _isInAsyncCall = true;
  String user_id = "", user_name = "", profile_image = "", flag = "";
  SharedPreferences sharedPreferences;

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = sharedPreferences.getString("user_id");
      user_name = sharedPreferences.getString("UserName");
      profile_image = sharedPreferences.getString("profile_image");
      flag = sharedPreferences.getString("flag1");
    });

    Firestore.instance
        .collection('shipping_address')
        .where("user_id", isEqualTo: user_id)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) async {
        if (doc.exists) {
          if (doc['status'] == "1") {
            //_radioValue = int.parse(doc['id_default']);
            buyingaddressList
              ..add(Shipping_address(
                  doc['shipping_add_id'],
                  doc['user_id'],
                  doc['name'],
                  doc['address_line_1'],
                  doc['address_line_2'],
                  doc['city'],
                  doc['zipcode'],
                  doc['state'],
                  doc['date'],
                  doc['id_default'],
                  doc['status']));
          }

          setState(() {
            _isInAsyncCall = false;
            buyingaddressList = buyingaddressList;
          });
        } else {
          // showInSnackBar('No payoutd data found!');

        }
      });
    });
  }

  int _radioValue = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    shellingaddressList = new List();
    buyingaddressList = new List();

    getCredential();
  }

  @override
  void dispose() {
    noteSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return WillPopScope(
      child: Scaffold(
        appBar: new AppBar(
          leading: GestureDetector(
            child: Icon(Icons.arrow_back),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Secure_Checkout_Screen()));
            },
          ),
          title: new Text('Address Book'),
          backgroundColor: Colors.white70,
        ),

        body: ModalProgressHUD(
          child: SafeArea(
            child: Container(
//                padding: EdgeInsets.only(
//                    left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
//                child: Card(
              child: Container(
                child: buyingaddressList.length > 0
                    ? Container(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 5.0, bottom: 5.0),
                        height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                            itemCount: buyingaddressList.length,
                            itemBuilder: (context, position) {
                              return new OnSlide(
                                  items: <ActionItems>[
                                    new ActionItems(
                                        icon: new IconButton(
                                          icon: new Icon(Icons.edit),
                                          iconSize: 30.0,
                                          splashColor: Colors.grey,
                                          onPressed: () {},
                                          color: Colors.white,
                                        ),
                                        onPress: () {
                                          sharedPreferences.setString('shipping_add_id', buyingaddressList[position].shipping_add_id);
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Add_Address_Screen(appbar_name: 'Update Address', Flag: 4,exit_Flag: 4,)));
                                        },
                                        backgroudColor: Colors.green),
                                    new ActionItems(
                                        icon: new IconButton(
                                          icon: new Icon(Icons.delete),
                                          iconSize: 30.0,
                                          splashColor: Colors.grey,
                                          onPressed: () {},
                                          color: Colors.white,
                                        ),
                                        onPress: () {
                                          var db = Firestore.instance;
                                          db.collection("shipping_address")
                                              .document(
                                                  buyingaddressList[position]
                                                      .shipping_add_id)
                                              .delete()
                                              .then((val) {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Shipping_Address_List()));
                                            print("sucess");
                                          }).catchError((err) {
                                            print(err);
                                            _isInAsyncCall = false;
                                          });
                                        },
                                        backgroudColor: Colors.red),
                                  ],
                                  child: GestureDetector(
                                    child: Container(
//                margin: EdgeInsets.only(bottom: 20.0),
                                      alignment: Alignment.centerRight,
                                      color: Colors.white,

                                      child: new Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 2,
                                            child: new Radio<int>(
                                              value: int.parse(
                                                  buyingaddressList[position]
                                                      .is_default),
                                              groupValue: 1,
                                              onChanged: (int value) async {
                                                setState(() {
                                                  _radioValue = value;
                                                });

                                                _isInAsyncCall = true;

                                                CollectionReference ref =
                                                    Firestore.instance
                                                        .collection(
                                                            'shipping_address');
                                                QuerySnapshot eventsQuery =
                                                    await ref
                                                        .where("user_id",
                                                            isEqualTo: user_id)
                                                        .getDocuments();

                                                if (eventsQuery
                                                    .documents.isEmpty) {
                                                  setState(() {
                                                    _isInAsyncCall = false;
                                                  });
                                                } else {
                                                  var da =
                                                      eventsQuery.documents;

                                                  for (int i = 0;
                                                      i < da.length;
                                                      i++) {
                                                    String shipp_id =
                                                        da[i].data[
                                                            'shipping_add_id'];
                                                    var up = {
                                                      'id_default': '0'
                                                    };
                                                    var db = Firestore.instance;
                                                    db
                                                        .collection(
                                                            "shipping_address")
                                                        .document(shipp_id)
                                                        .updateData(up)
                                                        .then((val) {
                                                      print("sucess");
                                                    }).catchError((err) {
                                                      print(err);
                                                    });
                                                  }

                                                  var db1 = Firestore.instance;

                                                  var docId = buyingaddressList[
                                                          position]
                                                      .shipping_add_id;
                                                  var updateId = {
                                                    "id_default": "1"
                                                  };

                                                  db1
                                                      .collection(
                                                          "shipping_address")
                                                      .document(docId)
                                                      .updateData(updateId)
                                                      .then((val) {
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                Secure_Checkout_Screen()));

                                                    setState(() {
                                                      _isInAsyncCall = false;
                                                    });

                                                    print("sucess");
                                                  }).catchError((err) {
                                                    print(err);
                                                    _isInAsyncCall = false;
                                                  });
                                                }
                                              },

                                              /* onChanged: handleRadioValueChanged(_radioValue,'${shipping_list[position].Id}'),*/
                                            ),
                                          ),
                                          Expanded(
                                            flex: 8,
                                            child: Container(
                                                alignment: Alignment.topLeft,
                                                padding:
                                                    EdgeInsets.only(left: 5.0),
                                                child: new Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: new Text(
                                                          '${buyingaddressList[position].name}',
                                                          style: TextStyle(
                                                              fontSize: 20.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5.0),
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      padding: EdgeInsets.only(
                                                          left: 5.0),
                                                      child: Text(
                                                        '${buyingaddressList[position].address_line_1}',
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5.0),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 5.0),
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        '${buyingaddressList[position].address_line_2}',
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5.0),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 5.0),
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        '${buyingaddressList[position].city}',
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5.0),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 5.0),
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        '${buyingaddressList[position].state}' +
                                                            "  " +
                                                            '${buyingaddressList[position].zip_code}',
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                    ),
                                                    new Container(
                                                        margin: const EdgeInsets
                                                                .only(
                                                            top: 5,
                                                            bottom: 5.0),
                                                        child: Divider(
                                                            color: Colors
                                                                .black26)),
                                                  ],
                                                )),
                                          )
                                        ],
                                      ),
                                      // photo and title
                                    ),
                                    onTap: () async {
                                      setState(() {
                                        _isInAsyncCall = true;
                                      });

                                      CollectionReference ref = Firestore
                                          .instance
                                          .collection('shipping_address');
                                      QuerySnapshot eventsQuery = await ref
                                          .where("user_id", isEqualTo: user_id)
                                          .getDocuments();

                                      if (eventsQuery.documents.isEmpty) {
                                        setState(() {
                                          _isInAsyncCall = false;
                                        });
                                      } else {
                                        var da = eventsQuery.documents;

                                        for (int i = 0; i < da.length; i++) {
                                          String shipp_id =
                                              da[i].data['shipping_add_id'];
                                          var up = {'id_default': '0'};
                                          var db = Firestore.instance;
                                          db
                                              .collection("shipping_address")
                                              .document(shipp_id)
                                              .updateData(up)
                                              .then((val) {
                                            print("sucess");
                                          }).catchError((err) {
                                            print(err);
                                          });
                                        }

                                        var db1 = Firestore.instance;

                                        var docId = buyingaddressList[position]
                                            .shipping_add_id;
                                        var updateId = {"id_default": "1"};

                                        db1
                                            .collection("shipping_address")
                                            .document(docId)
                                            .updateData(updateId)
                                            .then((val) {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Secure_Checkout_Screen()));

                                          print("sucess");
                                        }).catchError((err) {
                                          print(err);
                                          _isInAsyncCall = false;
                                        });

                                        setState(() {
                                          _isInAsyncCall = false;
                                        });
                                      }
                                    },
                                  ));
                            }),
                      )
                    : new Container(),
              ),
            ),
          ),
          inAsyncCall: _isInAsyncCall,
          opacity: 0.7,
          color: Colors.white,
          progressIndicator: CircularProgressIndicator(),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () =>
//            MyNavigator.gotoAddAddress(context, "Shipping Address",1),
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Add_Address_Screen(appbar_name: 'Update Address', Flag: 0,exit_Flag: 4,))),
          tooltip: '',
          elevation: 10.0,
          backgroundColor: Colors.redAccent,
          child: new Icon(
            Icons.add,
            color: Colors.white,
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
      onWillPop: () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Secure_Checkout_Screen()));
      },
    );
  }
}

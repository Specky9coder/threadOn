import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Product.dart';
import 'package:threadon/model/Share.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:flutter/services.dart';
import 'package:threadon/pages/splesh_screen.dart';

class Sold_ItemList_Product extends StatefulWidget {
  final Shell_Product_Model item;
  const Sold_ItemList_Product({@required this.item});

  @override
  State<StatefulWidget> createState() => new sold_itemlist_product(item);
// TODO: implement createState
}

class sold_itemlist_product extends State<Sold_ItemList_Product> {
  final Shell_Product_Model item;
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  bool _isInAsyncCall = false;
  sold_itemlist_product(this.item);
  String user_id = '', Share_id = '';
  final myController = TextEditingController();
  List<Share> shareList;

  bool favourite = false;

  @override
  void initState() {
    super.initState();

    getCredential();

    shareList = new List();
  }

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (this.mounted) {
      setState(() {
        user_id = sharedPreferences.getString("user_id");
      });
    }

    CollectionReference ref = Firestore.instance.collection('share_list');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
        });
      }
    } else {
      eventsQuery.documents.forEach((doc) async {
        shareList.add(Share(doc['share_id'], doc['user_id'], doc['date'],
            doc['share_list_name'], doc['share_product_id']));
      });
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        /*  Container(
          child: RaisedButton(onPressed: null,
          child: Text('Sold'),),
        ),
*/
        Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            Container(
              child: Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 120.0, right: 30.0, top: 0.0),
                        alignment: Alignment.centerRight,
                        child: ListTile(
                            // leading: Icon(Icons.favorite_border),
                            ),
                      ),
//                onTap:() => _openAddUserDialog ,
                      onTap: () {},
                    ),
                    AspectRatio(
                      aspectRatio: 18.0 / 12.0,
                      child: Image.network(
                        item.picture,
                      ),
                    ),
                    new Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 4.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              item.item_title,
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
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              item.item_brand,
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
                            child: Text(
                              item.item_price,
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
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                item.item_size,
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
            ),
            Container(
              margin: EdgeInsets.all(5.0),
              alignment: Alignment.centerLeft,
              child: RaisedButton(
                onPressed: null,
                child: Text('Sold'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

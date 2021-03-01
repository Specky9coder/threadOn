import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Favorite.dart';

import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/ItemList.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';

import 'package:threadon/utils/SharedPreferencesHelper.dart';

class Favorite_Tab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => favorite_tab();
}

class favorite_tab extends State<Favorite_Tab> with TickerProviderStateMixin {
  List<Favorite> favoriteList;
  List<Shell_Product_Model> productList;
  List<Shell_Product_Model> productList1 = new List<Shell_Product_Model>();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  String Sub_cat_id = '';
  String Category_name = '';

  double itemHeight;
  double itemWidth;
  String toolName;
  String user_id = "";
  bool _isInAsyncCall = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      _isInAsyncCall = true;
    });
    getCredential();

    productList = new List();
  }

  Future getData() async {
    CollectionReference ref = Firestore.instance.collection('favourite_item');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
        });
      }

      /* DateTime date = DateTime.now();
        String datea = date.toString();
        noteSub?.cancel();
        db.cartItem('', productid, '0', userId, datea).then((_) {
          geetcart();
        });
        sharedPreferences.setString('pid', '');*/
      /* setState(() {
        _isInAsyncCall = false;
        return favourite = false;
      });*/
    } else {
      eventsQuery.documents.forEach((doc) async {
        String fav_id = doc['product_id'];

        CollectionReference ref = Firestore.instance.collection('product');
        QuerySnapshot eventsQuery = await ref
            .where("product_id", isEqualTo: fav_id)
            .where('status', isEqualTo: '0')
            .getDocuments();

        if (eventsQuery.documents.isEmpty) {
          if (this.mounted) {
            setState(() {
              _isInAsyncCall = false;
            });
          }
        } else {
          eventsQuery.documents.forEach((doc) async {
            productList.add(Shell_Product_Model(
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
            if (this.mounted) {
              setState(() {
                _isInAsyncCall = false;
                this.productList1 = productList;
              });
            }
          });
        }
      });
    }
  }

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Sub_cat_id = await SharedPreferencesHelper.getcat_id();
    Category_name = await SharedPreferencesHelper.getcat_name();
    user_id = sharedPreferences.getString("user_id");
    getData();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.black;
    Color foregroundColor = Colors.white70;
    var size = MediaQuery.of(context).size;
    itemHeight = (size.height - kToolbarHeight - 24) / 2;
    itemWidth = size.width / 2;

    return new Scaffold(
        body: ModalProgressHUD(
      child: productList1.length == 0
          ? Center(child: Showmsg())
          : Container(child: _gridView()),
      inAsyncCall: _isInAsyncCall,
      opacity: 1,
      color: Colors.white,
      progressIndicator: CircularProgressIndicator(),
    ));
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
          'No favorite product found',
          style: TextStyle(fontSize: 20.0),
        ),
      ],
    ));
  }

  Widget _gridView() {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(4.0),
      childAspectRatio: 8.0 / 13.0,
      children: productList1
          .map(
            (Shell_Product_Model) => ItemList(item: Shell_Product_Model),
          )
          .toList(),
    );
  }
}

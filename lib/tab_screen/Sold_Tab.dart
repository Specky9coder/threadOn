import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Item.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/ItemList.dart';
import 'package:threadon/pages/Sold_ItemList.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';

class Sold_Tab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => sold_tab();
}

class sold_tab extends State<Sold_Tab> {
  double itemHeight;
  double itemWidth;
  String toolName;
  SharedPreferences sharedPreferences;
  String seller_Id = "",
      Name = "",
      email_id = "",
      profile_image = "",
      facebook_id = "",
      user_id = "",
      about_me = "",
      country = "",
      cover_picture = "",
      password = "",
      username = "",
      followers = "",
      following = "",
      device_id = "",
      tracking_id = "";
  TabController controller;

  List<Shell_Product_Model> final_item_list = new List<Shell_Product_Model>();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  bool _isInAsyncCall = true;

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    seller_Id = sharedPreferences.getString('seller_id');
    Name = sharedPreferences.getString('UserName');
    email_id = sharedPreferences.getString('loginname');
    profile_image = sharedPreferences.getString('profile_image');
    country = sharedPreferences.getString('country');
    about_me = sharedPreferences.getString('about_me');
    password = sharedPreferences.getString('password');
    username = sharedPreferences.getString('username');
    user_id = sharedPreferences.getString('user_id');
    following = sharedPreferences.getString('following');
    followers = sharedPreferences.getString('followers');
    device_id = sharedPreferences.getString('device_id');
    cover_picture = sharedPreferences.getString("cover_picture");

    CollectionReference ref = Firestore.instance.collection('product');

    QuerySnapshot eventsQuery = await ref
        .where("user_id", isEqualTo: user_id)
        .where('status', isEqualTo: "2")
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
        });
      }
    } else {
      eventsQuery.documents.forEach((doc) async {
        final_item_list.add(Shell_Product_Model(
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
          final_item_list = this.final_item_list;
          _isInAsyncCall = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCredential();
    final_item_list = new List();
  }

  @override
  void dispose() {
    noteSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    itemHeight = (size.height - kToolbarHeight - 24) / 2;
    itemWidth = size.width / 2;
    final double shortTestsize = MediaQuery.of(context).size.shortestSide;
    final bool mobilesize = shortTestsize < 600;

    final Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      body: ModalProgressHUD(
        child: final_item_list.length == 0
            ? Showmsg()
            : Container(
                child: mobilesize
                    ? _gridViewMobile(orientation: orientation)
                    : _gridViewTablet(orientation: orientation),
              ),
        inAsyncCall: _isInAsyncCall,
        opacity: 1,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
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
          'No sold product ',
          style: TextStyle(fontSize: 20.0),
        ),
      ],
    ));
  }

  Widget _gridViewMobile({@required Orientation orientation}) {
    return GridView.count(
      crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
      padding: const EdgeInsets.all(2.0),
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
      childAspectRatio: orientation == Orientation.portrait ? 0.5 : 0.6,
      children: final_item_list
          .map(
            (Shell_Product_Model) =>
                Sold_ItemList_Product(item: Shell_Product_Model),
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
      childAspectRatio: orientation == Orientation.portrait ? 0.7 : 1,
      children: final_item_list
          .map(
            (Shell_Product_Model) =>
                Sold_ItemList_Product(item: Shell_Product_Model),
          )
          .toList(),
    );
  }

  Widget _gridView() {
    setState(() {
      _isInAsyncCall = false;
    });
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(4.0),
      childAspectRatio: 8.0 / 13.0,
      children: final_item_list
          .map(
            (Item) => Sold_ItemList_Product(item: Item),
          )
          .toList(),
    );
  }
}

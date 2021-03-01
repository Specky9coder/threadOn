import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/GetProduct.dart';
import 'package:threadon/model/Share_List.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/ChatMessage.dart';
import 'package:threadon/pages/Coman_SearchList_Screen.dart';
import 'package:threadon/pages/ItemList.dart';
import 'package:threadon/pages/Share_ItemList.dart';

import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';

class Share_List_Screen extends StatefulWidget {
  String title;

  Share_List_Screen({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => share_list(title);
}

class share_list extends State<Share_List_Screen>
    with SingleTickerProviderStateMixin {
  String title;

  share_list(this.title);

  AnimationController _controller;

  List<Share_List> shareList;
  List<Share_List> shareList1 = new List<Share_List>();
  List<Shell_Product_Model> productList;
  List<Shell_Product_Model> productList1 = new List<Shell_Product_Model>();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  String Sub_cat_id = '', share_id = '';
  String Category_name = '';

  String Carttotal = "0";
  double itemHeight;
  double itemWidth;
  String toolName, user_id = '';
  bool _isInAsyncCall = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCredential();

    setState(() {
      _isInAsyncCall = true;
    });
    shareList = new List();
    productList = new List();
  }

  getData() async {
    CollectionReference ref = Firestore.instance.collection('share_list');
    QuerySnapshot eventsQuery =
        await ref.where("share_id", isEqualTo: share_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        List product_id = doc['share_product_id'];

        getProduct(product_id);
      });
    }
  }

  getProduct(List product) async {
    for (int i = 0; i < product.length; i++) {
      CollectionReference ref = Firestore.instance.collection('product');
      QuerySnapshot eventsQuery =
          await ref.where("product_id", isEqualTo: product[i]).getDocuments();

      if (eventsQuery.documents.isEmpty) {
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

          setState(() {
            this.productList1 = productList;
            _isInAsyncCall = false;
          });
        });
      }
    }
  }

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    share_id = await SharedPreferencesHelper.getshare_id();
    Category_name = await SharedPreferencesHelper.getcat_name();
    user_id = sharedPreferences.getString("user_id");
    if (user_id == null) {
      user_id = "";
    }
    setState(() {
      getData();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    var size = MediaQuery.of(context).size;
    itemHeight = (size.height - kToolbarHeight - 24) / 2;
    itemWidth = size.width / 2;

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(title),
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
//        automaticallyImplyLeading: false,
        ),
        body: ModalProgressHUD(
          child: _gridView(),
          inAsyncCall: _isInAsyncCall,
          opacity: 1,
          color: Colors.white,
          progressIndicator: CircularProgressIndicator(),
        ));
  }

  Widget _gridView() {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(4.0),
      childAspectRatio: 8.0 / 13.0,
      children: productList1
          .map(
            (Shell_Product_Model) => Share_ItemList(item: Shell_Product_Model),
          )
          .toList(),
    );
  }
}

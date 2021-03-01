import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Cart.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/utils/my_navigator.dart';

class Report extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new report();
// TODO: implement createState

}

class report extends State<Report> {
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  List<Cart> cartList;
  List<Cart> cartList1 = new List<Cart>();
  String user_id = '';
  String Carttotal = "0";
  @override
  void initState() {
    super.initState();
    getCredential();


    cartList = new List();
    cartList.clear();
    noteSub?.cancel();
    noteSub = db.getCartList().listen((QuerySnapshot snapshot) {
      final List<Cart> notes = snapshot.documents
          .map((documentSnapshot) => Cart.fromMap(documentSnapshot.data))
          .toList();
      setState(() {
        for(int i=0;i<notes.length;i++){
          if(user_id == notes[i].user_id){
            cartList1.add(Cart(notes[i].cart_id, notes[i].product_id, notes[i].status, notes[i].user_id, notes[i].date));
          }
        }
        this.cartList = cartList1;
      });
    });

  }

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = sharedPreferences.getString("user_id");
      if(user_id == null){
        user_id ="";
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
        backgroundColor: Colors.white70,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.search),
            tooltip: 'Action Tool Tip',
            onPressed: () {
              print("onPressed");
            },
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
                    stream:Firestore.instance
                        .collection("cart")
                        .where("user_id", isEqualTo: user_id)
                        .snapshots(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData)return Container();
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
          new IconButton(
            icon: new Icon(Icons.perm_identity),
            tooltip: 'Action Tool Tip',
            onPressed: () => MyNavigator.goToProfile(context),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 5.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
              GestureDetector(
                  child: Text(
                    "Authenticity Issue",
                    style: new TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      letterSpacing: 0.3,
                    ),
                  ),
                  onTap: () {
                    MyNavigator.gotoReport_Submit_Screen(context, 'Authenticity Issue');
                  },
                ),
              ],
            ),
          ),

          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 5.0),
            child: new Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                GestureDetector(
                  child: Text(
                    "Image Issue",
                    style: new TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      letterSpacing: 0.3,
                    ),
                  ),
                  onTap: () {
                    MyNavigator.gotoReport1_Submit_Screen(context, 'Image Issue');
                  },
                ),
              ],
            ),
          ),

          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 5.0),
            child: new Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                GestureDetector(
                  child: Text(
                    "Inaccurate Price/Info",
                    style: new TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      letterSpacing: 0.3,
                    ),
                  ),
                  onTap: () {
                    MyNavigator.gotoReport2_Submit_Screen(context, 'Inaccurate Price/Info');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

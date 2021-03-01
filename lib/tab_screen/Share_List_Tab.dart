import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Item.dart';
import 'package:threadon/model/Share.dart';
import 'package:threadon/pages/Favorites_screen.dart';
import 'package:threadon/pages/ShareList_user.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';

class ShareList_Tab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => sharelits_tab();
}

class sharelits_tab extends State<ShareList_Tab> {
  List<Share> categoryList;
  List<Share> categoryList1 = new List();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;

  String toolName, user_id = '';
  bool _isInAsyncCall = false;

  @override
  getCredential() async {
    categoryList = new List();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    user_id = sharedPreferences.getString("user_id");
    setState(() {
      getData();
    });
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    getCredential();
    categoryList = new List();
    setState(() {
      _isInAsyncCall = true;
    });
  }

  Future getData() async {
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
        categoryList.add(Share(
            doc['share_id'],
            doc['user_id'],
            doc['date'].toDate(),
            doc['share_list_name'],
            doc['share_product_id']));

        setState(() {
          _isInAsyncCall = false;
          this.categoryList1 = categoryList;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ModalProgressHUD(
      child: categoryList1.length == 0
          ? Showmsg()
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: categoryList1.length,
                    itemBuilder: (context, position) {
                      return GestureDetector(
                          child: Container(
                            margin:
                                const EdgeInsets.only(left: 5.0, right: 5.0),
                            height: 80.0,
                            child: Card(
                              elevation: 2.0,
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                      child: Padding(
                                    padding: EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      '${categoryList1[position].share_list_name}',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black87),
                                      maxLines: 1,
                                    ),
                                  )),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 20.0, right: 10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        new IconButton(
                                            icon: Icon(
                                              Icons.share,
                                              color: Colors.black,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (contex) =>
                                                          ShareList_user(
                                                              '${categoryList1[position].share_id}',
                                                              '${categoryList1[position].share_list_name}')));
                                            }),
                                        new IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.black,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isInAsyncCall = true;
                                              });
                                              var db1 = Firestore.instance;
                                              db1
                                                  .collection("share_list")
                                                  .document(
                                                      categoryList1[position]
                                                          .share_id)
                                                  .delete()
                                                  .then((val) {
                                                //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Favorite_Screen(appbar_name: 'Favorite',)));
                                                print("sucess");
                                                setState(() {
                                                  categoryList.clear();
                                                  getCredential();
                                                  _isInAsyncCall = false;
                                                });
                                              }).catchError((err) {
                                                print(err);
                                              });
                                            })
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // photo and title
                          ),
                          onTap: () async {
                            String share_id =
                                '${categoryList1[position].share_id}';
                            String Share_list_ame =
                                '${categoryList1[position].share_list_name}';
                            await SharedPreferencesHelper.setshare_id(share_id);
                            MyNavigator.gotoShare_List_Screen(
                                context, Share_list_ame);
                          });
                    },
                  ),
                ),
              ],
            ),
      inAsyncCall: _isInAsyncCall,
      opacity: 1,
      color: Colors.white,
      progressIndicator: CircularProgressIndicator(),
    ));
  }

  Future<List<String>> _getData() async {
    var values = new List<String>();
    values.add("Wedding Collection");
    values.add("Shoes Collection");
    values.add("New Collection");

    //throw new Exception("Danger Will Robinson!!!");

    await new Future.delayed(new Duration(seconds: 5));

    return values;
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
          'No share list data',
          style: TextStyle(fontSize: 20.0),
        ),
      ],
    ));
  }
}

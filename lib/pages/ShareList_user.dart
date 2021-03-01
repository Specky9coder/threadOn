import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Login.dart';
import 'package:threadon/model/Share.dart';
import 'package:threadon/pages/Favorites_screen.dart';
import 'package:threadon/pages/Share_List_screen.dart';
import 'package:threadon/tab_screen/Share_List_Tab.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';

class ShareList_user extends StatefulWidget {
  String Sharid = '';
  String Sharename = '';

  ShareList_user(this.Sharid, this.Sharename);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShareList(Sharid, Sharename);
  }
}

class ShareList extends State<ShareList_user> {
  String Sharid = '';
  String Sharename = '';
  List share_product_id;

  ShareList(this.Sharid, this.Sharename);

  List<Login_Modle> userList1 = new List();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String user_id = '';
  bool _isInAsyncCall = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCredential();
  }

  getCredential() async {
    share_product_id = new List();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    user_id = sharedPreferences.getString("user_id");
    userList1 = new List();
    noteSub?.cancel();

    CollectionReference ref = Firestore.instance.collection('share_list');
    QuerySnapshot eventsQuery =
        await ref.where('share_id', isEqualTo: Sharid).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        share_product_id = doc['share_product_id'];
        //userList1.add(Login_Modle(doc['user_id'], doc['username'], doc['password'], doc['name'], doc['status'], doc['profile_picture'], doc['latlong'].toString(), doc['following'],doc['followers'],doc['facebook_id'] , doc['device_id'], doc['device_id'], doc['device'], doc['cover_picture'], doc['country'], doc['about_me'], doc['refer_code'],doc['token_id']));

        CollectionReference ref = Firestore.instance.collection('users');
        QuerySnapshot eventsQuery =
            await ref.where('status', isEqualTo: "0").getDocuments();

        if (eventsQuery.documents.isEmpty) {
          setState(() {
            _isInAsyncCall = false;
          });
        } else {
          eventsQuery.documents.forEach((doc) async {
            if (doc['user_id'] != user_id) {
              userList1.add(Login_Modle(
                  doc['user_id'],
                  doc['username'],
                  doc['password'],
                  doc['name'],
                  doc['status'],
                  doc['profile_picture'],
                  doc['latlong'],
                  doc['following'],
                  doc['followers'],
                  doc['facebook_id'],
                  doc['device_id'],
                  doc['device_id'],
                  doc['device'],
                  doc['cover_picture'],
                  doc['country'],
                  doc['about_me'],
                  doc['refer_code'],
                  doc['token_id']));
            }

            setState(() {
              _isInAsyncCall = false;
              this.userList1 = userList1;
              print('Image :: ${userList1[0].Profile_picture}');
            });
          });
        }
      });
    }
  }

  void showInSnackBar(String value) {
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Users'),
        ),
        key: scaffoldKey,
        body: ModalProgressHUD(
          child: userList1.length == 0
              ? new Container()
              : Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        itemCount: userList1.length,
                        itemBuilder: (context, position) {
                          return GestureDetector(
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 5.0, right: 5.0),
                                height: 80.0,
                                child: Card(
                                  elevation: 2.0,
                                  color: Colors.white,
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: userList1[position]
                                                          .Profile_picture !=
                                                      ""
                                                  ? NetworkImage(
                                                      "${userList1[position].Profile_picture}")
                                                  : AssetImage(
                                                      'images/tonlogo.png'),
                                            ),
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                        margin: EdgeInsets.only(
                                            left: 10,
                                            top: 5,
                                            bottom: 5,
                                            right: 10.0),
                                        height: 60,
                                        width: 60,
                                      ),
                                      GestureDetector(
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.only(left: 20.0),
                                          child: Text(
                                            '${userList1[position].Name}',
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black87),
                                            maxLines: 1,
                                          ),
                                        ),
                                        onTap: () {
                                          db
                                              .createShareList(
                                                  Sharid,
                                                  userList1[position].Key,
                                                  DateTime.now(),
                                                  Sharename,
                                                  share_product_id)
                                              .then((_) {
                                            setState(() {
                                              showInSnackBar(
                                                  'Favourite items list successfully shared');
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Favorite_Screen(
                                                            appbar_name:
                                                                'Favorites',
                                                          )));
                                            });
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // photo and title
                              ),
                              onTap: () async {
                                /*String share_id = '${categoryList1[position].share_id}';
                      String Share_list_ame = '${categoryList1[position]
                          .share_list_name}';
                      await SharedPreferencesHelper
                          .setshare_id(share_id);
                      MyNavigator.gotoShare_List_Screen(
                          context, Share_list_ame);*/
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
}

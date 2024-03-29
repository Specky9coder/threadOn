import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Follow.dart';
import 'package:threadon/model/Login.dart';
import 'package:threadon/model/Share.dart';
import 'package:threadon/pages/splesh_screen.dart';

import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:http/http.dart' as http;
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:flutter/services.dart';

class User_Followers1 extends StatefulWidget {
  final Login_Modle item;
  final Login_Modle user_item;

  const User_Followers1({@required this.item, this.user_item});

  @override
  State<StatefulWidget> createState() => new user_followers1(item, user_item);
// TODO: implement createState
}

class user_followers1 extends State<User_Followers1> {
  final Login_Modle item;
  List<FollowModel> followModel;
  final Login_Modle user_item;
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  bool _isInAsyncCall = false;
  List<String> favlist_id = new List();
  List<String> favid = new List();

  user_followers1(this.item, this.user_item);

  String user_id = '', Share_id = '';
  final myController = TextEditingController();
  List<Share> shareList;
  List<Share> shareList1 = new List();
  bool favourite = false;
  String Flag1 = "", productId = "";
  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();

/*------------------------------------------favourite--------------------------------------*/
  bool _isFavorited = false;
  int _favoriteCount = 1;
  SharedPreferences sharedPreferences;
  List share_product_id;

  bool signs_press_no = false;
  String signs_press_text = 'Follow';
  String Name = '';
  final postUrl = 'https://fcm.googleapis.com/fcm/send';
  List userProductImage;

  String User_Follower, User_Following, Seller_following, Seller_followers;

  Future getProductData() async {
    userProductImage = new List();

    CollectionReference ref = Firestore.instance.collection('product');
    QuerySnapshot eventsQuery = await ref
        .where("user_id", isEqualTo: item.Key)
        .orderBy('date', descending: true)
        .limit(3)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        userProductImage.add(doc['picture']);
      });
    }
    if (this.mounted) {
      setState(() {
        _isInAsyncCall = false;
        userProductImage = this.userProductImage;
        // _isInAsyncCall = false;
      });
    }
  }

  Future getData() async {
    CollectionReference ref = Firestore.instance.collection('follow');
    QuerySnapshot eventsQuery = await ref
        .where("follower_id", isEqualTo: item.Key)
        .where('following_id', isEqualTo: user_id)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
          return signs_press_no = false;
        });
      }
    } else {
      eventsQuery.documents.forEach((doc) async {
        // favlist_id.add(doc['favourite_id']);

        if (this.mounted) {
          setState(() {
            var follower_id = doc['following_id'];
            getProductData();

            signs_press_text = "Following";

            signs_press_no = true;

            _isInAsyncCall = false;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _isInAsyncCall = true;
    });
    getCredential();

    shareList = new List();
    share_product_id = new List();
    userProductImage = new List();
  }

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();

    await SharedPreferencesHelper.setSeller_Follower(item.Followers);
    await SharedPreferencesHelper.setSeller_Following(item.Following);

    if (this.mounted) {
      setState(() {
        user_id = sharedPreferences.getString("user_id");
        Flag1 = sharedPreferences.getString('flag1');
        productId = sharedPreferences.getString('pid');
        Name = sharedPreferences.getString("UserName");

        setState(() {
          getData();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      body: ModalProgressHUD(
        child : Container(                
        child: Card(      
            elevation: 2.0,          
            child: 
            Column(children: <Widget>[
              Container(
                color: Colors.white,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[                      
                      Expanded(
                        flex: 3,
                        child: new GestureDetector(
                            child: item.Profile_picture == ""
                                ? new Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                        new Container(
                                          height: 70.0,
                                          width: 70.0,
                                          margin: EdgeInsets.only(
                                              left: 10.0, top: 10),
                                          decoration: new BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black54,
                                                width: 2.0),
                                            borderRadius: new BorderRadius.all(
                                                const Radius.circular(70.0)),
                                          ),
                                          child: new CircleAvatar(
                                            radius: 60.0,
                                            backgroundColor: Colors.white,
                                            backgroundImage: AssetImage(
                                                'images/placeholder_face.png'),
                                          ),
                                        )
                                      ])
                                : new Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      new Container(
                                        alignment: Alignment.topLeft,
                                        height: 70.0,
                                        width: 70.0,
                                        margin: EdgeInsets.only(
                                            left: 10.0, top: 10),
                                        decoration: new BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black54,
                                              width: 2.0),
                                          borderRadius: new BorderRadius.all(
                                              const Radius.circular(70.0)),
                                        ),
                                        child: new CircleAvatar(
                                          radius: 60.0,
                                          backgroundColor: Colors.white,
                                          backgroundImage: NetworkImage(
                                              item.Profile_picture),
                                        ),
                                      ),
                                      /* new Center(
                        //  child: new Image.asset("assets/photo_camera.png"),
                        child: Icon(Icons.perm_identity),
                      ),*/
                                    ],
                                  )),
                      ),
                      Expanded(
                          flex: 8,
                          child: GestureDetector(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    margin:
                                        EdgeInsets.only(top: 20.0, left: 5.0),
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      item.Name,
                                      style: TextStyle(
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                      maxLines: 1,
                                    )),
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(top: 3.0, left: 5.0),
                                  child: Text(
                                    item.Country,
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black),
                                    maxLines: 1,
                                  ),
                                ),                                                               
                                Container(                                  
                                    height: 120.0,
                                    alignment: Alignment.centerLeft,
                                    margin:
                                        EdgeInsets.only(top: 10.0, left: 10.0),
                                    child: ListView.builder(
                                        itemCount: 3, //userProductImage.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return userProductImage.length == 0
                                              ? new Container()
                                              : Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 5.0),
                                                  child: Container(
                                                      height: 100.0,
                                                      width: 100.0,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                        color: Colors.white,
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                          5.0,
                                                        ),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                  image:
                                                                      DecorationImage(
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    image: NetworkImage(
                                                                        userProductImage[
                                                                            index]),
                                                                  ),
                                                                  shape: BoxShape
                                                                      .rectangle,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              2))),
                                                          height: 90,
                                                          width: 90,
                                                        ),
                                                      )));
                                        })),
                              ],
                            ),
                            onTap: () {},
                          )),
                    ]),
              ),
              Container(
                  padding: const EdgeInsets.all(8.0),
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        flex: 10,
                        child: Button(),
                      )
                    ],
                  )),
            ])
            ),),
            
        inAsyncCall: _isInAsyncCall,
        opacity: 0.7,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }

  Widget Button() {
    if (user_id == item.Key) {
      return new Visibility(
          visible: false,
          child: RaisedButton(
              child: new Text(
                signs_press_no ? 'Following' : signs_press_text,
                textAlign: TextAlign.center,
              ),
              textColor: signs_press_no ? Colors.white : Colors.black,
              color: signs_press_no ? Colors.black : Colors.white,
              shape: new RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black)),
              onPressed: () async {
                if (signs_press_no == false) {
                  setState(() {
                    _isInAsyncCall = true;
                  });
                  setState(() => signs_press_no = !signs_press_no);
                } else {
                  setState(() => signs_press_no = !signs_press_no);
                }
              }));
    } else {
      return new RaisedButton(
          child: new Text(
            signs_press_no ? 'Following' : signs_press_text,
            textAlign: TextAlign.center,
          ),
          textColor: signs_press_no ? Colors.white : Colors.black,
          color: signs_press_no ? Colors.black : Colors.white,
          shape:
              new RoundedRectangleBorder(side: BorderSide(color: Colors.black)),
          onPressed: () async {
            /* getFollowing(followModel.Following_id,
                item.Device_id,
                followModel.Follower_id,
                item.Followers);*/
            getFollowing(item.Key);
          });
    }
  }

  getFollowing(String Seller_id) async {
    setState(() {
      _isInAsyncCall = true;
    });
    followModel = new List();
    CollectionReference ref = Firestore.instance.collection('follow');
    QuerySnapshot eventsQuery = await ref
        .where("following_id", isEqualTo: user_id)
        .where("follower_id", isEqualTo: Seller_id)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        var follower_id = doc['following_id'];
        followModel.add(FollowModel(doc['date'], doc['follower_id'],
            doc['following_id'], doc['id'], doc['status']));

        getData();
      });
    }

    User_Follower = await SharedPreferencesHelper.getuser_follower();
    User_Following = await SharedPreferencesHelper.getuser_following();

    Seller_followers = await SharedPreferencesHelper.getSeller_follower();
    Seller_following = await SharedPreferencesHelper.getSeller_following();

    if (signs_press_no == false) {
      // makeCall(device_id);

      var db = Firestore.instance;
      db.collection("follow").add({
        "date": DateTime.now(),
        "follower_id": item.Key,
        "following_id": user_id,
        "id": '',
        "status": '0',
      }).then((val) {
        print("sucess");

        String follid = val.documentID;

        var foll = {'id': follid};
        var folldb = Firestore.instance;
        folldb
            .collection("follow")
            .document(follid)
            .updateData(foll)
            .then((val) {
          setState(() {
            //  signs_press_no = true;
          });

          var value = int.tryParse(User_Following);
          value = value + 1;
          User_Following = value.toString();

          var up = {'following': User_Following};
          var db = Firestore.instance;

          db
              .collection("users")
              .document(user_id)
              .updateData(up)
              .then((val) async {
            var value = int.tryParse(Seller_followers);
            value = value + 1;
            Seller_followers = value.toString();

            var up1 = {'followers': Seller_followers};
            var db = Firestore.instance;
            db
                .collection("users")
                .document(item.Key)
                .updateData(up1)
                .then((val) async {
              print("sucess");

              await SharedPreferencesHelper.setSeller_Follower(
                  Seller_followers);
              await SharedPreferencesHelper.setSeller_Following(
                  Seller_following);

              await SharedPreferencesHelper.setUser_Follower(User_Follower);
              await SharedPreferencesHelper.setUser_Following(User_Following);

              setState(() {
                makeCall(item.Token);
                signs_press_text = "Following";
                signs_press_no = true;
                _isInAsyncCall = false;
              });
            }).catchError((err) {
              print(err);
              _isInAsyncCall = false;
            });

            print("sucess");
          }).catchError((err) {
            print(err);
            _isInAsyncCall = false;
          });

          print("sucess");
        }).catchError((err) {
          print(err);
          _isInAsyncCall = false;
        });
      }).catchError((err) {
        print(err);
        _isInAsyncCall = false;
      });
    } else {
      setState(() {
        _isInAsyncCall = true;
      });

      var db = Firestore.instance;
      db.collection("follow").document(followModel[0].Key).delete().then((val) {
        var value = int.tryParse(User_Following);
        value = value - 1;
        User_Following = value.toString();

        setState(() {
          signs_press_no = false;
        });
        var sub_follow = {'following': User_Following};
        var db = Firestore.instance;
        db
            .collection("users")
            .document(user_id)
            .updateData(sub_follow)
            .then((val) async {
          var value = int.tryParse(Seller_followers);
          value = value - 1;
          Seller_followers = value.toString();

          var sub_follow1 = {'followers': Seller_followers};
          var sub_db = Firestore.instance;
          sub_db
              .collection("users")
              .document(item.Key)
              .updateData(sub_follow1)
              .then((val) async {
            print("sucess");

            await SharedPreferencesHelper.setSeller_Follower(Seller_followers);
            await SharedPreferencesHelper.setSeller_Following(Seller_following);

            await SharedPreferencesHelper.setUser_Follower(User_Follower);
            await SharedPreferencesHelper.setUser_Following(User_Following);

            setState(() {
              signs_press_no = false;
              signs_press_text = 'Follow';
              _isInAsyncCall = false;
            });
          }).catchError((err) {
            print(err);
            _isInAsyncCall = false;
          });

          print("sucess");
        }).catchError((err) {
          _isInAsyncCall = false;
          print(err);
        });

        print("sucess");
      }).catchError((err) {
        _isInAsyncCall = false;
        print(err);
      });

/*
      CollectionReference ref = Firestore.instance.collection('follow');
      QuerySnapshot eventsQuery = await ref
          .where("following_id", isEqualTo: user_id)
          .where("follower_id", isEqualTo: following_idd)
          .where("status", isEqualTo: "0")
          .getDocuments();

      if (eventsQuery.documents.isEmpty) {
        setState(() {
          _isInAsyncCall = false;
        });
      } else {
        eventsQuery.documents.forEach((doc) async {
          String folllowId = doc["id"];


        });
      }*/
    }
  }
  
  Future<bool> makeCall(String device_id) async {
    final data = {
      "notification": {"body": Name + " followed you", "title": "Follow"},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done"
      },
      "to": item.Token
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAqfgKAe8:APA91bEEwkEhKzOBxsxQMjxF6HJ1g5U7lY7x363dqrSQqfv9CxRV8wxA-m4U9xD77Og423_seN-gyhFtB0uc4Ilw10bwcPv9HzrMlZVh8tb-tbL4QCYOx0Ad5WPawh0BBNbOfLIYGwjL'
    };

    final response = await http.post(postUrl,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // on success do sth
      return true;
    } else {
      // on failure do sth
      return false;
    }
  }
}

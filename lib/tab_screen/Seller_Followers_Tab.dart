import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Follow.dart';
import 'package:threadon/model/Item.dart';
import 'package:threadon/model/Login.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/pages/Seller_Followers1.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:http/http.dart' as http;

class Seller_Followers_Tab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => seller_followers_tab();
}

class seller_followers_tab extends State<Seller_Followers_Tab> {
  final postUrl = 'https://fcm.googleapis.com/fcm/send';

  double itemHeight;
  double itemWidth;
  String toolName;
  SharedPreferences sharedPreferences;
  String seller_Id = "",
      Seller_Name = "",
      Seller_email_id = "",
      Seller_profile_image = "",
      Seller_facebook_id = "",
      Seller_user_id = "",
      Seller_about_me = "",
      Seller_country = "",
      Seller_cover_picture = "",
      Seller_password = "",
      Seller_username = "",
      Seller_followers = "",
      Seller_following = "",
      Seller_device_id = "",
      Followe_id = "",
      Seller_refer_code = '';

  String Name = "",
      email_id = "",
      profile_image = "",
      facebook_id = "",
      user_id = "",
      about_me = "",
      country = "",
      cover_picture = "",
      password = "",
      username = "@",
      followers = "",
      following = "",
      device_id = "",
      refer_code = '';

  String date = "";
  TabController controller;
  List<Login_Modle> Seller_following_list;
  // List<Login_Modle> Seller_following_final_item_list = new List<Login_Modle>();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  List<FollowModel> folloeList;
  List<Login_Modle> notes;
  bool signs_press_yes = false;
  bool signs_press_no = false;
  String signs_press_text = 'Follow';

  bool _isInAsyncCall = false;

  getCredential() async {
    setState(() {
      _isInAsyncCall = true;
    });
    sharedPreferences = await SharedPreferences.getInstance();
    seller_Id = sharedPreferences.getString('seller_id');
    user_id = sharedPreferences.getString('user_id');
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    date = formatter.format(now);

    getUserData();
    // getFollowerData();
  }

//
  getUserData() async {
    CollectionReference ref = Firestore.instance.collection('users');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        sharedPreferences = await SharedPreferences.getInstance();

        await SharedPreferencesHelper.setUser_Follower(doc['followers']);
        await SharedPreferencesHelper.setUser_Following(doc['following']);
        if (!mounted) return;
        setState(() {
          Name = (doc['name']);
          email_id = (doc['email_id']);
          profile_image = (doc['profile_picture']);
          country = (doc['country']);
          about_me = (doc['about_me']);
          password = (doc['password']);
          username = (doc['username']);

          following = (doc['following']);
          followers = (doc['followers']);
          device_id = (doc['device_id']);
          cover_picture = (doc['cover_picture']);
          refer_code = (doc['refer_code']);
        });

        getFollowerData();
      });
    }
  }

//
  getFollowerData() async {
    // folloeList = new List();
    setState(() {
      _isInAsyncCall = true;
    });
    CollectionReference ref = Firestore.instance.collection('follow');
    QuerySnapshot eventsQuery =
        await ref.where("follower_id", isEqualTo: seller_Id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
        });
      }
    } else {
      eventsQuery.documents.forEach((doc) async {
        //  var  follower_id = doc['following_id'];
        //   if (doc['status'] == '0') {
        //     signs_press_text = "Following";
        //     signs_press_no = true;
        //   }
        var follower_id = doc['following_id'];
        folloeList.add(FollowModel(doc['date'].toDate(), doc['follower_id'],
            doc['following_id'], doc['id'], doc['status']));
        if (doc['status'] == '0') {
          signs_press_text = "Following";
          signs_press_no = true;
        }

        CollectionReference ref = Firestore.instance.collection('users');
        QuerySnapshot eventsQuery =
            await ref.where("user_id", isEqualTo: follower_id).getDocuments();

        if (eventsQuery.documents.isEmpty) {
          if (this.mounted) {
            setState(() {
              _isInAsyncCall = false;
            });
          }
        } else {
          eventsQuery.documents.forEach((doc) async {
            if (doc['status'] == "0") {
              Seller_following_list.add(Login_Modle(
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
                  doc['email_id'],
                  doc['device_id'],
                  doc['device'],
                  doc['cover_picture'],
                  doc['country'],
                  doc['about_me'],
                  doc['refer_code'],
                  doc['token_id']));
            } else {
              if (this.mounted) {
                setState(() {
                  Seller_following_list = this.Seller_following_list;
                  _isInAsyncCall = false;
                });
              }
            }
            if (this.mounted) {
              setState(() {
                // Seller_following_list = new List();
                Seller_following_list = this.Seller_following_list;
                _isInAsyncCall = false;
              });
            }
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCredential();
    folloeList = new List();
    Seller_following_list = new List();
  }

  @override
  void dispose() {
    super.dispose();
    noteSub?.cancel();
  }

  Widget _gridViewMobile({@required Orientation orientation}) {
    return GridView.count(
      crossAxisCount: orientation == Orientation.portrait ? 1 : 1,
      padding: const EdgeInsets.all(2.0),
      childAspectRatio: orientation == Orientation.portrait ? 1.5 : 0.8,
      children: Seller_following_list.map(
        (Login_Modle) => Seller_Followers1(
          item: Login_Modle,
        ),
      ).toList(),
    );
  }

  Widget _gridTabView({@required Orientation orientation}) {
    return GridView.count(
      crossAxisCount: orientation == Orientation.portrait ? 1 : 1,
      padding: const EdgeInsets.all(2.0),
      childAspectRatio: orientation == Orientation.portrait ? 2.2 : 0.8,
      children: Seller_following_list.map(
        (Login_Modle) => Seller_Followers1(
          item: Login_Modle,
        ),
      ).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    itemHeight = (size.height - kToolbarHeight - 24);
    itemWidth = size.width / 2;

    final double shortTestsize = MediaQuery.of(context).size.shortestSide;
    final bool mobilesize = shortTestsize < 600;

    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      body: ModalProgressHUD(
        child: folloeList.length == 0
            ? Showmsg()
            : Container(
                child: mobilesize
                    ? _gridViewMobile(orientation: orientation)
                    : _gridTabView(orientation: orientation),
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
          'No Followers',
          style: TextStyle(fontSize: 20.0),
        ),
      ],
    ));
  }

  Widget Button(int position) {
    if (user_id == Seller_following_list[position].Key) {
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
            getFollowing(
                folloeList[position].Following_id,
                Seller_following_list[position].Device_id,
                folloeList[position].Follower_id,
                Seller_following_list[position].Followers);
          });
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
      "to": device_id
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

  getFollowing(String following_idd, String device_id, String follower_idd,
      String followerr) async {
    if (signs_press_no == false) {
      setState(() {
        _isInAsyncCall = true;
      });
      makeCall(device_id);

      var db = Firestore.instance;
      db.collection("follow").add({
        "date": DateTime.now().toString(),
        "follower_id": following_idd,
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
            signs_press_no = true;
          });

          var value = int.tryParse(following);
          value = value + 1;
          following = value.toString();

          var up = {'following': following};
          var db = Firestore.instance;
          db
              .collection("users")
              .document(user_id)
              .updateData(up)
              .then((val) async {
            var value = int.tryParse(followerr);
            value = value + 1;
            followerr = value.toString();

            var up1 = {'followers': followerr};
            var db = Firestore.instance;
            db
                .collection("users")
                .document(following_idd)
                .updateData(up1)
                .then((val) async {
              sharedPreferences = await SharedPreferences.getInstance();
              sharedPreferences.setString('followers', followers);
              sharedPreferences.setString('following', following);
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

          var db = Firestore.instance;
          db.collection("follow").document(folllowId).delete().then((val) {
            following = sharedPreferences.getString('following');
            followers = sharedPreferences.getString('followers');

            var value = int.tryParse(following);
            value = value - 1;
            following = value.toString();

            setState(() {
              signs_press_no = false;
            });
            var sub_follow = {'following': following};
            var db = Firestore.instance;
            db
                .collection("users")
                .document(user_id)
                .updateData(sub_follow)
                .then((val) async {
              sharedPreferences = await SharedPreferences.getInstance();
              sharedPreferences.setString('followers', followers);
              sharedPreferences.setString('following', following);

              var value = int.tryParse(followerr);
              value = value - 1;
              followerr = value.toString();

              var sub_follow1 = {'followers': followerr};
              var sub_db = Firestore.instance;
              sub_db
                  .collection("users")
                  .document(following_idd)
                  .updateData(sub_follow1)
                  .then((val) {
                print("sucess");
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
        });
      }
    }
  }
}

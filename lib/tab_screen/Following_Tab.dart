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
import 'package:threadon/model/Signup.dart';

import 'package:threadon/pages/User_Following1.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:http/http.dart' as http;

class Following_Tab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => following_Tab();
}

class following_Tab extends State<Following_Tab> {
  final postUrl = 'https://fcm.googleapis.com/fcm/send';

  double itemHeight;
  double itemWidth;
  String toolName;
  SharedPreferences sharedPreferences;
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
      device_id = "";
  TabController controller;
  String refer_code = '';
  List<Login_Modle> Seller_following_list;

  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  String seller_Id = "";
  List<FollowModel> folloeList;
  List<Login_Modle> notes;
  String date = "";

  bool signs_press_yes = false;
  bool signs_press_no = false;
  String signs_press_text = 'Follow';

  bool _isInAsyncCall = true;

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();
    seller_Id = sharedPreferences.getString('seller_id');
    user_id = sharedPreferences.getString('user_id');
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    date = formatter.format(now);

    getFollowingData();
  }

  getFollowingData() async {
    // folloeList = new List();
    CollectionReference ref = Firestore.instance.collection('follow');
    QuerySnapshot eventsQuery =
        await ref.where("following_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
        });
      }
    } else {
      eventsQuery.documents.forEach((doc) async {
        var follower_id = doc['follower_id'];
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
          setState(() {
            _isInAsyncCall = false;
          });
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
            } else {}
            if (this.mounted) {
              setState(() {
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
    noteSub?.cancel();
    super.dispose();
  }

  Widget _gridViewMobile({@required Orientation orientation}) {
    return GridView.count(
      crossAxisCount: orientation == Orientation.portrait ? 1 : 1,
      padding: const EdgeInsets.all(2.0),
      childAspectRatio: orientation == Orientation.portrait ? 1.5 : 0.8,
      children: Seller_following_list.map(
        (Login_Modle) => User_Following1(
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
        (Login_Modle) => User_Following1(
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
    /*   body: ModalProgressHUD(
        child:  ListView.builder(
            itemCount: Seller_following_list.length,
            itemBuilder: (context, position) {
              return GestureDetector(
                child: Card(
                    elevation: 2.0,
                    child:Column(

                        children: <Widget>[
                          Container(
                            height: 100.0,
                            color: Colors.white,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[

                                  Expanded(
                                    flex: 3,
                                    child:  new GestureDetector(

                                        child: Seller_following_list[position].Profile_picture == ""
                                            ?  new Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[

                                              new Container(
                                                height: 70.0,
                                                width:70.0,
                                                margin: EdgeInsets.only(left: 10.0,top: 10),
                                                decoration: new BoxDecoration(


                                                  border: Border.all(color: Colors.black54, width: 2.0),
                                                  borderRadius: new BorderRadius.all(
                                                      const Radius.circular(70.0)),
                                                ),
                                                child: new CircleAvatar(
                                                  radius: 60.0,
                                                  backgroundColor: Colors.white,
                                                  backgroundImage: AssetImage('images/placeholder_face.png'),
                                                ),
                                              )
                                            ]
                                        )
                                            : new Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            new Container(
                                              alignment: Alignment.topLeft,
                                              height: 70.0,
                                              width: 70.0,
                                              margin: EdgeInsets.only(left: 10.0,top: 10),
                                              decoration: new BoxDecoration(
                                                border:
                                                Border.all(color: Colors.black54, width: 2.0),
                                                borderRadius: new BorderRadius.all(
                                                    const Radius.circular(70.0)),
                                              ),
                                              child: new CircleAvatar(
                                                radius: 60.0,
                                                backgroundColor: Colors.white,
                                                backgroundImage: NetworkImage(Seller_following_list[position].Profile_picture),
                                              ),
                                            ),
                                            */ /* new Center(
                        //  child: new Image.asset("assets/photo_camera.png"),
                        child: Icon(Icons.perm_identity),
                      ),*/ /*
                                          ],
                                        )
                                    ), ),

                                  Expanded(

                                    flex: 7,

                                    child: Column(

                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[



                                        Container(
                                            margin: EdgeInsets.only(top: 20.0, left: 5.0),
                                            alignment: Alignment.topLeft,
                                            child: Text(Seller_following_list[position].Name,
                                              style: TextStyle(fontSize: 17.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black), maxLines: 1,)
                                        ),

                                        Container(
                                          alignment: Alignment.topLeft,
                                          margin: EdgeInsets.only(top: 3.0, left: 5.0),
                                          child: Text(Seller_following_list[position].Country,
                                            style: TextStyle(fontSize: 15.0,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black), maxLines: 1,),
                                        ),



                                      ],
                                    ),

                                  ),


                                ]),
                          ),
                          Container(
                              padding: const EdgeInsets.all(8.0),

                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 10,
                                    child: Button(position),
                                  )
                                ],
                              )
                          )

                        ]
                    )


                ),
                onTap: null,
              );
            }
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.7,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),

    );
*/
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
          'No Following',
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
                folloeList[position].Key,
                folloeList[position].Follower_id,
                Seller_following_list[position].Device_id,
                folloeList[position].Following_id,
                Seller_following_list[position].Followers);
          });
    }
  }

  getFollowing(String id, String following_idd, String device_id,
      String follower_idd, String followerr) async {
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

          var idd = {'status': '0'};
          var fo = Firestore.instance;
          fo.collection("follow").document(id).updateData(idd).then((val) {
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

//            var idd = {'status': '1'};
//            var fo = Firestore.instance;
//            fo
//                .collection("follow")
//                .document(id)
//                .updateData(idd)
//                .then((val) {
//              setState(() {
//                signs_press_no = true;
//              });

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

//    Firestore.instance
//        .collection('follow')
//        .where("follower_id", isEqualTo: following_idd)
//        .snapshots()
//        .listen((data) {
//      data.documents.forEach((doc) async {
//        db.Unfollowing(doc["id"]).then((_) {
//          setState(() {
//            UpdateSubInfo();
//            Navigator.pop(context);
//          });
//        });
//      });
//    }, onDone: () {
//      print("Task Done");
//    }, onError: (error) {
//      print("Some Error");
//    });
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

  void UpdateAddInfo() {
    following = sharedPreferences.getString('following');
    followers = sharedPreferences.getString('followers');

    var value = int.tryParse(following);
    value = value + 1;
    following = value.toString();
    db
        .updateSignupData(Signup_Modle(
            user_id,
            username,
            password,
            Name,
            "0",
            profile_image,
            "120.002",
            followers,
            following,
            facebook_id,
            email_id,
            device_id,
            "0",
            cover_picture,
            country,
            about_me,
            refer_code))
        .then((_) async {
      sharedPreferences = await SharedPreferences.getInstance();

      sharedPreferences.setString('followers', followers);
      sharedPreferences.setString('following', following);

      //  SellerUpdateAddInfo();
      setState(() {
        _isInAsyncCall = false;
      });
    });
  }

  Future UpdateSubInfo() async {
    setState(() {
      _isInAsyncCall = true;
    });
    sharedPreferences = await SharedPreferences.getInstance();
    following = sharedPreferences.getString('following');
    followers = sharedPreferences.getString('followers');

    var value = int.tryParse(followers);
    value = value - 1;
    followers = value.toString();
    db
        .updateSignupData(Signup_Modle(
            user_id,
            username,
            password,
            Name,
            "0",
            profile_image,
            "120.002",
            followers,
            following,
            facebook_id,
            email_id,
            device_id,
            "0",
            cover_picture,
            country,
            about_me,
            refer_code))
        .then((_) async {
      sharedPreferences = await SharedPreferences.getInstance();

      sharedPreferences.setString('followers', followers);
      sharedPreferences.setString('following', following);

      //SellerUpdateSubInfo();

      setState(() {
        _isInAsyncCall = false;
      });
    });
  }
}

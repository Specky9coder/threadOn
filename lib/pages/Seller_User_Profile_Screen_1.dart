import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Follow.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/ChatMessage.dart';
import 'package:threadon/pages/Coman_SearchList_Screen.dart';
import 'package:threadon/pages/Message_Screen.dart';

import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/tab_screen/Seller_Followers_Tab.dart';
import 'package:threadon/tab_screen/Seller_Following_Tab.dart';
import 'package:threadon/tab_screen/Seller_Items_Tab.dart';
import 'package:threadon/tab_screen/Seller_Sold_Tab.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class Seller_Profile_screen extends StatefulWidget {
  String appbar_name;
  String profile;
  final notesReference = FirebaseDatabase.instance.reference().child('follow');

  Seller_Profile_screen({Key key, this.appbar_name, this.profile})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      seller_profile_screen(appbar_name, profile);
}

class seller_profile_screen extends State<Seller_Profile_screen>
    with SingleTickerProviderStateMixin {
  String tool_name1;
  TabController tabController;

  List<Shell_Product_Model> item_list;
  List<FollowModel> folloeList;
  List<Shell_Product_Model> final_item_list = new List<Shell_Product_Model>();
  List<Shell_Product_Model> sold_final_item_list =
      new List<Shell_Product_Model>();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;

  String profileImage;

  seller_profile_screen(this.tool_name1, this.profileImage);

  bool signs_press_yes = false;
  bool signs_press_no = false;
  String signs_press_text = 'Follow';

  final postUrl = 'https://fcm.googleapis.com/fcm/send';
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
      Seller_refer_code = "";

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
      refer_code = "";
  TabController controller;
  bool _isInAsyncCall = false;

  String date = "";
  String Follow_id = '';
  String Following_id = '';

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();
    seller_Id = sharedPreferences.getString('seller_id');
    Follow_id = sharedPreferences.getString('seller_id');
    Following_id = sharedPreferences.getString('user_id');
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    date = formatter.format(now);
    user_id = sharedPreferences.getString('user_id');

    CollectionReference ref = Firestore.instance.collection('users');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
    } else {
      eventsQuery.documents.forEach((doc) async {
        sharedPreferences = await SharedPreferences.getInstance();

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

        getsellerdata();
      });
    }
  }

  getsellerdata() async {
    // Seller_followers = "";

    Firestore.instance
        .collection('users')
        .where("user_id", isEqualTo: seller_Id)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) async {
        if (this.mounted) {
          setState(() {
            Seller_profile_image = doc["profile_picture"];
            Seller_Name = doc['name'];
            Seller_cover_picture = doc['cover_picture'];
            Seller_followers = doc['followers'].toString();
            Seller_following = doc['following'].toString();
            Seller_about_me = doc['about_me'];
            Seller_country = doc['country'];
            Seller_device_id = doc['token_id'];
            Seller_email_id = doc['email_id'];
            Seller_facebook_id = doc['facebook_id'];
            Seller_password = doc['password'];
            Seller_username = doc['username'];
            Seller_refer_code = doc['refer_code'];
          });
        }
      });
    }, onDone: () {
      print("Task Done");
    }, onError: (error) {
      print("Some Error");
    });
  }

  getFollowing() async {
    if (signs_press_no == false) {
      setState(() {
        _isInAsyncCall = true;
      });
      //   makeCall();

      var db = Firestore.instance;
      db.collection("follow").add({
        "date": DateTime.now(),
        "follower_id": Follow_id,
        "following_id": Following_id,
        "id": '',
        "status": '1',
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
            sharedPreferences = await SharedPreferences.getInstance();
            //   sharedPreferences.setString('followers', followers);
            // sharedPreferences.setString('following', following);

            var value = int.tryParse(Seller_followers);
            value = value + 1;
            Seller_followers = value.toString();

            var up1 = {'followers': Seller_followers};
            var db = Firestore.instance;
            db
                .collection("users")
                .document(seller_Id)
                .updateData(up1)
                .then((val) {
              print("sucess");
              makeCall();

              setState(() {
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

      CollectionReference ref = Firestore.instance.collection('follow');
      QuerySnapshot eventsQuery = await ref
          .where("following_id", isEqualTo: Following_id)
          .where("follower_id", isEqualTo: seller_Id)
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
            //following = sharedPreferences.getString('following');
            //followers = sharedPreferences.getString('followers');

            var value = int.tryParse(following);
            value = value - 1;
            following = value.toString();

            var sub_follow = {'following': following};
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
                  .document(seller_Id)
                  .updateData(sub_follow1)
                  .then((val) {
                setState(() {
                  signs_press_no = false;
                });
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
//
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          wifiName = await _connectivity.getWifiName();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          wifiBSSID = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _connectionStatus = '$result\n'
              'Wifi Name: $wifiName\n'
              'Wifi BSSID: $wifiBSSID\n'
              'Wifi IP: $wifiIP\n';
        });
        break;
      case ConnectivityResult.mobile:
        break;
      case ConnectivityResult.none:
        setState(() {
          _showDialog1();
        });
        break;
      default:
        break;
    }
  }

  void _showDialog1() {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("No Internet connection"),
          content: new Text(
              "We can\'t reach our network right now. Please check your connection."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog

            new FlatButton(
              child: new Text("Retry"),
              onPressed: () {
                setState(() {
                  initConnectivity();
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    getCredential();

    item_list = new List();

    noteSub?.cancel();
    noteSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Shell_Product_Model> notes = snapshot.documents
          .map((documentSnapshot) =>
              Shell_Product_Model.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        for (int i = 0; i < notes.length; i++) {
          if (seller_Id == notes[i].user_id) {
            if (notes[i].status == "0") {
              final_item_list.add(Shell_Product_Model(
                notes[i].any_sign_wear,
                notes[i].category,
                notes[i].category_id,
                notes[i].country,
                notes[i].date,
                notes[i].favourite_count,
                notes[i].is_cart,
                notes[i].is_favorite_count,
                notes[i].item_Ounces,
                notes[i].item_brand,
                notes[i].item_color,
                notes[i].item_description,
                notes[i].item_measurements,
                notes[i].item_picture,
                notes[i].item_pound,
                notes[i].item_price,
                notes[i].item_sale_price,
                notes[i].item_size,
                notes[i].item_sold,
                notes[i].item_sub_title,
                notes[i].item_title,
                notes[i].item_type,
                notes[i].packing_type,
                notes[i].picture,
                notes[i].product_id,
                notes[i].retail_tag,
                notes[i].shipping_charge,
                notes[i].shipping_id,
                notes[i].status,
                notes[i].sub_category,
                notes[i].sub_category_id,
                notes[i].user_id,
                notes[i].tracking_id,
                notes[i].order_id,
                notes[i].brand_new,
              ));
            } else if (notes[i].status == "2") {
              sold_final_item_list.add(Shell_Product_Model(
                notes[i].any_sign_wear,
                notes[i].category,
                notes[i].category_id,
                notes[i].country,
                notes[i].date,
                notes[i].favourite_count,
                notes[i].is_cart,
                notes[i].is_favorite_count,
                notes[i].item_Ounces,
                notes[i].item_brand,
                notes[i].item_color,
                notes[i].item_description,
                notes[i].item_measurements,
                notes[i].item_picture,
                notes[i].item_pound,
                notes[i].item_price,
                notes[i].item_sale_price,
                notes[i].item_size,
                notes[i].item_sold,
                notes[i].item_sub_title,
                notes[i].item_title,
                notes[i].item_type,
                notes[i].packing_type,
                notes[i].picture,
                notes[i].product_id,
                notes[i].retail_tag,
                notes[i].shipping_charge,
                notes[i].shipping_id,
                notes[i].status,
                notes[i].sub_category,
                notes[i].sub_category_id,
                notes[i].user_id,
                notes[i].tracking_id,
                notes[i].order_id,
                notes[i].brand_new,
              ));
            }
          }
        }
        tabController = new TabController(length: 4, vsync: this);
        this.item_list = final_item_list;
        this.sold_final_item_list = sold_final_item_list;
      });
    });

    noteSub = db.getFollwList().listen((QuerySnapshot snapshot) {
      folloeList = snapshot.documents
          .map((documentSnapshot) => FollowModel.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        for (int j = 0; j < folloeList.length; j++) {
          if (Follow_id == folloeList[j].Follower_id) {
            if (Following_id == folloeList[j].Following_id) {
              signs_press_text = "Following";
              signs_press_no = true;
            }
          }
        }
        _isInAsyncCall = false;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
    super.dispose();
  }

  Widget _getHomeContainer() {
    return new Column(
      children: <Widget>[
        new Expanded(
          child: new Container(),
        ),
        _getTextContainer()
      ],
    );
  }

  Widget _getTextContainer() {
    return new Container(
        padding: new EdgeInsets.only(bottom: 24.0, top: 40.0),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 40.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 80.0,
                    width: 80.0,
                    child: CircleAvatar(
                        backgroundImage: NetworkImage(Seller_profile_image)),
                  ),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: new Text(
                      Seller_Name != null ? Seller_Name : '',
                      maxLines: 1,
                      style: new TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ))
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: new Padding(
                padding:
                    new EdgeInsets.symmetric(vertical: 40.0, horizontal: 10.0),
                child: new Row(
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Container(
                        child: new RaisedButton(
                            padding: const EdgeInsets.all(8.0),
                            child: new Text("Message"),
                            textColor: Colors.black,
                            color: Colors.white,
                            onPressed: () {
                              if (Following_id == null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignupPage()));
                              } else {
                                sharedPreferences.setString(
                                    'user_id1', user_id);
                                sharedPreferences.setString(
                                    'Seller_device_id', Seller_device_id);
                                sharedPreferences.setString(
                                    'seller_id1', seller_Id);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Messages_Screnn(Seller_Name)));
                                setState(() {});
                              }
                            },
                            shape: new RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black))),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: EdgeInsets.only(left: 5.0),
                        child: new RaisedButton(
                            padding: const EdgeInsets.all(8.0),
                            child: new Text(
                              signs_press_no ? 'Following' : 'Follow',
                              textAlign: TextAlign.center,
                            ),
                            textColor:
                                signs_press_no ? Colors.white : Colors.black,
                            color: signs_press_no ? Colors.black : Colors.white,
                            shape: new RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black)),
                            onPressed: () async {
                              if (Following_id == null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignupPage()));
                              } else {
                                getFollowing();
                              }
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        alignment: Alignment.bottomLeft);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    double width12 = width;

    return Scaffold(
        body: ModalProgressHUD(
      child: DefaultTabController(
          child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                      elevation: 0.0,
                      backgroundColor: Colors.white,
                      expandedHeight: 280.0,
                      pinned: true,
                      actions: <Widget>[
                        new IconButton(
                            icon: new Icon(Icons.search),
                            tooltip: 'Search product',
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Coman_SearchList()));
                            }),
                        new IconButton(
                            icon: new Icon(Icons.local_offer),
                            tooltip: 'Add Product',
                            onPressed: () {
                              if (Following_id == null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignupPage()));
                              } else {
                                MyNavigator.gotoAddItemScreen(context);
                              }
                            }),
                        IconButton(
                          icon: new Icon(Icons.chat_bubble_outline),
                          tooltip: 'MessageList',
                          onPressed: () {
                            if (Following_id == null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignupPage()));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatMessageList()));
                            }
                          },
                        ),
                        new IconButton(
                          icon: new Icon(Icons.perm_identity),
                          tooltip: 'Me',
                          onPressed: () => MyNavigator.goToProfile(context),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        title: Text("",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 1.0,
                            )),
                        background: Stack(
                          fit: StackFit.passthrough,
                          children: <Widget>[
                            new Image.network(Seller_cover_picture,
                                fit: BoxFit.cover,
                                alignment: new AlignmentDirectional(0.2, 0.0)),
                            Container(
                              decoration:
                                  new BoxDecoration(color: Colors.white54),
                            ),
                            _getHomeContainer()
                          ],
                        ),
                      ),
                      bottom: PreferredSize(
                        child: TabBar(
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.black54,
                          isScrollable: true,

                          tabs: [
                            new Tab(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    item_list.length.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17.0),
                                  ),
                                  Text(
                                    'ITEMS',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13.0),
                                  ),
                                ],
                              ),
                              // set icon to the tab
                            ),
                            new Tab(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    sold_final_item_list.length.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17.0),
                                  ),
                                  Text(
                                    'SOLD',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13.0),
                                  ),
                                ],
                              ),
                              // set icon to the tab
                            ),
                            new Tab(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    Seller_followers,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17.0),
                                  ),
                                  Text(
                                    'FOLLOWERS',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13.0),
                                  ),
                                ],

                                // set icon to the tab
                              ),
                            ),
                            new Tab(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    Seller_following,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17.0),
                                  ),
                                  Text(
                                    'FOLLOWING',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13.0),
                                  ),
                                ],
                              ),
                              // set icon to the tab
                            ),
                          ],
                          // setup the controller
                          controller: tabController,
                        ),
                        preferredSize: Size.fromHeight(50.0),
                      )),
                ];
              },
              body: getTabBarView(<Widget>[
                new Seller_Items_Tab(),
                new Seller_Sold_Tab(),
                new Seller_Followers_Tab(),
                new Seller_Following_Tab()
              ])),
          length: 4),
      inAsyncCall: _isInAsyncCall,
      opacity: 0.7,
      color: Colors.white,
      progressIndicator: CircularProgressIndicator(),
    ));
  }

  TabBarView getTabBarView(var tabs) {
    return new TabBarView(
      // Add tabs as widgets
      children: tabs,
      // set the controller
      controller: tabController,
    );
  }

  Future<bool> makeCall() async {
    final data = {
      "notification": {"body": Name + " followed you", "title": "Follow"},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default",
        "id": "1",
        "status": "done",
        "nt": "1",
      },
      "to": Seller_device_id
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

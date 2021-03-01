import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Cart.dart';
import 'package:threadon/model/Product.dart';
import 'package:threadon/model/Share.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/Compare_screen.dart';
import 'package:threadon/pages/GridItemDetails.dart';
import 'package:threadon/pages/main_screen.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/pages/splesh_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:flutter/services.dart';

class ItemList extends StatefulWidget {
  final Shell_Product_Model item;

  const ItemList({@required this.item});

  @override
  State<StatefulWidget> createState() => new itemlist(item);
// TODO: implement createState
}

class itemlist extends State<ItemList> {
  final Shell_Product_Model item;
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  bool _isInAsyncCall = false;
  List<String> favlist_id = new List();
  List<String> favid = new List();

  itemlist(this.item);

  String user_id = '', Share_id = '';
  final myController = TextEditingController();
  List<Share> shareList;
  List<Share> shareList1 = new List();
  bool favourite = false;
  String Flag1 = "", productId = "";
  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  List share_product_id;

/*------------------------------------------favourite--------------------------------------*/
  bool _isFavorited = false;
  int _favoriteCount = 1;

  Future getData() async {
    CollectionReference ref = Firestore.instance.collection('favourite_item');
    QuerySnapshot eventsQuery = await ref
        .where("product_id", isEqualTo: item.product_id)
        .where("user_id", isEqualTo: user_id)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      /* DateTime date = DateTime.now();
        String datea = date.toString();
        noteSub?.cancel();
        db.cartItem('', productid, '0', userId, datea).then((_) {
          geetcart();
        });
        sharedPreferences.setString('pid', '');*/
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
          return favourite = false;
        });
      }
    } else {
      eventsQuery.documents.forEach((doc) async {
        favlist_id.add(doc['favourite_id']);
        return favourite = true;

        _isInAsyncCall = false;
      });
    }
    if (this.mounted) {
      setState(() {
        _isInAsyncCall = false;
        // _isInAsyncCall = false;
      });
    }
  }

  Future getfavProduct(String pid) async {
    CollectionReference ref = Firestore.instance.collection('favourite_item');
    QuerySnapshot eventsQuery = await ref
        .where("product_id", isEqualTo: pid)
        .where("user_id", isEqualTo: user_id)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      /* DateTime date = DateTime.now();
        String datea = date.toString();
        noteSub?.cancel();
        db.cartItem('', productid, '0', userId, datea).then((_) {
          geetcart();
        });
        sharedPreferences.setString('pid', '');*/
      setState(() {
        _isInAsyncCall = false;
        return favourite = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        favid.add(doc['favourite_id']);
        return favourite = true;

        _isInAsyncCall = false;
      });
    }
    setState(() {
      _isInAsyncCall = false;
      // _isInAsyncCall = false;
    });
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
  }

  Future _openAddUserDialog(String id) async {
    shareList = new List();
    shareList1.clear();
    AlertDialog dialog;

    CollectionReference ref = Firestore.instance.collection('share_list');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
    } else {
      eventsQuery.documents.forEach((doc) async {
        shareList.add(Share(
            doc['share_id'],
            doc['user_id'],
            doc['date'].toDate(),
            doc['share_list_name'],
            doc['share_product_id']));

        _isInAsyncCall = false;
      });
    }
    setState(() {
      this.shareList1 = shareList;
    });

    dialog = new AlertDialog(
      content: new Container(
        width: 260.0,
        height: 300.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            new Expanded(
              child: new Row(
                children: <Widget>[
                  new Container(
                    // padding: new EdgeInsets.all(10.0),
                    decoration: new BoxDecoration(
                      color: Colors.white,
                    ),
                    child: new Text(
                      'Add Item to your',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            Container(
                child: Card(
              elevation: 4.0,
              shape: new RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black)),
//                  color: Colors.black,
              child: FlatButton.icon(
                onPressed: () => (setState(() {
                  if (user_id == null) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignupPage()));
                  } else {
                    if (favourite) {
                      id = favid[0].toString();
                      unfavouritesubmit(id);
                    } else {
                      favourite = true;
                      favouritesubmit();
                    }
                  }
                })),
                icon: favourite
                    ? new Icon(Icons.favorite)
                    : new Icon(
                        Icons.favorite_border,
                      ),
//                    icon: Icon(Icons.favorite_border, color: Colors.black,),
                label: Text(
                  'Favorite',
                  style: TextStyle(color: Colors.black, fontSize: 17.0),
                ),
              ),
            )),

            Container(
              height: 150,
              child: ListView.builder(
                itemCount: shareList.length,
                itemBuilder: (context, position) {
                  return GestureDetector(
                      child: Container(
                        margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                        height: 50.0,
                        alignment: Alignment.centerRight,
                        color: Colors.white,
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Text(
                                '${shareList[position].share_list_name}',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black87),
                                maxLines: 1,
                              ),
                            ),
                            new Divider(color: Colors.black26),
                          ],
                        ),
                        // photo and title
                      ),
                      onTap: () async {
                        Share_id = '${shareList[position].share_id}';
                        submit(Share_id);
                      });
                },
              ),
            ),

            Container(
                child: Card(
              elevation: 4.0,
              shape: new RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black)),
              color: Colors.black,
              child: FlatButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openAddUserDialog1();
                },
                icon: Icon(null),
                label: Text(
                  'Add new Share List',
                  style: TextStyle(color: Colors.white, fontSize: 14.0),
                ),
              ),
            )),
          ],
        ),
      ),
    );
    showDialog(context: context, child: dialog);
  }

  void _openAddUserDialog1() {
    AlertDialog dialog = new AlertDialog(
      content: ModalProgressHUD(
        child: new Container(
          width: 260.0,
          height: 250.0,
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            color: const Color(0xFFFFFF),
            borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
          ),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // dialog top
              new Expanded(
                child: new Row(
                  children: <Widget>[
                    new Container(
                      // padding: new EdgeInsets.all(10.0),
                      decoration: new BoxDecoration(
                        color: Colors.white,
                      ),
                      child: new Text(
                        'Name of Share List',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 50.0),
                child: new TextFormField(
                  controller: myController,
                  decoration: new InputDecoration(
                    hintText: 'Add name',
                  ),
                ),
              ),

              Container(
                  child: Card(
                elevation: 4.0,
                shape: new RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black)),
                color: Colors.black,
                child: FlatButton.icon(
                  onPressed: () => handleSubmit(),
                  icon: Icon(null),
                  label: Text(
                    'Add Item to new Share List',
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ),
              )),
            ],
          ),
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.5,
        color: Colors.black,
        progressIndicator: CircularProgressIndicator(),
      ),
    );

    showDialog(context: context, child: dialog);
  }

  void favouritesubmit() async {
    setState(() {
      _isInAsyncCall = true;
    });

    noteSub?.cancel();

    var db = Firestore.instance;
    db.collection("favourite_item").add({
      "date": DateTime.now(),
      "favourite_name": item.item_title,
      "product_id": item.product_id,
      "status": "1",
      "user_id": user_id,
    }).then((val) {
      var docId = val.documentID;
      var updateId = {"favourite_id": docId};

      db
          .collection("favourite_item")
          .document(docId)
          .updateData(updateId)
          .then((val) async {
        CollectionReference ref = Firestore.instance.collection('product');
        QuerySnapshot eventsQuery = await ref
            .where("product_id", isEqualTo: item.product_id)
            .getDocuments();

        if (eventsQuery.documents.isEmpty) {
        } else {
          eventsQuery.documents.forEach((doc) async {
            String docId = doc['product_id'];
            String is_fav_count = doc['is_favorite_count'];

            var is_favorite_count = int.tryParse(is_fav_count);

            var total_favorite_count = is_favorite_count + 1;

            var up1 = {'is_favorite_count': total_favorite_count.toString()};

            db
                .collection("product")
                .document(docId)
                .updateData(up1)
                .then((val) {
              setState(() {
                _isInAsyncCall = false;
              });
              Navigator.of(context).pop();
              print("sucess");
            }).catchError((err) {
              print(err);
              _isInAsyncCall = false;
            });
          });
        }

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
  }

  handleSubmit() async {
    String submit = myController.text;
    setState(() {
      _isInAsyncCall = true;
    });

    noteSub?.cancel();
    db
        .createShareList('', user_id, DateTime.now(), submit, share_product_id)
        .then((_) {
      setState(() {
        _isInAsyncCall = false;
      });

      Navigator.of(context).pop();
      _openAddUserDialog('');
    });
  }

  /*----------------------------------------submit-------------------------------*/

  /*----------------------------------------submit-------------------------------*/

  submit(String Share_id) async {
    CollectionReference ref = Firestore.instance.collection('share_list');
    QuerySnapshot eventsQuery =
        await ref.where('share_id', isEqualTo: Share_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        share_product_id = doc['share_product_id'].toList();

        if (share_product_id.contains(item.product_id)) {
        } else {
          var db1 = Firestore.instance;
          share_product_id.add(item.product_id);
          var update = {'share_product_id': share_product_id};

          db1
              .collection("share_list")
              .document(Share_id)
              .updateData(update)
              .then((val) {
            Navigator.pop(context);
            share_product_id.clear();
            setState(() {
              _isInAsyncCall = false;
              showInSnackBar('product successfully add to share list.');
            });

            print("sucess");
          }).catchError((err) {
            print(err);
            _isInAsyncCall = false;
          });
        }

        //userList1.add(Login_Modle(doc['user_id'], doc['username'], doc['password'], doc['name'], doc['status'], doc['profile_picture'], doc['latlong'].toString(), doc['following'],doc['followers'],doc['facebook_id'] , doc['device_id'], doc['device_id'], doc['device'], doc['cover_picture'], doc['country'], doc['about_me'], doc['refer_code'],doc['token_id']));
      });
    }
  }

  void showInSnackBar(String value) {
    _scaffold.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = sharedPreferences.getString("user_id");
      Flag1 = sharedPreferences.getString('flag1');
      productId = sharedPreferences.getString('pid');

      setState(() {
        getData();
      });
    });
  }

  void unfavouritesubmit(String fav_id) async {
    favid = new List();
    setState(() {
      _isInAsyncCall = true;
    });
    CollectionReference ref = Firestore.instance.collection('product');
    QuerySnapshot eventsQuery = await ref
        .where("product_id", isEqualTo: item.product_id)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
    } else {
      eventsQuery.documents.forEach((doc) async {
        String docId = doc['product_id'];
        String is_fav_count = doc['is_favorite_count'];

        var is_favorite_count = int.tryParse(is_fav_count);

        var total_favorite_count = is_favorite_count - 1;

        var up1 = {'is_favorite_count': total_favorite_count.toString()};

        var db1 = Firestore.instance;
        db1.collection("product").document(docId).updateData(up1).then((val) {
          db.deleteFavorit(fav_id).then((Favorite) async {
            setState(() {
              Navigator.of(context)
                  .pop(); // here I pop to avoid multiple Dialogs
              //here i call the same function

              setState(() {
                favourite = false;
                _isInAsyncCall = false;
              });
            });
          });
          print("sucess");
        }).catchError((err) {
          print(err);
          _isInAsyncCall = false;
        });
      });
    }
  }

  void _showDialog(String msg) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      body: ModalProgressHUD(
        child: Container(
            child: Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      child: Container(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: favourite
                              ? new Icon(Icons.favorite)
                              : new Icon(
                                  Icons.favorite_border,
                                ),
                          onPressed: () {
                            getfavProduct(item.product_id);
                            if (user_id == null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignupPage()));
                            } else {
                              String id = "";
                              if (favlist_id.length == 0) {
                                _openAddUserDialog(id);
                              } else {
                                id = favlist_id[0].toString();
                                _openAddUserDialog(id);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            AspectRatio(
                              aspectRatio: 16.0 / 11.0,
                              child: FadeInImage.assetNetwork(
                                placeholder: 'images/tonlogo.png',
                                image: item.picture,
                                width: 100.0,
                                height: 100.0,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                            new Padding(
                              padding:
                                  EdgeInsets.fromLTRB(10.0, 10.0, 4.0, 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Container(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      item.item_title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  new Container(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      item.category,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 0.0),
//                  GetRatings(),
                                  SizedBox(height: 2.0),

                                  new Container(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      '\$' + item.item_price,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 0.0),
//                  GetRatings(),
                                  SizedBox(height: 2.0),

                                  new Container(
                                      child: Text(
                                    item.item_size,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (Flag1 == "0") {
                          if (productId == item.product_id) {
                            _showDialog('This product is selected to compare.');
                          } else {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Compare_screen(item: item)));
                          }
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GridItemDetails(item: item),
                            ),
                          );
                        }
                      },
                    )
                  ],
                ))),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.7,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }
}

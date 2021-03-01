import 'dart:async';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Editor.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/GridItemDetails.dart';
import 'package:threadon/pages/departments_screen1.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/my_navigator.dart';

class ImageCarousel extends StatefulWidget {
  static String tag = 'slider';

  _ImageCarouselState createState() => new _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  List<Editor_Model> notes1;
  List<Editor_Model> editorList;
  List<Shell_Product_Model> productList1 = new List<Shell_Product_Model>();

  List<Shell_Product_Model> p = new List<Shell_Product_Model>();
  SharedPreferences prf;
  String user_id = '';
  bool _isInAsyncCall = false;

  /* final List<String> imgList = [
    'https://newsd.in/wp-content/uploads/2018/11/shopping-2.jpg',
    'https://www.homeappliancesworld.com/files/2018/11/holiday-shopping1.jpg',
    'https://moadrupalweb.blob.core.windows.net/moadrupalweb/processed/9111_shopping-hero-first_card_1-small.jpg',
    'https://cdnwp.mobidea.com/academy/wp-content/uploads/2018/12/ecommerce-sites-shopping-abandonment-760x428.jpg',
  ];*/

  initState() {
    super.initState();

    setState(() {
      _isInAsyncCall = true;
    });
    controller = new AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animation = new Tween(begin: 0.0, end: 18.0).animate(controller)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
    controller.forward();

//    noteSub?.cancel();
//      noteSub = db.getEditorList().listen((QuerySnapshot snapshot) {
//        notes1 = snapshot.documents
//            .map((documentSnapshot) =>
//            Editor_Model.fromMap(documentSnapshot.data))
//            .toList();
//        setState(() {
//          this.editorList = notes1;
//        });
//      });
    getProduct();
  }

  getProduct() async {
    // await Firestore.instance.settings(timestampsInSnapshotsEnabled: true);
    prf = await SharedPreferences.getInstance();
    productList1 = new List<Shell_Product_Model>();

    user_id = prf.getString('user_id');
    editorList = new List();

    Firestore.instance
        .collection('product')
        .orderBy("date", descending: true)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) async {
        if (this.mounted) {
          setState(() {
            if (doc["status"] == "0") {
              if (doc['user_id'] != user_id) {
                productList1.add(Shell_Product_Model(
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
              }
            }
          });
        }
      });

      setState(() {
        // _isInAsyncCall = false;
        productList1 = this.productList1;
        getEditorProduct();
      });
    }, onDone: () {
      setState(() {
        _isInAsyncCall = false;
      });
      print("Task Done");
    }, onError: (error) {
      setState(() {
        _isInAsyncCall = false;
      });
      print("Some Error");
    });
  }

  getEditorProduct() {
    Firestore.instance
        .collection('editor_product')
        .where('status', isEqualTo: "0")
        .orderBy("date", descending: true)
        .limit(3)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) async {
        setState(() {
          editorList.add(Editor_Model(
              doc['date'].toDate(),
              doc['editor_id'],
              doc['editor_name'],
              doc['featured_image'],
              doc['product_id'],
              doc['status']));
        });
      });

      setState(() {
        _isInAsyncCall = false;
        editorList = this.editorList;
      });
    }, onDone: () {
      setState(() {
        _isInAsyncCall = false;
      });
      print("Task Done");
    }, onError: (error) {
      setState(() {
        _isInAsyncCall = false;
      });
      print("Some Error");
    });
  }

  _buildMainContent() {
    return CustomScrollView(
      slivers: <Widget>[
        /* SliverAppBar(
          pinned: true,
          expandedHeight: 0.0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text('Title'),
          ),
        ),*/
        SliverList(
          delegate: SliverChildListDelegate([
            getFullScreenCarousel(context),
            new Divider(
              color: Colors.white,
              height: 20.0,
            ),
            _buildListItem(),
            /* new Padding(padding: EdgeInsets.symmetric(horizontal: 2,vertical: 10),child:  new Container(
              child: Text('Editor\'s Picks',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17.0),),
            ),),*/
          ]),
        )
      ],
    );
  }

  Widget _buildListItem() {
    double width = MediaQuery.of(context).size.width;
    double width12 = width;
    return Column(
      children: <Widget>[
        ListView.builder(
          padding: EdgeInsets.only(top: 0.0),
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 0.0,
                vertical: 1.0,
              ),
              child: GestureDetector(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
//                        AspectRatio(
//                          aspectRatio: 16.0 / 11.0,

                        FadeInImage.assetNetwork(
                          placeholder: 'assets/image_pro1.gif',
                          image: '${productList1[index].picture}',
                          height: 200.0,
                          fit: BoxFit.scaleDown,
                        ),
//                        ),
                        new Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 10.0, 4.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Container(
                                margin:
                                    const EdgeInsets.only(top: 15, bottom: 8.0),
                                padding:
                                    EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                                child: Text(
                                  '${productList1[index].item_title}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.0),
                              Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 0.0, 10.0, 10.0),
                                  alignment: Alignment.center,
                                  child: new Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        new RichText(
                                          textAlign: TextAlign.center,
                                          text: new TextSpan(
                                            text: '\$' +
                                                productList1[index]
                                                    .item_sale_price,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        new Padding(
                                            padding:
                                                EdgeInsets.only(left: 10.0)),
                                        new RichText(
                                          textAlign: TextAlign.center,
                                          text: new TextSpan(
                                            text: '\$' +
                                                productList1[index].item_price,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.lineThrough),
                                          ),
                                        ),
                                      ])),
                              new Container(
                                margin: const EdgeInsets.only(bottom: 20.0),
                                child: Text(
                                  '${productList1[index].item_brand}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              new Container(
                                margin:
                                    const EdgeInsets.only(top: 5, bottom: 20.0),
                                child: Divider(color: Colors.black26),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                GridItemDetails(item: productList1[index])));
                  }),
            );
          },
          itemCount: productList1.length,
          shrinkWrap: true,
          // todo comment this out and check the result
          physics:
              ClampingScrollPhysics(), // todo comment this out and check the result
        ),
      ],
    );
  }

  getFullScreenCarousel(BuildContext mediaContext) {
    final double shortTestsize = MediaQuery.of(context).size.shortestSide;
    final bool mobilesize = shortTestsize < 600;

    return editorList.length == 0
        ? new Container()
        : mobilesize
            ? CarouselSlider(
                autoPlay: true,
                viewportFraction: 1.0,
                height: 270.0,
                items: editorList.map(
                  (url) {
                    return Container(
                        height: 400.0,
                        child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(0.0)),
                            child: GestureDetector(
                              onTap: () async {
                                SharedPreferences sharedPreferences =
                                    await SharedPreferences.getInstance();
                                sharedPreferences.setStringList('editor_list',
                                    url.product_id.cast<String>());
                                String Cat_name = '${url.editor_name}';
                                // sharedPreferences.setString('cat_name', tool_name);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DepartmentsScreen1(
                                              tool_name: Cat_name,
                                            )));
                              },
                              child: Stack(children: <Widget>[
                                Image.network(
                                  url.featured_image,
                                  fit: BoxFit.cover,
                                  width: 1000,
                                  height: 400.0,
                                ),
                                Container(
                                  color: Colors.black45,
                                ),
                                Center(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 10.0, right: 10.0),
                                      child: Text(
                                        url.editor_name,
                                        style: TextStyle(
                                            fontSize: 30.0,
                                            color: Colors.white),
                                        maxLines: 1,
                                      ),
                                    ),
/*
                              new Container(height: 20.0,),
                              SizedBox(height: 40.0,
                                  width: 130,

                                  child:new RaisedButton(
                                      onPressed: ()async{
                                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                                        sharedPreferences.setStringList('editor_list', url.product_id.cast<String>());
                                        String Cat_name = '${url.editor_name}';
                                        // sharedPreferences.setString('cat_name', tool_name);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => DepartmentsScreen1(
                                                  tool_name: Cat_name,
                                                )));


                                      },
                                      color: Colors.blue,
                                      splashColor: Colors.grey,
                                      shape: new RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.circular(
                                              10.0)),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            "SHOP NOW!",
                                            style: new TextStyle(
                                                color: new Color(0xFFFFFFFF),
                                                fontSize: 14.0),
                                          ),
                                        ],
                                      ))),*/
                                    // Text(url.editor_name,style: TextStyle(fontSize: 30.0,color: Colors.white),maxLines: 2,),
                                  ],
                                ))
                              ]),
                            )));
                  },
                ).toList(),
              )
            : CarouselSlider(
                autoPlay: true,
                viewportFraction: 1.0,
                height: 320.0,
                items: editorList.map(
                  (url) {
                    return Container(
                        height: 400.0,
                        child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(0.0)),
                            child: GestureDetector(
                              onTap: () async {
                                SharedPreferences sharedPreferences =
                                    await SharedPreferences.getInstance();
                                sharedPreferences.setStringList('editor_list',
                                    url.product_id.cast<String>());
                                String Cat_name = '${url.editor_name}';
                                // sharedPreferences.setString('cat_name', tool_name);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DepartmentsScreen1(
                                              tool_name: Cat_name,
                                            )));
                              },
                              child: Stack(children: <Widget>[
                                Image.network(
                                  url.featured_image,
                                  fit: BoxFit.cover,
                                  width: 1000,
                                  height: 400.0,
                                ),
                                Container(
                                  color: Colors.black45,
                                ),
                                Center(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 10.0, right: 10.0),
                                      child: Text(
                                        url.editor_name,
                                        style: TextStyle(
                                            fontSize: 40.0,
                                            color: Colors.white),
                                        maxLines: 1,
                                      ),
                                    ),

                                    /*            new Container(height: 30.0,),
                              SizedBox(height: 50.0,
                                  width: 150,

                                  child:new RaisedButton(
                                      onPressed: ()async{
                                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                                        sharedPreferences.setStringList('editor_list', url.product_id.cast<String>());
                                        String Cat_name = '${url.editor_name}';
                                        // sharedPreferences.setString('cat_name', tool_name);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => DepartmentsScreen1(
                                                  tool_name: Cat_name,
                                                )));

                                      },
                                      color: Colors.blue,
                                      splashColor: Colors.grey,
                                      shape: new RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.circular(
                                              10.0)),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            "SHOP NOW!",
                                            style: new TextStyle(
                                                color: new Color(0xFFFFFFFF),
                                                fontSize: 18.0),
                                          ),
                                        ],
                                      ))),*/
                                    // Text(url.editor_name,style: TextStyle(fontSize: 30.0,color: Colors.white),maxLines: 2,),
                                  ],
                                ))
                              ]),
                            )));
                  },
                ).toList(),
              );
  }

  List<Editor_Model> map<T>(List<Editor_Model> list, Function handler) {
    List<Editor_Model> result = new List();
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double width12 = width;

    return Scaffold(
        body: new RefreshIndicator(
      child: ModalProgressHUD(
        child: Container(
          color: Colors.white,
          child:
              productList1.length == 0 ? new Container() : _buildMainContent(),
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.7,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
      onRefresh: _handleRefresh,
    ));
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(seconds: 3));
    if (this.mounted) {
      setState(() {
        _isInAsyncCall = true;
        getProduct();
      });
    }
    return null;
  }
}

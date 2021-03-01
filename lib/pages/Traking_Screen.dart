import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/Coman_SearchList_Screen.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'package:xml2json/xml2json.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class Tracking_Screen extends StatefulWidget {
  String Product_id = '';
  String Order_id = '';
  String Tracking_id = '';

  Tracking_Screen(this.Product_id, this.Order_id, this.Tracking_id);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    // return
    return track_order(Product_id, Order_id, Tracking_id);
  }
}

class track_order extends State<Tracking_Screen> {
  String user_id = '',
      Product_id = '',
      Order_id = '',
      Tracking_id = '',
      Carttotal = "0";
  // String orderid = this.Order_id;
  final Xml2Json xml2json = Xml2Json();
  var a;
  var aLength = 0;
  var trackSummary = "";

  track_order(this.Product_id, this.Order_id, this.Tracking_id);
  bool _isInAsyncCall = true;
  List<Shell_Product_Model> productdata;
  List<Shell_Product_Model> productdata1 = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    trackOrderList(this.Tracking_id);
    getCredential();
  }

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    productdata = new List();
    user_id = sharedPreferences.getString("user_id");

    if (user_id == null) {
      user_id = "";
    }
    CollectionReference ref = Firestore.instance.collection('product');
    QuerySnapshot eventsQuery =
        await ref.where("product_id", isEqualTo: Product_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        productdata.add(Shell_Product_Model(
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
            doc['brand_new']));
      });
      setState(() {
        _isInAsyncCall = false;
        this.productdata1 = productdata;
      });
    }
  }

// -----------------------------------------------------------------------------
  Future trackOrderList(id) async {
    var builder = new xml.XmlBuilder();
    builder.element('TrackRequest', nest: () {
      builder.attribute('USERID', '186LOFTY0774');
      builder.element('TrackID', nest: () {
        builder.attribute('ID', id);
      });
    });

    var bookshelfXml = builder.build();

    String _uriMsj = bookshelfXml.toString();

    print("_uriMsj: $_uriMsj");

    String _uri =
        "http://production.shippingapis.com/ShippingAPI.dll?API=TrackV2&XML=";

    HttpClient client = new HttpClient();

    HttpClientRequest request = await client.postUrl(Uri.parse(_uri + _uriMsj));

    HttpClientResponse response = await request.close();

    StringBuffer _buffer = new StringBuffer();

    await for (String a in await utf8.decoder.bind(response)) {
      _buffer.write(a);
    }
    // var responses = response.transform(utf8.decoder);
    // var responses = utf8.decoder.bind(response);
    // await for (String a in await responses) {
    //   _buffer.write(a);
    // }

    bool error = _buffer.toString().contains('Error');
    print("_buffer.toString: ${_buffer.toString()}");

    if (error == false) {
      var responseJson = xml.parse(_buffer.toString());

      //  var  responseJson2 = xml.parse('<TrackResponse><TrackInfo ID="XXXXXXXXXXX1"><TrackSummary>Your item was delivered at 6:50 am on February 6 in BARTOW FL 33830.</TrackSummary> <TrackDetail>February 6 6:48 am ARRIVAL AT UNIT BARTOW FL 33830</TrackDetail><TrackDetail>February 6 6:48 am ARRIVAL AT UNIT BARTOW FL 33830</TrackDetail><TrackDetail>February 6 3:49 am ARRIVAL AT UNIT LAKELAND FL 33805</TrackDetail><TrackDetail>February 5 7:28 pm ENROUTE 33699</TrackDetail><TrackDetail>February 5 7:18 pm ACCEPT OR PICKUP 33699</TrackDetail></TrackInfo></TrackResponse>');

      // var valid = responseJson.findAllElements('TrackDetail').toString();
      var valid2 = responseJson.findAllElements('TrackDetail');
      var valid3 = responseJson.findAllElements('TrackSummary').single.text;

      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
          trackSummary = valid3;
        });
      }

      if (valid2.length != null && valid2.length != 0) {
        a = valid2.map((node) => node.text).toList();
        aLength = a.length;
        print(aLength);
        if (this.mounted) {
          setState(() {
            _isInAsyncCall = false;
            a = a;
          });
        }
      }
    } else {
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
          trackSummary = "Unable to fetch the tracking details";
        });
      }
    }
  }

// -------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
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
              onPressed: () {
                if (user_id == "") {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignupPage()));
                } else {
                  MyNavigator.gotoAddItemScreen(context);
                }
              }),
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
          new IconButton(
            icon: new Icon(Icons.perm_identity),
            tooltip: 'Me',
            onPressed: () => MyNavigator.goToProfile(context),
          ),
        ],
      ),
      body: ModalProgressHUD(
        child: productdata1.length == 0
            ? Container(
                child: Center(
                  child: Showmsg(),
                ),
              )
            : Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5.0),
                      child: Card(
                        child: Column(
                          children: <Widget>[
                            new Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(
                                  top: 15.0,
                                  left: 10.0,
                                  right: 10.0,
                                  bottom: 10.0),
                              child: Text(
                                'ORDER ID - ' + this.Order_id,
                                style: TextStyle(
                                    color: Colors.black26, fontSize: 14.0),
                              ),
                            ),
                            Divider(),
                            new Row(
                              children: <Widget>[
                                Expanded(
                                    flex: 7,
                                    child: Container(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                              alignment: Alignment.topLeft,
                                              padding: EdgeInsets.all(5.0),
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        10.0, 5.0, 10.0, 5.0),
                                                    child: Text(
                                                      productdata1[0]
                                                          .item_title,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                        fontSize: 20.0,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        10.0, 5.0, 10.0, 5.0),
                                                    child: new Row(
                                                      children: <Widget>[
                                                        Text(
                                                          "Brand : ",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          productdata1[0]
                                                              .item_brand,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        10.0, 5.0, 10.0, 5.0),
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: new RichText(
                                                      textAlign: TextAlign.left,
                                                      text: new TextSpan(
                                                        text: '',
                                                        style: TextStyle(
                                                          fontSize: 15.0,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                            text: '\$' +
                                                                productdata1[0]
                                                                    .item_sale_price,
                                                            style:
                                                                new TextStyle(
                                                              fontSize: 22.0,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.all(5.0),
                                      child: FadeInImage.assetNetwork(
                                        placeholder: 'images/tonlogo.png',
                                        image: productdata1[0].picture,
                                        width: 80.0,
                                        height: 80.0,
                                        fit: BoxFit.scaleDown,
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(),
                    ModalProgressHUD(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 27, right: 35, top: 10, bottom: 8),
                        child: Text(
                          trackSummary,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      inAsyncCall: _isInAsyncCall,
                      opacity: 1,
                      color: Colors.white,
                      progressIndicator: CircularProgressIndicator(),
                    ),
                    Divider(),
                    Expanded(
                      child: OrderData(),
                    ),
                  ],
                ),
              ),
        inAsyncCall: _isInAsyncCall,
        opacity: 1,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }

  Widget Showmsg() {
    return Container();
  }

  Widget OrderData() {
    return new Card(
      child: timelineModel(TimelinePosition.Left),
    );
  }

  timelineModel(TimelinePosition position) => Timeline.builder(
      itemBuilder: centerTimelineBuilder,
      itemCount: aLength,
      physics: position == TimelinePosition.Left
          ? ClampingScrollPhysics()
          : BouncingScrollPhysics(),
      position: position);

  TimelineModel centerTimelineBuilder(BuildContext context, int i) {
    final doodle = a[i];
    final textTheme = Theme.of(context).textTheme;
    return TimelineModel(
      Card(
        margin: EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        doodle,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                    ],
                  ),
                )
              ],
            )),
      ),
      position:
          i % 2 == 0 ? TimelineItemPosition.right : TimelineItemPosition.left,
      isFirst: i == 0,
      isLast: i == aLength,
      iconBackground: Colors.black,
    );
  }

// -------------------------------------------------------------
  // timelineModel(TimelinePosition position) => Timeline.builder(
  //     itemBuilder: centerTimelineBuilder,
  //     itemCount: doodles.length,
  //     physics: position == TimelinePosition.Left
  //         ? ClampingScrollPhysics()
  //         : BouncingScrollPhysics(),
  //     position: position);

  // TimelineModel centerTimelineBuilder(BuildContext context, int i) {
  //   final doodle = doodles[i];
  //   final textTheme = Theme.of(context).textTheme;
  //   return TimelineModel(
  //       Card(
  //         margin: EdgeInsets.symmetric(vertical: 16.0),
  //         shape:
  //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  //         clipBehavior: Clip.antiAlias,
  //         child: Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Row(
  //             children: <Widget>[
  //               Expanded(flex: 5, child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: <Widget>[

  //                 RaisedButton(
  //                   color: Colors.black87,
  //                           padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
  //                           child:  Container(
  //                           child: Text('SHOW', style: TextStyle(
  //                           fontSize: 15.0,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.white), maxLines: 1,),
  //                           ),
  //                   onPressed:() =>validTrackingIDCheck(),
  //                 ),
  //                   // Text(
  //                   //   doodle.name,
  //                   //   style: textTheme.title,
  //                   //   textAlign: TextAlign.center,
  //                   // ),
  //                   // Divider(),
  //                   Text(
  //                     doodle.content = trackOrder.toString(),

  //                     textAlign: TextAlign.left,
  //                   ),
  //                   const SizedBox(
  //                     height: 8.0,
  //                   ),
  //                 ],
  //               ),)
  //             ],
  //           )
  //         ),
  //       ),
  //       position:
  //       i % 2 == 0 ? TimelineItemPosition.right : TimelineItemPosition.left,
  //       isFirst: i == 0,
  //       isLast: i == doodles.length,
  //       iconBackground: doodle.iconBackground,
  //       );
  // }
}

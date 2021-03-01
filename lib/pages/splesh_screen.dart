import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/pages/Constant.dart';
import 'package:threadon/pages/Seller_User_Profile_Screen.dart';
import 'package:threadon/pages/departments_screen.dart';
import 'package:threadon/pages/main_screen.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
final List<String> imgList = [
  // 'images/sp.jpg'
  'images/sp_main.jpg'
   //'images/sp_bla.jpg'
];
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  SharedPreferences preferences;
  String UserName = '';
  String loginname = '';
  String textValue = '';
  bool LoginIn = false;
  String nt ="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCredential();
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> msg) async{
        print('on message $msg');
         nt = msg['nt'];
        _goToDeeplyNestedView();

      },
      onResume: (Map<String, dynamic> msg) {
        print('on resume $msg');
         nt = msg['nt'];
        _goToDeeplyNestedView();
      },
      onLaunch: (Map<String, dynamic> msg) {
        print('on launch $msg');
         nt = msg['nt'];
        _goToDeeplyNestedView();
      },
    );

    firebaseMessaging.getToken().then((token) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString('token_id', token);
      print(token);
    });
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed: $setting');
    });

    Timer(Duration(seconds: 10), () => _navigator());
  }

  _goToDeeplyNestedView() {

    if(nt == "1"){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> Seller_Profile()));
    }
    else if(nt == "2"){

      Navigator.push(context, MaterialPageRoute(builder: (context)=> Seller_Profile()));
    }



  }

  CarouselSlider getFullScreenCarousel(BuildContext mediaContext) {
    var w =MediaQuery.of(mediaContext).size.width;
    return CarouselSlider(
      autoPlay: false,

      viewportFraction: 1.0,
      aspectRatio: MediaQuery.of(mediaContext).size.aspectRatio,
      items: imgList.map(
            (url) {
          return Container(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(0.0)),
              child: Image.asset(
                url,
                fit: BoxFit.cover,
                width: w,
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  _navigator() {
    if (UserName.length == 0) {
      if (loginname.length == 0) {
        MyNavigator.goToHomee(context);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (BuildContext context) => MyHome()),
            (Route<dynamic> route) => false);
      }
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (BuildContext context) => MyHome()),
          (Route<dynamic> route) => false);
    }
  }

  getCredential() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      LoginIn = preferences.getBool("check");
      if (LoginIn != null) {
        if (LoginIn) {
          /* username.text = sharedPreferences.getString("username");
          password.text = sharedPreferences.getString("password");*/
          UserName = preferences.getString('UserName');
          loginname = preferences.getString('loginname');
        } else {
          UserName = '';
          preferences.clear();
        }
      } else {
        LoginIn = false;
      }
    });
  }
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;

  }
  MediaQueryData querydata;

  @override
  Widget build(BuildContext context) {
    querydata = MediaQuery.of(context);
    return new Scaffold(
      body: Stack(
        children: <Widget>[



          Center(
            child: Builder(builder: (context) {
              return Container(
                child:  getFullScreenCarousel(context),
              );
            })
          ),
          Container(
            color: Colors.black54,
          ),
          Positioned(
            bottom: 20.0,
            child: Center(child: new Container(
                width: querydata.size.width,
                child:Column(
                  children: <Widget>[



                    SizedBox(height: 10.0,),

                    Column(
                      children: <Widget>[

                        SizedBox(

                          child: ScaleAnimatedTextKit(

                              duration: Duration(milliseconds: 10000),
                              isRepeatingAnimation: false,
                              onTap: () {
                                print("Tap Event");
                              },
                              text: [
                                "ThreadOn"
                              ],
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40.0,
                                  fontFamily: "ggg",
                                letterSpacing: 5.0,
                                fontWeight: FontWeight.w900

                              ),
                              textAlign: TextAlign.start,
                              alignment: AlignmentDirectional.topStart // or Alignment.topLeft
                          ),
                        ),
                        SizedBox(height: 10.0,),

                        new Padding(padding: EdgeInsets.only(left: 30.0,right: 30.0),
                        child: Divider(
                          height: 30.0,
                          color: Colors.white,
                        ),),

                        Padding(padding: EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                        child: Text(
                          "Big brands realize they need so much more than a picture and description to sell products. They're all about selling a lifestyle, and that means bigger, better content is needed to engage shoppers.",
                          style: TextStyle(fontSize: 15,color: Colors.white70,fontFamily: 'RobotoSlab_Light',),
                          maxLines: 5,
                          textAlign: TextAlign.center,
                        ))
                        ,
                      ],
                    ),
                  ],
                )
            ),
          ),
          ),

        /*  Center(
              child: SizedBox(
                width: 250.0,
                child: ScaleAnimatedTextKit(
                    duration: Duration(milliseconds: 4000),
                    isRepeatingAnimation: false,
                    onTap: () {
                      print("Tap Event");
                    },
                    text: [
                      "ThreadOn"
                    ],
                    textStyle: TextStyle(
                      color: Colors.white,
                        fontSize: 70.0,
                        fontFamily: "SairaSemiCondensed",
                      fontWeight: FontWeight.w500
                    ),
                    textAlign: TextAlign.start,
                    alignment: AlignmentDirectional.topStart // or Alignment.topLeft
                ),
              )
          ),*/
        ],
      )
    );


//




    return new Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.black38,
        image: DecorationImage(
          colorFilter: new ColorFilter.mode(
              Colors.black.withOpacity(0.5), BlendMode.dstATop),
          image: AssetImage('assets/shpng.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
//    return Scaffold(
//      body: Stack(
//        fit: StackFit.expand,
//        children: <Widget>[
//          Container(
//            decoration: BoxDecoration(color: Colors.white),
//          ),
//          Column(
//            mainAxisAlignment: MainAxisAlignment.start,
//            children: <Widget>[
//              Expanded(
//                flex: 2,
//                child: Container(
//                  child: Column(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      CircleAvatar(
//                        backgroundColor: Colors.lightBlueAccent,
//                        radius: 50.0,
//                        child: Icon(
//                          Icons.shopping_cart,
//                          color: Colors.white,
//                          size: 50.0,
//                        ),
//                      ),
//                      Padding(
//                        padding: EdgeInsets.only(top: 10.0),
//                      ),
//                      Text(
//                        Tradesy.name,
//                        style: TextStyle(
//                            color: Colors.lightBlueAccent,
//                            fontWeight: FontWeight.bold,
//                            fontSize: 24.0),
//                      )
//                    ],
//                  ),
//                ),
//              ),
//              Expanded(
//                flex: 1,
//                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    CircularProgressIndicator(),
//                    Padding(
//                      padding: EdgeInsets.only(top: 20.0),
//                    ),
//                    Text(
//                      Tradesy.store,
//                      softWrap: true,
//                      textAlign: TextAlign.center,
//                      style: TextStyle(
//                          fontWeight: FontWeight.bold,
//                          fontSize: 18.0,
//                          color: Colors.lightBlueAccent),
//                    )
//                  ],
//                ),
//              )
//            ],
//          )
//        ],
//      ),
//    );
  }
}

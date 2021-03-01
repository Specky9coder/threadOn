import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/pages/login_screen.dart';
import 'package:threadon/pages/main_screen.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/utils/my_navigator.dart';

final List<String> imgList = [
  'images/sp_1.jpg','images/sp_3.jpg','images/sp_4.jpg',
  // 'images/sp_bla5.jpg','images/sp_bla2.jpg','images/sp_bla4.jpg',
];

class HomeScreen extends StatefulWidget {
  static String tag = 'home-page';

  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

PageController _controller =
new PageController(initialPage: 1, viewportFraction: 1.0);

class _HomeScreenState extends State<HomeScreen> {
  SharedPreferences preferences;
  String UserName = '';
  bool LoginIn = false;

  @override
  Widget build(BuildContext context) {
    return new Material(
        type: MaterialType.transparency,
        child: new Container(
          height: MediaQuery.of(context).size.height,
          child: PageView(
            controller: _controller,
            physics: new AlwaysScrollableScrollPhysics(),
            children: <Widget>[SignupPage(), homePage(), LoginPage()],
            scrollDirection: Axis.horizontal,
          ),
        ));
  }
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;

  }


  CarouselSlider getFullScreenCarousel(BuildContext mediaContext) {
    return CarouselSlider(
      autoPlay: true,
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
                width: 1000.0,
              ),
            ),
          );
        },
      ).toList(),
    );
  }
  Widget HomePage() {
    return new Stack(
      children: <Widget>[
        Container(
          child: getFullScreenCarousel(context),
        ),
        Container(
          color: Colors.black38,

          height: MediaQuery.of(context).size.height,

          child: new Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 100.0),
                child: Center(
//              child: Icon(
//                Icons.headset_mic,
//                color: Colors.white,
//                size: 40.0,
//              ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "ThreadOn",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "The Simple way to buy and sell",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 0.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "The Simple way to buy and sell traditional fashion",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
              new Container(
                width: MediaQuery.of(context).size.width,
                margin:
                const EdgeInsets.only(left: 30.0, right: 30.0, top: 50.0),
                alignment: Alignment.center,
                decoration: new BoxDecoration(color: Colors.white),
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new OutlineButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(2.0)),
                        color: Colors.redAccent,
                        highlightedBorderColor: Colors.white,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupPage()));
                          //  MyNavigator.goToSignup(context);
                        },
                        child: new Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 15.0,
                          ),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Expanded(
                                child: Text(
                                  "Join",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              new Container(
                width: MediaQuery.of(context).size.width,
                margin:
                const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                alignment: Alignment.center,
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new OutlineButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(2.0)),
                        color: Colors.redAccent,
                        highlightedBorderColor: Colors.white,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyHome()));
                          //  MyNavigator.goToMain(context);
                        },
                        child: new Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 15.0,
                          ),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Expanded(
                                child: Text(
                                  "Skip for Now",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 50.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    ),

                    new GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                          // MyNavigator.goToLogin(context);
                        },
                        child: new Text(
                          '   Log In',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        )),

//                ListTile(
//                  title: Text('   Log In'),
//                  onTap: () => MyNavigator.goToLogin(context),
//
//                ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  _navigator() {
    if (UserName.length != 0) {
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(
              builder: (BuildContext context) => new MyHome()),
              (Route<dynamic> route) => false);
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          child: new CupertinoAlertDialog(
            content: new Text(
              "username or password \ncan't be empty",
              style: new TextStyle(fontSize: 16.0),
            ),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: new Text("OK"))
            ],
          ));
    }
  }
}



class homePage extends StatelessWidget {
  MediaQueryData querydata;
  var w ;

  CarouselSlider getFullScreenCarousel(BuildContext mediaContext) {
    return CarouselSlider(
      autoPlay: true,
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

  @override
  Widget build(BuildContext context) {

    w = MediaQuery.of(context).size.width;
    querydata = MediaQuery.of(context);
    return Scaffold(

      body: new Container(

        child: new Stack(
          children: <Widget>[
            Container(
              child: getFullScreenCarousel(context),
            ),

            new Container(
              color: Colors.black54,
            ),
            Positioned(
              width: querydata.size.width,
              top: querydata.size.height * 0.1,
//              left: 20,
              child: Container(
                padding:
                EdgeInsets.only(left: 20, right: 50, top: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "ThreadOn",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: querydata.size.width * .10,
                          fontFamily: 'RobotoSlab_Bold'),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "ThreadOn is not an industry,\nThreadOn is a tactic.",
                      //"The Simple way to buy and sell traditional fashion.",
                      style: TextStyle(fontSize: 17,color: Colors.white70,fontFamily: 'RobotoSlab_Light'),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20.0,
              child: new Container(
                  width: querydata.size.width,
                  child:Column(
                    children: <Widget>[
                      new Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 28.0,
                        ),

                        child:  new OutlineButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(2.0)),
                          highlightedBorderColor: Colors.white,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyHome()));
                            //  MyNavigator.goToMain(context);
                          },
                          child: new Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 15.0,
                            ),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Expanded(
                                  child: Text(
                                    "Skip for Now",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),),


                      SizedBox(height: 10.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[




                          MaterialButton(
                            minWidth: querydata.size.width * .4,
                            height: 50,
                            child: Text(
                              "SIGN UP",
                              style: TextStyle(fontSize: 16.0, color: Colors.white),
                            ),
                            color: Colors.black,
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => SignupPage()));
                            },
                          ),
              MaterialButton(
            minWidth: querydata.size.width * .4,
              height: 50,
              child: Text(
                "SIGN IN",
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginPage()));
              },
            ),
                        ],
                      ),
                    ],
                  )
              ),
            ),

          ],
        ),
      ),
    );
  }
}
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:threadon/pages/main_screen.dart';

class RedeemConfirmationScreen extends StatelessWidget {

  var height;
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95), // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.

      body:SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.only(top: 20.0),
            height: height,
            color: Colors.black87,
            child: Column(

              children: <Widget>[
                Container(
                  height: 300.0,
                  child: FlareActor("assets/animation.flr", alignment:Alignment.center, fit:BoxFit.contain,animation: 'success',),
                ),

                new Wrap(
                  children: <Widget>[
                    Text("Thank you for\nyour order!",style: TextStyle(fontSize: 35.0,fontWeight: FontWeight.w500,color: Colors.white),textAlign: TextAlign.center)
                  ],
                ),

                new Padding(padding: EdgeInsets.only(top: 30.0)),
                new Wrap(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 10.0,right: 10.0),
                        child: Text("If you haven't seen Game of Thrones, go watch it right now. If you have then you'll totally get why this Hodor themed lorem ipsum generator is just brilliant.",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.w400,color: Colors.white70,letterSpacing: 1.5),textAlign: TextAlign.center,softWrap: true)
                    )  ],
                ),

                new Padding(
                  padding: EdgeInsets.symmetric(vertical: 70.0,horizontal: 20.0),
                  child: new InkWell(
                    onTap: () =>  Navigator.of(context).pushAndRemoveUntil(
                        new MaterialPageRoute(
                            builder: (BuildContext context) => new MyHome()),
                            (Route<dynamic> route) => false),
                    child: new Container(

                      //width: 100.0,
                      height: 50.0,
                      decoration: new BoxDecoration(
                        color: Colors.black87,
                        borderRadius: new BorderRadius.circular(25.0),
                      ),
                      child: new Center(child: new Text('Back to Home', style: new TextStyle(fontSize: 18.0, color: Colors.white),),),
                    ),
                  ),

                ),

              ],

            ) ,
          ),
        )
      )

    );
  }


}
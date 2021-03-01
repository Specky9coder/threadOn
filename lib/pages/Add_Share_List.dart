import 'package:flutter/material.dart';

class Add_ShareList_Screen extends StatefulWidget {
  String appbar_name;

  Add_ShareList_Screen({Key key, this.appbar_name}) : super(key: key);

  @override
  State<StatefulWidget> createState() => add_shareList_screen(appbar_name);
}

class add_shareList_screen extends State<Add_ShareList_Screen> {
  String tool_name1;

  add_shareList_screen(this.tool_name1);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(tool_name1),
        backgroundColor: Colors.white70,
//        automaticallyImplyLeading: false,
      ),
      body: Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child:SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: new Column(
                children: <Widget>[
                  new TextFormField(
                      keyboardType: TextInputType.text,
                      // Use email input type for emails.
                      decoration: new InputDecoration(
                        labelText: 'Name of Share List',
                      )),
                ],
              ),
            ),

            Container(

              margin: EdgeInsets.only(top: 40.0),
              color: Colors.black,
              alignment: Alignment.bottomCenter,
              child: Card(
                elevation: 3.0,
                child: Column(
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(10.0),
                        color: Colors.black,
                        child: GestureDetector(
                        /*  onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Editor_piker()));
                          },*/
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Add Item to new Share List",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17.0,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),



          ],
        ),
      ),
    ),
    /* body: Column(children: <Widget>[
          Container(
//          padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: new Column(
              children: <Widget>[
                new TextFormField(
                    keyboardType: TextInputType.text,
                    // Use email input type for emails.
                    decoration: new InputDecoration(
                      labelText: 'First and Last Name',
                    )),
              ],
            ),
          ),
          Container(
//          padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
            child: new Column(
              children: <Widget>[
                new TextFormField(
                    keyboardType: TextInputType.text,
                    // Use email input type for emails.
                    decoration: new InputDecoration(
                      labelText: 'Address Line 1',
                    )),
              ],
            ),
          ),
          Container(
//          padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
            child: new Column(
              children: <Widget>[
                new TextFormField(
                    keyboardType: TextInputType.text,
                    // Use email input type for emails.
                    decoration: new InputDecoration(
                      labelText: 'Address Line 2',
                    )),
              ],
            ),
          ),
          Container(
//          padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),

            child: new Row(
              children: <Widget>[
                new TextFormField(
                    keyboardType: TextInputType.text,
                    // Use email input type for emails.
                    decoration: new InputDecoration(
                      labelText: 'City',
                    )),
                new TextFormField(
                    keyboardType: TextInputType.text,
                    // Use email input type for emails.
                    decoration: new InputDecoration(
                      labelText: 'Zip Code',
                    )),
              ],
            ),
          ),
        ]));*/

    // TODO: implement build
    );
  }
}

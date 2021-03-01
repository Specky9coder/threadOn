import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Category.dart';
import 'package:threadon/model/Editor.dart';
import 'package:threadon/pages/department_detail.dart';
import 'package:threadon/pages/departments_screen1.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';

class CategoryScreen extends StatefulWidget {
  static String tag = 'home-page';
  @override
  State<StatefulWidget> createState() => _CategoryScreenState();
}

PageController _controller =
    new PageController(initialPage: 1, viewportFraction: 1.0);

class _CategoryScreenState extends State<CategoryScreen> {
  List<CategoryModel> categoryList;
  List<Editor_Model> editorList = new List();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  List<CategoryModel> notes;
  List<Editor_Model> notes1;
  String Cat_id = '', Editor_Id = '';

  bool _isInAsyncCall = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    categoryList = new List();

    noteSub?.cancel();
    noteSub = db.getCategoryList().listen((QuerySnapshot snapshot) {
      notes = snapshot.documents
          .map((documentSnapshot) =>
              CategoryModel.fromMap(documentSnapshot.data))
          .toList();
      setState(() {
        this.categoryList = notes;
      });
    });

    getEditorProduct();
  }

  getEditorProduct() async {
    CollectionReference ref = Firestore.instance.collection('editor_product');
    QuerySnapshot eventsQuery =
        await ref.where("status", isEqualTo: "0").getDocuments();
    editorList = new List();
    if (eventsQuery.documents.isEmpty) {
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
        });
      }
    } else {
      eventsQuery.documents.forEach((doc) async {
        editorList.add(Editor_Model(
          doc['date'].toDate(),
          doc['editor_id'],
          doc['editor_name'],
          doc['featured_image'],
          doc['product_id'].toList(),
          doc['status'],
        ));
      });
      if (this.mounted) {
        setState(() {
          _isInAsyncCall = false;
          editorList = this.editorList;
        });
      }
    }
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
            _buildListItem(),
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
              child: new Container(
                child: Text(
                  'Editor\'s Picks',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0),
                ),
              ),
            ),
            _buildListItem1()
          ]),
        )
      ],
    );
  }

  Widget _buildListItem() {
    return Column(
      children: <Widget>[
        ListView.builder(
          padding: EdgeInsets.only(top: 8.0),
          itemBuilder: (context, index) {
            return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 0.0,
                  vertical: 0.0,
                ),
                child: GestureDetector(
                  child: Card(
                    child: Row(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: categoryList[index].Cat_image != ""
                                    ? NetworkImage(
                                        '${categoryList[index].Cat_image}')
                                    : Image.asset('images/tonlogo.png'),
                              ),
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          margin: EdgeInsets.only(
                              left: 5, top: 5, right: 5, bottom: 5),
                          height: 70,
                          width: 70,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Text(
                            '${categoryList[index].Cat_Name}',
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
                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();
                    int sub_Cat_id = categoryList[index].is_sub_category;

                    if (sub_Cat_id == 1) {
                      await SharedPreferencesHelper.setcat_name(
                          categoryList[index].Cat_Name);
                      await SharedPreferencesHelper.setcat_id(
                          categoryList[index].Cat_id);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DepartmentScreen(
                                  tool_name: categoryList[index].Cat_Name)));
                    } else {
                      Cat_id = '${categoryList[index].Cat_id}';
                      String Cat_name = '${categoryList[index].Cat_Name}';

                      await SharedPreferencesHelper.setcat_id(Cat_id);
                      await SharedPreferencesHelper.setcat_name(Cat_name);
                      await SharedPreferencesHelper.setsub_cat_id('');
                      await SharedPreferencesHelper.setsub_cat_name('');
                      sharedPreferences.setString('cat_name', Cat_name);
                      sharedPreferences.setString('type', "");
                      MyNavigator.goToDepartmentss(context);
                    }
                  },
                ));
          },
          itemCount: categoryList.length,
          shrinkWrap: true, // todo comment this out and check the result
          physics:
              ClampingScrollPhysics(), // todo comment this out and check the result
        ),
      ],
    );
  }

  Widget _buildListItem1() {
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
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        Container(
                            height: 220.0,
                            width: width12,
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/image_pro1.gif',
                              image: (editorList[index].featured_image),
                              fit: BoxFit.cover,
                            )),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 5.0, right: 5.0, top: 15.0),
                          child: new Row(
//                mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Editor's Picks",
                                style: TextStyle(
                                  color: Colors.black26,
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 5.0, right: 5.0, top: 3.0, bottom: 5.0),
                          child: new Row(
//                mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                editorList[index].editor_name,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 5.0,
                        ),
                      ],
                    ),
                  ),
                  onTap: () async {
                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();
                    sharedPreferences.setStringList('editor_list',
                        editorList[index].product_id.cast<String>());
                    String Cat_name = '${editorList[index].editor_name}';
                    // sharedPreferences.setString('cat_name', tool_name);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DepartmentsScreen1(
                                  tool_name: Cat_name,
                                )));
                  },
                ));
          },
          itemCount: editorList.length,
          shrinkWrap: true, // todo comment this out and check the result
          physics:
              ClampingScrollPhysics(), // todo comment this out and check the result
        ),
      ],
    );
  }

  @override
  void dispose() {
    noteSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double width12 = width;
    return Scaffold(
        body: new RefreshIndicator(
      child: ModalProgressHUD(
        child: Container(
          color: Colors.white,
          child: _buildMainContent(),
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.7,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
      onRefresh: _handleRefresh,
    ));
  }

  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(seconds: 3));
    if (this.mounted) {
      setState(() {
        // editorList = this.editorList;
        _isInAsyncCall = true;
        getEditorProduct();
      });
    }
    return null;
  }
}

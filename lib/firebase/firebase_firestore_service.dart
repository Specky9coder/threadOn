import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:threadon/model/Cart.dart';
import 'package:threadon/model/Brand.dart';
import 'package:threadon/model/Favorite.dart';
import 'package:threadon/model/Follow.dart';
import 'package:threadon/model/Item_Order.dart';
import 'package:threadon/model/Message.dart';
import 'package:threadon/model/Message_List.dart';
import 'package:threadon/model/PaymentBill.dart';
import 'package:threadon/model/Product.dart';
import 'package:threadon/model/Report.dart';
import 'package:threadon/model/Share.dart';
import 'package:threadon/model/Share_List.dart';

import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/model/Signup.dart';
import 'package:threadon/model/shipping_address.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';

final CollectionReference categoryCollection =
    Firestore.instance.collection('category');
final CollectionReference editorCollection =
    Firestore.instance.collection('editor_product');
final CollectionReference walletCollection =
    Firestore.instance.collection('wallet');
final CollectionReference subcategoryCollection =
    Firestore.instance.collection('sub_category');
final CollectionReference productCollection =
    Firestore.instance.collection('product');
final CollectionReference brandCollection =
    Firestore.instance.collection('brand');
final CollectionReference messageCollection =
    Firestore.instance.collection('messages');

final CollectionReference userlogin = Firestore.instance.collection('users');
final CollectionReference userreport =
    Firestore.instance.collection('report_item');
final CollectionReference share_list =
    Firestore.instance.collection('share_list');
final CollectionReference share_list_item =
    Firestore.instance.collection('share_list_item');
final CollectionReference Favorite_item =
    Firestore.instance.collection('favourite_item');
final CollectionReference cartCollection =
    Firestore.instance.collection('cart');
final CollectionReference Product_item =
    Firestore.instance.collection('product');
final CollectionReference Shipping =
    Firestore.instance.collection('shipping_address');
final CollectionReference shipping_list =
    Firestore.instance.collection('shipping_method');
final CollectionReference followCollection =
    Firestore.instance.collection('follow');
final CollectionReference messagelistCollection =
    Firestore.instance.collection('chat_log_list');

final CollectionReference item_orderCollection =
    Firestore.instance.collection('item_order');

final CollectionReference billingCollection =
    Firestore.instance.collection('billing_card_details');

/*
class FirebaseFirestoreService {

  static final FirebaseFirestoreService _instance = new FirebaseFirestoreService*/

class FirebaseFirestoreService {
  static final FirebaseFirestoreService _instance =
      new FirebaseFirestoreService.internal();

  factory FirebaseFirestoreService() => _instance;

  FirebaseFirestoreService.internal();

  Future<PaymentBillModel> createCardIndo(
      String key,
      String id,
      DateTime date,
      String external_customer_id,
      String type,
      String number,
      String expire_month,
      String expire_year,
      String first_name,
      String last_name,
      List<String> billing_address,
      String valid_until,
      String create_time,
      String update_time,
      String user_id,
      String access_token) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(billingCollection.document());

      final PaymentBillModel note1 = new PaymentBillModel(
          ds.documentID,
          id,
          date,
          external_customer_id,
          type,
          number,
          expire_month,
          expire_year,
          first_name,
          last_name,
          billing_address,
          valid_until,
          create_time,
          update_time,
          user_id,
          access_token);
      final Map<String, dynamic> data = note1.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance
        .runTransaction(createTransaction)
        .then((doc) async {
/*      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

      bool isLoggedIn = true;
      sharedPreferences.setBool('check', isLoggedIn);
      sharedPreferences.setString('UserName', doc['name']);
      sharedPreferences.setString('loginname', doc["email_id"]);
      sharedPreferences.setString('profile_image',doc["profile_picture"] );
      sharedPreferences.setString('facebook_id', doc["facebook_id"]);
      sharedPreferences.setString('followers', doc["followers"]);
      sharedPreferences.setString('following', doc["following"]);
      sharedPreferences.setString('user_id', doc["user_id"]);
      sharedPreferences.setString('username', doc["username"]);
      sharedPreferences.setString('password', doc["password"]);
      sharedPreferences.setString('about_me', doc["about_me"]);
      sharedPreferences.setString('country', doc["country"]);
      sharedPreferences.setString('cover_picture', doc["cover_picture"]);
      sharedPreferences.setString('refer_code', doc['refer_code']);
      sharedPreferences.setString('device_id', doc["device_id"]);*/

      return PaymentBillModel.fromMap(doc);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  Future<Signup_Modle> createLogin(
      String Key,
      String Username,
      String Password,
      String Name,
      String Status,
      String Profile_picture,
      String Latlong,
      String Following,
      String Followers,
      String Facebook_id,
      String Email_id,
      String Device_id,
      String Device,
      String Cover_picture,
      String Country,
      String About_me,
      String refer_code) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(userlogin.document());

      final Signup_Modle note = new Signup_Modle(
          ds.documentID,
          Username,
          Password,
          Name,
          Status,
          Profile_picture,
          Latlong,
          Following,
          Followers,
          Facebook_id,
          Email_id,
          Device_id,
          Device,
          Cover_picture,
          Country,
          About_me,
          refer_code);
      final Map<String, dynamic> data = note.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance
        .runTransaction(createTransaction)
        .then((doc) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      bool isLoggedIn = true;
      sharedPreferences.setBool('check', isLoggedIn);
      sharedPreferences.setString('UserName', doc['name']);
      sharedPreferences.setString('loginname', doc["email_id"]);
      sharedPreferences.setString('profile_image', doc["profile_picture"]);
      sharedPreferences.setString('facebook_id', doc["facebook_id"]);
      sharedPreferences.setString('followers', doc["followers"]);
      sharedPreferences.setString('following', doc["following"]);
      sharedPreferences.setString('user_id', doc["user_id"]);
      sharedPreferences.setString('username', doc["username"]);
      sharedPreferences.setString('password', doc["password"]);
      sharedPreferences.setString('about_me', doc["about_me"]);
      sharedPreferences.setString('country', doc["country"]);
      sharedPreferences.setString('cover_picture', doc["cover_picture"]);
      sharedPreferences.setString('refer_code', doc['refer_code']);
      sharedPreferences.setString('device_id', doc["device_id"]);

      return Signup_Modle.fromMap(doc);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  Future<dynamic> updateSignupData(Signup_Modle _singup) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(userlogin.document(_singup.Key));

      await tx.update(ds.reference, _singup.toMap());
      return {'updated': true};
    };

    return await Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => result['updated'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  Stream<QuerySnapshot> getUserList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = userlogin.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Future<Report> createReport(
    String Report_id,
    String User_id,
    String Product_id,
    String Status,
    DateTime Date,
    String Authenticity_issue,
    String Image_issue,
    String Inaccurate_price_issue,
  ) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(userreport.document());

      final Report note = new Report(ds.documentID, User_id, Product_id, Status,
          Date, Authenticity_issue, Image_issue, Inaccurate_price_issue);
      final Map<String, dynamic> data = note.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      Future<Signup_Modle> createLogin(
        String Key,
        String Username,
        String Password,
        String Name,
        String Status,
        String Profile_picture,
        String Latlong,
        String Following,
        String Followers,
        String Facebook_id,
        String Email_id,
        String Device_id,
        String Device,
        String Cover_picture,
        String Country,
        String About_me,
      ) async {
        final TransactionHandler createTransaction = (Transaction tx) async {
          final DocumentSnapshot ds = await tx.get(userlogin.document());

          /*   userlogin.document()
         .setData({ 'title': 'title', 'author': 'author' });*/
        };

        return Firestore.instance
            .runTransaction(createTransaction)
            .then((mapData) {
          return Signup_Modle.fromMap(mapData);
        }).catchError((error) {
          print('error: $error');
          return null;
        });
      }

      return Report.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  Future<Share> createShareList(String Share_id, String User_id, DateTime Date,
      String Share_list_name, List share_product_id) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(share_list.document());

      final Share note = new Share(
          ds.documentID, User_id, Date, Share_list_name, share_product_id);
      final Map<String, dynamic> data = note.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      Future<Signup_Modle> createLogin(
          String Key,
          String Username,
          String Password,
          String Name,
          String Status,
          String Profile_picture,
          String Latlong,
          String Following,
          String Followers,
          String Facebook_id,
          String Email_id,
          String Device_id,
          String Device,
          String Cover_picture,
          String Country,
          String About_me,
          String refer_code) async {
        final TransactionHandler createTransaction = (Transaction tx) async {
          final DocumentSnapshot ds = await tx.get(userlogin.document());

          /*   userlogin.document()
         .setData({ 'title': 'title', 'author': 'author' });*/

          final Signup_Modle note = new Signup_Modle(
              ds.documentID,
              Username,
              Password,
              Name,
              Status,
              Profile_picture,
              Latlong,
              Following,
              Followers,
              Facebook_id,
              Email_id,
              Device_id,
              Device,
              Cover_picture,
              Country,
              About_me,
              refer_code);
          final Map<String, dynamic> data = note.toMap();

          await tx.set(ds.reference, data);

          return data;
        };

        return Firestore.instance
            .runTransaction(createTransaction)
            .then((mapData) {
          return Signup_Modle.fromMap(mapData);
        }).catchError((error) {
          print('error: $error');
          return null;
        });
      }

      return Share.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  Future<dynamic> updateSharelist(Share share) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds =
          await tx.get(share_list.document(share.share_id));

      await tx.update(ds.reference, share.toMap());
      return {'updated': true};
    };

    return await Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => result['updated'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

/*-----------------------------------------------Share_List_Item--------------------------------------*/

  Future<Share_List> createfavouriteShareList(
    String Share_list_id,
    String User_id,
    String Product_id,
    String Share_id,
    DateTime Date,
    String Share_list_name,
  ) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(share_list_item.document());

      final Share_List note = new Share_List(
          ds.documentID, User_id, Product_id, Share_id, Date, Share_list_name);
      final Map<String, dynamic> data = note.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      Future<Signup_Modle> createLogin(
          String Key,
          String Username,
          String Password,
          String Name,
          String Status,
          String Profile_picture,
          String Latlong,
          String Following,
          String Followers,
          String Facebook_id,
          String Email_id,
          String Device_id,
          String Device,
          String Cover_picture,
          String Country,
          String About_me,
          String refer_code) async {
        final TransactionHandler createTransaction = (Transaction tx) async {
          final DocumentSnapshot ds = await tx.get(userlogin.document());

          /*   userlogin.document()
         .setData({ 'title': 'title', 'author': 'author' });*/

          final Signup_Modle note = new Signup_Modle(
              ds.documentID,
              Username,
              Password,
              Name,
              Status,
              Profile_picture,
              Latlong,
              Following,
              Followers,
              Facebook_id,
              Email_id,
              Device_id,
              Device,
              Cover_picture,
              Country,
              About_me,
              refer_code);
          final Map<String, dynamic> data = note.toMap();

          await tx.set(ds.reference, data);

          return data;
        };

        return Firestore.instance
            .runTransaction(createTransaction)
            .then((mapData) {
          return Signup_Modle.fromMap(mapData);
        }).catchError((error) {
          print('error: $error');
          return null;
        });
      }

      return Share_List.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  /*-----------------------------------------------Favourite_Item--------------------------------------*/

  Future<Favorite> createfavouriteItem(
    String Favourite_id,
    String User_id,
    String Product_id,
    DateTime Date,
    String Status,
    String Favourite_name,
  ) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(Favorite_item.document());

      final Favorite note = new Favorite(
          ds.documentID, User_id, Product_id, Date, Status, Favourite_name);
      final Map<String, dynamic> data = note.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      Future<Signup_Modle> createLogin(
          String Key,
          String Username,
          String Password,
          String Name,
          String Status,
          String Profile_picture,
          String Latlong,
          String Following,
          String Followers,
          String Facebook_id,
          String Email_id,
          String Device_id,
          String Device,
          String Cover_picture,
          String Country,
          String About_me,
          String refer_code) async {
        final TransactionHandler createTransaction = (Transaction tx) async {
          final DocumentSnapshot ds = await tx.get(userlogin.document());

          /*   userlogin.document()
         .setData({ 'title': 'title', 'author': 'author' });*/

          final Signup_Modle note = new Signup_Modle(
              ds.documentID,
              Username,
              Password,
              Name,
              Status,
              Profile_picture,
              Latlong,
              Following,
              Followers,
              Facebook_id,
              Email_id,
              Device_id,
              Device,
              Cover_picture,
              Country,
              About_me,
              refer_code);
          final Map<String, dynamic> data = note.toMap();

          await tx.set(ds.reference, data);

          return data;
        };

        return Firestore.instance
            .runTransaction(createTransaction)
            .then((mapData) {
          return Signup_Modle.fromMap(mapData);
        }).catchError((error) {
          print('error: $error');
          return null;
        });
      }

      return Favorite.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }
  /*-------------------------------------New-Following-------------------------------------------------*/

  Future<FollowModel> add_Follow_new(DateTime Date, String FollowId,
      String Following_id, String Key, String Status) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(followCollection.document());

      final FollowModel note =
          new FollowModel(Date, FollowId, Following_id, ds.documentID, Status);
      final Map<String, dynamic> data = note.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      Future<Signup_Modle> createLogin(
          String Key,
          String Username,
          String Password,
          String Name,
          String Status,
          String Profile_picture,
          String Latlong,
          String Following,
          String Followers,
          String Facebook_id,
          String Email_id,
          String Device_id,
          String Device,
          String Cover_picture,
          String Country,
          String About_me,
          String refer_code) async {
        final TransactionHandler createTransaction = (Transaction tx) async {
          final DocumentSnapshot ds = await tx.get(userlogin.document());
          final Signup_Modle note = new Signup_Modle(
              ds.documentID,
              Username,
              Password,
              Name,
              Status,
              Profile_picture,
              Latlong,
              Following,
              Followers,
              Facebook_id,
              Email_id,
              Device_id,
              Device,
              Cover_picture,
              Country,
              About_me,
              refer_code);
          final Map<String, dynamic> data = note.toMap();
          await tx.set(ds.reference, data);
          return data;
        };

        return Firestore.instance
            .runTransaction(createTransaction)
            .then((mapData) {
          return Signup_Modle.fromMap(mapData);
        }).catchError((error) {
          print('error: $error');
          return null;
        });
      }

      return FollowModel.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  /*-------------------------------------------delete_favourite-------------------------------*/

  Future<dynamic> deleteFavorit(String id) async {
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(Favorite_item.document(id));

      await tx.delete(ds.reference);
      return {'deleted': true};
    };

    return Firestore.instance
        .runTransaction(deleteTransaction)
        .then((result) => result['deleted'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  /*-----------------------------------------------Cart_Item--------------------------------------*/

  Future<Cart> cartItem(
    String Cart_id,
    String Product_id,
    String Status,
    String User_id,
    DateTime Date,
  ) async {
    TransactionHandler createTransaction = (Transaction tx) async {
      // print("Debuge : service call");
      final DocumentSnapshot ds = await tx.get(cartCollection.document());

      final Cart note =
          new Cart(ds.documentID, Product_id, Status, User_id, Date);
      final Map<String, dynamic> data = note.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    // add new
    // return Firestore.instance.runTransaction((Transaction transaction) async {
    //   print("Transaction call");
    //   DocumentSnapshot ds = await transaction.get(cartCollection.document());
    //   final Cart note =
    //       new Cart(ds.documentID, Product_id, Status, User_id, Date);
    //   final Map<String, dynamic> data = note.toMap();
    //   await transaction.set(ds.reference, data);
    //   return data;
    // }).then((mapData) async {
    //   //print("firebase add");
    //   return Cart.fromMap(mapData);
    // }).catchError((error) {
    //   print('error: $error');
    //   return null;
    // });

    return Firestore.instance
        .runTransaction(createTransaction)
        .then((mapData) async {
      //print("firebase add");
      return Cart.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  Future<dynamic> updateCart(Cart cart) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds =
          await tx.get(cartCollection.document(cart.Cart_id));

      await tx.update(ds.reference, cart.toMap());
      return {'updated': true};
    };

    return await Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => result['updated'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

/*--------------------------------------------------------------------------------------------*/
  Future<dynamic> updateAddress(Shipping_address address) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds =
          await tx.get(Shipping.document(address.shipping_add_id));

      await tx.update(ds.reference, address.toMap());
      return {'updated': true};
    };

    return Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => result['updated'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  /*-----------------------------------------Shipping_address--------------------------------------------------*/

  Future<Shipping_address> createShippingaddress(
    String Shipping_add_id,
    String User_id,
    String Name,
    String Address_line_1,
    String Address_line_2,
    String City,
    String Zip_code,
    String State,
    DateTime Date,
    String Is_default,
    String Status,
  ) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(Shipping.document());

      final Shipping_address note = new Shipping_address(
          ds.documentID,
          User_id,
          Name,
          Address_line_1,
          Address_line_2,
          City,
          Zip_code,
          State,
          Date,
          Is_default,
          Status);
      final Map<String, dynamic> data = note.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance
        .runTransaction(createTransaction)
        .then((mapData) async {
      return Shipping_address.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  Future<dynamic> deleteAddress(String id) async {
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(Shipping.document(id));

      await tx.delete(ds.reference);
      return {'deleted': true};
    };

    return Firestore.instance
        .runTransaction(deleteTransaction)
        .then((result) => result['deleted'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  Stream<QuerySnapshot> getaddressList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = Shipping.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }
    if (limit != null) {
      snapshots = snapshots.take(limit);
    }
    return snapshots;
  }

  Stream<QuerySnapshot> getShippingList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = shipping_list.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Stream<QuerySnapshot> getCategoryList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = categoryCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Stream<QuerySnapshot> getSharList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = share_list.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Stream<QuerySnapshot> getCartList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = cartCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Stream<QuerySnapshot> getFavoriteList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = Favorite_item.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Stream<QuerySnapshot> getShippingaddressList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = Shipping.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Stream<QuerySnapshot> getSharListItem({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = share_list_item.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Stream<QuerySnapshot> getSubCategoryList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = subcategoryCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Future<dynamic> updateNote(Shell_Product_Model note) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds =
          await tx.get(Product_item.document(note.product_id));

      await tx.update(ds.reference, note.toMap());
      return {'updated': true};
    };

    return Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => result['updated'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  Future<dynamic> deleteNote(String id) async {
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(Favorite_item.document(id));

      await tx.delete(ds.reference);
      return {'deleted': true};
    };

    return Firestore.instance
        .runTransaction(deleteTransaction)
        .then((result) => result['deleted'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  Future<dynamic> deleteshareitem(String id) async {
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(share_list_item.document(id));

      await tx.delete(ds.reference);
      return {'deleted': true};
    };

    return Firestore.instance
        .runTransaction(deleteTransaction)
        .then((result) => result['deleted'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  Future<dynamic> deleteCart(String id) async {
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(cartCollection.document(id));

      await tx.delete(ds.reference);
      return {'deleted': true};
    };

    return Firestore.instance
        .runTransaction(deleteTransaction)
        .then((result) => result['deleted'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  /*------------------------------------Product------------------------------------------*/

  /*---------ADD----------*/

  Future<Shell_Product_Model> add_Product(
      String Any_sign_wear,
      String category,
      String category_id,
      String country,
      DateTime date,
      String favourite_count,
      String is_cart,
      String is_favorite_count,
      int item_Ounces,
      String item_brand,
      String item_color,
      String item_description,
      String item_measurements,
      List item_picture,
      int item_pound,
      String item_price,
      String item_sale_price,
      String item_size,
      String item_sold,
      String item_sub_title,
      String item_title,
      String item_type,
      List packing_type,
      String picture,
      String Key,
      String retail_tag,
      String shipping_charge,
      String shipping_id,
      String status,
      String sub_category,
      String sub_category_id,
      String user_id,
      String tracking_id,
      String order_id,
      String like_new) async {
    final TransactionHandler createTransaction1 = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(productCollection.document());

      final Shell_Product_Model product = new Shell_Product_Model(
          Any_sign_wear,
          category,
          category_id,
          country,
          date,
          favourite_count,
          is_cart,
          is_favorite_count,
          item_Ounces,
          item_brand,
          item_color,
          item_description,
          item_measurements,
          item_picture,
          item_pound,
          item_price,
          item_sale_price,
          item_size,
          item_sold,
          item_sub_title,
          item_title,
          item_type,
          packing_type,
          picture,
          ds.documentID,
          retail_tag,
          shipping_charge,
          shipping_id,
          status,
          sub_category,
          sub_category_id,
          user_id,
          tracking_id,
          order_id,
          like_new);
      final Map<String, dynamic> data = product.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance
        .runTransaction(createTransaction1)
        .then((mapData) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('product_id', mapData['product_id']);
      return Shell_Product_Model.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

/*---------Get----------*/

  Stream<QuerySnapshot> getProductList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = productCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }
    if (limit != null) {
      snapshots = snapshots.take(limit);
    }
    return snapshots;
  }

  /*---------Get----------*/

  Stream<QuerySnapshot> getBrandList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = brandCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }
    if (limit != null) {
      snapshots = snapshots.take(limit);
    }
    return snapshots;
  }

/*---------Update----------*/

  Future<dynamic> updateProduct(Shell_Product_Model _product) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds =
          await tx.get(productCollection.document(_product.product_id));

      await tx.update(ds.reference, _product.toMap());
      return {'updated': true};
    };

    return await Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => result['updated'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

/*---------Delete----------*/

  Future<dynamic> deleteProduct(String id) async {
    print('id : $id');
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      // print("call");
      final DocumentSnapshot ds = await tx.get(productCollection.document(id));

      await tx.delete(ds.reference);
      return {'deleted': true};
    };

    return Firestore.instance
        .runTransaction(deleteTransaction)
        .then((result) => result['deleted'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  /*------------------------------------Brand------------------------------------------*/

  /*---------Get----------*/

//
//  Stream<QuerySnapshot> getBrandList({int offset, int limit}) {
//    Stream<QuerySnapshot> snapshots = brandCollection.snapshots();
//
//
//    if (offset != null) {
//      snapshots = snapshots.skip(offset);
//    }
//
//    if (limit != null) {
//      snapshots = snapshots.take(limit);
//    }
//
//    return snapshots;
//  }

  /*---------ADD----------*/

  Future<BrandModel> add_Brand(
    String Key,
    String Brand_name,
    String Status,
  ) async {
    final TransactionHandler createTransaction1 = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(brandCollection.document());

      final BrandModel brand =
          new BrandModel(ds.documentID, Brand_name, Status);
      final Map<String, dynamic> data = brand.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance
        .runTransaction(createTransaction1)
        .then((mapData) {
      return BrandModel.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  /*------------------------------------Follow------------------------------------------*/

  /*---------Get----------*/

  Stream<QuerySnapshot> getFollwList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = followCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  /*---------ADD----------*/

  Future<FollowModel> add_Follow(DateTime Date, String FollowId,
      String Following_id, String Key, String Status) async {
    final TransactionHandler foloowTransaction1 = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(followCollection.document());

      final FollowModel follow =
          new FollowModel(Date, FollowId, Following_id, ds.documentID, Status);
      final Map<String, dynamic> data = follow.toMap();

      await tx.set(ds.reference, data);

      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('unfollowing', data['id']);
      return data;
    };

    return Firestore.instance
        .runTransaction(foloowTransaction1)
        .then((mapData) {
      return FollowModel.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return false;
    });
  }

/*---------Delete----------*/
  Future<dynamic> Unfollowing(String id) async {
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(followCollection.document(id));

      await tx.delete(ds.reference);
      return {'deleted': true};
    };
    return Firestore.instance
        .runTransaction(deleteTransaction)
        .then((result) => result['deleted'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

//  Future<dynamic> Unfollowing(String id) async {
//    final TransactionHandler deleteTransaction = (Transaction tx) async {
//      final DocumentSnapshot ds = await tx.get(followCollection.document(id));
//
//      await tx.delete(ds.reference);
//      return {'deleted': true};
//    };
//
//    return Firestore.instance
//        .runTransaction(deleteTransaction)
//        .then((result) => result['deleted'])
//        .catchError((error) {
//      print('error: $error');
//      return false;
//    });
//  }

  /*------------------------------------Editor------------------------------------------*/

  /*---------Get----------*/

  Stream<QuerySnapshot> getEditorList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = editorCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  /*------------------------------------Editor------------------------------------------*/

  /*---------Get----------*/

  Stream<QuerySnapshot> getWalletData({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = walletCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  /*------------------------------------Brand------------------------------------------*/

  /*---------Get----------*/

  Stream<QuerySnapshot> getMessages({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = messageCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  /*---------ADD----------*/

  Future<MessageModel> and_Message(
      String Attachment,
      DateTime Date,
      String Message,
      DateTime Message_date,
      int Message_type,
      String Receiver_id,
      String Sender_id,
      String Sender_image,
      String Sender_name) async {
    final TransactionHandler createTransaction1 = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(messageCollection.document());

      final brand = new MessageModel(Attachment, Date, Message, Message_date,
          Message_type, Receiver_id, Sender_id, Sender_image, Sender_name);
      final Map<String, dynamic> data = brand.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance
        .runTransaction(createTransaction1)
        .then((mapData) {
      return MessageModel.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  Future<MessageListModel> and_Messagelist(
    String Chat_id,
    DateTime Date,
    String Receiver_id,
    String Sender_id,
  ) async {
    final TransactionHandler createTransaction1 = (Transaction tx) async {
      final DocumentSnapshot ds =
          await tx.get(messagelistCollection.document());

      final brand =
          new MessageListModel(ds.documentID, Date, Receiver_id, Sender_id);
      final Map<String, dynamic> data = brand.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance
        .runTransaction(createTransaction1)
        .then((mapData) {
      return MessageListModel.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  Future<dynamic> updateMessagelist(MessageListModel _message) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds =
          await tx.get(messagelistCollection.document(_message.chat_id));

      await tx.update(ds.reference, _message.toMap());
      return {'updated': true};
    };

    return await Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => result['updated'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }
}

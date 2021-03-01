class Item_OrderModel {
  String Key;
  DateTime Date;
  String Item_id;
  DateTime Order_date;
  String Order_status;
  String Payment_method;
  String Promo_code;
  String Purchase_price;
  List shipping_address;
  String Shipping_charge;
  DateTime Shipping_date;
  String Shipping_status;
  String User_id;
  Pickup_order pickup_order;
  String tracking_id;

  Item_OrderModel(
      this.Key,
      this.Date,
      this.Item_id,
      this.Order_date,
      this.Order_status,
      this.Payment_method,
      this.Promo_code,
      this.Purchase_price,
      this.shipping_address,
      this.Shipping_charge,
      this.Shipping_date,
      this.Shipping_status,
      this.User_id,
      this.pickup_order);

  /*Item_OrderModel.map(dynamic obj) {
    this.Key = obj['order_id'];
    this.Date = obj['date'];
    this.Item_id = obj['item_id'];
    this.Order_date = obj['order_date'];
    this.Order_status = obj['order_status'];
    this.Payment_method = obj['payment_method'];
    this.Promo_code = obj['promo_code'];
    this.Purchase_price = obj['purchase_price'];
    this.shipping_address = obj['shipping_address'];
    this.Shipping_charge = obj['shipping_charge'];
    this.Shipping_date = obj['shipping_date'];
    this.Shipping_status = obj['shipping_status'];
    this.User_id = obj['user_id'];

  }*/

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (Key != null) {
      map['order_id'] = Key;
    }
    map['date'] = Date;
    map['item_id'] = Item_id;

    map['order_date'] = Order_date;

    map['order_status'] = Order_status;

    map['payment_method'] = Payment_method;

    map['promo_code'] = Promo_code;

    map['purchase_price'] = Purchase_price;

    map['shipping_address'] = shipping_address;

    map['shipping_charge'] = Shipping_charge;
    map['shipping_date'] = Shipping_date;
    map['shipping_status'] = Shipping_status;
    map['user_id'] = User_id;
    map['pickup_order'] = pickup_order;

    return map;
  }

  Item_OrderModel.fromMap(Map<String, dynamic> map) {
    this.Key = map['order_id'];
    this.Date = map['date'].toDate();

    this.Item_id = map['item_id'];

    this.Order_date = map['order_date'].toDate();

    this.Order_status = map['order_status'];

    this.Payment_method = map['payment_method'];

    this.Promo_code = map['promo_code'];

    this.Purchase_price = map['purchase_price'];

    this.shipping_address = new List<String>.from(map['shipping_address']);

    this.Shipping_charge = map['shipping_charge'];
    this.Shipping_date = map['shipping_date'].toDate();
    this.Shipping_status = map['shipping_status'];
    this.User_id = map['user_id'];
    this.pickup_order = new Pickup_order.fromMap(
        map['pickup_order']); //.map((i) => Pickup_order.fromMap(i));
    //this.pickup_order = new List<Pickup_order>. Pickup_order.fromMap(map['pickup_order']) as List<Pickup_order>;
//    this.pickup_order = new  List<Pickup_order>.from(map['pickup_order']).toList();

    /* this.pickup_order = (map['pickup_order']  as List).map((i) {

      return Pickup_order.fromMap(i);

    }).toList();
*/
  }
}

class Pickup_order {
  String day_week;
  String label;
  String pickup_date;
  String seller_id;
  String status;

  Pickup_order(
      this.day_week, this.label, this.pickup_date, this.seller_id, this.status);

/*
  factory Pickup_order.fromJson(Map<String, dynamic> parsedJson){

    return Pickup_order(
        day_week: parsedJson['day_week'],
        label: parsedJson['label'],
        pickup_date: parsedJson['pickup_date'],
        seller_id:  parsedJson['seller_id'],
        status: parsedJson['status'],

    );
  }*/

  Pickup_order.fromMap(Map map) {
    this.day_week = map['day_week'];
    this.label = map['label'];

    this.pickup_date = map['pickup_date'];

    this.seller_id = map['seller_id'];

    this.status = map['status'];
  }
}

/*

class Item_OrderModel {
  String Key;
  DateTime Date;
  String Item_id;
  DateTime Order_date;
  String Order_status;
  String Payment_method;
  String Promo_code;
  String Purchase_price;
  List shipping_address;
  String Shipping_charge;
  DateTime Shipping_date;
  String Shipping_status;
  String User_id;
  List<Pickup_order> pickup_order =[];


  Item_OrderModel({this.Key, this.Date, this.Item_id, this.Order_date,
    this.Order_status, this.Payment_method, this.Promo_code,
    this.Purchase_price, this.shipping_address, this.Shipping_charge,
    this.Shipping_date, this.Shipping_status, this.User_id,
    this.pickup_order});

  */
/*Item_OrderModel.map(dynamic obj) {
    this.Key = obj['order_id'];
    this.Date = obj['date'];
    this.Item_id = obj['item_id'];
    this.Order_date = obj['order_date'];
    this.Order_status = obj['order_status'];
    this.Payment_method = obj['payment_method'];
    this.Promo_code = obj['promo_code'];
    this.Purchase_price = obj['purchase_price'];
    this.shipping_address = obj['shipping_address'];
    this.Shipping_charge = obj['shipping_charge'];
    this.Shipping_date = obj['shipping_date'];
    this.Shipping_status = obj['shipping_status'];
    this.User_id = obj['user_id'];

  }*/ /*



  factory Item_OrderModel.fromJson(Map<String, dynamic> json) {
    return Item_OrderModel(
        Key: json['order_id'],
        Date:json['date'],
        Item_id: json['item_id'],
        Order_date: json['order_date'],
        Order_status: json['order_status'],
        Payment_method:json['payment_method'],
        Promo_code: json['promo_code'],
        Purchase_price:  json['purchase_price'],
        shipping_address:   List<String>.from(json['shipping_address']),
    Shipping_charge: json['shipping_charge'],
    Shipping_date: json['shipping_date'],
    Shipping_status: json['shipping_status'],
    User_id: json['user_id'],
    pickup_order : new Map.from(json['pickup_order']) as List<Pickup_order>;
    );

  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (Key != null) {
      map['order_id'] = Key;
    }
    map['date'] = Date;
    map['item_id'] = Item_id;

    map['order_date'] = Order_date;

    map['order_status'] = Order_status;

    map['payment_method'] = Payment_method;

    map['promo_code'] = Promo_code;

    map['purchase_price'] = Purchase_price;

    map['shipping_address'] = shipping_address;

    map['shipping_charge'] = Shipping_charge;
    map['shipping_date'] = Shipping_date;
    map['shipping_status'] = Shipping_status;
    map['user_id'] = User_id;
    map['pickup_order'] = pickup_order;

    return map;
  }

  Item_OrderModel.fromMap(Map<String, dynamic> map) {
    this.Key = map['order_id'];
    this.Date = map['date'];

    this.Item_id = map['item_id'];

    this.Order_date = map['order_date'];

    this.Order_status = map['order_status'];

    this.Payment_method = map['payment_method'];

    this.Promo_code = map['promo_code'];

    this.Purchase_price = map['purchase_price'];

    this.shipping_address = new List<String>.from(map['shipping_address']);

    this.Shipping_charge = map['shipping_charge'];
    this.Shipping_date = map['shipping_date'];
    this.Shipping_status = map['shipping_status'];
    this.User_id = map['user_id'];
    this.pickup_order = map['pickup_order'].map((i) =>
        Pickup_order.fromJson(i)).toList();
    //this.pickup_order = new List<Pickup_order>. Pickup_order.fromMap(map['pickup_order']) as List<Pickup_order>;
    this.pickup_order = new Map.from(map['pickup_order']) as List<Pickup_order> ; //List<Pickup_order>.from(map['pickup_order']).toList();


    */
/* this.pickup_order = (map['pickup_order']  as List).map((i) {

      return Pickup_order.fromMap(i);

    }).toList();
*/ /*

  }
}

class Pickup_order{

  String day_week;
  String label;
  String pickup_date;
  String seller_id;
  String status;

  Pickup_order({this.day_week, this.label, this.pickup_date, this.seller_id,
    this.status});


  factory Pickup_order.fromJson(Map<String, dynamic> parsedJson){

    return Pickup_order(
      day_week: parsedJson['day_week'],
      label: parsedJson['label'],
      pickup_date: parsedJson['pickup_date'],
      seller_id:  parsedJson['seller_id'],
      status: parsedJson['status'],

    );
  }

*/
/* Pickup_order.fromMap(Map<String, dynamic> map) {
    this.day_week = map['day_week'];
    this.label = map['label'];

    this.pickup_date = map['pickup_date'];

    this.seller_id = map['seller_id'];

    this.status = map['status'];


  }*/ /*

}
*/

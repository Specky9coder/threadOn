
class Cart{
  String Cart_id;
  String Product_id;
  String Status;
  String User_id;
  DateTime Date;



  Cart(this.Cart_id, this.Product_id, this.Status, this.User_id, this.Date);

  Cart.map(dynamic obj) {
    this.Cart_id = obj['cart_id'];
    this.Product_id = obj['product_id'];
    this.Status = obj['status'];
    this.User_id = obj['user_id'];
    this.Date = obj['date'];
  }

  String get cart_id => Cart_id;
  String get product_id => Product_id;
  String get status => Status ;
  String get user_id => User_id;
  DateTime get date => Date;


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (Cart_id != null) {
      map['cart_id'] = Cart_id;
    }
    map['product_id'] = Product_id;
    map['status'] = Status;
    map['user_id'] = user_id;
    map['date'] = Date;

    return map;
  }

  Cart.fromMap(Map<String, dynamic> map) {
    this.Cart_id = map['cart_id'];
    this.Product_id = map['product_id'];
    this.Status = map['status'];
    this.User_id = map['user_id'];
    this.Date = map['date'];
  }
}


class Shipping_model{

  String Method;
  String Other_info;
  String Id;
  String shipping_charge;
  String shipping_id;


  Shipping_model(this.Method, this.Other_info, this.Id, this.shipping_charge,
      this.shipping_id);

  Shipping_model.map(dynamic obj) {
    this.Method = obj['id'];
    this.Other_info = obj['method'];
    this.Id = obj['other_info'];
    this.shipping_charge = obj['shipping_charge'];
    this.shipping_id = obj['shipping_id'];
  }


  String get cat_id => Method;
  String get cat_name => Other_info ;
  String get cat_image => Id;
  String get shipping_charge1 =>shipping_charge;
  String get shipping_id1 =>shipping_id;


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (Id != null) {
      map['id'] = Id;
    }
    map['method'] = Method;
    map['other_info'] = Other_info;
    map['shipping_charge'] = shipping_charge1;
    map['shipping_id'] = shipping_id1;

    return map;
  }

  Shipping_model.fromMap(Map<String, dynamic> map) {
    this.Id = map['id'];
    this.Method = map['method'];
    this.Other_info = map['other_info'];
    this.shipping_charge = map['shipping_charge'];
    this.shipping_id = map['shipping_id'];
  }
}

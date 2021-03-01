class PaymentBillModel{

  String key;
  String id;
  DateTime date;
  String external_customer_id;
  String type;
  String number;
  String expire_month;
  String expire_year;
  String first_name;
  String last_name;
  List billing_address;
  String valid_until;
  String create_time;
  String update_time;
  String user_id;
  String access_token;


  PaymentBillModel(this.key, this.id, this.date, this.external_customer_id,
      this.type, this.number, this.expire_month, this.expire_year,
      this.first_name, this.last_name, this.billing_address, this.valid_until,
      this.create_time, this.update_time, this.user_id,this.access_token);

  PaymentBillModel.map(dynamic obj) {
    this.key = obj['key'];
    this.id = obj['id'];
    this.date = obj['date'];
    this.external_customer_id = obj['external_customer_id'];
    this.type = obj['type'];
    this.number = obj['number'];
    this.expire_month = obj['expire_month'];
    this.expire_year = obj['expire_year'];
    this.first_name = obj['first_name'];
    this.last_name = obj['last_name'];
    this.billing_address = obj['billing_address'];
    this.valid_until = obj['valid_until'];
    this.create_time = obj['create_time'];
    this.update_time = obj['update_time'];
    this.user_id = obj['user_id'];
    this.access_token =obj['access_token'];
  }

Map<String, dynamic> toMap() {
  var map = new Map<String, dynamic>();
  if (key != null) {
    map['key'] = key;
  }
  map['id'] = id;
  map['date'] = date;
  map['external_customer_id'] = external_customer_id;
  map['type'] = type;
  map['number'] = number;
  map['expire_month'] = expire_month;
  map['expire_year'] = expire_year;
  map['first_name'] = first_name;
  map['last_name'] = last_name;
  map['billing_address'] = billing_address.toList();
  map['valid_until'] = valid_until;
  map['create_time'] = create_time;
  map['update_time'] = update_time;
  map['user_id'] = user_id;
  map['access_token'] = access_token;

  return map;
}

  PaymentBillModel.fromMap(Map<String, dynamic> map) {
  this.key = map['key'];
  this.id = map['id'];
  this.date = map['date'];
  this.external_customer_id = map['external_customer_id'];
  this.type = map['type'];
  this.number = map['number'];
  this.expire_month = map['expire_month'];
  this.expire_year = map['expire_year'];
  this.first_name = map['first_name'];
  this.last_name = map['last_name'];

  this.billing_address = new List<String>.from(map['billing_address']);
  this.valid_until = map['valid_until'];
  this.create_time = map['create_time'];
  this.update_time = map['update_time'];
  this.user_id = map['user_id'];
  this.access_token = map['access_token'];
}
}

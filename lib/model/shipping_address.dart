class Shipping_address{
  String _shipping_add_id;
  String _user_id;
  String _name;
  String _address_line_1;
  String _address_line_2;
  String _city;
  String _zip_code;
  String _state;
  DateTime _date;
  String _is_default;
  String _status;

  Shipping_address(this._shipping_add_id, this._user_id, this._name,this._address_line_1, this._address_line_2, this._city, this._zip_code,
      this._state, this._date, this._is_default, this._status);

  Shipping_address.map(dynamic obj) {
    this._shipping_add_id = obj['shipping_add_id'];
    this._user_id = obj['user_id'];
    this._name = obj['name'];
    this._address_line_1 = obj['address_line_1'];
    this._address_line_2 = obj['address_line_2'];
    this._city = obj['city'];
    this._zip_code = obj['zipcode'];
    this._state = obj['state'];
    this._date = obj['date'];
    this._is_default = obj['id_default'];
    this._status = obj['status'];
  }

  String get shipping_add_id => _shipping_add_id;
  String get user_id => _user_id ;
  String get name => _name;
  String get address_line_1 => _address_line_1;
  String get address_line_2 => _address_line_2;
  String get city => _city;
  String get zip_code => _zip_code;
  String get state => _state;
  DateTime get date => _date;
  String get is_default => _is_default;
  String get status => _status;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_shipping_add_id != null) {
      map['shipping_add_id'] = _shipping_add_id;
    }
    map['user_id'] = _user_id;
    map['name'] = _name;
    map['address_line_1'] = _address_line_1;
    map['address_line_2'] = _address_line_2;
    map['city'] = _city;
    map['zipcode'] = _zip_code;
    map['state'] = _state;
    map['date'] = _date;
    map['id_default'] = _is_default;
    map['status'] = _status;

    return map;
  }

  Shipping_address.fromMap(Map<String, dynamic> map) {
    this._shipping_add_id= map['shipping_add_id'];
    this._user_id= map['user_id'];
    this._name= map['name'];
    this._address_line_1= map['address_line_1'];
    this._address_line_2= map['address_line_2'];
    this._city= map['city'];
    this._zip_code= map['zipcode'];
    this._state= map['state'];
    this._date= map['date'];
    this._is_default= map['id_default'];
    this._status= map['status'];
  }
}
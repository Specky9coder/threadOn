
class Wallet_Model{


  String available_amount;
  DateTime date;
  String lifetime_earning;
  String pending_amount;
  String site_credit;
  String user_id;
  String wallet_id;


  Wallet_Model(this.available_amount, this.date, this.lifetime_earning,
      this.pending_amount, this.site_credit, this.user_id, this.wallet_id);

  Wallet_Model.map(dynamic obj) {
    this.available_amount = obj['available_amount'];
    this.date = obj['date'];
    this.lifetime_earning = obj['lifetime_earning'];
    this.pending_amount = obj['pending_amount'];
    this.site_credit = obj['site_credit'];
    this.user_id = obj['user_id'];
    this.wallet_id = obj['wallet_id'];
  }


  String get _available_amount => available_amount;
  DateTime get _date => date;
  String get _lifetime_earning => lifetime_earning;
  String get _pending_amount => pending_amount ;
  String get _site_credit => site_credit;
  String get _user_id => user_id;
  String get _wallet_id => wallet_id;



  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['available_amount'] = _available_amount;

    map['date'] = date;
    map['lifetime_earning'] = _lifetime_earning;
    map['pending_amount'] = _pending_amount;
    map['site_credit'] = _site_credit;
    map['user_id'] = _user_id;
    map['wallet_id'] = _wallet_id;

    return map;
  }

  Wallet_Model.fromMap(Map<String, dynamic> map) {
    this.available_amount = map['available_amount'];
    this.date = map['date'];
    this.lifetime_earning = map['lifetime_earning'];
    this.pending_amount = map['pending_amount'];
    this.site_credit = map['site_credit'];
    this.user_id = map['user_id'];
    this.wallet_id = map['wallet_id'];
  }



}
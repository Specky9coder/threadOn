class MessageModel{


  String Attachment;
  DateTime Date;
  String Message;
  DateTime Message_date;
  int Message_type;
  String Receiver_id;
  String Sender_id;
  String Sender_image;
  String Sender_name;


  MessageModel(this.Attachment, this.Date, this.Message, this.Message_date,
       this.Message_type, this.Receiver_id, this.Sender_id,
      this.Sender_image, this.Sender_name);

  MessageModel.map(dynamic obj) {

    this.Attachment = obj['attachment'];
    this.Date = obj['date'];
    this.Message = obj['message'];
    this.Message_date = obj['message_date'];
    this.Message_type = obj['message_type'];
    this.Receiver_id = obj['receiver_id'];
    this.Sender_id = obj['sender_id'];
    this.Sender_image = obj['sender_image'];
    this.Sender_name = obj['sender_name'];
  }


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map['attachment'] = Attachment;
    map['date'] = Date;
    map['message'] = Message;
    map['message_date'] = Message_date;
    map['message_type'] = Message_type;
    map['receiver_id'] = Receiver_id;
    map['sender_image'] = Sender_image;
    map['sender_name'] = Sender_name;

    return map;
  }


  MessageModel.fromMap(Map<String, dynamic> map) {

    this.Attachment = map['attachment'];
    this.Date = map['date'];
    this.Message = map['message'];
    this.Message_date = map['message_date'];
    this.Message_type = map['message_type'];
    this.Receiver_id = map['receiver_id'];
    this.Sender_id = map['sender_id'];
    this.Sender_image = map['sender_image'];
    this.Sender_name = map['sender_name'];
  }

}
 class MessageListModel{

   String chat_id;
   DateTime date;
   String receiver_id;
   String sender_id;


   MessageListModel(this.chat_id, this.date, this.receiver_id, this.sender_id);

   MessageListModel.map(dynamic obj) {
     this.chat_id = obj['chat_id'];
     this.date = obj['date'];
     this.receiver_id = obj['receiver_id'];
     this.sender_id = obj['sender_id'];
   }

   Map<String, dynamic> toMap() {
     var map = new Map<String, dynamic>();
     if (chat_id != null) {
       map['chat_id'] = chat_id;
     }
     map['date'] = date;
     map['receiver_id'] = receiver_id;
     map['sender_id'] = sender_id;

     return map;
   }

   MessageListModel.fromMap(Map<String, dynamic> map) {
     this.chat_id = map['chat_id'];
     this.date = map['date'];
     this.receiver_id = map['receiver_id'];
     this.sender_id = map['sender_id'];

   }
}
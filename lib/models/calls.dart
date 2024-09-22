class Calls {
  final String callerID;
  final String callerName;
  final String callerPic;
  final String receiverId;
  final String receieverName;
  final String receiverPic;
  final String callId;
  final bool hasDialled;
  Calls({
    required this.callerID,
    required this.callerName,
    required this.callerPic,
    required this.receiverId,
    required this.receieverName,
    required this.receiverPic,
    required this.callId,
    required this.hasDialled,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'callerID': callerID,
      'callerName': callerName,
      'callerPic': callerPic,
      'receiverId': receiverId,
      'receieverName': receieverName,
      'receiverPic': receiverPic,
      'callId': callId,
      'hasDialled': hasDialled,
    };
  }

  factory Calls.fromMap(Map<String, dynamic> map) {
    return Calls(
      callerID: map['callerID'] as String,
      callerName: map['callerName'] as String,
      callerPic: map['callerPic'] as String,
      receiverId: map['receiverId'] as String,
      receieverName: map['receieverName'] as String,
      receiverPic: map['receiverPic'] as String,
      callId: map['callId'] as String,
      hasDialled: map['hasDialled'] as bool,
    );
  }
}

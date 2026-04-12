class TransactionModel {
  final String id;
  final String senderWallet;
  final String receiverWallet;
  final double amount;
  final String status;
  final String type;
  final DateTime? createdAt;

  TransactionModel({
    required this.id,
    required this.senderWallet,
    required this.receiverWallet,
    required this.amount,
    required this.status,
    required this.type,
    this.createdAt,
  });

  bool get isSuccess => status == 'SUCCESS';
  bool get isSend => type == 'SEND';
  bool get isReceive => type == 'RECEIVE';
  bool get isAddMoney => type == 'ADD_MONEY';

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    id: json['id']?.toString() ?? '',
    senderWallet: json['senderWallet'] ?? '',
    receiverWallet: json['receiverWallet'] ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    status: json['status'] ?? '',
    type: json['type'] ?? '',
    createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
  );
}
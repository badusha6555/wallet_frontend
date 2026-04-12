// ─── Remittance Provider Model ────────────────────────
class RemittanceProvider {
  final String providerName;
  final double fee;
  final double rate;
  final double finalAmount;

  RemittanceProvider({
    required this.providerName,
    required this.fee,
    required this.rate,
    required this.finalAmount,
  });

  factory RemittanceProvider.fromJson(Map<String, dynamic> json) => RemittanceProvider(
    providerName: json['providerName'] ?? '',
    fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
    rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
    finalAmount: (json['finalAmount'] as num?)?.toDouble() ?? 0.0,
  );
}

// ─── Remittance Result Model ──────────────────────────
class RemittanceResult {
  final String bestProvider;
  final List<RemittanceProvider> providers;

  RemittanceResult({required this.bestProvider, required this.providers});

  factory RemittanceResult.fromJson(Map<String, dynamic> json) => RemittanceResult(
    bestProvider: json['bestProvider'] ?? '',
    providers: (json['providers'] as List<dynamic>? ?? [])
        .map((e) => RemittanceProvider.fromJson(e))
        .toList(),
  );

  RemittanceProvider? get best =>
      providers.where((p) => p.providerName == bestProvider).firstOrNull;
}

// ─── User Model ──────────────────────────────────────
class UserModel {
  final String username;
  final String email;
  final String? phone;
  final String? address;
  final String? profileImage;
  final double? balance;

  UserModel({
    required this.username,
    required this.email,
    this.phone,
    this.address,
    this.profileImage,
    this.balance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'],
    address: json['address'],
    profileImage: json['profileImage'],
    balance: (json['balance'] as num?)?.toDouble(),
  );
}

// ─── Wallet Model ─────────────────────────────────────
class WalletModel {
  final String username;
  final String walletNumber;
  final double balance;
  final bool isVerified;

  WalletModel({
    required this.username,
    required this.walletNumber,
    required this.balance,
    required this.isVerified,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
    username: json['username'] ?? '',
    walletNumber: json['walletNumber'] ?? '',
    balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    isVerified: json['verified'] ?? json['isVerified'] ?? false,
  );
}

// ─── Transaction Model ───────────────────────────────
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
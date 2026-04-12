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
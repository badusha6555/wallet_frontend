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
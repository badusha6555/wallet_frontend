import 'package:fintech_wallet/models/remittance_provider_model.dart';

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
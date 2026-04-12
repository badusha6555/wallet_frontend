import 'package:flutter/material.dart';



import '../core/api/api_service.dart';
import '../models/transcation_model.dart';
import '../models/remittance_result_model.dart';


enum RemittanceStatus { idle, loading, loaded, error }

class RemittanceController extends ChangeNotifier {
  RemittanceStatus _status = RemittanceStatus.idle;
  RemittanceResult? _result;
  String? _error;
  double _lastAmount = 1000;
  String _lastFromCurrency = 'SAR';
  String _lastToCurrency = 'INR';
  String _lastCountry = 'India';

  RemittanceStatus get status => _status;
  RemittanceResult? get result => _result;
  String? get error => _error;
  double get lastAmount => _lastAmount;
  String get lastFromCurrency => _lastFromCurrency;
  String get lastToCurrency => _lastToCurrency;
  String get lastCountry => _lastCountry;
  bool get isLoading => _status == RemittanceStatus.loading;

  Future<void> optimize({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    required String receiverCountry,
  }) async {
    _status = RemittanceStatus.loading;
    _error = null;
    _lastAmount = amount;
    _lastFromCurrency = fromCurrency;
    _lastToCurrency = toCurrency;
    _lastCountry = receiverCountry;
    notifyListeners();

    try {
      final data = await ApiService.optimizeRemittance(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        receiverCountry: receiverCountry,
      );
      _result = RemittanceResult.fromJson(data);
      _status = RemittanceStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = RemittanceStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _result = null;
    _status = RemittanceStatus.idle;
    _error = null;
    notifyListeners();
  }
}
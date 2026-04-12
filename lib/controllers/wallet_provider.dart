import 'package:flutter/material.dart';
import '../core/api/api_service.dart';
import '../models/transcation_model.dart';
import '../models/wallet_model.dart';

class WalletProvider extends ChangeNotifier {
  WalletModel? _wallet;
  List<TransactionModel> _transactions = [];
  bool _loading = false;
  bool _txnLoading = false;
  String? _error;

  WalletModel? get wallet => _wallet;
  List<TransactionModel> get transactions => _transactions;
  bool get loading => _loading;
  bool get txnLoading => _txnLoading;
  String? get error => _error;

  Future<void> loadWallet() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.getMyWallet();
      _wallet = WalletModel.fromJson(data);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _txnLoading = true;
    notifyListeners();
    try {
      final list = await ApiService.getTransactionHistory();
      _transactions = list.map((e) => TransactionModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    }
    _txnLoading = false;
    notifyListeners();
  }

  Future<bool> sendMoney(String receiverWallet, double amount) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final key = DateTime.now().millisecondsSinceEpoch.toString();
      await ApiService.sendMoney(
        receiverWalletNumber: receiverWallet,
        amount: amount,
        idempotencyKey: key,
      );
      await loadWallet();
      await loadTransactions();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addMoney(double amount) async {
    if (_wallet == null) return false;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await ApiService.addMoney(_wallet!.walletNumber, amount);
      await loadWallet();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<WalletModel?> verifyWallet(String walletNumber) async {
    try {
      final data = await ApiService.verifyWallet(walletNumber);
      return WalletModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _wallet = null;
    _transactions = [];
    _error = null;
    notifyListeners();
  }
}
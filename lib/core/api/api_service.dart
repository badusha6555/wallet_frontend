import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
//Authentication>>>>>>>>>>
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _headers(),
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
    );
    return _parse(res);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _parse(res);
  }

  // ─── WALLET ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getMyWallet() async {
    final res = await http.get(
      Uri.parse('$baseUrl/wallet/me'),
      headers: await _headers(auth: true),
    );
    return _parse(res);
  }

  static Future<Map<String, dynamic>> addMoney(String walletId, double amount) async {
    final res = await http.post(
      Uri.parse('$baseUrl/wallet/add/$walletId?amount=$amount'),
      headers: await _headers(auth: true),
    );
    return _parse(res);
  }

  static Future<Map<String, dynamic>> verifyWallet(String walletNumber) async {
    final res = await http.get(
      Uri.parse('$baseUrl/wallet/verify/$walletNumber'),
      headers: await _headers(auth: true),
    );
    return _parse(res);
  }

  static Future<Map<String, dynamic>> getBalance(String walletId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/wallet/balance/$walletId'),
      headers: await _headers(auth: true),
    );
    return _parse(res);
  }

  // ─── TRANSACTION ─────────────────────────────────────
  static Future<Map<String, dynamic>> sendMoney({
    required String receiverWalletNumber,
    required double amount,
    required String idempotencyKey,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/transaction/send'),
      headers: await _headers(auth: true),
      body: jsonEncode({
        'receiverWalletNumber': receiverWalletNumber,
        'amount': amount,
        'idempotencyKey': idempotencyKey,
      }),
    );
    return _parse(res);
  }

  static Future<List<dynamic>> getTransactionHistory() async {
    final res = await http.get(
      Uri.parse('$baseUrl/transaction/history'),
      headers: await _headers(auth: true),
    );
    final raw = jsonDecode(res.body);
    if (raw is List) return raw;
    return [];
  }

  // ─── REMITTANCE ──────────────────────────────────────
  static Future<Map<String, dynamic>> optimizeRemittance({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    required String receiverCountry,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/remittance/optimize'),
      headers: await _headers(auth: true),
      body: jsonEncode({
        'amount': amount,
        'fromCurrency': fromCurrency,
        'toCurrency': toCurrency,
        'receiverCountry': receiverCountry,
      }),
    );
    return _parse(res);
  }

  // ─── PROFILE ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: await _headers(auth: true),
    );
    return _parse(res);
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: await _headers(auth: true),
      body: jsonEncode({
        'phone': phone,
        'address': address,
        'profileImage': profileImage,
      }),
    );
    return _parse(res);
  }

  // ─── PARSER ──────────────────────────────────────────
  static Map<String, dynamic> _parse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body;
      if (body.isEmpty) return {'success': true};
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded, 'success': true};
    } else {
      String msg = 'Something went wrong';
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map) msg = decoded['message'] ?? msg;
      } catch (_) {
        msg = res.body;
      }
      throw ApiException(msg, res.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}
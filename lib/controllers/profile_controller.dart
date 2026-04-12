import 'package:flutter/material.dart';
import '../core/api/api_service.dart';

import '../models/transcation_model.dart';
import '../models/user_model.dart';

class ProfileProvider extends ChangeNotifier {
  UserModel? _profile;
  bool _loading = false;
  String? _error;
  bool _updating = false;

  UserModel? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;
  bool get updating => _updating;

  Future<void> loadProfile() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.getProfile();
      _profile = UserModel.fromJson(data);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({String? phone, String? address, String? profileImage}) async {
    _updating = true;
    _error = null;
    notifyListeners();
    try {
      await ApiService.updateProfile(
        phone: phone ?? _profile?.phone,
        address: address ?? _profile?.address,
        profileImage: profileImage ?? _profile?.profileImage,
      );
      await loadProfile();
      _updating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _updating = false;
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _profile = null;
    _error = null;
    notifyListeners();
  }
}
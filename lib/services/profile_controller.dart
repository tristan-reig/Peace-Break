import 'package:flutter/foundation.dart';

import '../models/profile.dart';
import 'profile_service.dart';

class ProfileController extends ChangeNotifier {
  final _service = ProfileService();

  Profile? _profile;
  bool _loading = false;
  String? _error;

  Profile? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _service.fetch();
    } catch (_) {
      _error = 'Impossible de charger ton profil';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }
}

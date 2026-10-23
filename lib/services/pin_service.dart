import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

// O PIN fica só no aparelho: guardamos um hash SHA-256 com salt aleatório,
// nunca o PIN em texto puro, e nada disso vai para o Firestore.
class PinService {
  PinService._();

  static const int pinLength = 4;

  static String _hashKey(String userId) => 'pinHash_$userId';
  static String _saltKey(String userId) => 'pinSalt_$userId';

  static String _hash(String salt, String pin) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  static Future<bool> hasPin(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_hashKey(userId)) != null;
  }

  static Future<void> setPin(String userId, String pin) async {
    final random = Random.secure();
    final salt = base64Encode(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_saltKey(userId), salt);
    await prefs.setString(_hashKey(userId), _hash(salt, pin));
  }

  static Future<bool> verifyPin(String userId, String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = prefs.getString(_saltKey(userId));
    final hash = prefs.getString(_hashKey(userId));
    if (salt == null || hash == null) return false;
    return _hash(salt, pin) == hash;
  }

  static Future<void> removePin(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hashKey(userId));
    await prefs.remove(_saltKey(userId));
  }
}

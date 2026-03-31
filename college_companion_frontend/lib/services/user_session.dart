class UserSession {
  static String? _userName;
  static String? _rollNumber;
  static List<String>? _userGroups;

  static void setSession({
    required String userName,
    required String rollNumber,
    required List<String> userGroups,
  }) {
    _userName = userName;
    _rollNumber = rollNumber;
    _userGroups = userGroups;
  }

  static String? get userName => _userName;
  static String? get rollNumber => _rollNumber;
  static List<String>? get userGroups => _userGroups;

  static void clearSession() {
    _userName = null;
    _rollNumber = null;
    _userGroups = null;
  }

  static bool get isLoggedIn => _userName != null;
}

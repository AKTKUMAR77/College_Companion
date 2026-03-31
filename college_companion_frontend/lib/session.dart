class UserSession {
  static String name = '';
  static String roll = '';
  static String role = '';
  static bool isAdmin = false;
  static List<String> groups = [];

  // ---------------- STATE ----------------

  static bool get isLoggedIn => roll.isNotEmpty;

  static String get rollNumber => roll;

  // ---------------- ACTIONS ----------------

  static void setSession({
    required String userName,
    required String rollNumber,
    required String userRole,
    required bool admin,
    required List<String> userGroups,
  }) {
    name = userName;
    roll = rollNumber;
    role = userRole;
    isAdmin = admin;
    groups = userGroups;
  }

  static void logout() {
    clear();
  }

  static void clear() {
    name = '';
    roll = '';
    role = '';
    isAdmin = false;
    groups = [];
  }
}

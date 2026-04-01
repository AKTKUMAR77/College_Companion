import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

class Api {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _adminName = 'admin';
  static const String _adminEmployeeId = '000000';
  static const String _adminPassword = '000000';
  static const List<String> _clubNames = [
    'Altius Sports Club',
    'Clairvoyance Photography Club',
    'Think India Club',
    'Technical Club',
    'Literature Club',
    'Yoga Club',
    'BIS Club',
  ];

  static String _hashPassword(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }

  static String _timestampToIso(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    return DateTime.now().toIso8601String();
  }

  static Map<String, dynamic> _decodeRoll(String roll) {
    final year = '20${roll.substring(0, 2)}';
    const branchMap = {
      '1212': 'AI-DS',
      '1221': 'VLSI',
      '121': 'CSE',
      '132': 'CE',
      '131': 'ME',
      '122': 'ECE',
      '123': 'EEE',
    };

    String? branch;
    String? branchCode;
    final rollBody = roll.substring(2);

    final codes = branchMap.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final code in codes) {
      if (rollBody.startsWith(code)) {
        branch = branchMap[code];
        branchCode = code;
        break;
      }
    }

    if (branch == null || branchCode == null) {
      throw Exception('Invalid roll');
    }

    final rollNo = int.tryParse(rollBody.substring(branchCode.length));
    if (rollNo == null) {
      throw Exception('Invalid roll');
    }

    String? section;
    String? group;

    if (branch == 'CSE') {
      section = rollNo <= 65 ? 'CS1' : 'CS2';
      group = rollNo <= 33 ? 'G1' : 'G2';
    } else if (branch == 'ECE' ||
        branch == 'EEE' ||
        branch == 'CE' ||
        branch == 'ME') {
      section = branch;
      if (rollNo >= 1 && rollNo <= 25) {
        group = 'G1';
      } else if (rollNo <= 50) {
        group = 'G2';
      } else if (rollNo <= 75) {
        group = 'G3';
      } else if (rollNo <= 99) {
        group = 'G4';
      }
    }

    return {
      'year': year,
      'branch': branch,
      'section': section,
      'group': group,
    };
  }

  static List<String> _buildGroupsForUser({
    required String role,
    required String roll,
  }) {
    if (role == 'faculty') {
      return ['Faculty Lounge', 'Department Announcements'];
    }

    final decoded = _decodeRoll(roll);
    final groups = <String>[
      '${decoded['year']} Batch',
      decoded['branch'] as String,
    ];

    final section = decoded['section'] as String?;
    final group = decoded['group'] as String?;
    if (section != null && section.isNotEmpty) {
      groups.add(section);
    }
    if (section != null && group != null && group.isNotEmpty) {
      groups.add('$section-$group');
    }
    return groups;
  }

  static Future<List<String>> _getAllAccessibleGroups() async {
    final snapshot = await _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    final groups = <String>{'Faculty Lounge', 'Department Announcements'};
    for (final doc in snapshot.docs) {
      final roll = (doc.data()['roll'] ?? '').toString();
      if (roll.isEmpty) {
        continue;
      }
      try {
        groups.addAll(_buildGroupsForUser(role: 'student', roll: roll));
      } catch (_) {
        continue;
      }
    }
    return groups.toList()..sort();
  }

  static Future<Map<String, dynamic>> login(
    String role,
    String roll,
    String password,
  ) async {
    final normalizedRole = role.trim().toLowerCase();
    final normalizedRoll = roll.trim();
    final normalizedPassword = password.trim();

    if (normalizedRole == 'faculty' &&
        normalizedRoll == _adminEmployeeId &&
        normalizedPassword == _adminPassword) {
      return {
        'name': _adminName,
        'roll': _adminEmployeeId,
        'role': 'faculty',
        'is_admin': true,
        'groups': await _getAllAccessibleGroups(),
      };
    }

    final userDoc = await _db.collection('users').doc(normalizedRoll).get();
    if (!userDoc.exists) {
      throw Exception('Invalid credentials');
    }

    final data = userDoc.data()!;
    if ((data['role'] ?? '').toString() != normalizedRole) {
      throw Exception('Role mismatch for this account');
    }

    if ((data['password_hash'] ?? '').toString() !=
        _hashPassword(normalizedPassword)) {
      throw Exception('Invalid credentials');
    }

    return {
      'name': (data['name'] ?? '').toString(),
      'roll': normalizedRoll,
      'role': normalizedRole,
      'is_admin': false,
      'groups': _buildGroupsForUser(role: normalizedRole, roll: normalizedRoll),
    };
  }

  static Future<void> signup(
    String role,
    String name,
    String roll,
    String password,
  ) async {
    final normalizedRole = role.trim().toLowerCase();
    final normalizedName = name.trim();
    final normalizedRoll = roll.trim();
    final normalizedPassword = password.trim();

    if (normalizedRole == 'student') {
      _decodeRoll(normalizedRoll);
    }

    final userRef = _db.collection('users').doc(normalizedRoll);
    final existing = await userRef.get();
    if (existing.exists) {
      throw Exception('User already exists');
    }

    await userRef.set({
      'role': normalizedRole,
      'name': normalizedName,
      'roll': normalizedRoll,
      'password_hash': _hashPassword(normalizedPassword),
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>> fetchPyqOptions() async {
    final currentYear = DateTime.now().year;
    return {
      'years': List.generate(10, (index) => '${currentYear - index}'),
      'branches': ['CSE', 'ECE', 'ME', 'EEE', 'CE'],
      'semesters': List.generate(8, (index) => '${index + 1}'),
    };
  }

  static Future<List<Map<String, dynamic>>> fetchPyqs({
    required String year,
    required String branch,
    required String semester,
  }) async {
    final snapshot = await _db
        .collection('pyq')
        .where('year', isEqualTo: year)
        .where('branch', isEqualTo: branch)
        .where('semester', isEqualTo: semester)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'year': (data['year'] ?? '').toString(),
        'branch': (data['branch'] ?? '').toString(),
        'semester': (data['semester'] ?? '').toString(),
        'subject': (data['subject'] ?? '').toString(),
        'drive_link': (data['drive_link'] ?? '').toString(),
        'uploaded_by': (data['uploaded_by'] ?? '').toString(),
        'created_at': _timestampToIso(data['created_at']),
      };
    }).toList();
  }

  static Future<void> uploadPyq({
    required String uploaderRoll,
    required String year,
    required String branch,
    required String semester,
    required String subject,
    required String driveLink,
  }) async {
    if (uploaderRoll != _adminEmployeeId) {
      throw Exception('Only admin can upload PYQ');
    }

    final cleanLink = driveLink.trim();
    if (!(cleanLink.startsWith('http://') || cleanLink.startsWith('https://'))) {
      throw Exception('Valid drive link is required');
    }

    await _db.collection('pyq').add({
      'year': year.trim(),
      'branch': branch.trim(),
      'semester': semester.trim(),
      'subject': subject.trim(),
      'drive_link': cleanLink,
      'uploaded_by': uploaderRoll,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>> fetchClubAccess({
    required String clubName,
    required String studentRoll,
  }) async {
    if (!_clubNames.contains(clubName)) {
      throw Exception('Invalid club');
    }

    if (studentRoll == _adminEmployeeId) {
      return {
        'status': 'approved',
        'can_send_message': true,
        'is_admin': true,
      };
    }

    final memberDoc = await _db
        .collection('clubs')
        .doc(clubName)
        .collection('memberships')
        .doc(studentRoll)
        .get();

    if (memberDoc.exists) {
      return {
        'status': 'approved',
        'can_send_message': memberDoc.data()?['can_send_message'] == true,
        'is_admin': false,
      };
    }

    final requestDoc = await _db
        .collection('clubs')
        .doc(clubName)
        .collection('requests')
        .doc(studentRoll)
        .get();

    return {
      'status': requestDoc.exists
          ? (requestDoc.data()?['status'] ?? 'pending').toString()
          : 'not_requested',
      'can_send_message': false,
      'is_admin': false,
    };
  }

  static Future<void> requestClubAccess({
    required String clubName,
    required String studentRoll,
    required String studentName,
  }) async {
    if (!_clubNames.contains(clubName)) {
      throw Exception('Invalid club');
    }

    if (studentRoll == _adminEmployeeId) {
      return;
    }

    final memberDoc = await _db
        .collection('clubs')
        .doc(clubName)
        .collection('memberships')
        .doc(studentRoll)
        .get();
    if (memberDoc.exists) {
      return;
    }

    await _db
        .collection('clubs')
        .doc(clubName)
        .collection('requests')
        .doc(studentRoll)
        .set({
      'student_roll': studentRoll,
      'student_name': studentName.trim(),
      'status': 'pending',
      'reviewed_by': null,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<List<Map<String, dynamic>>> fetchClubMessages({
    required String clubName,
    required String studentRoll,
  }) async {
    final access = await fetchClubAccess(
      clubName: clubName,
      studentRoll: studentRoll,
    );
    final canView =
        access['is_admin'] == true || (access['status'] ?? '') == 'approved';
    if (!canView) {
      throw Exception('Club access not approved');
    }

    final snapshot = await _db
        .collection('clubs')
        .doc(clubName)
        .collection('messages')
        .orderBy('created_at')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'sender': (data['sender'] ?? '').toString(),
        'text': (data['text'] ?? '').toString(),
        'timestamp': _timestampToIso(data['created_at']),
      };
    }).toList();
  }

  static Future<void> sendClubMessage({
    required String clubName,
    required String studentRoll,
    required String sender,
    required String text,
  }) async {
    final access = await fetchClubAccess(
      clubName: clubName,
      studentRoll: studentRoll,
    );
    final isAdmin = access['is_admin'] == true;
    final canSend = isAdmin || (access['can_send_message'] == true);
    if (!canSend) {
      throw Exception('Message permission is disabled for this club');
    }

    await _db.collection('clubs').doc(clubName).collection('messages').add({
      'sender': sender.trim(),
      'text': text.trim(),
      'student_roll': studentRoll,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<Map<String, dynamic>>> fetchClubRequests({
    required String clubName,
    required String adminRoll,
  }) async {
    if (adminRoll != _adminEmployeeId) {
      throw Exception('Only admin can view requests');
    }

    final snapshot = await _db
        .collection('clubs')
        .doc(clubName)
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('created_at')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'student_roll': (data['student_roll'] ?? '').toString(),
        'student_name': (data['student_name'] ?? '').toString(),
        'status': (data['status'] ?? '').toString(),
        'created_at': _timestampToIso(data['created_at']),
        'updated_at': _timestampToIso(data['updated_at']),
      };
    }).toList();
  }

  static Future<void> decideClubRequest({
    required String clubName,
    required String requestId,
    required String adminRoll,
    required String action,
    required bool canSendMessage,
  }) async {
    if (adminRoll != _adminEmployeeId) {
      throw Exception('Only admin can decide requests');
    }

    final normalizedAction = action.trim().toLowerCase();
    if (normalizedAction != 'approve' && normalizedAction != 'reject') {
      throw Exception('action must be approve or reject');
    }

    final requestRef = _db
        .collection('clubs')
        .doc(clubName)
        .collection('requests')
        .doc(requestId);
    final requestDoc = await requestRef.get();
    if (!requestDoc.exists) {
      throw Exception('Request not found');
    }

    final data = requestDoc.data()!;
    final status = normalizedAction == 'approve' ? 'approved' : 'rejected';

    await requestRef.set({
      'status': status,
      'reviewed_by': adminRoll,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (normalizedAction == 'approve') {
      await _db
          .collection('clubs')
          .doc(clubName)
          .collection('memberships')
          .doc(requestId)
          .set({
        'student_roll': (data['student_roll'] ?? '').toString(),
        'student_name': (data['student_name'] ?? '').toString(),
        'can_send_message': canSendMessage,
        'approved_by': adminRoll,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  static Future<List<Map<String, dynamic>>> fetchClubMembers({
    required String clubName,
    required String adminRoll,
  }) async {
    if (adminRoll != _adminEmployeeId) {
      throw Exception('Only admin can view members');
    }

    final snapshot = await _db
        .collection('clubs')
        .doc(clubName)
        .collection('memberships')
        .orderBy('student_roll')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'student_roll': (data['student_roll'] ?? '').toString(),
        'student_name': (data['student_name'] ?? '').toString(),
        'can_send_message': data['can_send_message'] == true,
        'approved_by': (data['approved_by'] ?? '').toString(),
        'created_at': _timestampToIso(data['created_at']),
        'updated_at': _timestampToIso(data['updated_at']),
      };
    }).toList();
  }

  static Future<void> updateClubMemberMessagePermission({
    required String clubName,
    required String studentRoll,
    required String adminRoll,
    required bool canSendMessage,
  }) async {
    if (adminRoll != _adminEmployeeId) {
      throw Exception('Only admin can update permission');
    }

    final memberRef = _db
        .collection('clubs')
        .doc(clubName)
        .collection('memberships')
        .doc(studentRoll);
    final memberDoc = await memberRef.get();
    if (!memberDoc.exists) {
      throw Exception('Member not found');
    }

    await memberRef.set({
      'can_send_message': canSendMessage,
      'approved_by': adminRoll,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<List<Map<String, dynamic>>> fetchMessages(String group) async {
    final snapshot = await _db
        .collection('group_messages')
        .doc(group)
        .collection('items')
        .orderBy('created_at')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'sender': (data['sender'] ?? '').toString(),
        'text': (data['text'] ?? '').toString(),
        'timestamp': _timestampToIso(data['created_at']),
      };
    }).toList();
  }

  static Future<void> sendMessage(String group, String sender, String msg) async {
    await _db.collection('group_messages').doc(group).collection('items').add({
      'sender': sender.trim(),
      'text': msg.trim(),
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}

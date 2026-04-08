import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    return {'year': year, 'branch': branch, 'section': section, 'group': group};
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
    
    // Add Restricted Groups
    final branchName = decoded['branch'] as String;
    groups.add('$branchName Announcements');
    groups.add('$branchName Notes');
    return groups;
  }

  static Future<String?> resolveEmailForPasswordReset(String identifier) async {
    final normalized = identifier.trim();
    if (normalized.contains('@')) {
      final query = await _db
          .collection('users')
          .where('email', isEqualTo: normalized.toLowerCase())
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        return null;
      }
      return (query.docs.first.data()['email'] ?? '').toString();
    }

    final userDoc = await _db.collection('users').doc(normalized).get();
    if (!userDoc.exists) {
      return null;
    }
    return (userDoc.data()?['email'] ?? '').toString();
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
        'is_cr': false,
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

    // Get the email from Firestore
    final email = (data['email'] ?? '').toString().trim();
    if (email.isEmpty) {
      throw Exception(
        'This account is not linked to an email. Please contact support.',
      );
    }

    final overrideValue = data['email_verified_admin_override'];
    final adminOverrideVerified =
        overrideValue == true ||
        overrideValue.toString().toLowerCase() == 'true';

    // Authenticate using Firebase Auth (uses current password in Firebase)
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email,
            password: normalizedPassword,
          );

      if (!userCredential.user!.emailVerified && !adminOverrideVerified) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Please verify your email before signing in.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Invalid credentials');
      }
      if (e.code == 'user-not-found') {
        throw Exception(
          'Linked email account not found. Please contact support.',
        );
      }
      if (e.code == 'too-many-requests') {
        throw Exception('Too many failed login attempts. Try again later.');
      }
      throw Exception('Authentication failed: ${e.message}');
    }

    return {
      'name': (data['name'] ?? '').toString(),
      'roll': normalizedRoll,
      'role': normalizedRole,
      'is_admin': false,
      'is_cr': data['is_cr'] == true,
      'groups': _buildGroupsForUser(role: normalizedRole, roll: normalizedRoll),
    };
  }

  static Future<void> signup(
    String role,
    String name,
    String roll,
    String email,
    String password,
  ) async {
    final normalizedRole = role.trim().toLowerCase();
    final normalizedName = name.trim();
    final normalizedRoll = roll.trim();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    if (normalizedRole == 'student') {
      _decodeRoll(normalizedRoll);
    }

    final userRef = _db.collection('users').doc(normalizedRoll);
    final existing = await userRef.get();
    if (existing.exists) {
      throw Exception('User already exists');
    }

    final existingEmailQuery = await _db
        .collection('users')
        .where('email', isEqualTo: normalizedEmail)
        .limit(1)
        .get();
    if (existingEmailQuery.docs.isNotEmpty) {
      throw Exception('This email is already registered.');
    }

    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: normalizedEmail,
            password: normalizedPassword,
          );
      await userCredential.user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists with this email.');
      }
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      }
      throw Exception(e.message ?? 'Failed to create account.');
    }

    try {
      await userRef.set({
        'role': normalizedRole,
        'name': normalizedName,
        'roll': normalizedRoll,
        'email': normalizedEmail,
        'is_cr': normalizedRole == 'student' && normalizedRoll.endsWith('01'),
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      await userCredential.user?.delete();
      throw Exception('Could not save user profile. Please try again.');
    }
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
    final cleanYear = year.trim();
    final cleanBranch = branch.trim();
    final cleanSemester = semester.trim();

    try {
      final snapshot = await _db
          .collection('pyq')
          .where('year', isEqualTo: cleanYear)
          .where('branch', isEqualTo: cleanBranch)
          .where('semester', isEqualTo: cleanSemester)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs.map(_mapPyqDoc).toList();
    } on FirebaseException catch (e) {
      final message = e.message?.toLowerCase() ?? '';
      if (message.contains('requires an index') ||
          message.contains('failed precondition')) {
        final snapshot = await _db.collection('pyq').get();
        final filtered = snapshot.docs.where((doc) {
          final data = doc.data();
          return _matchesPyqFilter(data, cleanYear, cleanBranch, cleanSemester);
        }).toList();
        filtered.sort((a, b) {
          final aTs = a.data()['created_at'];
          final bTs = b.data()['created_at'];
          if (aTs is Timestamp && bTs is Timestamp) {
            return bTs.compareTo(aTs);
          }
          return 0;
        });
        return filtered.map(_mapPyqDoc).toList();
      }
      rethrow;
    }
  }

  static bool _matchesPyqFilter(
    Map<String, dynamic> data,
    String year,
    String branch,
    String semester,
  ) {
    final valueYear = data['year'];
    final valueBranch = data['branch'];
    final valueSemester = data['semester'];

    final yearMatch =
        valueYear?.toString().trim() == year ||
        (valueYear is int && valueYear.toString() == year);
    final branchMatch =
        valueBranch?.toString().trim().toLowerCase() == branch.toLowerCase();
    final semesterMatch =
        valueSemester?.toString().trim() == semester ||
        (valueSemester is int && valueSemester.toString() == semester);

    return yearMatch && branchMatch && semesterMatch;
  }

  static Map<String, dynamic> _mapPyqDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
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
    if (!(cleanLink.startsWith('http://') ||
        cleanLink.startsWith('https://'))) {
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
      return {'status': 'approved', 'can_send_message': true, 'is_admin': true};
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
        .get();

    final requests = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'student_roll': (data['student_roll'] ?? '').toString(),
        'student_name': (data['student_name'] ?? '').toString(),
        'status': (data['status'] ?? '').toString(),
        'created_at': _timestampToIso(data['created_at']),
        'updated_at': _timestampToIso(data['updated_at']),
        '_created_at_raw': data['created_at'],
      };
    }).toList();

    requests.sort((a, b) {
      final aValue = a['_created_at_raw'];
      final bValue = b['_created_at_raw'];
      if (aValue is Timestamp && bValue is Timestamp) {
        return aValue.compareTo(bValue);
      }
      return 0;
    });

    return requests.map((request) {
      request.remove('_created_at_raw');
      return request;
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

  static Future<void> sendMessage(
    String group,
    String sender,
    String msg,
    {bool isAdmin = false, bool isCr = false}
  ) async {
    if (group.endsWith(' Announcements') || group.endsWith(' Notes')) {
      if (!isAdmin && !isCr) {
        throw Exception('Only Class Representatives can post in this group.');
      }
    }

    await _db.collection('group_messages').doc(group).collection('items').add({
      'sender': sender.trim(),
      'text': msg.trim(),
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>> searchStudentByRoll(
    String rollNumber,
  ) async {
    final normalizedRoll = rollNumber.trim();
    final userDoc = await _db.collection('users').doc(normalizedRoll).get();

    if (!userDoc.exists) {
      throw Exception('Student not found');
    }

    final data = userDoc.data()!;
    final emailVerifiedOverride =
        data['email_verified_admin_override'] ?? false;
    final emailVerified =
        emailVerifiedOverride || (data['email_verified'] ?? false);

    return {
      'name': (data['name'] ?? '').toString(),
      'roll': (data['roll'] ?? '').toString(),
      'role': (data['role'] ?? '').toString(),
      'email': (data['email'] ?? '').toString(),
      'created_at': _timestampToIso(data['created_at']),
      'email_verified': emailVerified,
      'email_verified_admin_override': emailVerifiedOverride,
      'is_cr': data['is_cr'] == true,
    };
  }

  static Future<void> updateStudentDetails({
    required String rollNumber,
    required String? email,
    required String? password,
    required bool emailVerified,
    bool? isCr,
  }) async {
    final normalizedRoll = rollNumber.trim();
    final userDoc = await _db.collection('users').doc(normalizedRoll).get();

    if (!userDoc.exists) {
      throw Exception('Student not found');
    }

    final data = userDoc.data()!;
    final currentEmail = (data['email'] ?? '').toString();

    // Update Firestore
    final updateData = <String, dynamic>{};
    if (email != null && email.isNotEmpty && email != currentEmail) {
      // Check if email is already used by another user
      final existingEmailQuery = await _db
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();
      if (existingEmailQuery.docs.isNotEmpty &&
          existingEmailQuery.docs.first.id != normalizedRoll) {
        throw Exception('This email is already registered to another user.');
      }
      updateData['email'] = email.toLowerCase();
    }

    if (emailVerified) {
      updateData['email_verified_admin_override'] = true;
    } else {
      updateData['email_verified_admin_override'] = FieldValue.delete();
    }

    if (isCr != null) {
      updateData['is_cr'] = isCr;
    }

    if (updateData.isNotEmpty) {
      await _db.collection('users').doc(normalizedRoll).update(updateData);
    }

    // Update Firebase Auth
    if (currentEmail.isNotEmpty || (email != null && email.isNotEmpty)) {
      final authEmail = email ?? currentEmail;
      if (authEmail.isNotEmpty) {
        try {
          // Get user by email
          final userQuery = await FirebaseAuth.instance
              .fetchSignInMethodsForEmail(authEmail);

          if (userQuery.isNotEmpty) {
            // User exists in Auth, update password if provided
            if (password != null && password.isNotEmpty) {
              // Note: This requires the user to be signed in or special admin privileges
              // For now, we'll just update the password requirement in Firestore
              // In a production app, you'd use Firebase Admin SDK
              throw Exception(
                'Password reset requires user to change it themselves. Please instruct the student to use "Forgot Password".',
              );
            }
          } else if (email != null && email.isNotEmpty) {
            // Create new Auth user if email provided but no Auth account exists
            try {
              final tempPassword =
                  password ?? 'TempPass123!'; // Generate a temp password
              final userCredential = await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                    email: authEmail,
                    password: tempPassword,
                  );

              if (emailVerified) {
                await _db.collection('users').doc(normalizedRoll).update({
                  'temp_password_set': true,
                  'updated_at': FieldValue.serverTimestamp(),
                });
              }

              await FirebaseAuth.instance
                  .signOut(); // Sign out the admin-created account
            } on FirebaseAuthException catch (e) {
              if (e.code == 'email-already-in-use') {
                throw Exception(
                  'Email already exists in authentication system.',
                );
              }
              throw Exception(
                'Failed to create authentication account: ${e.message}',
              );
            }
          }
        } catch (e) {
          if (e.toString().contains('Password reset requires')) {
            rethrow;
          }
          // For other auth errors, continue with Firestore update
          print('Auth update failed: $e');
        }
      }
    }
  }

  // ==========================================
  // ELECTION & POLLING MODULE
  // ==========================================

  /// Creates a new election (Admin only)
  static Future<String> createElection({
    required String adminRoll,
    required String title,
    required String description,
    required String branch,
    required String year,
    required String semester,
    required DateTime startDate,
    required DateTime endDate,
    required String rules,
  }) async {
    if (adminRoll != _adminEmployeeId) {
      throw Exception('Only admin can create elections');
    }

    final docRef = await _db.collection('elections').add({
      'title': title.trim(),
      'description': description.trim(),
      'branch': branch.trim(),
      'year': year.trim(),
      'semester': semester.trim(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'rules': rules.trim(),
      'is_results_locked': true,
      'status': 'active',
      'created_at': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Adds a candidate to an election (Admin only)
  static Future<void> addCandidate({
    required String adminRoll,
    required String electionId,
    required String name,
    required String rollNumber,
    required String photoUrl,
    required String manifesto,
  }) async {
    if (adminRoll != _adminEmployeeId) {
      throw Exception('Only admin can add candidates');
    }

    final cleanRoll = rollNumber.trim();
    
    // Check if candidate already exists
    final query = await _db
        .collection('elections')
        .doc(electionId)
        .collection('candidates')
        .where('roll_number', isEqualTo: cleanRoll)
        .get();

    if (query.docs.isNotEmpty) {
      throw Exception('Candidate with this roll number already exists setup for this election.');
    }

    await _db
        .collection('elections')
        .doc(electionId)
        .collection('candidates')
        .add({
      'name': name.trim(),
      'roll_number': cleanRoll,
      'photo_url': photoUrl.trim(),
      'manifesto': manifesto.trim(),
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch elections that a student is eligible to vote in
  static Future<List<Map<String, dynamic>>> fetchEligibleElections({
    required String studentRoll,
  }) async {
    if (studentRoll == _adminEmployeeId) {
      // Admins see all elections
      final snapshot = await _db.collection('elections').orderBy('created_at', descending: true).get();
      return snapshot.docs.map(_mapElectionDoc).toList();
    }

    // Decode roll to find branch, year
    final decoded = _decodeRoll(studentRoll);
    final year = decoded['year'] as String;
    final branch = decoded['branch'] as String;

    // Firebase queries require indexes for multiple fields, so we will pull all Active
    // elections and filter locally for ease unless it gets massive.
    final snapshot = await _db
        .collection('elections')
        .orderBy('created_at', descending: true)
        .get();

    final eligibleElections = snapshot.docs.where((doc) {
      final data = doc.data();
      final eYear = data['year']?.toString();
      final eBranch = data['branch']?.toString();
      
      // Target matches OR is set to "All" (assuming blank/All means valid for everyone)
      final yearMatch = eYear == year || eYear == 'All' || eYear == null || eYear.isEmpty;
      final branchMatch = eBranch == branch || eBranch == 'All' || eBranch == null || eBranch.isEmpty;
      
      return yearMatch && branchMatch;
    }).toList();

    return eligibleElections.map(_mapElectionDoc).toList();
  }

  static Map<String, dynamic> _mapElectionDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return {
      'id': doc.id,
      'title': (data['title'] ?? '').toString(),
      'description': (data['description'] ?? '').toString(),
      'branch': (data['branch'] ?? 'All').toString(),
      'year': (data['year'] ?? 'All').toString(),
      'semester': (data['semester'] ?? 'All').toString(),
      'start_date': (data['start_date'] ?? '').toString(),
      'end_date': (data['end_date'] ?? '').toString(),
      'rules': (data['rules'] ?? '').toString(),
      'is_results_locked': data['is_results_locked'] == true,
      'status': (data['status'] ?? 'active').toString(),
    };
  }

  /// Fetch all candidates for an election
  static Future<List<Map<String, dynamic>>> fetchCandidates(String electionId) async {
    final snapshot = await _db
        .collection('elections')
        .doc(electionId)
        .collection('candidates')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': (data['name'] ?? '').toString(),
        'roll_number': (data['roll_number'] ?? '').toString(),
        'photo_url': (data['photo_url'] ?? '').toString(),
        'manifesto': (data['manifesto'] ?? '').toString(),
      };
    }).toList();
  }

  /// Check if a student has voted
  static Future<bool> hasStudentVoted({
    required String electionId,
    required String studentRoll,
  }) async {
    final doc = await _db
        .collection('elections')
        .doc(electionId)
        .collection('votes')
        .doc(studentRoll)
        .get();
        
    return doc.exists;
  }

  /// Cast a vote securely
  static Future<void> castVote({
    required String electionId,
    required String candidateId,
    required String studentRoll,
  }) async {
    if (studentRoll == _adminEmployeeId) {
      throw Exception('Admins cannot vote.');
    }

    final electionRef = _db.collection('elections').doc(electionId);
    final voteRef = electionRef.collection('votes').doc(studentRoll);
    
    await _db.runTransaction((transaction) async {
      // 1. Verify election is active
      final electionDoc = await transaction.get(electionRef);
      if (!electionDoc.exists) throw Exception('Election not found');
      
      final endDateStr = electionDoc.data()?['end_date']?.toString() ?? '';
      if (endDateStr.isNotEmpty) {
        final endDate = DateTime.tryParse(endDateStr);
        if (endDate != null && DateTime.now().isAfter(endDate)) {
          throw Exception('Voting is closed for this election.');
        }
      }
      
      if (electionDoc.data()?['status'] == 'ended') {
        throw Exception('Voting has ended.');
      }

      // 2. Prevent double voting
      final voteDoc = await transaction.get(voteRef);
      if (voteDoc.exists) {
        throw Exception('You have already cast your vote in this election.');
      }

      // 3. Register vote (record who voted to avoid dupes, but only link candidate temporarily if needed)
      transaction.set(voteRef, {
        'candidate_id': candidateId, // Anonymous systems wouldn't store this, but we need it to count naturally via Firebase
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Fetch results (Will only succeed if admin or rules allow)
  static Future<Map<String, int>> fetchElectionResults({
    required String electionId,
    required String requestingRoll,
  }) async {
    final electionDoc = await _db.collection('elections').doc(electionId).get();
    if (!electionDoc.exists) throw Exception('Election not found');

    final isLocked = electionDoc.data()?['is_results_locked'] == true;
    if (isLocked && requestingRoll != _adminEmployeeId) {
      throw Exception('Results are locked and currently hidden by admin.');
    }

    final votesSnapshot = await _db
        .collection('elections')
        .doc(electionId)
        .collection('votes')
        .get();

    final Map<String, int> results = {};
    for (var doc in votesSnapshot.docs) {
      final candidateId = doc.data()['candidate_id'] as String?;
      if (candidateId != null) {
        results[candidateId] = (results[candidateId] ?? 0) + 1;
      }
    }
    return results;
  }

  /// Admin toggle results lock
  static Future<void> toggleResultsLock({
    required String adminRoll,
    required String electionId,
    required bool lock,
  }) async {
    if (adminRoll != _adminEmployeeId) throw Exception('Admin only');
    await _db.collection('elections').doc(electionId).update({
      'is_results_locked': lock,
    });
  }

  /// Admin end election
  static Future<void> endElection({
    required String adminRoll,
    required String electionId,
  }) async {
    if (adminRoll != _adminEmployeeId) throw Exception('Admin only');
    await _db.collection('elections').doc(electionId).update({
      'status': 'ended',
    });
  }
}

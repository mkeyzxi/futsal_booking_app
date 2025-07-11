// lib/services/auth_service.dart
import 'package:futsal_booking_app/models/user.dart';
import 'package:futsal_booking_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Masih digunakan untuk menyimpan currentUser
import 'dart:convert'; // Masih digunakan untuk JSON encode/decode
import 'package:uuid/uuid.dart';
import 'package:futsal_booking_app/utils/database_helper.dart'; // Import DatabaseHelper
import 'package:sqflite/sqflite.dart'; // Import yang benar

class AuthService {
  final Uuid _uuid = const Uuid();
  final DatabaseHelper _dbHelper =
      DatabaseHelper(); // Inisialisasi DatabaseHelper
  static const String _currentUserKey =
      'current_user_id'; // Hanya simpan ID user

  // Metode untuk mendapatkan user berdasarkan username (digunakan internal untuk login)
  Future<User?> _getUserByUsername(String username) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromSqliteMap(maps.first);
    }
    return null;
  }

  // Metode publik untuk mendapatkan user berdasarkan ID
  Future<User?> getUserById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromSqliteMap(maps.first);
    }
    return null;
  }

  // --- Auth Logic ---
  Future<User?> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulasi delay

    final db = await _dbHelper.database;

    // Periksa admin user khusus
    if (username == AppConstants.adminUsername &&
        password == AppConstants.adminPassword) {
      final List<Map<String, dynamic>> adminMaps = await db.query(
        'users',
        where: 'username = ? AND role = ?',
        whereArgs: [
          AppConstants.adminUsername,
          UserRole.admin.toString().split('.').last,
        ],
      );
      if (adminMaps.isNotEmpty) {
        final User adminUser = User.fromSqliteMap(adminMaps.first);
        await setCurrentUserId(adminUser.id); // Simpan hanya ID
        return adminUser;
      }
    }

    // Periksa user biasa
    final List<Map<String, dynamic>> userMaps = await db.query(
      'users',
      where:
          'username = ? AND password = ? AND role = ?', // Password ikut diperiksa
      whereArgs: [username, password, UserRole.user.toString().split('.').last],
    );

    if (userMaps.isNotEmpty) {
      final User user = User.fromSqliteMap(userMaps.first);
      await setCurrentUserId(user.id); // Simpan hanya ID
      return user;
    }
    return null;
  }

  Future<User?> register(String username, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulasi delay
    final db = await _dbHelper.database;

    // Periksa username
    final List<Map<String, dynamic>> existingUsername = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (existingUsername.isNotEmpty) {
      throw Exception('Username sudah digunakan.');
    }

    // Periksa email
    final List<Map<String, dynamic>> existingEmail = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (existingEmail.isNotEmpty) {
      throw Exception('Email sudah digunakan.');
    }

    final newUser = User(
      id: _uuid.v4(),
      username: username,
      email: email,
      role: UserRole.user,
      balance: AppConstants.initialBalance, // Saldo awal untuk user baru
    );

    // Simpan password di sini (hanya di database, tidak di model User)
    final Map<String, dynamic> userMapToInsert = newUser.toSqliteMap();
    userMapToInsert['password'] = password; // Tambahkan password ke map

    await db.insert(
      'users',
      userMapToInsert,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return newUser; // Return user object tanpa password
  }

  // Menyimpan perubahan pada data user (termasuk saldo dan profileImageUrl)
  Future<void> updateUser(User updatedUser) async {
    final db = await _dbHelper.database;
    await db.update(
      'users',
      updatedUser.toSqliteMap(), // Menggunakan toSqliteMap
      where: 'id = ?',
      whereArgs: [updatedUser.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Jika user yang diupdate adalah user yang sedang login, update juga ID di SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final currentUserIdInPrefs = prefs.getString(_currentUserKey);
    if (currentUserIdInPrefs == updatedUser.id) {
      await setCurrentUserId(updatedUser.id); // Simpan ID terbaru
    }
  }

  // Hanya menyimpan ID user yang sedang login di SharedPreferences
  Future<void> setCurrentUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, userId);
  }

  // Mendapatkan user yang sedang login berdasarkan ID yang disimpan di SharedPreferences
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString(_currentUserKey);
    if (userId != null) {
      return await getUserById(userId); // Ambil data user lengkap dari SQLite
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
}

// lib/services/auth_service.dart
import 'package:futsal_booking_app/models/user.dart';
import 'package:futsal_booking_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class AuthService {
  final Uuid _uuid = const Uuid();
  static const String _registeredUsersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';

  // --- Helpers for user data persistence ---
  Future<List<User>> _loadAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> usersJson = prefs.getStringList(_registeredUsersKey) ?? [];
    return usersJson.map((e) => User.fromJson(jsonDecode(e))).toList();
  }

  Future<void> _saveAllUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      _registeredUsersKey,
      users.map((u) => jsonEncode(u.toJson())).toList(),
    );
  }

  // Metode privat untuk mendapatkan user berdasarkan username (digunakan internal untuk login)
  Future<User?> _getUserByUsername(String username) async {
    List<User> users = await _loadAllUsers();
    try {
      return users.firstWhere((user) => user.username == username);
    } catch (e) {
      return null;
    }
  }

  // Metode publik untuk mendapatkan user berdasarkan ID (digunakan oleh provider lain)
  Future<User?> getUserById(String id) async {
    List<User> users = await _loadAllUsers();
    try {
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Pastikan admin user ada saat pertama kali aplikasi dibuka
  Future<void> _ensureAdminExists() async {
    List<User> users = await _loadAllUsers();
    if (!users.any(
      (u) =>
          u.username == AppConstants.adminUsername && u.role == UserRole.admin,
    )) {
      User adminUser = User(
        id: _uuid.v4(),
        username: AppConstants.adminUsername,
        email: 'admin@futsal.com',
        role: UserRole.admin,
        balance: 0.0, // Admin tidak punya saldo untuk transaksi booking
      );
      users.add(adminUser);
      await _saveAllUsers(users);
    }
  }

  // --- Auth Logic ---
  Future<User?> login(String username, String password) async {
    await _ensureAdminExists(); // Pastikan admin ada
    await Future.delayed(const Duration(milliseconds: 500)); // Simulasi delay

    if (username == AppConstants.adminUsername &&
        password == AppConstants.adminPassword) {
      User? adminUser = await _getUserByUsername(AppConstants.adminUsername);
      if (adminUser != null) {
        await setCurrentUser(adminUser);
        return adminUser;
      }
    }

    User? user = await _getUserByUsername(username);
    if (user != null && user.role == UserRole.user && password == 'user123') {
      await setCurrentUser(user);
      return user;
    }
    return null;
  }

  Future<User?> register(String username, String email, String password) async {
    await _ensureAdminExists(); // Pastikan admin ada
    await Future.delayed(const Duration(milliseconds: 500)); // Simulasi delay

    User? existingUser = await _getUserByUsername(username);
    if (existingUser != null) {
      throw Exception('Username sudah digunakan.');
    }

    User newUser = User(
      id: _uuid.v4(),
      username: username,
      email: email,
      role: UserRole.user,
      balance: AppConstants.initialBalance, // <--- SALDO AWAL UNTUK USER BARU
    );
    List<User> allUsers = await _loadAllUsers();
    allUsers.add(newUser);
    await _saveAllUsers(allUsers);
    return newUser; // Tidak auto-login setelah register
  }

  // Menyimpan perubahan pada data user (termasuk saldo dan profileImageUrl)
  Future<void> updateUser(User updatedUser) async {
    List<User> users = await _loadAllUsers();
    int index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
      await _saveAllUsers(users);
      // Jika user yang diupdate adalah user yang sedang login, update juga current user
      User? currentUser = await getCurrentUser();
      if (currentUser?.id == updatedUser.id) {
        await setCurrentUser(updatedUser);
      }
    }
  }

  Future<void> saveUserProfileImage(String userId, String imageUrl) async {
    User? user = await getUserById(userId);
    if (user != null) {
      User updatedUser = User(
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        profileImageUrl: imageUrl,
        balance: user.balance, // Pastikan saldo tetap sama
      );
      await updateUser(updatedUser);
    }
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_currentUserKey);
    if (userJson != null) {
      final User user = User.fromJson(jsonDecode(userJson));
      // Pastikan data user terkini dimuat dari _loadAllUsers()
      // Ini penting jika profileImageUrl atau balance diupdate
      return await getUserById(user.id);
    }
    return null;
  }

  Future<void> setCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
}

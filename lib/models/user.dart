// lib/models/user.dart
import 'package:uuid/uuid.dart'; // Tambahkan ini jika belum ada

enum UserRole { admin, user }

class User {
  final String id;
  final String username;
  final String email;
  final String? profileImageUrl;
  final UserRole role;
  double balance; // Tidak final, agar bisa diubah

  User({
    String? id, // Ubah menjadi opsional agar bisa digenerate
    required this.username,
    required this.email,
    this.profileImageUrl,
    this.role = UserRole.user,
    this.balance = 0.0,
  }) : id = id ?? const Uuid().v4(); // Generate ID jika tidak disediakan

  // Konversi objek User ke Map untuk penyimpanan SQLite
  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      // Password tidak disimpan di model, hanya di Auth Service
      'profileImageUrl': profileImageUrl,
      'role': role.toString().split('.').last, // Simpan enum sebagai string
      'balance': balance,
    };
  }

  // Buat objek User dari Map yang dibaca dari SQLite
  factory User.fromSqliteMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      profileImageUrl: map['profileImageUrl'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.user, // Default jika tidak ditemukan
      ),
      balance: (map['balance'] as num).toDouble(),
    );
  }
}

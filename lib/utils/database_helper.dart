// lib/utils/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:futsal_booking_app/models/user.dart'; // Import models untuk schema
import 'package:futsal_booking_app/models/field.dart';
import 'package:futsal_booking_app/models/booking.dart';
import 'package:futsal_booking_app/utils/constants.dart'; // Untuk AppConstants
import 'package:uuid/uuid.dart'; // Tambahkan import Uuid

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await getDatabasesPath();
    String databasePath = join(path, 'futsal_booking_app.db'); // Nama database

    return await openDatabase(
      databasePath,
      version: 1, // Tingkatkan versi jika ada perubahan skema
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Pengguna
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE,
        email TEXT UNIQUE,
        password TEXT, -- Untuk demo, kita simpan password plaintext. Dalam produksi, gunakan hashing!
        profileImageUrl TEXT,
        role TEXT, -- 'admin' atau 'user'
        balance REAL DEFAULT 0.0
      )
    ''');

    // Tabel Lapangan Futsal
    await db.execute('''
      CREATE TABLE fields (
        id TEXT PRIMARY KEY,
        name TEXT,
        type TEXT,
        description TEXT,
        pricePerHour REAL,
        imageUrl TEXT
      )
    ''');

    // Tabel Booking
    await db.execute('''
      CREATE TABLE bookings (
        id TEXT PRIMARY KEY,
        userId TEXT,
        fieldId TEXT,
        bookingDate TEXT, -- Disimpan sebagai ISO8601 string (YYYY-MM-DDTHH:MM:SS.sss)
        startTime TEXT,  -- Disimpan sebagai HH:MM string
        durationHours INTEGER,
        totalPrice REAL,
        dpAmount REAL,
        amountPaid REAL,
        status TEXT, -- Enum BookingStatus.values.last
        createdAt TEXT, -- Disimpan sebagai ISO8601 string
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (fieldId) REFERENCES fields(id) ON DELETE CASCADE
      )
    ''');

    // Tambahkan admin user saat database pertama kali dibuat
    await _insertInitialAdmin(db);
    // Tambahkan data dummy lapangan saat database pertama kali dibuat
    await _insertInitialFields(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implementasi migrasi di sini jika skema database berubah di masa mendatang
    // Contoh:
    // if (oldVersion < 2) {
    //   await db.execute("ALTER TABLE users ADD COLUMN newColumn TEXT;");
    // }
  }

  Future<void> _insertInitialAdmin(Database db) async {
    final List<Map<String, dynamic>> existingAdmin = await db.query(
      'users',
      where: 'username = ? AND role = ?',
      whereArgs: [
        AppConstants.adminUsername,
        UserRole.admin.toString().split('.').last,
      ],
    );

    if (existingAdmin.isEmpty) {
      final User adminUser = User(
        id: const Uuid().v4(), // Generate ID unik untuk admin
        username: AppConstants.adminUsername,
        email: 'admin@futsal.com',
        role: UserRole.admin,
        profileImageUrl: null,
        balance: 0.0,
      );
      // Untuk demo, simpan password plaintext. Dalam produksi, hashing sangat disarankan.
      await db.insert('users', {
        ...adminUser.toSqliteMap(), // Gunakan toSqliteMap
        'password': AppConstants.adminPassword, // Simpan password admin
      });
      print('Admin user inserted successfully.');
    } else {
      print('Admin user already exists.');
    }
  }

  Future<void> _insertInitialFields(Database db) async {
    final List<Map<String, dynamic>> existingFields = await db.query('fields');
    if (existingFields.isEmpty) {
      final Uuid uuid = const Uuid();
      final List<Field> initialFields = [
        Field(
          id: uuid.v4(),
          name: 'Lapangan Vinyl',
          type: 'Karpet Vinyl',
          description:
              'Lapangan futsal modern dengan permukaan vinyl berkualitas tinggi, ideal untuk permainan cepat dan meminimalkan cedera.',
          pricePerHour: 120000,
          imageUrl: 'assets/images/futsal_field_vinyl.png',
        ),
        Field(
          id: uuid.v4(),
          name: 'Lapangan Sintetis',
          type: 'Rumput Sintetis',
          description:
              'Lapangan dengan rumput sintetis yang menyerupai asli, memberikan pengalaman bermain yang nyaman dan realistis.',
          pricePerHour: 150000,
          imageUrl: 'assets/images/futsal_field_synthetic.png',
        ),
        Field(
          id: uuid.v4(),
          name: 'Lapangan Standar',
          type: 'Standar Umum',
          description:
              'Lapangan futsal standar dengan harga terjangkau, cocok untuk bermain santai bersama teman-teman.',
          pricePerHour: 100000,
          imageUrl: 'assets/images/futsal_field_standard.png',
        ),
        Field(
          id: uuid.v4(),
          name: 'Lapangan Premier',
          type: 'Indoor Sport',
          description:
              'Lapangan indoor serbaguna dengan pencahayaan optimal dan sistem pendingin udara, cocok untuk berbagai aktivitas olahraga.',
          pricePerHour: 180000,
          imageUrl:
              'assets/images/futsal_field_synthetic.png', // Bisa pakai gambar yang sudah ada
        ),
      ];

      for (var field in initialFields) {
        await db.insert('fields', field.toSqliteMap()); // Gunakan toSqliteMap
      }
      print('Initial fields inserted successfully.');
    } else {
      print('Fields already exist.');
    }
  }

  // Metode untuk membersihkan database (berguna untuk testing/reset)
  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete('bookings');
    await db.delete('fields');
    // Hati-hati menghapus user, mungkin ingin mempertahankan admin
    await db.delete(
      'users',
      where: 'role = ?',
      whereArgs: [UserRole.user.toString().split('.').last],
    );
    print('All tables cleared (except admin user).');
  }
}

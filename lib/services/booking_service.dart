// lib/services/booking_service.dart
import 'package:futsal_booking_app/models/booking.dart';
import 'package:uuid/uuid.dart';
import 'package:futsal_booking_app/utils/database_helper.dart'; // Import DatabaseHelper
import 'package:sqflite/sqflite.dart'; // Import untuk ConflictAlgorithm

class BookingService {
  final Uuid _uuid = const Uuid();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Membuat booking baru
  Future<Booking> createBooking(Booking newBooking) async {
    final db = await _dbHelper.database;
    final bookingId = _uuid.v4();
    final bookingToInsert = Booking(
      id: bookingId,
      userId: newBooking.userId,
      fieldId: newBooking.fieldId,
      bookingDate: newBooking.bookingDate,
      startTime: newBooking.startTime,
      durationHours: newBooking.durationHours,
      totalPrice: newBooking.totalPrice,
      dpAmount: newBooking.dpAmount,
      amountPaid: newBooking.amountPaid,
      status: newBooking.status,
      createdAt: DateTime.now(),
    );

    await db.insert(
      'bookings',
      bookingToInsert.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return bookingToInsert;
  }

  // Mengambil semua data booking
  Future<List<Booking>> getAllBookings() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('bookings');
    return List.generate(maps.length, (i) {
      return Booking.fromSqliteMap(maps[i]);
    });
  }

  // Mengambil data booking berdasarkan ID pengguna
  Future<List<Booking>> getUserBookings(String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'bookingDate DESC, startTime DESC',
    );
    return List.generate(maps.length, (i) {
      return Booking.fromSqliteMap(maps[i]);
    });
  }

  // Memperbarui status booking
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    final db = await _dbHelper.database;
    await db.update(
      'bookings',
      {'status': newStatus.toString().split('.').last},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }

  // Memperbarui jumlah pembayaran booking
  Future<void> updateBookingPayment(String bookingId, double amount) async {
    final db = await _dbHelper.database;
    // Ambil booking saat ini untuk memperbarui amountPaid dan status
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [bookingId],
    );

    if (maps.isNotEmpty) {
      Booking currentBooking = Booking.fromSqliteMap(maps.first);
      currentBooking.amountPaid += amount;

      // Atur status booking berdasarkan total pembayaran
      if (currentBooking.amountPaid >= currentBooking.totalPrice) {
        currentBooking.status = BookingStatus.paidFull;
      } else if (currentBooking.amountPaid >= currentBooking.dpAmount &&
          currentBooking.dpAmount > 0) {
        currentBooking.status = BookingStatus.paidDP;
      }

      await db.update(
        'bookings',
        {
          'amountPaid': currentBooking.amountPaid,
          'status': currentBooking.status.toString().split('.').last,
        },
        where: 'id = ?',
        whereArgs: [bookingId],
      );
    } else {
      throw Exception('Booking with ID $bookingId not found.');
    }
  }

  // Mendapatkan booking berdasarkan ID
  Future<Booking?> getBookingById(String bookingId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [bookingId],
    );
    if (maps.isNotEmpty) {
      return Booking.fromSqliteMap(maps.first);
    }
    return null;
  }
}

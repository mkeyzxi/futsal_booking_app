// lib/services/booking_service.dart
import 'package:futsal_booking_app/models/booking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart'; // Pastikan package ini sudah ditambahkan di pubspec.yaml

class BookingService {
  final Uuid _uuid = const Uuid();
  static const String _bookingsKey =
      'app_bookings'; // Kunci untuk menyimpan data booking di SharedPreferences

  // Metode privat untuk memuat semua data booking dari SharedPreferences
  Future<List<Booking>> _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? bookingsJson = prefs.getString(_bookingsKey);
    if (bookingsJson != null) {
      // Jika ada data, decode JSON string menjadi list of Maps, lalu ubah ke List<Booking>
      Iterable decoded = jsonDecode(bookingsJson);
      return decoded.map((model) => Booking.fromJson(model)).toList();
    }
    // Jika tidak ada data, kembalikan list kosong
    return [];
  }

  // Metode privat untuk menyimpan List<Booking> ke SharedPreferences
  Future<void> _saveBookings(List<Booking> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    // Encode List<Booking> menjadi JSON string untuk disimpan
    String encoded = jsonEncode(bookings.map((b) => b.toJson()).toList());
    await prefs.setString(_bookingsKey, encoded);
  }

  // Membuat booking baru
  Future<Booking> createBooking(Booking newBooking) async {
    List<Booking> bookings =
        await _loadBookings(); // Muat semua booking yang sudah ada
    // Buat objek Booking baru dengan ID unik yang digenerate
    final bookingWithId = Booking(
      id: _uuid.v4(), // Generate unique ID
      userId: newBooking.userId,
      fieldId: newBooking.fieldId,
      bookingDate: newBooking.bookingDate,
      startTime: newBooking.startTime,
      durationHours: newBooking.durationHours,
      totalPrice: newBooking.totalPrice,
      dpAmount: newBooking.dpAmount,
      amountPaid: newBooking.amountPaid,
      status: newBooking.status,
      createdAt: DateTime.now(), // Set waktu pembuatan booking
    );
    bookings.add(bookingWithId); // Tambahkan booking baru ke list
    await _saveBookings(
      bookings,
    ); // Simpan kembali list booking yang sudah diupdate
    return bookingWithId; // Kembalikan booking yang baru dibuat
  }

  // Mengambil semua data booking
  Future<List<Booking>> getAllBookings() async {
    return await _loadBookings();
  }

  // Mengambil data booking berdasarkan ID pengguna
  Future<List<Booking>> getUserBookings(String userId) async {
    List<Booking> allBookings = await _loadBookings();
    return allBookings.where((booking) => booking.userId == userId).toList();
  }

  // Memperbarui status booking (misalnya dari pending ke cancelled atau completed)
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    List<Booking> bookings = await _loadBookings();
    int index = bookings.indexWhere(
      (b) => b.id == bookingId,
    ); // Cari indeks booking berdasarkan ID
    if (index != -1) {
      bookings[index].status = newStatus; // Perbarui status
      await _saveBookings(bookings); // Simpan perubahan
    }
  }

  // Memperbarui jumlah pembayaran booking
  Future<void> updateBookingPayment(String bookingId, double amount) async {
    List<Booking> bookings = await _loadBookings();
    int index = bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      bookings[index].amountPaid += amount; // Tambahkan jumlah yang dibayarkan
      // Atur status booking berdasarkan total pembayaran
      if (bookings[index].amountPaid >= bookings[index].totalPrice) {
        bookings[index].status = BookingStatus.paidFull;
      } else if (bookings[index].amountPaid >= bookings[index].dpAmount) {
        bookings[index].status = BookingStatus.paidDP;
      }
      await _saveBookings(bookings); // Simpan perubahan
    }
  }

  // Membatalkan booking (mengubah status menjadi cancelled)
  Future<void> cancelBooking(String bookingId) async {
    List<Booking> bookings = await _loadBookings();
    int index = bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      bookings[index].status =
          BookingStatus.cancelled; // Set status ke cancelled
      await _saveBookings(bookings); // Simpan perubahan
    }
  }
}

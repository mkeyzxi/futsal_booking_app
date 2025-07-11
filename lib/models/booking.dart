// lib/models/booking.dart
import 'package:futsal_booking_app/models/field.dart';
import 'package:futsal_booking_app/models/user.dart';

enum BookingStatus {
  pendingPayment, // Menunggu DP atau Lunas (termasuk cash di lokasi)
  paidDP, // DP sudah dibayar, sisa perlu dibayar di lokasi
  paidFull, // Sudah lunas
  cancelled, // Dibatalkan oleh admin atau user
  completed, // Booking sudah selesai (lapangan sudah digunakan)
}

class Booking {
  final String id;
  final String userId;
  final User? user; // Hanya untuk display, tidak disimpan di DB Booking
  final String fieldId;
  final Field? field; // Hanya untuk display, tidak disimpan di DB Booking
  final DateTime bookingDate;
  final String startTime; // Format "HH:MM"
  final int durationHours;
  final double totalPrice;
  final double dpAmount;
  double amountPaid;
  BookingStatus status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    this.user, // opsional
    required this.fieldId,
    this.field, // opsional
    required this.bookingDate,
    required this.startTime,
    required this.durationHours,
    required this.totalPrice,
    required this.dpAmount,
    this.amountPaid = 0.0,
    this.status = BookingStatus.pendingPayment,
    required this.createdAt,
  });

  // Konversi objek Booking ke Map untuk penyimpanan SQLite
  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'userId': userId,
      'fieldId': fieldId,
      'bookingDate':
          bookingDate
              .toIso8601String()
              .split('T')
              .first, // Simpan hanya tanggal
      'startTime': startTime,
      'durationHours': durationHours,
      'totalPrice': totalPrice,
      'dpAmount': dpAmount,
      'amountPaid': amountPaid,
      'status': status.toString().split('.').last, // Simpan enum sebagai string
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Buat objek Booking dari Map yang dibaca dari SQLite
  factory Booking.fromSqliteMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as String,
      userId: map['userId'] as String,
      fieldId: map['fieldId'] as String,
      bookingDate: DateTime.parse(
        map['bookingDate'] as String,
      ), // Parse dari string
      startTime: map['startTime'] as String,
      durationHours: map['durationHours'] as int,
      totalPrice: (map['totalPrice'] as num).toDouble(),
      dpAmount: (map['dpAmount'] as num).toDouble(),
      amountPaid: (map['amountPaid'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse:
            () => BookingStatus.pendingPayment, // Default jika tidak ditemukan
      ),
      createdAt: DateTime.parse(
        map['createdAt'] as String,
      ), // Parse dari string
    );
  }
}

// lib/models/booking.dart (Pastikan seperti ini)
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
  final User? user;
  final String fieldId;
  final Field? field;
  final DateTime bookingDate;
  final String startTime; // <--- PASTIKAN TIPE DATA INI STRING
  final int durationHours;
  final double totalPrice;
  final double dpAmount;
  double amountPaid; // Tidak final, seperti yang sudah diperbaiki
  BookingStatus status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    this.user,
    required this.fieldId,
    this.field,
    required this.bookingDate,
    required this.startTime, // <--- Ini menerima STRING
    required this.durationHours,
    required this.totalPrice,
    required this.dpAmount,
    this.amountPaid = 0.0,
    this.status = BookingStatus.pendingPayment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fieldId': fieldId,
      'bookingDate': bookingDate.toIso8601String(),
      'startTime': startTime, // <--- Menyimpan STRING
      'durationHours': durationHours,
      'totalPrice': totalPrice,
      'dpAmount': dpAmount,
      'amountPaid': amountPaid,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['userId'],
      fieldId: json['fieldId'],
      bookingDate: DateTime.parse(json['bookingDate']),
      startTime: json['startTime'], // <--- Membaca STRING
      durationHours: json['durationHours'],
      totalPrice: (json['totalPrice'] as num).toDouble(),
      dpAmount: (json['dpAmount'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => BookingStatus.pendingPayment,
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

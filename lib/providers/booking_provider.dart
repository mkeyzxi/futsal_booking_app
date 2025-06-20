// lib/providers/booking_provider.dart
import 'package:flutter/material.dart';
import 'package:futsal_booking_app/models/booking.dart';
import 'package:futsal_booking_app/models/user.dart'; // Import User
import 'package:futsal_booking_app/models/field.dart'; // Import Field
import 'package:futsal_booking_app/services/booking_service.dart';
import 'package:futsal_booking_app/services/field_service.dart'; // Import FieldService
import 'package:futsal_booking_app/services/auth_service.dart'; // Import AuthService

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final FieldService _fieldService =
      FieldService(); // Untuk mengambil detail lapangan
  final AuthService _authService = AuthService(); // Untuk mengambil detail user

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBookings({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<Booking> fetchedBookings =
          userId == null
              ? await _bookingService.getAllBookings()
              : await _bookingService.getUserBookings(userId);

      // Load additional details for user and field for display purposes
      List<Booking> enrichedBookings = [];
      for (var booking in fetchedBookings) {
        // PERBAIKAN DI SINI: Panggil metode publik getUserById
        User? user = await _authService.getUserById(booking.userId);
        Field? field = await _fieldService.getFieldById(booking.fieldId);
        enrichedBookings.add(
          Booking(
            id: booking.id,
            userId: booking.userId,
            user: user, // user sekarang diambil dari method publik
            fieldId: booking.fieldId,
            field: field,
            bookingDate: booking.bookingDate,
            startTime: booking.startTime,
            durationHours: booking.durationHours,
            totalPrice: booking.totalPrice,
            dpAmount: booking.dpAmount,
            amountPaid: booking.amountPaid,
            status: booking.status,
            createdAt: booking.createdAt,
          ),
        );
      }

      _bookings = enrichedBookings;
    } catch (e) {
      _errorMessage = 'Gagal memuat daftar booking: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Booking?> createBooking({
    required String userId,
    required String fieldId,
    required DateTime bookingDate,
    required TimeOfDay startTime,
    required int durationHours,
    required double totalPrice,
    required double dpAmount,
    required double amountPaid,
    required BookingStatus status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newBooking = Booking(
        id: '', // ID akan digenerate oleh service
        userId: userId,
        fieldId: fieldId,
        bookingDate: bookingDate,
        startTime:
            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
        durationHours: durationHours,
        totalPrice: totalPrice,
        dpAmount: dpAmount,
        amountPaid: amountPaid,
        status: status,
        createdAt: DateTime.now(),
      );
      final createdBooking = await _bookingService.createBooking(newBooking);
      // Refresh daftar booking setelah pembuatan, untuk memastikan UI diupdate
      // Tergantung kebutuhan, Anda bisa refresh semua booking atau hanya booking user
      await fetchBookings(
        userId: userId,
      ); // Contoh: refresh booking untuk user ini
      notifyListeners();
      return createdBooking;
    } catch (e) {
      _errorMessage = 'Gagal membuat booking: ${e.toString()}';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _bookingService.updateBookingStatus(bookingId, newStatus);
      await fetchBookings(); // Refresh all bookings for admin or relevant bookings
    } catch (e) {
      _errorMessage = 'Gagal memperbarui status booking: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    // Memanggil updateBookingStatus untuk mengubah status menjadi cancelled
    await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  Future<void> markBookingAsCompleted(String bookingId) async {
    // Memanggil updateBookingStatus untuk mengubah status menjadi completed
    await updateBookingStatus(bookingId, BookingStatus.completed);
  }

  Future<void> updateBookingPayment(String bookingId, double amount) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _bookingService.updateBookingPayment(bookingId, amount);
      await fetchBookings(); // Refresh all bookings to show updated payment
    } catch (e) {
      _errorMessage = 'Gagal memperbarui pembayaran booking: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

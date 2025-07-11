// lib/providers/booking_provider.dart
import 'package:flutter/material.dart';
import 'package:futsal_booking_app/models/booking.dart';
import 'package:futsal_booking_app/models/user.dart';
import 'package:futsal_booking_app/models/field.dart';
import 'package:futsal_booking_app/services/booking_service.dart';
import 'package:futsal_booking_app/services/field_service.dart';
import 'package:futsal_booking_app/services/auth_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final FieldService _fieldService = FieldService();
  final AuthService _authService = AuthService();

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Memuat semua booking (biasanya untuk admin) atau booking spesifik user
  Future<void> fetchBookings({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<Booking> fetchedBookings;
      if (userId == null) {
        fetchedBookings = await _bookingService.getAllBookings();
      } else {
        fetchedBookings = await _bookingService.getUserBookings(userId);
      }

      // Load additional details (User and Field objects) for display
      List<Booking> enrichedBookings = [];
      for (var booking in fetchedBookings) {
        User? user = await _authService.getUserById(booking.userId);
        Field? field = await _fieldService.getFieldById(booking.fieldId);

        enrichedBookings.add(
          Booking(
            id: booking.id,
            userId: booking.userId,
            user: user, // Set user object
            fieldId: booking.fieldId,
            field: field, // Set field object
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

  // Membuat booking baru
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
      await fetchBookings(userId: userId); // Refresh booking untuk user ini
      return createdBooking;
    } catch (e) {
      _errorMessage = 'Gagal membuat booking: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
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
      // Dapatkan userId dari booking yang diupdate untuk refresh spesifik
      final updatedBooking = await _bookingService.getBookingById(bookingId);
      if (updatedBooking != null) {
        await fetchBookings(userId: updatedBooking.userId);
      } else {
        await fetchBookings(); // Fallback untuk refresh semua
      }
    } catch (e) {
      _errorMessage = 'Gagal memperbarui status booking: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  Future<void> markBookingAsCompleted(String bookingId) async {
    await updateBookingStatus(bookingId, BookingStatus.completed);
  }

  Future<void> updateBookingPayment(
    String bookingId,
    double amount,
    String userId,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _bookingService.updateBookingPayment(bookingId, amount);
      // Refresh booking untuk user yang terkait
      await fetchBookings(userId: userId);
    } catch (e) {
      _errorMessage = 'Gagal memperbarui pembayaran booking: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

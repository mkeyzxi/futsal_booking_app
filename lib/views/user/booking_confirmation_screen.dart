// lib/views/user/booking_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:futsal_booking_app/models/field.dart';
import 'package:futsal_booking_app/models/booking.dart';
import 'package:futsal_booking_app/models/user.dart'; // <-- Tambahkan ini untuk UserRole
import 'package:futsal_booking_app/providers/auth_provider.dart'; // <--- Gunakan ini untuk saldo
import 'package:futsal_booking_app/providers/booking_provider.dart';
import 'package:futsal_booking_app/utils/app_styles.dart';
import 'package:futsal_booking_app/views/common_widgets/custom_button.dart';
import 'package:intl/intl.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Field field;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int durationHours;
  final double totalPrice;
  final double dpAmount;

  const BookingConfirmationScreen({
    super.key,
    required this.field,
    required this.selectedDate,
    required this.selectedTime,
    required this.durationHours,
    required this.totalPrice,
    required this.dpAmount,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  String _paymentMethod = 'dp_only';
  bool _isProcessing = false;

  void _processPaymentAndBooking() async {
    setState(() {
      _isProcessing = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    double amountToPay = 0;
    BookingStatus bookingStatus = BookingStatus.pendingPayment;
    String transactionMessage = '';

    if (authProvider.currentUser == null ||
        authProvider.currentUser!.role != UserRole.user) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Anda harus login sebagai pengguna untuk melakukan booking.',
          ),
        ),
      );
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    try {
      // 1. Tentukan jumlah pembayaran dan status booking
      if (_paymentMethod == 'dp_only') {
        amountToPay = widget.dpAmount;
        bookingStatus = BookingStatus.paidDP;
        transactionMessage = 'Uang muka (DP)';
        // Debit saldo dari AuthProvider
        await authProvider.debitBalance(amountToPay);
      } else if (_paymentMethod == 'full_payment') {
        amountToPay = widget.totalPrice;
        bookingStatus = BookingStatus.paidFull;
        transactionMessage = 'Pembayaran lunas';
        // Debit saldo dari AuthProvider
        await authProvider.debitBalance(amountToPay);
      } else if (_paymentMethod == 'cash') {
        amountToPay = 0; // Tidak ada pembayaran melalui aplikasi
        bookingStatus =
            BookingStatus
                .pendingPayment; // Status awal, perlu dikonfirmasi admin
        transactionMessage =
            'Booking berhasil dengan pembayaran cash di lokasi.';
        // Tidak perlu debit saldo user dari aplikasi untuk pembayaran cash
      }

      // 2. Validasi Ketersediaan Jadwal (Overlap)
      final DateTime selectedStartDateTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        widget.selectedTime.hour,
        widget.selectedTime.minute,
      );
      final DateTime selectedEndDateTime = selectedStartDateTime.add(
        Duration(hours: widget.durationHours),
      );

      // Ambil semua booking yang relevan untuk validasi
      await bookingProvider.fetchBookings(userId: null); // Ambil semua booking
      final List<Booking> existingBookingsForField =
          bookingProvider.bookings
              .where(
                (b) =>
                    b.fieldId == widget.field.id &&
                    b.status != BookingStatus.cancelled &&
                    b.status != BookingStatus.completed,
              )
              .toList();

      for (var existingBooking in existingBookingsForField) {
        final existingStartHour = int.parse(
          existingBooking.startTime.split(':')[0],
        );
        final existingMinute = int.parse(
          existingBooking.startTime.split(':')[1],
        );
        final DateTime existingStartDateTime = DateTime(
          existingBooking.bookingDate.year,
          existingBooking.bookingDate.month,
          existingBooking.bookingDate.day,
          existingStartHour,
          existingMinute,
        );
        final DateTime existingEndDateTime = existingStartDateTime.add(
          Duration(hours: existingBooking.durationHours),
        );

        bool isOverlap =
            selectedStartDateTime.isBefore(existingEndDateTime) &&
            selectedEndDateTime.isAfter(existingStartDateTime);

        if (isOverlap) {
          // Jika ada overlap, batalkan transaksi saldo yang sudah didebit (jika ada)
          if (amountToPay > 0 &&
              (_paymentMethod == 'dp_only' ||
                  _paymentMethod == 'full_payment')) {
            await authProvider.addBalance(
              amountToPay,
            ); // Rollback saldo melalui AuthProvider
          }
          throw Exception(
            'Jadwal ini sudah dibooking. Silakan pilih waktu lain.',
          );
        }
      }

      // 3. Buat Booking Baru jika Validasi Berhasil
      await bookingProvider.createBooking(
        userId: authProvider.currentUser!.id,
        fieldId: widget.field.id,
        bookingDate: widget.selectedDate,
        startTime: widget.selectedTime,
        durationHours: widget.durationHours,
        totalPrice: widget.totalPrice,
        dpAmount: widget.dpAmount,
        amountPaid: amountToPay,
        status: bookingStatus,
      );

      String finalMessage = '';
      if (_paymentMethod == 'cash') {
        finalMessage = transactionMessage;
      } else {
        finalMessage =
            '$transactionMessage sebesar Rp ${amountToPay.toInt()} berhasil! Booking Anda telah dikonfirmasi.';
      }

      _showSuccessDialog(finalMessage);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Akses saldo dari AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(title: const Text('Konfirmasi Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Booking', style: AppStyles.headingStyle),
            const SizedBox(height: 16),
            _buildDetailRow('Lapangan:', widget.field.name),
            _buildDetailRow('Jenis Lapangan:', widget.field.type),
            _buildDetailRow(
              'Tanggal:',
              DateFormat(
                'dd MMMM sebagaimana',
                'id_ID',
              ).format(widget.selectedDate),
            ),
            _buildDetailRow(
              'Waktu Mulai:',
              widget.selectedTime.format(context),
            ),
            _buildDetailRow('Durasi:', '${widget.durationHours} jam'),
            const SizedBox(height: 24),
            Text('Rincian Pembayaran', style: AppStyles.headingStyle),
            const SizedBox(height: 16),
            _buildPaymentSummaryRow(
              'Harga per jam:',
              'Rp ${widget.field.pricePerHour.toInt()}',
            ),
            _buildPaymentSummaryRow(
              'Total Harga:',
              'Rp ${widget.totalPrice.toInt()}',
            ),
            _buildPaymentSummaryRow(
              'Uang Muka (DP 30%):',
              'Rp ${widget.dpAmount.toInt()}',
            ),
            _buildPaymentSummaryRow(
              'Sisa Pembayaran:',
              'Rp ${(widget.totalPrice - widget.dpAmount).toInt()}',
              isBold: true,
            ),
            const SizedBox(height: 24),
            Text('Metode Pembayaran', style: AppStyles.headingStyle),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppStyles.defaultBorderRadius,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppStyles.defaultPadding),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Text(
                        'Bayar Uang Muka (DP) Rp ${widget.dpAmount.toInt()}',
                        style: AppStyles.bodyTextStyle,
                      ),
                      value: 'dp_only',
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                      activeColor: AppStyles.primaryColor,
                    ),
                    RadioListTile<String>(
                      title: Text(
                        'Bayar Lunas Rp ${widget.totalPrice.toInt()}',
                        style: AppStyles.bodyTextStyle,
                      ),
                      value: 'full_payment',
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                      activeColor: AppStyles.primaryColor,
                    ),
                    RadioListTile<String>(
                      title: Text(
                        'Bayar Cash di Lokasi',
                        style: AppStyles.bodyTextStyle,
                      ),
                      value: 'cash',
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                      activeColor: AppStyles.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(AppStyles.defaultPadding),
              decoration: AppStyles.cardDecoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo Anda:',
                    style: AppStyles.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Akses saldo dari authProvider
                  Text(
                    'Rp ${authProvider.userBalance.toInt()}',
                    style: AppStyles.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppStyles.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Konfirmasi Pembayaran',
              isLoading: _isProcessing,
              onPressed: _processPaymentAndBooking,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppStyles.bodyTextStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppStyles.bodyTextStyle)),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyles.bodyTextStyle.copyWith(
              color: Colors.grey[700],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: AppStyles.bodyTextStyle.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.defaultBorderRadius),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppStyles.successColor),
              SizedBox(width: 8),
              Text('Booking Berhasil!'),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: AppStyles.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                ); // Kembali ke dashboard user
              },
            ),
          ],
        );
      },
    );
  }
}

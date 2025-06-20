// lib/views/user/booking_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:futsal_booking_app/providers/booking_provider.dart';
import 'package:futsal_booking_app/providers/auth_provider.dart';
import 'package:futsal_booking_app/models/booking.dart';
import 'package:futsal_booking_app/utils/app_styles.dart';
import 'package:intl/intl.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        Provider.of<BookingProvider>(
          context,
          listen: false,
        ).fetchBookings(userId: authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(title: const Text('Riwayat Booking')),
      body: Consumer2<AuthProvider, BookingProvider>(
        builder: (context, authProvider, bookingProvider, child) {
          if (authProvider.currentUser == null) {
            return const Center(
              child: Text('Mohon login untuk melihat riwayat booking.'),
            );
          }

          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookingProvider.errorMessage != null) {
            return Center(child: Text(bookingProvider.errorMessage!));
          }

          if (bookingProvider.bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'Belum ada riwayat booking.',
                    style: AppStyles.bodyTextStyle.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Lakukan booking pertama Anda sekarang!',
                    style: AppStyles.smallTextStyle.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // Filter booking untuk user yang sedang login
          final userBookings =
              bookingProvider.bookings
                  .where((b) => b.userId == authProvider.currentUser!.id)
                  .toList();

          if (userBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'Belum ada riwayat booking.',
                    style: AppStyles.bodyTextStyle.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Lakukan booking pertama Anda sekarang!',
                    style: AppStyles.smallTextStyle.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // Urutkan booking dari yang terbaru
          userBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.builder(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            itemCount: userBookings.length,
            itemBuilder: (context, index) {
              final booking = userBookings[index];
              return _buildBookingCard(context, booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking) {
    Color statusColor;
    String statusText;
    switch (booking.status) {
      case BookingStatus.pendingPayment:
        statusColor = Colors.orange;
        statusText = 'Menunggu Pembayaran';
        break;
      case BookingStatus.paidDP:
        statusColor = Colors.blue;
        statusText = 'DP Dibayar';
        break;
      case BookingStatus.paidFull:
        statusColor = AppStyles.successColor;
        statusText = 'Lunas';
        break;
      case BookingStatus.cancelled:
        statusColor = AppStyles.errorColor;
        statusText = 'Dibatalkan';
        break;
      case BookingStatus.completed:
        statusColor = Colors.grey;
        statusText = 'Selesai';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.field?.name ?? 'Lapangan Tidak Dikenal',
                  style: AppStyles.subHeadingStyle.copyWith(fontSize: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: AppStyles.smallTextStyle.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(booking.bookingDate)}', // Menambahkan locale
              style: AppStyles.bodyTextStyle.copyWith(color: Colors.grey[700]),
            ),
            Text(
              'Pukul: ${booking.startTime} (${booking.durationHours} jam)',
              style: AppStyles.bodyTextStyle.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Harga:',
                  style: AppStyles.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rp ${booking.totalPrice.toInt()}',
                  style: AppStyles.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppStyles.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dibayar:',
                  style: AppStyles.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rp ${booking.amountPaid.toInt()}',
                  style: AppStyles.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppStyles.successColor,
                  ),
                ),
              ],
            ),
            if (booking.status == BookingStatus.paidDP)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sisa Pembayaran:',
                      style: AppStyles.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rp ${(booking.totalPrice - booking.amountPaid).toInt()}',
                      style: AppStyles.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppStyles.errorColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

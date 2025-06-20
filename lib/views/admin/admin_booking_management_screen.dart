// lib/views/admin/admin_booking_management_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:futsal_booking_app/providers/booking_provider.dart';
import 'package:futsal_booking_app/models/booking.dart';
import 'package:futsal_booking_app/utils/app_styles.dart';
import 'package:intl/intl.dart';

class AdminBookingManagementScreen extends StatefulWidget {
  const AdminBookingManagementScreen({super.key});

  @override
  State<AdminBookingManagementScreen> createState() =>
      _AdminBookingManagementScreenState();
}

class _AdminBookingManagementScreenState
    extends State<AdminBookingManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(title: const Text('Manajemen Booking')),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
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
                  Icon(Icons.book_online, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'Belum ada booking yang masuk.',
                    style: AppStyles.bodyTextStyle.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Daftar booking dari pengguna akan tampil di sini.',
                    style: AppStyles.smallTextStyle.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // Urutkan booking dari yang terbaru
          final sortedBookings = List<Booking>.from(bookingProvider.bookings);
          sortedBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.builder(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            itemCount: sortedBookings.length,
            itemBuilder: (context, index) {
              final booking = sortedBookings[index];
              return _buildBookingCard(context, booking, bookingProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    Booking booking,
    BookingProvider bookingProvider,
  ) {
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
                Expanded(
                  child: Text(
                    booking.field?.name ?? 'Lapangan Tidak Dikenal',
                    style: AppStyles.subHeadingStyle.copyWith(fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
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
              'User: ${booking.user?.username ?? 'Anonim'}',
              style: AppStyles.bodyTextStyle.copyWith(color: Colors.grey[700]),
            ),
            Text(
              'Tanggal: ${DateFormat('dd MMMM yyyy').format(booking.bookingDate)}',
              style: AppStyles.bodyTextStyle.copyWith(color: Colors.grey[700]),
            ),
            Text(
              'Waktu: ${booking.startTime} (${booking.durationHours} jam)',
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
            const SizedBox(height: 16),
            if (booking.status != BookingStatus.cancelled &&
                booking.status != BookingStatus.completed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      bookingProvider.isLoading
                          ? null
                          : () => _confirmCancelBooking(
                            context,
                            booking,
                            bookingProvider,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.errorColor,
                  ),
                  child:
                      bookingProvider.isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Batalkan Booking',
                            style: AppStyles.bodyTextStyle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            if (booking.status == BookingStatus.paidDP ||
                booking.status == BookingStatus.pendingPayment)
              const SizedBox(height: 8),
            if (booking.status == BookingStatus.paidDP ||
                booking.status == BookingStatus.pendingPayment)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      bookingProvider.isLoading
                          ? null
                          : () => _confirmPaymentUpdate(
                            context,
                            booking,
                            bookingProvider,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryColor,
                  ),
                  child:
                      bookingProvider.isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Update Pembayaran',
                            style: AppStyles.bodyTextStyle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            if (booking.status == BookingStatus.paidFull ||
                booking.status == BookingStatus.paidDP)
              const SizedBox(height: 8),
            if (booking.status == BookingStatus.paidFull ||
                booking.status == BookingStatus.paidDP)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      bookingProvider.isLoading
                          ? null
                          : () => _confirmCompleteBooking(
                            context,
                            booking,
                            bookingProvider,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.successColor,
                  ),
                  child:
                      bookingProvider.isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Tandai Selesai',
                            style: AppStyles.bodyTextStyle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmCancelBooking(
    BuildContext context,
    Booking booking,
    BookingProvider bookingProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Batalkan Booking?'),
          content: Text(
            'Anda yakin ingin membatalkan booking lapangan "${booking.field?.name}" oleh "${booking.user?.username}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Ya, Batalkan',
                style: TextStyle(color: AppStyles.errorColor),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await bookingProvider.cancelBooking(booking.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking berhasil dibatalkan.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmCompleteBooking(
    BuildContext context,
    Booking booking,
    BookingProvider bookingProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selesaikan Booking?'),
          content: Text('Anda yakin ingin menandai booking ini selesai?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Ya, Selesai',
                style: TextStyle(color: AppStyles.successColor),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await bookingProvider.markBookingAsCompleted(booking.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking ditandai selesai.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmPaymentUpdate(
    BuildContext context,
    Booking booking,
    BookingProvider bookingProvider,
  ) {
    TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Booking oleh: ${booking.user?.username ?? 'Anonim'} untuk lapangan ${booking.field?.name ?? 'Tidak Dikenal'}',
              ),
              Text(
                'Sisa pembayaran: Rp ${(booking.totalPrice - booking.amountPaid).toInt()}',
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Masukkan jumlah pembayaran',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Bayar',
                style: TextStyle(color: AppStyles.primaryColor),
              ),
              onPressed: () async {
                final double? amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Jumlah pembayaran tidak valid.'),
                    ),
                  );
                  return;
                }
                if (amount > (booking.totalPrice - booking.amountPaid)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Jumlah pembayaran melebihi sisa yang harus dibayar.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();
                await bookingProvider.updateBookingPayment(booking.id, amount);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pembayaran sebesar Rp ${amount.toInt()} berhasil diupdate.',
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

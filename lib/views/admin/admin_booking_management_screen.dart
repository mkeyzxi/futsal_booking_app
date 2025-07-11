// lib/views/admin/admin_booking_management_screen.dart
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
      // Panggil fetchBookings tanpa userId untuk mendapatkan semua booking
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

          // Urutkan booking dari yang terbaru berdasarkan createdAt
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
        statusColor = AppStyles.warningColor; // Ganti ke warna warning
        statusText = 'Menunggu Pembayaran';
        break;
      case BookingStatus.paidDP:
        statusColor = AppStyles.infoColor; // Ganti ke warna info
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
      child: InkWell(
        // Tambahkan InkWell agar card bisa diklik untuk detail
        onTap: () {
          _showBookingDetailsDialog(context, booking, bookingProvider);
        },
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
                style: AppStyles.bodyTextStyle.copyWith(
                  color: AppStyles.secondaryTextColor,
                ),
              ),
              Text(
                'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(booking.bookingDate)}',
                style: AppStyles.bodyTextStyle.copyWith(
                  color: AppStyles.secondaryTextColor,
                ),
              ),
              Text(
                'Waktu: ${booking.startTime} (${booking.durationHours} jam)',
                style: AppStyles.bodyTextStyle.copyWith(
                  color: AppStyles.secondaryTextColor,
                ),
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
              if (booking.status == BookingStatus.paidDP ||
                  booking.status == BookingStatus.pendingPayment)
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
              // Tombol aksi di dalam card (disesuaikan dengan status)
              _buildActionButtons(context, booking, bookingProvider),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk tombol aksi di card
  Widget _buildActionButtons(
    BuildContext context,
    Booking booking,
    BookingProvider bookingProvider,
  ) {
    if (booking.status == BookingStatus.cancelled ||
        booking.status == BookingStatus.completed) {
      return const SizedBox.shrink(); // Tidak menampilkan tombol jika sudah dibatalkan/selesai
    }

    return Column(
      children: [
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
            style:
                AppStyles
                    .primaryButtonStyle, // Gunakan style yang sudah didefinisikan
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
                    : Text('Update Pembayaran', style: AppStyles.buttonText),
          ),
        ),
        const SizedBox(height: AppStyles.paddingSmall),
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
              backgroundColor:
                  AppStyles.successColor, // Contoh penggunaan warna langsung
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusDefault),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyles.paddingLarge,
                vertical: AppStyles.paddingSmall,
              ),
              textStyle: AppStyles.buttonText,
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
                    : Text('Tandai Selesai', style: AppStyles.buttonText),
          ),
        ),
        const SizedBox(height: AppStyles.paddingSmall),
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
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusDefault),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyles.paddingLarge,
                vertical: AppStyles.paddingSmall,
              ),
              textStyle: AppStyles.buttonText,
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
                    : Text('Batalkan Booking', style: AppStyles.buttonText),
          ),
        ),
      ],
    );
  }

  // Dialog untuk menampilkan detail satu booking
  void _showBookingDetailsDialog(
    BuildContext context,
    Booking booking,
    BookingProvider bookingProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.defaultBorderRadius),
          ),
          title: Text(
            'Detail Booking: ${booking.field?.name ?? 'Tidak Dikenal'}',
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Lapangan:', booking.field?.name ?? 'N/A'),
                _buildDetailRow('User:', booking.user?.username ?? 'N/A'),
                _buildDetailRow('Email User:', booking.user?.email ?? 'N/A'),
                _buildDetailRow(
                  'Tanggal Booking:',
                  DateFormat(
                    'dd MMMM yyyy',
                    'id_ID',
                  ).format(booking.bookingDate),
                ),
                _buildDetailRow(
                  'Waktu Booking:',
                  '${booking.startTime} (${booking.durationHours} jam)',
                ),
                _buildDetailRow(
                  'Harga Total:',
                  'Rp ${booking.totalPrice.toInt()}',
                ),
                _buildDetailRow('Dibayar:', 'Rp ${booking.amountPaid.toInt()}'),
                _buildDetailRow(
                  'Status:',
                  booking.status
                      .toString()
                      .split('.')
                      .last
                      .replaceAll('pendingPayment', 'Menunggu Pembayaran')
                      .replaceAll('paidDP', 'DP Dibayar')
                      .replaceAll('paidFull', 'Lunas')
                      .replaceAll('cancelled', 'Dibatalkan')
                      .replaceAll('completed', 'Selesai'),
                ),
                const SizedBox(height: 16),
                // Tombol aksi di dalam dialog detail
                _buildActionButtons(context, booking, bookingProvider),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Tutup',
                style: TextStyle(color: AppStyles.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                //bookingProvider.fetchBookings(); // Refresh data setelah menutup dialog jika ada perubahan
              },
            ),
          ],
        );
      },
    );
  }

  // Metode pembantu untuk baris detail (tidak ada perubahan)
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppStyles.bodyTextStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppStyles.bodyTextStyle.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Metode konfirmasi aksi (cancel, complete, payment update) yang dipanggil dari dialog detail
  void _confirmCancelBooking(
    BuildContext context,
    Booking booking,
    BookingProvider bookingProvider,
  ) {
    // Tutup dialog sebelumnya (detail booking)
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Batalkan Booking?'),
          content: Text(
            'Anda yakin ingin membatalkan booking lapangan "${booking.field?.name ?? 'Tidak Dikenal'}" oleh "${booking.user?.username ?? 'Anonim'}" pada ${DateFormat('dd MMM HH:mm', 'id_ID').format(booking.bookingDate)}?',
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
                // Setelah aksi, refresh data booking di admin screen
                bookingProvider.fetchBookings();
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
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selesaikan Booking?'),
          content: Text(
            'Anda yakin ingin menandai booking lapangan "${booking.field?.name ?? 'Tidak Dikenal'}" oleh "${booking.user?.username ?? 'Anonim'}" selesai?',
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
                'Ya, Selesai',
                style: TextStyle(color: AppStyles.successColor),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await bookingProvider.markBookingAsCompleted(booking.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking ditandai selesai.')),
                );
                // Setelah aksi, refresh data booking di admin screen
                bookingProvider.fetchBookings();
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
    Navigator.of(context).pop();
    TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Mendapatkan tema input dari AppStyles.inputDecorationTheme
        final InputDecorationTheme inputTheme =
            Theme.of(context).inputDecorationTheme;

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
                // Terapkan tema input ke InputDecoration
                decoration: InputDecoration(
                  hintText: 'Masukkan jumlah pembayaran',
                ).applyDefaults(inputTheme), // Panggil applyDefaults
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
                // Penting: Kirim userId juga karena updateBookingPayment di provider membutuhkannya
                await bookingProvider.updateBookingPayment(
                  booking.id,
                  amount,
                  booking.userId,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pembayaran sebesar Rp ${amount.toInt()} berhasil diupdate.',
                    ),
                  ),
                );
                // Setelah aksi, refresh data booking di admin screen
                bookingProvider.fetchBookings();
              },
            ),
          ],
        );
      },
    );
  }
}

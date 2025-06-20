// lib/views/admin/admin_schedule_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:futsal_booking_app/providers/booking_provider.dart';
import 'package:futsal_booking_app/providers/field_provider.dart';
import 'package:futsal_booking_app/models/booking.dart';
import 'package:futsal_booking_app/models/field.dart';
import 'package:futsal_booking_app/utils/app_styles.dart';
import 'package:intl/intl.dart';

class AdminScheduleManagementScreen extends StatefulWidget {
  const AdminScheduleManagementScreen({super.key});

  @override
  State<AdminScheduleManagementScreen> createState() =>
      _AdminScheduleManagementScreenState();
}

class _AdminScheduleManagementScreenState
    extends State<AdminScheduleManagementScreen> {
  DateTime _selectedDate = DateTime.now();
  final TimeOfDay _openingTime = const TimeOfDay(
    hour: 8,
    minute: 0,
  ); // Lapangan buka jam 8 pagi
  final TimeOfDay _closingTime = const TimeOfDay(
    hour: 20,
    minute: 0,
  ); // Lapangan tutup jam 8 malam (disesuaikan agar ada sisa slot setelah 15.30)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    await Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    await Provider.of<FieldProvider>(context, listen: false).fetchFields();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Metode untuk menghasilkan segmen jadwal (booked/available)
  Map<Field, List<Map<String, dynamic>>> _getScheduleSegments(
    List<Booking> allBookings,
    List<Field> allFields,
  ) {
    Map<Field, List<Map<String, dynamic>>> fieldSchedules = {};
    final selectedDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final now = DateTime.now();
    final currentDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );

    for (var field in allFields) {
      List<Map<String, dynamic>> segments = [];

      // Filter booking untuk lapangan ini pada tanggal yang dipilih dan status aktif
      final relevantBookings =
          allBookings.where((booking) {
            return booking.fieldId == field.id &&
                booking.bookingDate.year == selectedDay.year &&
                booking.bookingDate.month == selectedDay.month &&
                booking.bookingDate.day == selectedDay.day &&
                booking.status != BookingStatus.cancelled &&
                booking.status != BookingStatus.completed;
          }).toList();

      // Urutkan booking berdasarkan waktu mulai
      relevantBookings.sort((a, b) {
        final startTimeA = DateTime(
          a.bookingDate.year,
          a.bookingDate.month,
          a.bookingDate.day,
          int.parse(a.startTime.split(':')[0]),
          int.parse(a.startTime.split(':')[1]),
        );
        final startTimeB = DateTime(
          b.bookingDate.year,
          b.bookingDate.month,
          b.bookingDate.day,
          int.parse(b.startTime.split(':')[0]),
          int.parse(b.startTime.split(':')[1]),
        );
        return startTimeA.compareTo(startTimeB);
      });

      // Inisialisasi waktu mulai jadwal lapangan
      DateTime currentCursor = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        _openingTime.hour,
        _openingTime.minute,
      );
      DateTime closingDateTime = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        _closingTime.hour,
        _closingTime.minute,
      );

      for (var booking in relevantBookings) {
        final bookedStartHourParsed = int.parse(
          booking.startTime.split(':')[0],
        );
        final bookedStartMinuteParsed = int.parse(
          booking.startTime.split(':')[1],
        );
        final DateTime bookingStartDateTime = DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
          bookedStartHourParsed,
          bookedStartMinuteParsed,
        );
        final DateTime bookingEndDateTime = bookingStartDateTime.add(
          Duration(hours: booking.durationHours),
        );

        // Tambahkan segmen 'available' jika ada gap sebelum booking ini
        if (bookingStartDateTime.isAfter(currentCursor)) {
          segments.add({
            'type': 'available',
            'start': currentCursor,
            'end': bookingStartDateTime,
            'isPast': currentCursor.isBefore(currentDateTime),
          });
        }

        // Tambahkan segmen 'booked'
        segments.add({
          'type': 'booked',
          'start': bookingStartDateTime,
          'end': bookingEndDateTime,
          'booking': booking,
          'isPast': bookingStartDateTime.isBefore(currentDateTime),
        });

        // Pindahkan kursor ke akhir booking ini
        currentCursor = bookingEndDateTime;
      }

      // Tambahkan segmen 'available' jika ada sisa waktu setelah booking terakhir hingga tutup
      if (currentCursor.isBefore(closingDateTime)) {
        segments.add({
          'type': 'available',
          'start': currentCursor,
          'end': closingDateTime,
          'isPast': currentCursor.isBefore(currentDateTime),
        });
      }

      // Filter segmen yang lewat sepenuhnya
      segments =
          segments
              .where(
                (s) =>
                    (s['end'] as DateTime).isAfter(currentDateTime) ||
                    (s['start'] as DateTime).isBefore(currentDateTime),
              )
              .toList();

      fieldSchedules[field] = segments;
    }
    return fieldSchedules;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(title: const Text('Manajemen Jadwal')),
      body: Consumer2<BookingProvider, FieldProvider>(
        builder: (context, bookingProvider, fieldProvider, child) {
          if (bookingProvider.isLoading || fieldProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (bookingProvider.errorMessage != null) {
            return Center(child: Text(bookingProvider.errorMessage!));
          }
          if (fieldProvider.errorMessage != null) {
            return Center(child: Text(fieldProvider.errorMessage!));
          }

          final Map<Field, List<Map<String, dynamic>>> fieldSchedules =
              _getScheduleSegments(
                bookingProvider.bookings,
                fieldProvider.fields,
              );

          // Urutkan lapangan berdasarkan nama untuk tampilan yang konsisten
          final sortedFields =
              fieldProvider.fields.toList()
                ..sort((a, b) => a.name.compareTo(b.name));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppStyles.defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tanggal Dipilih: ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)}', // Menambah 'yyyy'
                      style: AppStyles.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: const Text('Ubah Tanggal'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child:
                    sortedFields.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sports_score,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Belum ada lapangan yang terdaftar.',
                                style: AppStyles.bodyTextStyle.copyWith(
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: sortedFields.length,
                          itemBuilder: (context, fieldIndex) {
                            final field = sortedFields[fieldIndex];
                            final segments = fieldSchedules[field] ?? [];

                            if (segments.isEmpty) {
                              // Jika tidak ada segmen (misal: lapangan tidak memiliki jam buka), tampilkan pesan
                              return Padding(
                                padding: const EdgeInsets.all(
                                  AppStyles.defaultPadding,
                                ),
                                child: Text(
                                  'Tidak ada jadwal tersedia untuk ${field.name} pada tanggal ini.',
                                  style: AppStyles.bodyTextStyle.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppStyles.defaultPadding,
                                vertical: 8,
                              ),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppStyles.defaultBorderRadius,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  AppStyles.defaultPadding,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${field.name} (${field.type})',
                                      style: AppStyles.subHeadingStyle.copyWith(
                                        fontSize: 18,
                                        color: AppStyles.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Column(
                                      children:
                                          segments.map((segment) {
                                            Color segmentColor;
                                            String segmentText;
                                            VoidCallback? onTap;

                                            final DateTime segStart =
                                                segment['start'];
                                            final DateTime segEnd =
                                                segment['end'];
                                            final bool isPast =
                                                segment['isPast'];
                                            final Booking? booking =
                                                segment['booking']; // Hanya ada jika type=='booked'

                                            if (isPast) {
                                              segmentColor = Colors.grey[200]!;
                                              segmentText = 'Lewat Waktu';
                                            } else if (segment['type'] ==
                                                'booked') {
                                              segmentColor = AppStyles
                                                  .errorColor
                                                  .withOpacity(0.1);
                                              segmentText =
                                                  'Booked oleh ${booking?.user?.username ?? 'Anonim'}';
                                              onTap = () {
                                                if (booking != null) {
                                                  _showBookingDetailsDialog(
                                                    context,
                                                    booking,
                                                    bookingProvider,
                                                  );
                                                }
                                              };
                                            } else {
                                              // type == 'available'
                                              segmentColor = AppStyles
                                                  .successColor
                                                  .withOpacity(0.1);
                                              segmentText = 'Tersedia';
                                            }

                                            return InkWell(
                                              onTap: onTap,
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: segmentColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        AppStyles
                                                                .defaultBorderRadius /
                                                            2,
                                                      ),
                                                  border: Border.all(
                                                    color:
                                                        segment['type'] ==
                                                                'booked'
                                                            ? AppStyles
                                                                .errorColor
                                                            : AppStyles
                                                                .successColor,
                                                    width: 0.5,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${DateFormat('HH:mm').format(segStart)} - ${DateFormat('HH:mm').format(segEnd)}',
                                                      style: AppStyles.bodyTextStyle.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            isPast
                                                                ? Colors
                                                                    .grey[700]
                                                                : (segment['type'] ==
                                                                        'booked'
                                                                    ? AppStyles
                                                                        .errorColor
                                                                    : AppStyles
                                                                        .successColor),
                                                      ),
                                                    ),
                                                    Text(
                                                      segmentText,
                                                      style: AppStyles.smallTextStyle.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            isPast
                                                                ? Colors
                                                                    .grey[600]
                                                                : (segment['type'] ==
                                                                        'booked'
                                                                    ? AppStyles
                                                                        .errorColor
                                                                    : AppStyles
                                                                        .successColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
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
                      .replaceAll('paidDP', 'DP Dibayar ')
                      .replaceAll('paidFull', 'Lunas ')
                      .replaceAll('pendingPayment', 'Menunggu Pembayaran'),
                ),
                const SizedBox(height: 16),
                if (booking.status != BookingStatus.cancelled &&
                    booking.status != BookingStatus.completed)
                  Column(
                    children: [
                      ElevatedButton(
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
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child:
                            bookingProvider.isLoading &&
                                    bookingProvider.errorMessage == null
                                ? const SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 1.5,
                                  ),
                                )
                                : const Text(
                                  'Batalkan Booking',
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
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
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child:
                            bookingProvider.isLoading &&
                                    bookingProvider.errorMessage == null
                                ? const SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 1.5,
                                  ),
                                )
                                : const Text(
                                  'Update Pembayaran',
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
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
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child:
                            bookingProvider.isLoading &&
                                    bookingProvider.errorMessage == null
                                ? const SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 1.5,
                                  ),
                                )
                                : const Text(
                                  'Tandai Selesai',
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ],
                  ),
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
                bookingProvider.fetchBookings();
              },
            ),
          ],
        );
      },
    );
  }

  // Metode pembantu untuk baris detail
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
            'Anda yakin ingin membatalkan booking lapangan "${booking.field?.name}" oleh "${booking.user?.username}" pada ${DateFormat('dd MMM HH:mm', 'id_ID').format(booking.bookingDate)}?',
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
                bookingProvider.fetchBookings(); // Refresh data setelah aksi
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
            'Anda yakin ingin menandai booking lapangan "${booking.field?.name}" oleh "${booking.user?.username}" selesai?',
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
                bookingProvider.fetchBookings();
              },
            ),
          ],
        );
      },
    );
  }
}

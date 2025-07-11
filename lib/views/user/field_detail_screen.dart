// lib/views/user/field_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:futsal_booking_app/models/field.dart';
import 'package:futsal_booking_app/models/booking.dart'; // Tetap butuh untuk validasi overlap
import 'package:futsal_booking_app/providers/booking_provider.dart'; // Tetap butuh untuk validasi overlap
import 'package:futsal_booking_app/views/user/booking_confirmation_screen.dart';
import 'package:futsal_booking_app/utils/app_styles.dart';
import 'package:intl/intl.dart';

class FieldDetailScreen extends StatefulWidget {
  final Field field;

  const FieldDetailScreen({super.key, required this.field});

  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  int _selectedHours = 1;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime; // Jam mulai bebas yang dipilih user

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Inisialisasi tanggal hari ini
    // Tidak perlu memanggil fetchBookings di sini, karena akan dipanggil di _processPaymentAndBooking
    // di BookingConfirmationScreen untuk validasi real-time.
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 90),
      ), // Batas 3 bulan ke depan
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Reset waktu jika tanggal berubah, agar user memilih ulang waktu
        _selectedTime = null;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: true), // Force 24-hour format
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  double get totalBookingPrice => widget.field.pricePerHour * _selectedHours;
  double get dpAmount => totalBookingPrice * 0.3; // DP 30%

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(title: Text(widget.field.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.field.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppStyles.defaultBorderRadius,
                ),
                child: Image.asset(
                  // Menggunakan Image.asset karena path lokal
                  widget.field.imageUrl!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 250,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                ),
              ),
            const SizedBox(height: 24),
            Text(widget.field.name, style: AppStyles.headingStyle),
            const SizedBox(height: 8),
            Text(
              widget.field.type,
              style: AppStyles.subHeadingStyle.copyWith(
                color: AppStyles.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.field.description,
              style: AppStyles.bodyTextStyle.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Harga per jam:',
                  style: AppStyles.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rp ${widget.field.pricePerHour.toInt()}/jam',
                  style: AppStyles.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppStyles.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBookingOption(
              title: 'Pilih Tanggal',
              value:
                  _selectedDate == null
                      ? 'Pilih tanggal booking'
                      : DateFormat(
                        'dd MMMM yyyy',
                        'id_ID', // Tambahkan locale
                      ).format(_selectedDate!),
              icon: Icons.calendar_today,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 12),
            _buildBookingOption(
              title: 'Pilih Waktu Mulai',
              value:
                  _selectedTime == null
                      ? 'Pilih jam mulai booking'
                      : _selectedTime!.format(context),
              icon: Icons.access_time,
              onTap: () {
                if (_selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mohon pilih tanggal terlebih dahulu.'),
                    ),
                  );
                  return;
                }
                _selectTime(context);
              },
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppStyles.defaultBorderRadius,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyles.defaultPadding,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.hourglass_bottom,
                      color: AppStyles.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Durasi Sewa:',
                      style: AppStyles.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<int>(
                      value: _selectedHours,
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedHours = newValue;
                          });
                        }
                      },
                      items:
                          <int>[1, 2, 3, 4].map<DropdownMenuItem<int>>((
                            int value,
                          ) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                '$value jam',
                                style: AppStyles.bodyTextStyle,
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(AppStyles.defaultPadding),
              decoration: AppStyles.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rincian Pembayaran:', style: AppStyles.subHeadingStyle),
                  const SizedBox(height: 10),
                  _buildPaymentRow(
                    'Harga Total Booking:',
                    'Rp ${totalBookingPrice.toInt()}',
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentRow(
                    'Uang Muka (DP 30%):',
                    'Rp ${dpAmount.toInt()}',
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentRow(
                    'Sisa Pembayaran:',
                    'Rp ${(totalBookingPrice - dpAmount).toInt()}',
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedDate == null || _selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mohon pilih tanggal dan waktu booking.'),
                      ),
                    );
                    return;
                  }
                  // Navigasi ke halaman konfirmasi booking
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => BookingConfirmationScreen(
                            field: widget.field,
                            selectedDate: _selectedDate!,
                            selectedTime: _selectedTime!,
                            durationHours: _selectedHours,
                            totalPrice: totalBookingPrice,
                            dpAmount: dpAmount,
                          ),
                    ),
                  );
                },
                child: Text(
                  'Booking Sekarang',
                  style: AppStyles.bodyTextStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingOption({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.defaultPadding,
            vertical: 12,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppStyles.primaryColor),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppStyles.smallTextStyle.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.bodyTextStyle.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppStyles.textColor : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: AppStyles.bodyTextStyle.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppStyles.primaryColor : AppStyles.textColor,
          ),
        ),
      ],
    );
  }
}

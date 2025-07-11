// lib/views/user/user_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:futsal_booking_app/providers/auth_provider.dart';
import 'package:futsal_booking_app/providers/field_provider.dart';
import 'package:futsal_booking_app/providers/booking_provider.dart';
import 'package:futsal_booking_app/models/field.dart';
import 'package:futsal_booking_app/models/booking.dart';
import 'package:futsal_booking_app/views/auth/login_screen.dart';
import 'package:futsal_booking_app/views/user/field_list_screen.dart';
import 'package:futsal_booking_app/views/user/booking_history_screen.dart';
import 'package:futsal_booking_app/views/user/profile_screen.dart';
import 'package:futsal_booking_app/views/user/field_detail_screen.dart';
import 'package:futsal_booking_app/utils/app_styles.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _currentFieldPageIndex = 0;
  int _selectedIndex = 0; // Mengelola indeks BottomNavigationBar

  final List<String> _amenities = [
    'Free Water',
    'Artificial Grass',
    'Free Parking',
    'Kid Provided',
    'Changing Room',
  ];

  late PageController _fieldPageController;

  @override
  void initState() {
    super.initState();
    _fieldPageController = PageController(
      viewportFraction: 0.85, // Menyesuaikan lebar kartu di PageView
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Memuat data fields saat init
      Provider.of<FieldProvider>(context, listen: false).fetchFields();

      // Memuat booking terbaru untuk user yang sedang login
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
  void dispose() {
    _fieldPageController.dispose();
    super.dispose();
  }

  // Fungsi untuk menangani navigasi BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Menggunakan pushReplacementNamed jika Anda ingin menghapus tumpukan rute sebelumnya
    // atau pushNamed jika ingin tetap di tumpukan (dengan tombol back aktif)
    // Untuk navigasi BottomNavBar, biasanya lebih umum menggunakan pushReplacement atau popUntil
    // agar tumpukan rute tidak terlalu dalam.
    // Namun, sesuai struktur Anda yang menggunakan push untuk setiap halaman, kita akan tetap pakai itu.
    // Pastikan rute yang ada di AppRouter sesuai jika Anda menggunakannya.
    switch (index) {
      case 0:
        // Beranda - Sudah di sini, tidak perlu navigasi
        break;
      case 1:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const FieldListScreen()));
        break;
      case 2:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const BookingHistoryScreen()));
        break;
      case 3:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  /// Helper function to combine bookingDate and startTime string into a DateTime object.
  /// Handles cases where startTime might be 'HH:mm' or 'HH'
  DateTime _getBookingDateTime(DateTime date, String timeString) {
    // Default to current year, month, day if not provided by date
    final int year = date.year;
    final int month = date.month;
    final int day = date.day;

    int hour = 0;
    int minute = 0;
    try {
      final List<String> parts = timeString.split(':');
      if (parts.length == 2) {
        hour = int.parse(parts[0]);
        minute = int.parse(parts[1]);
      } else {
        // Fallback to just hour if no minutes (e.g., "9" for 09:00)
        hour = int.parse(timeString);
      }
    } catch (e) {
      // Log error or handle gracefully
      print('Error parsing time string: $timeString, $e');
    }

    return DateTime(year, month, day, hour, minute);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final fieldProvider = Provider.of<FieldProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final user = authProvider.currentUser;

    // Redirect ke LoginScreen jika user belum login
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Mengambil booking terbaru untuk ditampilkan (sudah difilter di provider untuk user saat ini)
    final latestBookingsForUser =
        bookingProvider
            .bookings; // bookings di provider sudah difilter untuk user ini
    latestBookingsForUser.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    Booking? recentBooking =
        latestBookingsForUser.isNotEmpty ? latestBookingsForUser.first : null;

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      // Menggunakan AppBar untuk judul dan tombol menu
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.only(right: AppStyles.paddingDefault),
              child: Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  ImageProvider? profileImage;
                  if (auth.currentUser?.profileImageUrl != null) {
                    if (auth.currentUser!.profileImageUrl!.startsWith('http')) {
                      profileImage = NetworkImage(
                        auth.currentUser!.profileImageUrl!,
                      );
                    } else if (File(
                      auth.currentUser!.profileImageUrl!,
                    ).existsSync()) {
                      // Pastikan file ada
                      profileImage = FileImage(
                        File(auth.currentUser!.profileImageUrl!),
                      );
                    }
                  }
                  return CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    backgroundImage: profileImage,
                    child:
                        profileImage == null
                            ? const Icon(
                              Icons.person,
                              color: AppStyles.primaryColor,
                              size: 25,
                            )
                            : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar:
          true, // Membuat body bisa berada di belakang AppBar
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(), // Scroll halus
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Banner Section (lebih ramping dan modern)
                  Stack(
                    children: [
                      Image.asset(
                        'assets/images/futsal_banner.png',
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4), // Lebih gelap
                              Colors.black.withOpacity(0.8), // Lebih gelap
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        // Menggunakan Positioned untuk kontrol posisi yang lebih baik
                        bottom: AppStyles.paddingLarge,
                        left: AppStyles.paddingDefault,
                        right: AppStyles.paddingDefault,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arena',
                              style: AppStyles.headline1.copyWith(
                                color: const Color.fromARGB(255, 23, 158, 255),
                                fontSize: 36, // Ukuran lebih besar
                                shadows: [
                                  // Tambah shadow untuk efek pop-out
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 3.0,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Futsal Stadion',
                              style: AppStyles.headline1.copyWith(
                                color: Colors.white,
                                fontSize: 32, // Ukuran lebih besar
                                shadows: [
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 3.0,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Pesan lapangan favoritmu sekarang!', // Pesan yang lebih menarik
                              style: AppStyles.bodyText1.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: AppStyles.paddingLarge,
                  ), // Jarak yang lebih konsisten
                  // Amenities Section (dengan tampilan card/ikon)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppStyles.paddingDefault,
                    ),
                    child: Text(
                      'Fasilitas Unggulan', // Ganti judul
                      style: AppStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingDefault),
                  SizedBox(
                    height: 90, // Sesuaikan tinggi agar ikon dan teks muat
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppStyles.paddingDefault,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: _amenities.length,
                      separatorBuilder:
                          (context, index) =>
                              const SizedBox(width: 12), // Jarak antar chip
                      itemBuilder: (context, index) {
                        return _buildAmenityChip(_amenities[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingLarge),

                  // Informasi Booking Terbaru Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppStyles.paddingDefault,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaksi Terbaru',
                          style: AppStyles.subtitle1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Menampilkan indikator loading atau error
                        if (bookingProvider.isLoading && recentBooking == null)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        if (bookingProvider.errorMessage != null &&
                            !bookingProvider.isLoading)
                          Tooltip(
                            message: bookingProvider.errorMessage,
                            child: const Icon(
                              Icons.error,
                              color: AppStyles.errorColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingDefault),
                  if (recentBooking == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppStyles.paddingDefault,
                      ),
                      child: Center(
                        child: Text(
                          bookingProvider.isLoading
                              ? 'Memuat transaksi...'
                              : bookingProvider.errorMessage ??
                                  'Belum ada transaksi terbaru.',
                          style: AppStyles.bodyText2.copyWith(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    _buildLatestBookingCard(context, recentBooking),
                  const SizedBox(height: AppStyles.paddingLarge),

                  // Field Selection (Carousel) Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppStyles.paddingDefault,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pilih Lapangan',
                          style: AppStyles.subtitle1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Menampilkan indikator loading atau error
                        if (fieldProvider.isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        if (fieldProvider.errorMessage != null &&
                            !fieldProvider.isLoading)
                          Tooltip(
                            message: fieldProvider.errorMessage,
                            child: const Icon(
                              Icons.error,
                              color: AppStyles.errorColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingDefault),
                  if (fieldProvider.fields.isEmpty && !fieldProvider.isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppStyles.paddingDefault,
                      ),
                      child: Center(
                        child: Text(
                          fieldProvider.errorMessage ??
                              'Tidak ada lapangan tersedia saat ini.',
                          style: AppStyles.bodyText2.copyWith(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        SizedBox(
                          height:
                              260, // Sesuaikan tinggi agar tidak perlu scroll
                          child: PageView.builder(
                            controller: _fieldPageController,
                            itemCount: fieldProvider.fields.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentFieldPageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final Field field = fieldProvider.fields[index];
                              final bool isActive =
                                  _currentFieldPageIndex == index;
                              return _buildFieldCard(context, field, isActive);
                            },
                          ),
                        ),
                        const SizedBox(height: AppStyles.paddingSmall),
                        // Indikator halaman untuk PageView
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            fieldProvider.fields.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              height: 8.0,
                              width:
                                  _currentFieldPageIndex == index ? 24.0 : 8.0,
                              decoration: BoxDecoration(
                                color:
                                    _currentFieldPageIndex == index
                                        ? AppStyles.primaryColor
                                        : Colors.grey.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: AppStyles.paddingLarge),
                ],
              ),
            ),
          ),
          // Bottom Navigation Bar
          _buildBottomNavigationBar(context),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                ImageProvider? profileImage;
                if (auth.currentUser?.profileImageUrl != null) {
                  if (auth.currentUser!.profileImageUrl!.startsWith('http')) {
                    profileImage = NetworkImage(
                      auth.currentUser!.profileImageUrl!,
                    );
                  } else if (File(
                    auth.currentUser!.profileImageUrl!,
                  ).existsSync()) {
                    // Pastikan file ada
                    profileImage = FileImage(
                      File(auth.currentUser!.profileImageUrl!),
                    );
                  }
                }
                return UserAccountsDrawerHeader(
                  accountName: Text(
                    auth.currentUser?.username ?? 'Pengguna',
                    style: AppStyles.subtitle1.copyWith(color: Colors.white),
                  ),
                  accountEmail: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.currentUser?.email ?? '',
                        style: AppStyles.bodyText2.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Saldo: Rp ${NumberFormat('#,##0', 'id_ID').format(auth.userBalance.toInt())}',
                        style: AppStyles.bodyText1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  currentAccountPicture: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: profileImage,
                      child:
                          profileImage == null
                              ? const Icon(
                                Icons.person,
                                size: 50,
                                color: AppStyles.primaryColor,
                              )
                              : null,
                    ),
                  ),
                  decoration: const BoxDecoration(
                    color: AppStyles.primaryColor,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.sports_soccer,
                color: AppStyles.primaryColor,
              ),
              title: Text('Daftar Lapangan', style: AppStyles.bodyText1),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FieldListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: AppStyles.primaryColor),
              title: Text('Riwayat Booking', style: AppStyles.bodyText1),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BookingHistoryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: AppStyles.primaryColor),
              title: Text('Profil Saya', style: AppStyles.bodyText1),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppStyles.errorColor),
              title: Text('Logout', style: AppStyles.bodyText1),
              onTap: () async {
                await authProvider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget baru untuk Amenity Chip
  Widget _buildAmenityChip(String amenity) {
    IconData icon;
    switch (amenity) {
      case 'Free Water':
        icon = Icons.local_drink;
        break;
      case 'Artificial Grass':
        icon = Icons.grass;
        break;
      case 'Free Parking':
        icon = Icons.local_parking;
        break;
      case 'Kid Provided':
        icon = Icons.child_care;
        break;
      case 'Changing Room':
        icon = Icons.wc;
        break;
      default:
        icon = Icons.info_outline;
    }

    return Container(
      width: 100, // Lebar fixed untuk setiap amenity
      padding: const EdgeInsets.symmetric(
        vertical: AppStyles.paddingSmall,
        horizontal: 4.0,
      ),
      decoration: BoxDecoration(
        color: AppStyles.cardColor,
        borderRadius: BorderRadius.circular(AppStyles.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppStyles.primaryColor, size: 28),
          const SizedBox(height: 4),
          Text(
            amenity,
            textAlign: TextAlign.center,
            style: AppStyles.caption.copyWith(
              color: AppStyles.textColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan kartu booking terbaru
  Widget _buildLatestBookingCard(BuildContext context, Booking booking) {
    Color statusColor;
    String statusText;
    switch (booking.status) {
      case BookingStatus.pendingPayment:
        statusColor = AppStyles.warningColor;
        statusText = 'Menunggu Pembayaran';
        break;
      case BookingStatus.paidDP:
        statusColor = AppStyles.infoColor;
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
        statusColor = AppStyles.secondaryTextColor;
        statusText = 'Selesai';
        break;
      default:
        statusColor = Colors.black;
        statusText = 'Tidak Diketahui';
        break;
    }

    // Combine bookingDate and startTime string into a full DateTime for display
    final DateTime startTimeAsDateTime = _getBookingDateTime(
      booking.bookingDate,
      booking.startTime,
    );
    final DateTime endTimeAsDateTime = startTimeAsDateTime.add(
      Duration(hours: booking.durationHours),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppStyles.paddingDefault),
      elevation: 6, // Elevasi lebih tinggi
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppStyles.radiusDefault + 4,
        ), // Lebih bulat
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BookingHistoryScreen()),
          );
        },
        borderRadius: BorderRadius.circular(AppStyles.radiusDefault + 4),
        child: Padding(
          padding: const EdgeInsets.all(
            AppStyles.paddingLarge,
          ), // Padding lebih besar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    // Agar teks nama lapangan tidak overflow
                    child: Text(
                      booking.field?.name ?? 'Lapangan Tidak Dikenal',
                      style: AppStyles.subtitle1.copyWith(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ), // Padding chip lebih besar
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(
                        0.15,
                      ), // Opasitas sedikit lebih tinggi
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusText,
                      style: AppStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1), // Garis pemisah modern
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: AppStyles.secondaryTextColor,
                  ),
                  const SizedBox(width: AppStyles.paddingSmall),
                  Text(
                    // Correctly formatted date using the bookingDate property
                    'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(booking.bookingDate)}',
                    style: AppStyles.bodyText2,
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.paddingSmall),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: AppStyles.secondaryTextColor,
                  ),
                  const SizedBox(width: AppStyles.paddingSmall),
                  Text(
                    // Correctly formatted time using the derived DateTime objects
                    'Waktu: ${DateFormat('HH:mm').format(startTimeAsDateTime)} - ${DateFormat('HH:mm').format(endTimeAsDateTime)}',
                    style: AppStyles.bodyText2,
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.paddingDefault),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Total Pembayaran: Rp ${NumberFormat('#,##0', 'id_ID').format(booking.totalPrice.toInt())}',
                  style: AppStyles.subtitle1.copyWith(
                    color: AppStyles.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget baru untuk Field Card
  Widget _buildFieldCard(BuildContext context, Field field, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal:
            isActive ? AppStyles.paddingSmall : AppStyles.paddingDefault,
        vertical: isActive ? 0.0 : 1,
      ),
      decoration:
          isActive
              ? AppStyles.highlightCardDecoration
              : AppStyles.cardDecoration,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => FieldDetailScreen(field: field)),
          );
        },
        borderRadius: BorderRadius.circular(AppStyles.radiusDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppStyles.radiusDefault),
              ),
              child: Image.asset(
                field.imageUrl ??
                    'assets/images/futsal_field_standard.png', // Fallback jika imageUrl null
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppStyles.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.name,
                    style: AppStyles.subtitle1.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    field.type,
                    style: AppStyles.bodyText2.copyWith(
                      color: AppStyles.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingSmall),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'Rp ${NumberFormat('#,##0', 'id_ID').format(field.pricePerHour)}/jam',
                      style: AppStyles.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppStyles.primaryColor,
                      ),
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

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyles.cardColor, // Menggunakan warna card yang konsisten
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppStyles.radiusLarge),
        ), // Sudut membulat di atas
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Shadow lebih lembut
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        // Memastikan inkwell effect tidak keluar dari border radius
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppStyles.radiusLarge),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppStyles.primaryColor,
          unselectedItemColor:
              AppStyles.secondaryTextColor, // Warna abu-abu yang lebih lembut
          backgroundColor: Colors.transparent,
          elevation: 0, // Hilangkan shadow bawaan BottomNavigationBar
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true, // Tampilkan label saat selected
          showUnselectedLabels: true, // Tampilkan label saat unselected
          selectedLabelStyle: AppStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: AppStyles.caption,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), // Ikon rounded lebih modern
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded), // Ikon terkait booking
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded), // Ikon rounded
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), // Ikon rounded
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

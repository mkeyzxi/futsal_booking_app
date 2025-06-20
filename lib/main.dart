// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:futsal_booking_app/providers/auth_provider.dart';
import 'package:futsal_booking_app/providers/field_provider.dart';
import 'package:futsal_booking_app/providers/booking_provider.dart';
// import 'package:futsal_booking_app/providers/user_balance_provider.dart'; // <--- HAPUS INI

import 'package:futsal_booking_app/views/auth/login_screen.dart';
import 'package:futsal_booking_app/views/user/user_dashboard_screen.dart';
import 'package:futsal_booking_app/views/admin/admin_dashboard_screen.dart';

import 'package:futsal_booking_app/models/user.dart';
import 'package:futsal_booking_app/utils/app_styles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FieldProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        // Hapus ChangeNotifierProvider untuk UserBalanceProvider
        // ChangeNotifierProvider(create: (_) => UserBalanceProvider()),
      ],
      child: MaterialApp(
        title: 'Sistem Booking Lapangan Futsal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppStyles.primaryColor,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          fontFamily: 'Montserrat',
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: AppStyles.textColor,
            ),
            titleMedium: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppStyles.textColor,
            ),
            bodyLarge: TextStyle(fontSize: 16.0, color: AppStyles.textColor),
            bodyMedium: TextStyle(fontSize: 14.0, color: AppStyles.textColor),
          ),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', ''), Locale('id', '')],
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (authProvider.currentUser != null) {
              if (authProvider.currentUser!.role == UserRole.admin) {
                return const AdminDashboardScreen();
              } else {
                return const UserDashboardScreen();
              }
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}

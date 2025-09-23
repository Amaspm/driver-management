import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'services/driver_shift_service.dart';
import 'config/theme.dart';
import 'screens/login_screen.dart';

import 'screens/main_screen.dart';
import 'screens/training_online_screen.dart';
// import 'screens/registration_complete_screen.dart'; // Not used in new flow
import 'screens/account_pending_screen.dart';
import 'screens/account_activated_screen.dart';
import 'screens/account_rejected_screen.dart';
import 'screens/vehicle_matching_screen.dart';
import 'screens/edit_ktp_upload_screen.dart';
import 'screens/edit_sim_upload_screen.dart';
import 'screens/edit_certificate_upload_screen.dart';
import 'screens/bpjs_upload_screen.dart';
import 'screens/photo_upload_screen.dart';
import 'screens/rejection_details_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/trips_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService()),
        ChangeNotifierProvider<DriverShiftService>(create: (_) => DriverShiftService()),
        ProxyProvider<AuthService, ApiService>(
          update: (_, authService, __) => ApiService(authService),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Driver Management',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            home: AuthWrapper(),
            routes: {
          '/login': (context) => LoginScreen(),

          '/main': (context) => MainScreen(),
          '/training_online': (context) => TrainingOnlineScreen(),
          // '/registration_complete': (context) => RegistrationCompleteScreen(), // Not used
          '/account_pending': (context) => AccountPendingScreen(),
          '/account_activated': (context) => AccountActivatedScreen(),
          '/account_rejected': (context) => AccountRejectedScreen(),
          '/vehicle_matching': (context) => VehicleMatchingScreen(),
          '/ktp_upload': (context) => EditKtpUploadScreen(),
          '/edit_ktp_upload': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return EditKtpUploadScreen(
              isRejectionFlow: args?['isRejectionFlow'] ?? false,
              nextDocuments: List<String>.from(args?['nextDocuments'] ?? []),
            );
          },
          '/edit_sim_upload': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return EditSimUploadScreen(
              isRejectionFlow: args?['isRejectionFlow'] ?? false,
              nextDocuments: List<String>.from(args?['nextDocuments'] ?? []),
            );
          },
          '/edit_certificate_upload': (context) => EditCertificateUploadScreen(),
          '/bpjs_upload': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return BpjsUploadScreen(
              isRejectionFlow: args?['isRejectionFlow'] ?? false,
            );
          },
          '/photo_upload': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return PhotoUploadScreen(
              isRejectionFlow: args?['isRejectionFlow'] ?? false,
            );
          },
          '/rejection_details': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return RejectionDetailsScreen(
              rejectionReason: args?['rejectionReason'] ?? 'Tidak ada alasan',
              rejectedDocuments: List<String>.from(args?['rejectedDocuments'] ?? []),
            );
          },
          '/profile_edit': (context) => ProfileEditScreen(),
          '/trips': (context) => TripsScreen(),
        },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AuthService>(context, listen: false).loadSavedUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Driver Management',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          );
        }
        
        final authService = Provider.of<AuthService>(context);
        return authService.currentUser != null 
            ? MainScreen() 
            : LoginScreen();
      },
    );
  }
}
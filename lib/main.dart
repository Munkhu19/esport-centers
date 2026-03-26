import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/booking_store.dart';
import 'data/center_store.dart';
import 'data/firebase_state.dart';
import 'data/role_store.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_controller.dart';
import 'screens/admin_root_shell.dart';
import 'screens/login_screen.dart';
import 'screens/owner_pending_screen.dart';
import 'screens/owner_root_shell.dart';
import 'screens/root_shell.dart';
import 'widgets/app_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseAvailable = true;
  } catch (_) {
    firebaseAvailable = false;
  }
  await BookingStore.initialize();
  await CenterStore.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, locale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.transparent,
            canvasColor: Colors.transparent,
            cardColor: const Color(0xCC101826),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF111827),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF0B1220).withValues(alpha: 0.82),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15B8A6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xCC101826),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xCC172033),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          builder: (context, child) {
            return AppBackground(child: child ?? const SizedBox.shrink());
          },
          home: const AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!firebaseAvailable) {
      return const RootShell();
    }

    return ValueListenableBuilder<bool>(
      valueListenable: authFlowInProgress,
      builder: (context, isAuthFlowInProgress, _) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (isAuthFlowInProgress) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.data != null) {
              final user = snapshot.data!;
              return FutureBuilder<String>(
                future: RoleStore.roleForEmail(user.email),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (roleSnapshot.data == RoleStore.ownerPendingRole) {
                    return const OwnerPendingScreen();
                  }
                  if (roleSnapshot.data == RoleStore.adminRole) {
                    return const AdminRootShell();
                  }
                  if (roleSnapshot.data == RoleStore.ownerRole) {
                    return const OwnerRootShell();
                  }
                  return const RootShell();
                },
              );
            }
            return const LoginScreen();
          },
        );
      },
    );
  }
}

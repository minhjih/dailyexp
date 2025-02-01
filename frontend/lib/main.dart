import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/papers/paper_list_screen.dart';
import 'screens/main/main_screen.dart'; // 추가
import 'theme/colors.dart';
import 'providers/user_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // dotenv 초기화를 먼저 수행
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'DailyExp',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.light(
            primary: primaryColor,
            secondary: secondaryColor,
            surface: surfaceColor,
            background: backgroundColor,
            error: errorColor,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: primaryTextColor,
            onBackground: primaryTextColor,
            onError: Colors.white,
          ),
          scaffoldBackgroundColor: backgroundColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: surfaceColor,
            foregroundColor: primaryTextColor,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            color: surfaceColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: inactiveColor.withOpacity(0.2),
              ),
            ),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              color: primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: TextStyle(
              color: primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: TextStyle(
              color: primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
            titleMedium: TextStyle(
              color: primaryTextColor,
              fontWeight: FontWeight.w500,
            ),
            bodyLarge: TextStyle(color: primaryTextColor),
            bodyMedium: TextStyle(color: secondaryTextColor),
          ),
        ),
        routes: {
          '/signup': (context) => const SignupScreen(),
          '/login': (context) => const LoginScreen(),
          '/main': (context) => const MainScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const MainScreen(),
          );
        },
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isAuthenticated
                ? const MainScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}

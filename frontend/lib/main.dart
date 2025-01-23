import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart'; // 이 파일은 아직 만들어야 함
import 'screens/papers/paper_list_screen.dart';
import 'theme/colors.dart';

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
      ],
      child: MaterialApp(
        title: 'DailyExp',
        theme: ThemeData(
          primaryColor: primaryColor,
          useMaterial3: true,
          colorScheme: ColorScheme.light(
            primary: primaryColor,
            secondary: primaryLightColor,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: primaryLightColor,
          useMaterial3: true,
          colorScheme: ColorScheme.dark(
            primary: primaryLightColor,
            secondary: primaryColor,
          ),
        ),
        initialRoute: '/login', // 초기 화면을 로그인으로 설정
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(), // 임시 홈 스크린
          '/papers': (context) => const PaperListScreen(),
          // 다른 라우트들은 나중에 추가
        },
      ),
    );
  }
}

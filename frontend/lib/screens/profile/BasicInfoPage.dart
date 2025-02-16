import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BasicInfoPage extends StatefulWidget {
  @override
  _BasicInfoPageState createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _obscurePassword = true; // 비밀번호 숨김 상태 변수 추가

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  // 이메일 유효성 검사 함수
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '올바른 이메일 형식이 아닙니다';
    }
    return null;
  }

  // 비밀번호 유효성 검사 함수
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return '대문자를 포함해야 합니다';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return '숫자를 포함해야 합니다';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return '특수문자를 포함해야 합니다';
    }
    return null;
  }

  // 이름 유효성 검사 함수
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요';
    }
    if (value.length < 2) {
      return '이름은 2자 이상이어야 합니다';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('기본정보', style: GoogleFonts.poppins())),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // 배경색을 흰색으로 변경
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 기본 정보 입력 폼
                    Card(
                      elevation: 0, // 그림자 제거
                      color: const Color(0xFFE8F5E9), // 연한 녹색 배경
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _fullNameController,
                                decoration: InputDecoration(
                                  labelText: '이름',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateName,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: '이메일',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: '비밀번호',
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: _obscurePassword,
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: '비밀번호 확인',
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: _obscurePassword,
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return '비밀번호가 일치하지 않습니다';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 40),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // 폼이 유효하면
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('저장되었습니다')),
                                    );
                                  }
                                },
                                child: Text(
                                  '저장하기',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

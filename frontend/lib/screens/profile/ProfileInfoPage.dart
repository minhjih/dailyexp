import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileInfoPage extends StatefulWidget {
  @override
  _ProfileInfoPageState createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final _bioController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();

  @override
  void dispose() {
    _bioController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  // 유효성 검사 함수
  String? _validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return '자기소개를 입력해주세요';
    }
    return null;
  }

  String? _validateExternalLinks(String? value) {
    if (value == null || value.isEmpty) {
      return '링크를 입력해주세요';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('프로필정보', style: GoogleFonts.poppins())),
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
                    // 프로필 정보 입력 폼
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
                                controller: _bioController,
                                decoration: InputDecoration(
                                  labelText: '자기소개',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateBio,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _githubController,
                                decoration: InputDecoration(
                                  labelText: 'GitHub 링크',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateExternalLinks,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _linkedinController,
                                decoration: InputDecoration(
                                  labelText: 'LinkedIn 링크',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateExternalLinks,
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

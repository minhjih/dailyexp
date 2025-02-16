import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResearchInfoPage extends StatefulWidget {
  @override
  _ResearchInfoPageState createState() => _ResearchInfoPageState();
}

class _ResearchInfoPageState extends State<ResearchInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final _researchFieldController = TextEditingController();
  final _researchInterestController = TextEditingController();

  @override
  void dispose() {
    _researchFieldController.dispose();
    _researchInterestController.dispose();
    super.dispose();
  }

  // 유효성 검사 함수
  String? _validateResearchField(String? value) {
    if (value == null || value.isEmpty) {
      return '연구 분야를 입력해주세요';
    }
    return null;
  }

  String? _validateResearchInterest(String? value) {
    if (value == null || value.isEmpty) {
      return '연구 관심사를 입력해주세요';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('연구정보', style: GoogleFonts.poppins())),
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
                    // 연구 정보 입력 폼
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
                                controller: _researchFieldController,
                                decoration: InputDecoration(
                                  labelText: '연구 분야',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateResearchField,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _researchInterestController,
                                decoration: InputDecoration(
                                  labelText: '연구 관심사',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateResearchInterest,
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

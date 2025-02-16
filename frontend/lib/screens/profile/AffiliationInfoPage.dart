import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AffiliationInfoPage extends StatefulWidget {
  @override
  _AffiliationInfoPageState createState() => _AffiliationInfoPageState();
}

class _AffiliationInfoPageState extends State<AffiliationInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final _institutionController = TextEditingController();
  final _departmentController = TextEditingController();

  @override
  void dispose() {
    _institutionController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  // 유효성 검사 함수
  String? _validateInstitution(String? value) {
    if (value == null || value.isEmpty) {
      return '소속 기관을 입력해주세요';
    }
    return null;
  }

  String? _validateDepartment(String? value) {
    if (value == null || value.isEmpty) {
      return '소속 부서를 입력해주세요';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('소속정보', style: GoogleFonts.poppins())),
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
                    // 소속 정보 입력 폼
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
                                controller: _institutionController,
                                decoration: InputDecoration(
                                  labelText: '소속 기관',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateInstitution,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _departmentController,
                                decoration: InputDecoration(
                                  labelText: '소속 부서',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateDepartment,
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

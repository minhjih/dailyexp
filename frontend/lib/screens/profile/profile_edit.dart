import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위해 image_picker 패키지 사용
import 'dart:io'; // File 클래스 사용을 위해 필요

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  String? name = '';
  String? email = '';
  String? password = '';
  XFile? _image; // 선택된 이미지 파일

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 수정', style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage, // 이미지 변경을 위해 탭 핸들러 추가
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _image != null ? FileImage(File(_image!.path)) : null,
                  child: _image == null ? Icon(Icons.camera_alt, size: 60, color: Colors.grey.shade800) : null,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '이름',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요.';
                  }
                  return null;
                },
                onSaved: (value) => name = value,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return '유효한 이메일 주소를 입력해주세요.';
                  }
                  return null;
                },
                onSaved: (value) => email = value,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '새 비밀번호',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return '비밀번호는 최소 6자 이상이어야 합니다.';
                  }
                  return null;
                },
                onSaved: (value) => password = value,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _submit,
                child: Text('저장하기', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _submit() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      // 여기에 프로필 정보를 업데이트하는 로직을 추가합니다. 예: 서버 API 호출

      // 데이터 업데이트 후 다이얼로그 표시
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text('저장 완료'),
              content: Text('변경사항이 저장되었습니다.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    Navigator.of(context).pop(); // 프로필 수정 페이지 닫고 이전 화면으로 돌아가기
                  },
                  child: Text('확인'),
                ),
              ],
            ),
      );
    }
  }
}

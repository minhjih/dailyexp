import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // 기본 정보
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();

  // 소속 정보
  final _institutionController = TextEditingController();
  final _departmentController = TextEditingController();

  // 연구 정보
  final _researchFieldController = TextEditingController();
  final List<String> _selectedInterests = [];

  // 프로필 정보
  final _bioController = TextEditingController();
  final Map<String, TextEditingController> _externalLinksController = {
    'github': TextEditingController(),
    'linkedin': TextEditingController(),
  };
  final Map<String, String> _externalLinks = {};

  // 연구 관심사 목록 (예시)
  final List<String> _availableInterests = [
    'Machine Learning',
    'Deep Learning',
    'Natural Language Processing',
    'Computer Vision',
    'Robotics',
    'Data Science',
    'Artificial Intelligence',
    // ... 더 많은 관심사 추가
  ];

  bool _obscurePassword = true; // 비밀번호 숨김 상태 변수 추가

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _institutionController.dispose();
    _departmentController.dispose();
    _researchFieldController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        final signupData = {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'full_name': _fullNameController.text.trim(),
          'institution': _institutionController.text.trim(),
          'department': _departmentController.text.trim(),
          'research_field': _researchFieldController.text.trim(),
          'research_interests': _selectedInterests.toList(),
          'bio': _bioController.text.trim(),
          'external_links': _externalLinks.isEmpty ? {} : _externalLinks,
        };

        await Provider.of<AuthProvider>(context, listen: false)
            .signup(signupData);

        if (mounted) {
          // 회원가입 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('회원가입이 완료되었습니다. 로그인해주세요.'),
              backgroundColor: Colors.green,
            ),
          );

          // 로그인 페이지로 이동
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('회원가입 실패: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    } else {
      _signup();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  // 이메일 유효성 검사 함수
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    // 이메일 형식 검사
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
                    const SizedBox(height: 40),
                    // 회원가입 카드
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
                              _buildSignupStepper(),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 400,
                                child: PageView(
                                  controller: _pageController,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    _buildBasicInfoPage(),
                                    _buildAffiliationPage(),
                                    _buildResearchInfoPage(),
                                    _buildProfilePage(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 로그인 링크
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: "Sign in",
                              style: TextStyle(
                                color: Color(0xFF43A047),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

  Widget _buildSignupStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentPage > 0)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
                color: const Color(0xFF43A047),
              )
            else
              const SizedBox(width: 48), // 아이콘 버튼 크기만큼 공간 확보
            Text(
              _getStepTitle(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF43A047),
              ),
            ),
            const SizedBox(width: 48), // 균형을 위한 공간
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (int i = 0; i < 4; i++) ...[
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= _currentPage
                        ? const Color(0xFF43A047)
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (i < 3) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }

  String _getStepTitle() {
    switch (_currentPage) {
      case 0:
        return '기본 정보';
      case 1:
        return '소속 정보';
      case 2:
        return '연구 정보';
      case 3:
        return '프로필 정보';
      default:
        return '';
    }
  }

  Widget _buildNavigationButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF43A047),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 공통 InputDecoration 스타일 정의
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF43A047)),
      filled: true,
      fillColor: Colors.white,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF43A047), width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(color: Color(0xFF43A047)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    );
  }

  Widget _buildBasicInfoPage() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 400),
      child: SingleChildScrollView(
        // 스크롤 가능하도록 추가
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: _buildInputDecoration('이메일', Icons.email),
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _passwordController,
              decoration: _buildInputDecoration('비밀번호', Icons.lock).copyWith(
                helperText: '8자 이상, 대문자, 숫자, 특수문자 포함',
                helperMaxLines: 2,
                suffixIcon: IconButton(
                  // 눈 아이콘 버튼 추가
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[400],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: _validatePassword,
              obscureText: _obscurePassword, // 상태 변수 사용
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _fullNameController,
              decoration: _buildInputDecoration('이름', Icons.person),
              validator: _validateName,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 40),
            _buildNavigationButton(
              text: '다음',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _nextPage();
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAffiliationPage() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 400),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _institutionController,
                decoration: _buildInputDecoration('소속 기관', Icons.business),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _departmentController,
                decoration: _buildInputDecoration('학과/부서', Icons.school),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 40),
              _buildNavigationButton(
                text: '다음',
                onPressed: _nextPage,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResearchInfoPage() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 400),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _researchFieldController,
                decoration: _buildInputDecoration('연구 분야', Icons.science),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _availableInterests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: FilterChip(
                      label: Text(
                        interest,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedInterests.add(interest);
                          } else {
                            _selectedInterests.remove(interest);
                          }
                        });
                      },
                      selectedColor: const Color(0xFF43A047),
                      backgroundColor: Colors.white,
                      checkmarkColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              _buildNavigationButton(
                text: '다음',
                onPressed: _nextPage,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 400),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _bioController,
                decoration: _buildInputDecoration('자기소개', Icons.person_outline)
                    .copyWith(
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _externalLinksController['github'],
                decoration: _buildInputDecoration('GitHub 프로필', Icons.link),
                textInputAction: TextInputAction.next,
                onChanged: (value) => _externalLinks['github'] = value,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _externalLinksController['linkedin'],
                decoration: _buildInputDecoration('LinkedIn 프로필', Icons.link),
                textInputAction: TextInputAction.done,
                onChanged: (value) => _externalLinks['linkedin'] = value,
              ),
              const SizedBox(height: 40),
              _buildNavigationButton(
                text: '가입하기',
                onPressed: _signup,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

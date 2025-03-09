import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../api/auth_api.dart';
import '../../models/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateWorkspaceScreen extends StatefulWidget {
  const CreateWorkspaceScreen({super.key});

  @override
  _CreateWorkspaceScreenState createState() => _CreateWorkspaceScreenState();
}

class _CreateWorkspaceScreenState extends State<CreateWorkspaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _researchFieldController = TextEditingController();
  final _searchController = TextEditingController();

  bool _isPublic = true;
  String _myRole = 'maintainer'; // 기본값은 관리자(maintainer)
  List<String> _researchTopics = [];
  List<User> _searchResults = [];
  List<InvitedMember> _invitedMembers = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _researchFieldController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // AuthAPI를 사용하여 사용자 검색
      final users = await AuthAPI().searchUsers(query);

      setState(() {
        _searchResults = users;
        _isSearching = false;
      });
    } catch (e) {
      print('Error searching users: $e');

      // 오류 발생 시 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 검색 중 오류가 발생했습니다: $e')),
      );

      setState(() {
        _isSearching = false;
      });
    }
  }

  void _addMember(User user) {
    // 이미 초대된 멤버인지 확인
    if (_invitedMembers.any((member) => member.user.id == user.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.fullName}님은 이미 초대되었습니다.')),
      );
      return;
    }

    // 팔로잉 관계가 아니면 초대 불가
    if (!user.isFollowing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('팔로잉 중인 사용자만 초대할 수 있습니다.')),
      );
      return;
    }

    setState(() {
      _invitedMembers.add(
        InvitedMember(
          user: user,
          role: 'member', // 기본 역할은 member
        ),
      );
      _searchResults = [];
      _searchController.clear();
    });
  }

  void _removeMember(int? userId) {
    if (userId == null) return;

    setState(() {
      _invitedMembers.removeWhere((member) => member.user.id == userId);
    });
  }

  void _updateMemberRole(int? userId, String role) {
    if (userId == null) return;

    setState(() {
      final index =
          _invitedMembers.indexWhere((member) => member.user.id == userId);
      if (index != -1) {
        _invitedMembers[index] = InvitedMember(
          user: _invitedMembers[index].user,
          role: role,
        );
      }
    });
  }

  void _addResearchTopic(String topic) {
    if (topic.isNotEmpty && !_researchTopics.contains(topic)) {
      setState(() {
        _researchTopics.add(topic);
      });
    }
  }

  void _removeResearchTopic(String topic) {
    setState(() {
      _researchTopics.remove(topic);
    });
  }

  Future<void> _createWorkspace() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 최소 한 명의 maintainer가 있는지 확인
    if (_myRole != 'maintainer' &&
        !_invitedMembers.any((member) => member.role == 'maintainer')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 한 명의 관리자(maintainer)를 지정해야 합니다.')),
      );
      return;
    }

    // 워크스페이스 생성 데이터 준비
    final workspaceData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'research_field': _researchFieldController.text,
      'research_topics': _researchTopics,
      'is_public': _isPublic,
      'creator_role': _myRole, // 생성자 역할 추가
      'members': _invitedMembers
          .map((member) => {
                'user_id': member.user.id,
                'role': member.role,
              })
          .toList(),
    };

    try {
      // API 호출로 워크스페이스 생성
      final response = await AuthAPI().createWorkspace(workspaceData);

      // 성공 시 이전 화면으로 돌아가기
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('워크스페이스가 성공적으로 생성되었습니다.')),
      );
      Navigator.pop(context, true); // true는 새로고침 신호
    } catch (e) {
      print('Error creating workspace: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('워크스페이스 생성 중 오류가 발생했습니다: $e')),
      );
    }
  }

  Future<void> _followUser(int? userId) async {
    if (userId == null) return;

    try {
      // 사용자 팔로우 API 호출
      await AuthAPI().followUser(userId);

      // 팔로우 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자를 팔로우했습니다. 이제 초대할 수 있습니다.')),
      );

      // 검색 결과 새로고침
      if (_searchController.text.isNotEmpty) {
        _searchUsers(_searchController.text);
      }
    } catch (e) {
      print('Error following user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 팔로우 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '새 워크스페이스 생성',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _createWorkspace,
            child: Text(
              '생성',
              style: GoogleFonts.poppins(
                color: const Color(0xFF43A047),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 워크스페이스 기본 정보
            Text(
              '기본 정보',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '워크스페이스 이름',
                hintText: '연구 그룹의 이름을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '워크스페이스 이름을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: '설명',
                hintText: '연구 그룹에 대한 설명을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _researchFieldController,
              decoration: InputDecoration(
                labelText: '연구 분야',
                hintText: '주요 연구 분야를 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '연구 분야를 입력해주세요';
                }
                return null;
              },
            ),

            // 연구 주제 태그
            const SizedBox(height: 24),
            Text(
              '연구 주제',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '연구 주제를 입력하고 추가하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final text = _researchFieldController.text.trim();
                          if (text.isNotEmpty) {
                            _addResearchTopic(text);
                            _researchFieldController.clear();
                          }
                        },
                      ),
                    ),
                    onSubmitted: _addResearchTopic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _researchTopics
                  .map((topic) => Chip(
                        label: Text(topic),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeResearchTopic(topic),
                      ))
                  .toList(),
            ),

            // 공개 설정
            const SizedBox(height: 24),
            Text(
              '공개 설정',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('공개'),
                    subtitle: const Text('모든 사용자가 볼 수 있습니다'),
                    value: true,
                    groupValue: _isPublic,
                    onChanged: (value) {
                      setState(() {
                        _isPublic = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('비공개'),
                    subtitle: const Text('초대된 멤버만 볼 수 있습니다'),
                    value: false,
                    groupValue: _isPublic,
                    onChanged: (value) {
                      setState(() {
                        _isPublic = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            // 본인 역할 설정
            const SizedBox(height: 24),
            Text(
              '내 역할 설정',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF43A047),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '내 역할',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text('워크스페이스에서의 내 역할을 선택하세요'),
                      ],
                    ),
                  ),
                  DropdownButton<String>(
                    value: _myRole,
                    items: const [
                      DropdownMenuItem(
                        value: 'member',
                        child: Text('멤버'),
                      ),
                      DropdownMenuItem(
                        value: 'maintainer',
                        child: Text('관리자'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _myRole = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            // 멤버 초대
            const SizedBox(height: 24),
            Text(
              '멤버 초대',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '연구자 이름으로 검색 (팔로잉 중인 사용자만 초대 가능)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                // 입력된 텍스트가 있으면 검색 시작
                if (value.trim().isNotEmpty) {
                  _searchUsers(value.trim());
                } else {
                  setState(() {
                    _searchResults = [];
                  });
                }
              },
            ),

            // 검색 결과
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          user.profileImageUrl ??
                              'https://via.placeholder.com/150',
                        ),
                      ),
                      title: Text(user.fullName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.institution ?? '소속 없음'),
                          const SizedBox(height: 4),
                          Text(
                            user.isFollowing ? '팔로잉 중' : '팔로우 필요',
                            style: TextStyle(
                              color:
                                  user.isFollowing ? Colors.green : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: user.isFollowing
                          ? IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Colors.green),
                              onPressed: () => _addMember(user),
                              tooltip: '멤버로 초대',
                            )
                          : OutlinedButton(
                              onPressed: () {
                                // 팔로우 기능 구현
                                _followUser(user.id);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: const Text('팔로우'),
                            ),
                    );
                  },
                ),
              ),

            // 초대된 멤버 목록
            if (_invitedMembers.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '초대된 멤버',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _invitedMembers.length,
                itemBuilder: (context, index) {
                  final member = _invitedMembers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          member.user.profileImageUrl ??
                              'https://via.placeholder.com/150',
                        ),
                      ),
                      title: Text(member.user.fullName),
                      subtitle: Text(member.user.institution ?? '소속 없음'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<String>(
                            value: member.role,
                            items: const [
                              DropdownMenuItem(
                                value: 'member',
                                child: Text('멤버'),
                              ),
                              DropdownMenuItem(
                                value: 'maintainer',
                                child: Text('관리자'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                _updateMemberRole(member.user.id, value);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _removeMember(member.user.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _createWorkspace,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43A047),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '워크스페이스 생성',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 초대된 멤버 클래스
class InvitedMember {
  final User user;
  final String role; // 'member' 또는 'maintainer'

  InvitedMember({
    required this.user,
    required this.role,
  });
}

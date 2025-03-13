import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 이미지 URL을 처리하는 유틸리티 함수
/// 이미지 URL이 상대 경로인 경우 API URL을 추가합니다.
String getFullImageUrl(String? imageUrl) {
  // 이미지 URL이 없는 경우 기본 이미지 URL 반환
  if (imageUrl == null || imageUrl.isEmpty) {
    return 'https://via.placeholder.com/150';
  }

  // 이미지 URL이 http로 시작하는 경우 그대로 반환
  if (imageUrl.startsWith('http')) {
    return imageUrl;
  }

  // 이미지 URL이 상대 경로인 경우 API URL 추가
  final String apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';

  // 이미지 URL이 /로 시작하지 않는 경우 /를 추가
  if (!imageUrl.startsWith('/')) {
    imageUrl = '/$imageUrl';
  }

  print('이미지 URL 변환: $imageUrl -> $apiUrl$imageUrl');
  return '$apiUrl$imageUrl';
}

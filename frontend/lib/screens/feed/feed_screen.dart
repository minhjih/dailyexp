import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_app_bar.dart';

class FeedScreen extends StatelessWidget {
  final ScrollController scrollController;

  const FeedScreen({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: 10,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemBuilder: (context, index) {
        return _FeedCard(index: index);
      },
    );
  }
}

class _FeedCard extends StatelessWidget {
  final int index;

  const _FeedCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildHeader(context),
          ),
          _buildContent(context),
          _buildImageGrid(context),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildFooter(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Text(
            'U${index + 1}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '연구자 ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '2시간 전',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    final List<String> images = [
      'https://picsum.photos/500/300?random=${index * 3}',
      'https://picsum.photos/500/300?random=${index * 3 + 1}',
      'https://picsum.photos/500/300?random=${index * 3 + 2}',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: images.length == 1
              ? _buildSingleImage(images.first)
              : GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: images.length >= 3 ? 3 : 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: images.map((url) => _buildGridImage(url)).toList(),
                ),
        ),
      ),
    );
  }

  Widget _buildSingleImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildGridImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '논문 제목 ${index + 1}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '이 논문은 매우 흥미로운 연구 결과를 보여줍니다. 주요 발견점과 시사점을 공유합니다. '
            '연구 방법론과 결과 분석에 대한 자세한 내용을 확인해보세요.',
            style: TextStyle(
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        _buildFooterButton(
          context,
          Icons.favorite_border,
          '좋아요',
          '128',
        ),
        const SizedBox(width: 16),
        _buildFooterButton(
          context,
          Icons.comment_outlined,
          '댓글',
          '32',
        ),
        const SizedBox(width: 16),
        _buildFooterButton(
          context,
          Icons.share_outlined,
          '공유',
          '8',
        ),
      ],
    );
  }

  Widget _buildFooterButton(
    BuildContext context,
    IconData icon,
    String label,
    String count,
  ) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              count,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

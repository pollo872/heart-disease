import 'package:flutter/material.dart';
import 'package:heart_disease/features/main_pages/data/data_source/article_data.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/main_appbar.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar("Articles", context),
      body: ListView.builder(
        itemCount: staticArticles.length,
        itemBuilder: (context, index) {
          final article = staticArticles[index];
          return _ArticleCard(article: article);
        },
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final ArticleModel article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ArticleDetailScreen(article: article),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category + read time

            // Image placeholder
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFDBEAFE),
                    Color(0xFFCBFBF1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book_outlined,
                  size: 40, color: Colors.grey),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Color(
                            int.parse('FF${article.categoryColor}', radix: 16))
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    article.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(
                          int.parse('FF${article.categoryColor}', radix: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '⏱ ${article.readTime}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 10),
            // Title
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            // Subtitle
            Text(
              article.subtitle,
              style: const TextStyle(
                  fontSize: 12, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 8),
            // Read More
            const Text(
              'Read More →',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF1E63F3),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleDetailScreen extends StatelessWidget {
  final ArticleModel article;
  const _ArticleDetailScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category + read time
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Color(
                            int.parse('FF${article.categoryColor}', radix: 16))
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    article.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(
                          int.parse('FF${article.categoryColor}', radix: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('⏱ ${article.readTime}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            // Image placeholder
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFDBEAFE),
                    Color(0xFFCBFBF1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book_outlined,
                  size: 60, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Content
            Text(
              article.content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

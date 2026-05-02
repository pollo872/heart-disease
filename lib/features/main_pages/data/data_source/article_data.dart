class ArticleModel {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String category;
  final String readTime;
  final String categoryColor; // hex

  const ArticleModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.category,
    required this.readTime,
    required this.categoryColor,
  });
}

const List<ArticleModel> staticArticles = [
  ArticleModel(
    id: '1',
    category: 'Prevention',
    categoryColor: '1E63F3',
    readTime: '5 min read',
    title: 'Understanding Blood Pressure: What the Numbers Mean',
    subtitle: 'Learn how to interpret your blood pressure readings and what they indicate about your heart health.',
    content: '''Blood pressure is one of the most important indicators of cardiovascular health...

Blood pressure is measured in millimeters of mercury (mmHg) and recorded as two numbers: systolic pressure (the top number) over diastolic pressure (the bottom number).

**Key Takeaways:**
- Normal blood pressure is below 120/80 mmHg
- Systolic measures force when heart beats
- Diastolic measures pressure between beats
- Regular monitoring helps catch problems early
- Lifestyle changes can significantly impact blood pressure''',
  ),
  ArticleModel(
    id: '2',
    category: 'Nutrition',
    categoryColor: '2E7D32',
    readTime: '7 min read',
    title: '10 Heart-Healthy Foods to Add to Your Diet',
    subtitle: 'Discover the best foods for cardiovascular health and how to incorporate them into your daily meals.',
    content: '''Eating the right foods can dramatically improve your heart health...''',
  ),
  ArticleModel(
    id: '3',
    category: 'Fitness',
    categoryColor: 'E65100',
    readTime: '6 min read',
    title: 'Heart Rate Balance: Finding the Right Balance',
    subtitle: 'Understand the optimal amount and type of exercise for maintaining a healthy heart.',
    content: '''Regular physical activity is essential for cardiovascular health...''',
  ),
  ArticleModel(
    id: '4',
    category: 'Wellness',
    categoryColor: '6A1B9A',
    readTime: '5 min read',
    title: 'Managing Stress for Better Heart Health',
    subtitle: 'Explore proven techniques to reduce stress and protect your cardiovascular system.',
    content: '''Chronic stress can have serious impacts on your heart health...''',
  ),
];
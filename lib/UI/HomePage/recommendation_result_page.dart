import 'package:flutter/material.dart';

class RecommendationResultPage extends StatelessWidget {
  final List<String> recommendedCrops;
  final Map<String, double> inputs;

  RecommendationResultPage({required this.recommendedCrops, required this.inputs});

  // Crop descriptions map
  final Map<String, String> cropDescriptions = {
    'jute': 'Jute is a long, soft, shiny vegetable fiber used to make strong threads. It is often used to make sacks and coarse cloth.',
    'mango': 'Mango is a tropical stone fruit known for its sweet and juicy flavor, growing best in warm, tropical climates.',
    'chickpea': 'Chickpea, or garbanzo bean, is a protein-rich legume often used in dishes like hummus and falafel.',
    'kidneybeans': 'Kidney beans are rich in protein and commonly used in stews and soups. They are named for their kidney shape.',
    'pigeonpeas': 'Pigeon peas are drought-resistant legumes often used in soups, stews, and curries in tropical regions.',
    'coffee': 'Coffee plants produce beans used to make the popular beverage. They thrive in moderate rainfall and well-drained soils.',
    'mungbean': 'Mung beans are small, green legumes used in soups and salads. They grow well in warm, humid climates.',
    'blackgram': 'Black gram, or urad dal, is a protein-rich pulse used in curries and dals. It is commonly grown in South Asia.',
    'lentil': 'Lentils are small legumes rich in protein and fiber, often used in vegetarian dishes and soups.',
    'pomegranate': 'Pomegranate is known for its juicy seeds and health benefits. It thrives in warm, dry climates.',
    'banana': 'Bananas are a tropical fruit high in potassium and widely consumed for their sweet taste and soft texture.',
    'maize': 'Maize, or corn, is a cereal grain used for both human consumption and livestock feed. It is a staple food in many regions.',
    'grapes': 'Grapes are small, sweet fruits that grow in clusters. They are eaten fresh, dried as raisins, or used to make wine.',
    'watermelon': 'Watermelon is a large, sweet fruit with high water content, ideal for hot climates.',
    'muskmelon': 'Muskmelon is a sweet and fragrant melon, typically enjoyed fresh in warm, dry climates.',
    'apple': 'Apples are popular fruits grown in temperate climates, used in cooking, baking, or eaten fresh.',
    'orange': 'Oranges are citrus fruits known for their sweet-tangy flavor and are rich in vitamin C.',
    'papaya': 'Papaya is a tropical fruit known for its sweet flesh and digestive health benefits.',
    'coconut': 'Coconuts are versatile fruits used for their water, milk, oil, and meat, growing in tropical coastal areas.',
    'cotton': 'Cotton is a soft fiber grown in bolls around the cotton plant seeds, used extensively in the textile industry.',
    'rice': 'Rice is a staple grain that grows in flooded fields and is a daily food source for billions worldwide.',
    'mothbeans': 'Moth beans are drought-tolerant legumes commonly grown in arid regions, known for their high protein content.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommendation Result'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended Crops:',
              style: Theme.of(context).textTheme.titleLarge, // Updated from headline6 to titleLarge
            ),
            SizedBox(height: 8),
            ...recommendedCrops.map((crop) => Card(
              child: ListTile(
                title: Text(crop),
                subtitle: Text(cropDescriptions[crop.toLowerCase()] ?? 'Description not available'), // Show description or fallback
                trailing: Icon(Icons.agriculture),
              ),
            )).toList(),
            SizedBox(height: 16),
            Text(
              'Input Parameters:',
              style: Theme.of(context).textTheme.titleLarge, // Updated from headline6 to titleLarge
            ),
            SizedBox(height: 8),
            ...inputs.entries.map((entry) => _buildInputRow(entry.key, entry.value)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String key, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value.toStringAsFixed(2)),
        ],
      ),
    );
  }
}

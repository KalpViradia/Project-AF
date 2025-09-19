import '../model/category_model.dart';
import '../utils/import_export.dart';
import '../utils/api_constants.dart';

class CategoryService {
  final Dio _dio = Get.find<Dio>();
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('$baseUrl/Categories');
      if (response.data is List) {
        return (response.data as List).map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return getDefaultCategories();
    }
  }

  Future<List<Category>> getActiveCategories() async {
    try {
      final response = await _dio.get('$baseUrl/Categories');
      if (response.data is List) {
        final categories = (response.data as List).map((json) => Category.fromJson(json)).toList();
        return categories.where((category) => category.isActive).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching active categories: $e');
      return getDefaultCategories();
    }
  }

  Future<Category?> getCategoryById(int categoryId) async {
    try {
      final response = await _dio.get('$baseUrl/Categories/$categoryId');
      return Category.fromJson(response.data);
    } catch (e) {
      print('Error fetching category by ID: $e');
      // Try to find in default categories
      final defaultCategories = getDefaultCategories();
      try {
        return defaultCategories.firstWhere((category) => category.categoryId == categoryId);
      } catch (e) {
        return null;
      }
    }
  }

  // Default categories for fallback
  List<Category> getDefaultCategories() {
    return [
      Category(
        categoryId: 1,
        name: 'Work',
        description: 'Business meetings, conferences, and professional events',
        color: '#1565C0',
        icon: 'work',
      ),
      Category(
        categoryId: 2,
        name: 'Celebration',
        description: 'Birthdays, anniversaries, and special occasions',
        color: '#FF6F00',
        icon: 'celebration',
      ),
      Category(
        categoryId: 3,
        name: 'Sports',
        description: 'Sports activities, tournaments, and fitness events',
        color: '#2E7D32',
        icon: 'sports',
      ),
      Category(
        categoryId: 4,
        name: 'Education',
        description: 'Workshops, seminars, and learning sessions',
        color: '#7B1FA2',
        icon: 'education',
      ),
      Category(
        categoryId: 5,
        name: 'Health',
        description: 'Medical appointments, wellness, and health activities',
        color: '#C62828',
        icon: 'health',
      ),
      Category(
        categoryId: 6,
        name: 'Social',
        description: 'Parties, gatherings, and social meetups',
        color: '#D84315',
        icon: 'social',
      ),
      Category(
        categoryId: 7,
        name: 'Travel',
        description: 'Trips, vacations, and travel adventures',
        color: '#0097A7',
        icon: 'travel',
      ),
      Category(
        categoryId: 8,
        name: 'Food',
        description: 'Dining, cooking events, and food festivals',
        color: '#5D4037',
        icon: 'food',
      ),
      Category(
        categoryId: 9,
        name: 'Entertainment',
        description: 'Movies, concerts, shows, and entertainment events',
        color: '#AD1457',
        icon: 'entertainment',
      ),
      Category(
        categoryId: 10,
        name: 'Other',
        description: 'Miscellaneous events and activities',
        color: '#455A64',
        icon: 'other',
      ),
    ];
  }
}

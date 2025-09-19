import '../utils/import_export.dart';
import '../model/category_model.dart';
import '../service/category_service.dart';

class CategoryController extends GetxController {
  final CategoryService _categoryService;
  
  CategoryController(this._categoryService);

  final RxList<Category> categories = <Category>[].obs;
  final RxList<Category> activeCategories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<Category?> selectedCategory = Rx<Category?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      final fetchedCategories = await _categoryService.getActiveCategories();
      
      if (fetchedCategories.isNotEmpty) {
        categories.value = fetchedCategories;
        activeCategories.value = fetchedCategories.where((cat) => cat.isActive).toList();
      } else {
        // Use default categories if API fails
        final defaultCategories = _categoryService.getDefaultCategories();
        categories.value = defaultCategories;
        activeCategories.value = defaultCategories;
      }
    } catch (e) {
      print('Error loading categories: $e');
      // Fallback to default categories
      final defaultCategories = _categoryService.getDefaultCategories();
      categories.value = defaultCategories;
      activeCategories.value = defaultCategories;
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(Category? category) {
    selectedCategory.value = category;
  }

  Category? getCategoryById(int? categoryId) {
    if (categoryId == null) return null;
    try {
      return categories.firstWhere((cat) => cat.categoryId == categoryId);
    } catch (e) {
      return null;
    }
  }

  List<Category> getCategoriesByIds(List<int> categoryIds) {
    return categories.where((cat) => categoryIds.contains(cat.categoryId)).toList();
  }

  void clearSelection() {
    selectedCategory.value = null;
  }
}

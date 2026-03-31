import '../../models/category.dart';

abstract class ICategoryRepository {

  Future<List<Category>> getAllCategories();

  Future<List<Category>> getCategories();
  
}

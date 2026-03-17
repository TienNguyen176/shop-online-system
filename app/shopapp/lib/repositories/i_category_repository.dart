import '../models/category.dart';

abstract class ICategoryRepository {

  Future<List<Category>> getCategories();
  
}

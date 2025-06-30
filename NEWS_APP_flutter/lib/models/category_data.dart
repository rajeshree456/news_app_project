import 'package:flutter_application_3/models/category_model.dart';

List<CategoryModel> getCategories() {
  List<CategoryModel> category = [];
  CategoryModel categoryModel = new CategoryModel();

  categoryModel.categoryName = "India";
  categoryModel.image = "assets/images/india_4.png";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  categoryModel.categoryName = "Business";
  categoryModel.image = "assets/images/business_4.png";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  categoryModel.categoryName = "Sports";
  categoryModel.image = "assets/images/sports_4.png";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  categoryModel.categoryName = "Health";
  categoryModel.image = "assets/images/health_4.png";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  categoryModel.categoryName = "Technology";
  categoryModel.image = "assets/images/technology_4.png";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  categoryModel.categoryName = "Entertainment";
  categoryModel.image = "assets/images/entertainment_4.png";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  categoryModel.categoryName = "General";
  categoryModel.image = "assets/images/politics_4.png";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  return category;
}

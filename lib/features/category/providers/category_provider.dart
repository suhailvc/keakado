import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/api_response_model.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/common/reposotories/product_repo.dart';
import 'package:flutter_grocery/features/category/domain/models/category_model.dart';
import 'package:flutter_grocery/features/category/domain/reposotories/category_repo.dart';
import 'package:flutter_grocery/features/search/domain/reposotories/search_repo.dart';
import 'package:flutter_grocery/helper/api_checker_helper.dart';

// class CategoryProvider extends ChangeNotifier {
//   final CategoryRepo categoryRepo;
//   final ProductRepo productRepo;
//   final SearchRepo searchRepo;

//   CategoryProvider(
//       {required this.categoryRepo,
//       required this.productRepo,
//       required this.searchRepo});

//   int _selectedCategoryIndex = -1;
//   int _categoryIndex = 0;
//   List<CategoryModel>? _categoryList;
//   final List<CategoryModel> _subCategoryList = [];
//   List<Product> _categoryProductList = [];
//   final List<Product> _categoryAllProductList = [];
//   CategoryModel? _categoryModel;
//   int _selectCategory = -1;

//   int get categoryIndex => _categoryIndex;
//   int get selectedCategoryIndex => _selectedCategoryIndex;
//   List<CategoryModel>? get categoryList => _categoryList;
//   List<CategoryModel>? get subCategoryList => _subCategoryList;
//   List<Product> get categoryProductList => _categoryProductList;
//   CategoryModel? get categoryModel => _categoryModel;
//   int get selectCategory => _selectCategory;
//   Map<String, List<CategoryModel>> subCategoryMap = {};

//   Future<ApiResponseModel> getCategoryList(BuildContext context, bool reload,
//       {int? id}) async {
//     ApiResponseModel apiResponse = await categoryRepo.getCategoryList();

//     if (apiResponse.response != null &&
//         apiResponse.response!.statusCode == 200) {
//       _categoryList = [];
//       apiResponse.response!.data.forEach(
//           (category) => _categoryList!.add(CategoryModel.fromJson(category)));
//       _selectedCategoryIndex = -1;
//       _categoryIndex = 0;
//     } else {
//       ApiCheckerHelper.checkApi(apiResponse);
//     }
//     notifyListeners();
//     return apiResponse;
//   }

//   void getCategory(int? id, BuildContext context) async {
//     if (_categoryList == null) {
//       await getCategoryList(context, true);
//       _categoryModel =
//           _categoryList!.firstWhere((category) => category.id == id);
//       notifyListeners();
//     } else {
//       try {
//         _categoryModel =
//             _categoryList!.firstWhere((category) => category.id == id);
//       } catch (e) {
//         debugPrint('error : $e');
//       }
//     }
//   }

//   // void getSubCategoryList(BuildContext context, String categoryID) async {
//   //   _subCategoryList = null;

//   //   ApiResponseModel apiResponse =
//   //       await categoryRepo.getSubCategoryList(categoryID);
//   //   if (apiResponse.response != null &&
//   //       apiResponse.response!.statusCode == 200) {
//   //     _subCategoryList = [];
//   //     apiResponse.response!.data.forEach((category) =>
//   //         _subCategoryList!.add(CategoryModel.fromJson(category)));
//   //     getCategoryProductList(categoryID);
//   //     log(_subCategoryList.toString());
//   //   } else {
//   //     ApiCheckerHelper.checkApi(apiResponse);
//   //   }
//   //   notifyListeners();
//   // }

//   List<CategoryModel>? getSubCategories(String categoryID) {
//     return subCategoryMap[categoryID] ?? [];
//   }

//   void getSubCategoryList(BuildContext context, String categoryID) async {
//     subCategoryMap[categoryID] =
//         []; // Reset the specific subcategory list before fetching

//     ApiResponseModel apiResponse =
//         await categoryRepo.getSubCategoryList(categoryID);
//     if (apiResponse.response != null &&
//         apiResponse.response!.statusCode == 200) {
//       subCategoryMap[categoryID] =
//           []; // Initialize the list for this categoryID
//       apiResponse.response!.data.forEach((category) {
//         log(category.toString(), name: "Sub-Cat");
//         subCategoryMap[categoryID]!.add(CategoryModel.fromJson(category));
//       });

//       getCategoryProductList(
//           categoryID); // Optional: Call additional functions if needed
//       log(subCategoryMap[categoryID]
//           .toString()); // Log the specific subcategory list
//     } else {
//       ApiCheckerHelper.checkApi(apiResponse);
//     }

//     notifyListeners();
//   }

//   void getCategoryProductList(String categoryID) async {
//     _categoryProductList = [];

//     ApiResponseModel apiResponse =
//         await categoryRepo.getCategoryProductList(categoryID);
//     if (apiResponse.response != null &&
//         apiResponse.response!.statusCode == 200) {
//       _categoryProductList = [];
//       apiResponse.response!.data.forEach(
//           (category) => _categoryProductList.add(Product.fromJson(category)));
//       _categoryAllProductList.addAll(_categoryProductList);
//     } else {
//       ApiCheckerHelper.checkApi(apiResponse);
//     }
//     notifyListeners();
//   }

//   void updateSelectCategory(int index) {
//     _selectCategory = index;
//     notifyListeners();
//   }

//   void onChangeSelectIndex(int selectedIndex, {bool notify = true}) {
//     _selectedCategoryIndex = selectedIndex;
//     if (notify) {
//       notifyListeners();
//     }
//   }

//   void onChangeCategoryIndex(int selectedIndex, {bool notify = true}) {
//     _categoryIndex = selectedIndex;
//     if (notify) {
//       notifyListeners();
//     }
//   }

//   List<Product> _subCategoryProductList = [];
//   bool? _hasData;
//   double _maxValue = 0;
//   double get maxValue => _maxValue;
//   List<Product> get subCategoryProductList => _subCategoryProductList;
//   List<String?> _allSortBy = [];
//   List<String?> get allSortBy => _allSortBy;
//   bool? get hasData => _hasData;

//   void initCategoryProductList(String id) async {
//     _subCategoryProductList = [];
//     _hasData = true;
//     ApiResponseModel apiResponse =
//         await productRepo.getBrandOrCategoryProductList(id);
//     if (apiResponse.response != null &&
//         apiResponse.response!.statusCode == 200) {
//       _subCategoryProductList = [];
//       apiResponse.response!.data.forEach(
//           (product) => _subCategoryProductList.add(Product.fromJson(product)));
//       _hasData = _subCategoryProductList.length > 1;
//       List<Product> products = [];
//       products.addAll(_subCategoryProductList);
//       List<double> prices = [];
//       for (var product in products) {
//         prices.add(double.parse(product.price.toString()));
//       }
//       prices.sort();
//       if (subCategoryProductList.isNotEmpty) {
//         _maxValue = prices[prices.length - 1];
//       }
//     } else {
//       ApiCheckerHelper.checkApi(apiResponse);
//     }
//     notifyListeners();
//   }

//   void sortCategoryProduct(int filterIndex) {
//     if (filterIndex == 0) {
//       _subCategoryProductList.sort(
//           (product1, product2) => product1.price!.compareTo(product2.price!));
//     } else if (filterIndex == 1) {
//       _subCategoryProductList.sort(
//           (product1, product2) => product1.price!.compareTo(product2.price!));
//       Iterable iterable = _subCategoryProductList.reversed;
//       _subCategoryProductList = iterable.toList() as List<Product>;
//     } else if (filterIndex == 2) {
//       _subCategoryProductList.sort((product1, product2) =>
//           product1.name!.toLowerCase().compareTo(product2.name!.toLowerCase()));
//     } else if (filterIndex == 3) {
//       _subCategoryProductList.sort((product1, product2) =>
//           product1.name!.toLowerCase().compareTo(product2.name!.toLowerCase()));
//       Iterable iterable = _subCategoryProductList.reversed;
//       _subCategoryProductList = iterable.toList() as List<Product>;
//     }
//     notifyListeners();
//   }

//   void initializeAllSortBy(BuildContext context) {
//     if (_allSortBy.isEmpty) {
//       _allSortBy = [];
//       _allSortBy = searchRepo.getAllSortByList();
//     }
//   }
// }

class CategoryProvider extends ChangeNotifier {
  final CategoryRepo categoryRepo;
  final ProductRepo productRepo;
  final SearchRepo searchRepo;

  CategoryProvider(
      {required this.categoryRepo,
      required this.productRepo,
      required this.searchRepo});

  int _selectedCategoryIndex = -1;
  int _categoryIndex = 0;
  List<CategoryModel>? _categoryList;
  final List<CategoryModel> _subCategoryList = [];
  List<Product> _categoryProductList = [];
  final List<Product> _categoryAllProductList = [];
  CategoryModel? _categoryModel;
  int _selectCategory = -1;

  int get categoryIndex => _categoryIndex;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  List<CategoryModel>? get categoryList => _categoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;
  List<Product> get categoryProductList => _categoryProductList;
  CategoryModel? get categoryModel => _categoryModel;
  int get selectCategory => _selectCategory;
  Map<String, List<CategoryModel>> subCategoryMap = {};

  Future<ApiResponseModel> getCategoryList(BuildContext context, bool reload,
      {int? id}) async {
    ApiResponseModel apiResponse = await categoryRepo.getCategoryList();

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _categoryList = [];
      apiResponse.response!.data.forEach(
          (category) => _categoryList!.add(CategoryModel.fromJson(category)));
      _selectedCategoryIndex = -1;
      _categoryIndex = 0;
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }

  Future<void> getCategory(int? id, BuildContext context) async {
    if (_categoryList == null) {
      await getCategoryList(context, true);
      _categoryModel =
          _categoryList!.firstWhere((category) => category.id == id);
      notifyListeners();
    } else {
      try {
        _categoryModel =
            _categoryList!.firstWhere((category) => category.id == id);
      } catch (e) {
        debugPrint('error : $e');
      }
    }
  }

  // void getSubCategoryList(BuildContext context, String categoryID) async {
  //   _subCategoryList = null;

  //   ApiResponseModel apiResponse =
  //       await categoryRepo.getSubCategoryList(categoryID);
  //   if (apiResponse.response != null &&
  //       apiResponse.response!.statusCode == 200) {
  //     _subCategoryList = [];
  //     apiResponse.response!.data.forEach((category) =>
  //         _subCategoryList!.add(CategoryModel.fromJson(category)));
  //     getCategoryProductList(categoryID);
  //     log(_subCategoryList.toString());
  //   } else {
  //     ApiCheckerHelper.checkApi(apiResponse);
  //   }
  //   notifyListeners();
  // }

  List<CategoryModel>? getSubCategories(String categoryID) {
    return subCategoryMap[categoryID] ?? [];
  }

  Future<void> getSubCategoryList(
      BuildContext context, String categoryID) async {
    // Check if data is already available for this categoryID
    if (subCategoryMap[categoryID]?.isNotEmpty ?? false) {
      return; // Skip fetching if already loaded
    }

    subCategoryMap[categoryID] = []; // Reset the list

    try {
      ApiResponseModel apiResponse =
          await categoryRepo.getSubCategoryList(categoryID);
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        subCategoryMap[categoryID] = [];

        var data = apiResponse.response!.data;

        if (data is Map<String, dynamic>) {
          // Handle Map response
          data.forEach((key, value) {
            subCategoryMap[categoryID]!.add(CategoryModel.fromJson(value));
          });
        } else if (data is List<dynamic>) {
          // Handle List response
          data.forEach((item) {
            subCategoryMap[categoryID]!.add(CategoryModel.fromJson(item));
          });
        } else {
          debugPrint("Unexpected data type: ${data.runtimeType}");
        }
      }
      // if (apiResponse.response != null &&
      //     apiResponse.response!.statusCode == 200) {
      //   subCategoryMap[categoryID] = [];

      //   // Check if the response data is a Map
      //   (apiResponse.response!.data as Map<String, dynamic>)
      //       .forEach((key, value) {
      //     subCategoryMap[categoryID]!.add(CategoryModel.fromJson(value));
      //   });
      // }
      // if (apiResponse.response != null &&
      //     apiResponse.response!.statusCode == 200) {
      //   subCategoryMap[categoryID] = [];
      //   apiResponse.response!.data.forEach((category) {
      //     subCategoryMap[categoryID]!.add(CategoryModel.fromJson(category));
      //   });
      //}
      else if (apiResponse.response!.statusCode == 429) {
        await Future.delayed(Duration(seconds: 2)); // Retry after delay
        await getSubCategoryList(context, categoryID); // Retry
      } else {
        ApiCheckerHelper.checkApi(apiResponse);
      }
    } catch (e) {
      if (e is DioError && e.response?.statusCode == 429) {
        await Future.delayed(Duration(seconds: 2)); // Retry after delay
        await getSubCategoryList(context, categoryID); // Retry
      } else {
        debugPrint("Error fetching subcategories: $e");
      }
    }

    notifyListeners(); // Notify listeners about updates
  }

  // Future<void> getSubCategoryList(
  //     BuildContext context, String categoryID) async {
  //   subCategoryMap[categoryID] =
  //       []; // Reset the specific subcategory list before fetching

  //   ApiResponseModel apiResponse =
  //       await categoryRepo.getSubCategoryList(categoryID);
  //   if (apiResponse.response != null &&
  //       apiResponse.response!.statusCode == 200) {
  //     subCategoryMap[categoryID] =
  //         []; // Initialize the list for this categoryID
  //     apiResponse.response!.data.forEach((category) {
  //       log(category.toString(), name: "Sub-Cat");
  //       subCategoryMap[categoryID]!.add(CategoryModel.fromJson(category));
  //     });

  //     getCategoryProductList(
  //         categoryID); // Optional: Call additional functions if needed
  //     log(subCategoryMap[categoryID]
  //         .toString()); // Log the specific subcategory list
  //   } else {
  //     ApiCheckerHelper.checkApi(apiResponse);
  //   }

  //   notifyListeners();
  // }
  void getCategoryProductList(String categoryID) async {
    _categoryProductList = [];
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        ApiResponseModel apiResponse =
            await categoryRepo.getCategoryProductList(categoryID);

        // Check if the response status code is 200
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          // Validate the response format
          if (apiResponse.response!.data is List) {
            _categoryProductList = [];
            apiResponse.response!.data.forEach((category) {
              _categoryProductList.add(Product.fromJson(category));
            });
            _categoryAllProductList.addAll(_categoryProductList);
            notifyListeners();
            return; // Success, exit retry loop
          } else {
            debugPrint(
                "Invalid response format: ${apiResponse.response!.data}");
            break; // Exit if the response is not as expected
          }
        } else if (apiResponse.response!.statusCode == 429) {
          debugPrint("Rate-limited: Retrying...");
          await Future.delayed(
              const Duration(seconds: 2)); // Wait before retrying
          retryCount++;
        } else {
          ApiCheckerHelper.checkApi(apiResponse);
          return; // Exit for other errors
        }
      } catch (e) {
        if (e is FormatException) {
          debugPrint("Error parsing response: ${e.message}");
        } else {
          debugPrint("Error fetching products: $e");
        }
        break; // Stop retrying on unexpected errors
      }
    }

    debugPrint("Failed to fetch products after $maxRetries retries.");
  }

  // void getCategoryProductList(String categoryID) async {
  //   _categoryProductList = [];

  //   ApiResponseModel apiResponse =
  //       await categoryRepo.getCategoryProductList(categoryID);
  //   if (apiResponse.response != null &&
  //       apiResponse.response!.statusCode == 200) {
  //     _categoryProductList = [];
  //     apiResponse.response!.data.forEach(
  //         (category) => _categoryProductList.add(Product.fromJson(category)));
  //     _categoryAllProductList.addAll(_categoryProductList);
  //   } else {
  //     ApiCheckerHelper.checkApi(apiResponse);
  //   }
  //   notifyListeners();
  // }

  void updateSelectCategory(int index) {
    _selectCategory = index;
    notifyListeners();
  }

  void onChangeSelectIndex(int selectedIndex, {bool notify = true}) {
    _selectedCategoryIndex = selectedIndex;
    if (notify) {
      notifyListeners();
    }
  }

  void onChangeCategoryIndex(int selectedIndex, {bool notify = true}) {
    _categoryIndex = selectedIndex;
    if (notify) {
      notifyListeners();
    }
  }

  List<Product> _subCategoryProductList = [];
  bool? _hasData;
  double _maxValue = 0;
  double get maxValue => _maxValue;
  List<Product> get subCategoryProductList => _subCategoryProductList;
  List<String?> _allSortBy = [];
  List<String?> get allSortBy => _allSortBy;
  bool? get hasData => _hasData;

  Future<void> initCategoryProductList(String id) async {
    _subCategoryProductList = [];
    _hasData = true;
    ApiResponseModel apiResponse =
        await productRepo.getBrandOrCategoryProductList(id);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _subCategoryProductList = [];
      apiResponse.response!.data.forEach(
          (product) => _subCategoryProductList.add(Product.fromJson(product)));
      _hasData = _subCategoryProductList.length > 1;
      List<Product> products = [];
      products.addAll(_subCategoryProductList);
      List<double> prices = [];
      for (var product in products) {
        prices.add(double.parse(product.price.toString()));
      }
      prices.sort();
      if (subCategoryProductList.isNotEmpty) {
        _maxValue = prices[prices.length - 1];
      }
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  // void sortCategoryProduct(int filterIndex) {
  //   // Reset _subCategoryProductList to the original unsorted list
  //   _subCategoryProductList = List.from(_categoryAllProductList);

  //   if (filterIndex == 0) {
  //     // Sort by price low to high
  //     _subCategoryProductList.sort(
  //         (product1, product2) => product1.price!.compareTo(product2.price!));
  //   } else if (filterIndex == 1) {
  //     // Sort by price high to low
  //     _subCategoryProductList.sort(
  //         (product1, product2) => product1.price!.compareTo(product2.price!));
  //     _subCategoryProductList = _subCategoryProductList.reversed.toList();
  //   } else if (filterIndex == 2) {
  //     // Sort alphabetically (A-Z)
  //     _subCategoryProductList.sort((product1, product2) =>
  //         product1.name!.toLowerCase().compareTo(product2.name!.toLowerCase()));
  //   } else if (filterIndex == 3) {
  //     // Sort reverse alphabetically (Z-A)
  //     _subCategoryProductList.sort((product1, product2) =>
  //         product1.name!.toLowerCase().compareTo(product2.name!.toLowerCase()));
  //     _subCategoryProductList = _subCategoryProductList.reversed.toList();
  //   }
  //   notifyListeners();
  // }
  void sortCategoryProduct(int filterIndex) {
    if (filterIndex == 0) {
      _subCategoryProductList.sort(
          (product1, product2) => product1.price!.compareTo(product2.price!));
    } else if (filterIndex == 1) {
      _subCategoryProductList.sort(
          (product1, product2) => product1.price!.compareTo(product2.price!));
      Iterable iterable = _subCategoryProductList.reversed;
      _subCategoryProductList = iterable.toList() as List<Product>;
    } else if (filterIndex == 2) {
      _subCategoryProductList.sort((product1, product2) =>
          product1.name!.toLowerCase().compareTo(product2.name!.toLowerCase()));
    } else if (filterIndex == 3) {
      _subCategoryProductList.sort((product1, product2) =>
          product1.name!.toLowerCase().compareTo(product2.name!.toLowerCase()));
      Iterable iterable = _subCategoryProductList.reversed;
      _subCategoryProductList = iterable.toList() as List<Product>;
    }
    notifyListeners();
  }

  void initializeAllSortBy(BuildContext context) {
    if (_allSortBy.isEmpty) {
      _allSortBy = [];
      _allSortBy = searchRepo.getAllSortByList();
    }
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/product_filter_type_enum.dart';
import 'package:flutter_grocery/common/models/api_response_model.dart';
import 'package:flutter_grocery/common/models/brands_model.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/common/reposotories/product_repo.dart';
import 'package:flutter_grocery/common/reposotories/related_product_repo.dart';
import 'package:flutter_grocery/features/search/domain/reposotories/search_repo.dart';
import 'package:flutter_grocery/helper/api_checker_helper.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/utill/product_type.dart';
import 'package:provider/provider.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepo productRepo;
  final SearchRepo searchRepo;

  ProductProvider({required this.productRepo, required this.searchRepo});
  bool _isLoading = true;
  ProductModel? _allProductModel;
  ProductModel? _brandProductModel;
  Product? _product;
  int? _imageSliderIndex;
  ProductModel? _dailyProductModel;
  ProductModel? _organicProductModel;
  ProductModel? _featuredProductModel;
  ProductModel? _mostViewedProductModel;
  ProductModel? _relatedProductModel;
  ProductFilterType _selectedFilterType = ProductFilterType.latest;
  bool isLoading = false;
  BrandsModel? _brandsModel;
  bool? get Isloading => _isLoading;
  Product? get product => _product;
  ProductModel? get allProductModel => _allProductModel;
  ProductModel? get brandProductModel => _brandProductModel;
  ProductModel? get dailyProductModel => _dailyProductModel;
  ProductModel? get organicProductModel => _organicProductModel;
  ProductModel? get featuredProductModel => _featuredProductModel;
  ProductModel? get mostViewedProductModel => _mostViewedProductModel;
  ProductModel? get reltedProductModel => _relatedProductModel;
  BrandsModel? get brandsModel => _brandsModel;

  int? get imageSliderIndex => _imageSliderIndex;
  ProductFilterType get selectedFilterType => _selectedFilterType;

  Future<void> getAllProductList(int offset, bool reload,
      {bool isUpdate = true}) async {
    if (reload) {
      _allProductModel = null;

      if (isUpdate) {
        notifyListeners();
      }
    }

    ApiResponseModel? response =
        await productRepo.getAllProductList(offset, _selectedFilterType);
    if (response.response != null &&
        response.response?.data != null &&
        response.response?.statusCode == 200) {
      if (offset == 1) {
        _allProductModel = ProductModel.fromJson(response.response?.data);
      } else {
        _allProductModel!.totalSize =
            ProductModel.fromJson(response.response?.data).totalSize;
        _allProductModel!.offset =
            ProductModel.fromJson(response.response?.data).offset;
        _allProductModel!.products!
            .addAll(ProductModel.fromJson(response.response?.data).products!);
      }

      notifyListeners();
    } else {
      ApiCheckerHelper.checkApi(response);
    }
  }

  List<Product> _productList = [];
  List<String?> _allSortBy = [];
  List<String?> get allSortBy => _allSortBy;
  Future<void> getRelatedProduct(String? token) async {
    _relatedProductModel = await fetchRelatedProductService(token);
    _isLoading = false;
    notifyListeners();
    print("-----related--------${_relatedProductModel!.products!.length}");
  }

  Future<void> getAllBrands([int? limit = 10]) async {
    try {
      isLoading = true;
      ApiResponseModel? response = await productRepo.getAllBrands(1000);
      if (response.response != null &&
          response.response?.data != null &&
          response.response?.statusCode == 200) {
        _brandsModel = BrandsModel.fromJson(response.response!.data);
        notifyListeners();
      } else {
        ApiCheckerHelper.checkApi(response);
      }
    } catch (e, s) {
      log("", error: e, stackTrace: s);
    }
    isLoading = false;
  }

  Future<void> getAllBrandProducts(String brandId) async {
    isLoading = true;
    notifyListeners();

    try {
      ApiResponseModel? response =
          await productRepo.getAllBrandProducts(brandId);
      if (response.response != null &&
          response.response?.data != null &&
          response.response?.statusCode == 200) {
        _brandProductModel = ProductModel.fromJson(response.response?.data);

        notifyListeners();
      } else {
        ApiCheckerHelper.checkApi(response);
      }
    } catch (e, s) {
      log("", error: e, stackTrace: s);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> getItemList(int offset,
      {bool isUpdate = true,
      bool isReload = true,
      required String? productType}) async {
    isLoading = true;
    notifyListeners();

    if (offset == 1) {
      _dailyProductModel = null;
      _featuredProductModel = null;
      _mostViewedProductModel = null;
      _organicProductModel = null;
      if (isUpdate) {
        notifyListeners();
      }
    }
    ApiResponseModel apiResponse =
        await productRepo.getItemList(offset, productType);

    if (apiResponse.response?.statusCode == 200) {
      if (offset == 1) {
        if (productType == ProductType.dailyItem) {
          _dailyProductModel =
              ProductModel.fromJson(apiResponse.response?.data);
        } else if (productType == ProductType.featuredItem) {
          _featuredProductModel =
              ProductModel.fromJson(apiResponse.response?.data);
        } else if (productType == ProductType.organicProduct) {
          _organicProductModel =
              ProductModel.fromJson(apiResponse.response?.data);
        } else if (productType == ProductType.mostReviewed) {
          _mostViewedProductModel =
              ProductModel.fromJson(apiResponse.response?.data);
        }
      } else {
        if (productType == ProductType.dailyItem) {
          _dailyProductModel?.offset =
              ProductModel.fromJson(apiResponse.response?.data).offset;
          _dailyProductModel?.totalSize =
              ProductModel.fromJson(apiResponse.response?.data).totalSize;
          _dailyProductModel?.products?.addAll(
              ProductModel.fromJson(apiResponse.response?.data).products ?? []);
        } else if (productType == ProductType.featuredItem) {
          _featuredProductModel?.offset =
              ProductModel.fromJson(apiResponse.response?.data).offset;
          _featuredProductModel?.totalSize =
              ProductModel.fromJson(apiResponse.response?.data).totalSize;
          _featuredProductModel?.products?.addAll(
              ProductModel.fromJson(apiResponse.response?.data).products ?? []);
        } else if (productType == ProductType.organicProduct) {
          _organicProductModel?.offset =
              ProductModel.fromJson(apiResponse.response?.data).offset;
          _organicProductModel?.totalSize =
              ProductModel.fromJson(apiResponse.response?.data).totalSize;
          _organicProductModel?.products?.addAll(
              ProductModel.fromJson(apiResponse.response?.data).products ?? []);
        } else if (productType == ProductType.mostReviewed) {
          _mostViewedProductModel?.offset =
              ProductModel.fromJson(apiResponse.response?.data).offset;
          _mostViewedProductModel?.totalSize =
              ProductModel.fromJson(apiResponse.response?.data).totalSize;
          _mostViewedProductModel?.products?.addAll(
              ProductModel.fromJson(apiResponse.response?.data).products ?? []);
        }
      }
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<Product?> getProductDetails(String productID,
      {bool searchQuery = false}) async {
    final CartProvider cartProvider =
        Provider.of<CartProvider>(Get.context!, listen: false);

    _product = null;
    ApiResponseModel apiResponse = await productRepo.getProductDetails(
      productID,
      searchQuery,
    );

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      debugPrint("TESTTTTTTTTT ==> Inside product details success");
      _product = Product.fromJson(apiResponse.response!.data);
      cartProvider.initData(_product!);
      return _product;
    } else {
      debugPrint(
          " TESTTTTTTTTT ==> after product details error ${apiResponse.error} ${apiResponse.response}");

      ApiCheckerHelper.checkApi(apiResponse);
    }

    notifyListeners();

    debugPrint(
        " TESTTTTTTTTT ==> after product details success ${_product?.name}");
    return null;
    // return _product;
  }

  // void sortCategoryProduct(int filterIndex) {
  //   if (_allProductModel?.products != null) {
  //     List<Product> products = List.from(_allProductModel!.products!);

  //     if (filterIndex == 0) {
  //       // Sort by price low to high
  //       products.sort(
  //           (product1, product2) => product1.price!.compareTo(product2.price!));
  //     } else if (filterIndex == 1) {
  //       // Sort by price high to low
  //       products.sort(
  //           (product1, product2) => product2.price!.compareTo(product1.price!));
  //     } else if (filterIndex == 2) {
  //       // Sort alphabetically (A-Z)
  //       products.sort(
  //           (product1, product2) => product1.name!.compareTo(product2.name!));
  //     } else if (filterIndex == 3) {
  //       // Sort reverse alphabetically (Z-A)
  //       products.sort(
  //           (product1, product2) => product2.name!.compareTo(product1.name!));
  //     }

  //     // Update _allProductModel's products with the sorted list
  //     _allProductModel!.products = products;
  //     notifyListeners();
  //   }
  // }
  // void sortCategoryProduct(int filterIndex) {
  //   List<Product>? productsToSort;

  //   // Determine which product list to sort based on current view
  //   if (_dailyProductModel?.products != null &&
  //       _dailyProductModel!.products!.isNotEmpty) {
  //     productsToSort = _dailyProductModel!.products;
  //   } else if (_featuredProductModel?.products != null &&
  //       _featuredProductModel!.products!.isNotEmpty) {
  //     productsToSort = _featuredProductModel!.products;
  //   } else if (_mostViewedProductModel?.products != null &&
  //       _mostViewedProductModel!.products!.isNotEmpty) {
  //     productsToSort = _mostViewedProductModel!.products;
  //   } else if (_organicProductModel?.products != null &&
  //       _organicProductModel!.products!.isNotEmpty) {
  //     productsToSort = _organicProductModel!.products;
  //   }
  //   print('-------- prodct to $productsToSort');
  //   if (productsToSort != null) {
  //     print('-------- prodct to sort');
  //     if (filterIndex == 0) {
  //       // Low to high price
  //       productsToSort.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
  //     } else if (filterIndex == 1) {
  //       // High to low price
  //       productsToSort.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
  //     } else if (filterIndex == 2) {
  //       // A to Z
  //       productsToSort.sort((a, b) => (a.name ?? '')
  //           .toLowerCase()
  //           .compareTo((b.name ?? '').toLowerCase()));
  //     } else if (filterIndex == 3) {
  //       // Z to A
  //       productsToSort.sort((a, b) => (b.name ?? '')
  //           .toLowerCase()
  //           .compareTo((a.name ?? '').toLowerCase()));
  //     }
  //     notifyListeners();
  //   }
  // }
  void sortCategoryProduct(int filterIndex) {
    print('Sorting triggered with index: $filterIndex');

    // Handle Daily Products
    if (_dailyProductModel?.products != null &&
        _dailyProductModel!.products!.isNotEmpty) {
      List<Product> productsToSort =
          List<Product>.from(_dailyProductModel!.products!);

      applySorting(productsToSort, filterIndex);

      _dailyProductModel = ProductModel(
        totalSize: _dailyProductModel!.totalSize,
        limit: _dailyProductModel!.limit,
        offset: _dailyProductModel!.offset,
        products: productsToSort,
      );
    }

    // Handle Featured Products
    if (_featuredProductModel?.products != null &&
        _featuredProductModel!.products!.isNotEmpty) {
      List<Product> productsToSort =
          List<Product>.from(_featuredProductModel!.products!);

      applySorting(productsToSort, filterIndex);

      _featuredProductModel = ProductModel(
        totalSize: _featuredProductModel!.totalSize,
        limit: _featuredProductModel!.limit,
        offset: _featuredProductModel!.offset,
        products: productsToSort,
      );
    }

    // Handle Most Viewed Products
    if (_mostViewedProductModel?.products != null &&
        _mostViewedProductModel!.products!.isNotEmpty) {
      List<Product> productsToSort =
          List<Product>.from(_mostViewedProductModel!.products!);

      applySorting(productsToSort, filterIndex);

      _mostViewedProductModel = ProductModel(
        totalSize: _mostViewedProductModel!.totalSize,
        limit: _mostViewedProductModel!.limit,
        offset: _mostViewedProductModel!.offset,
        products: productsToSort,
      );
    }

    // Handle Organic Products
    if (_organicProductModel?.products != null &&
        _organicProductModel!.products!.isNotEmpty) {
      List<Product> productsToSort =
          List<Product>.from(_organicProductModel!.products!);

      applySorting(productsToSort, filterIndex);

      _organicProductModel = ProductModel(
        totalSize: _organicProductModel!.totalSize,
        limit: _organicProductModel!.limit,
        offset: _organicProductModel!.offset,
        products: productsToSort,
      );
    }

    notifyListeners();
  }

// Helper method to apply sorting
  void applySorting(List<Product> products, int filterIndex) {
    switch (filterIndex) {
      case 0: // Low to high price
        products.sort((a, b) => ((a.price ?? 0).compareTo(b.price ?? 0)));
        break;
      case 1: // High to low price
        products.sort((a, b) => ((b.price ?? 0).compareTo(a.price ?? 0)));
        break;
      case 2: // A to Z
        products.sort((a, b) => (a.name ?? '')
            .toLowerCase()
            .compareTo((b.name ?? '').toLowerCase()));
        break;
      case 3: // Z to A
        products.sort((a, b) => (b.name ?? '')
            .toLowerCase()
            .compareTo((a.name ?? '').toLowerCase()));
        break;
    }
  }
  // void sortCategoryProduct(int filterIndex) {
  //   if (filterIndex == 0) {
  //     _productList.sort(
  //         (product1, product2) => product1.price!.compareTo(product2.price!));
  //   } else if (filterIndex == 1) {
  //     _productList.sort(
  //         (product1, product2) => product1.price!.compareTo(product2.price!));
  //     Iterable iterable = _productList.reversed;
  //     _productList = iterable.toList() as List<Product>;
  //   } else if (filterIndex == 2) {
  //     _productList.sort((product1, product2) =>
  //         product1.name!.toLowerCase().compareTo(product2.name!.toLowerCase()));
  //   } else if (filterIndex == 3) {
  //     _productList.sort((product1, product2) =>
  //         product1.name!.toLowerCase().compareTo(product2.name!.toLowerCase()));
  //     Iterable iterable = _productList.reversed;
  //     _productList = iterable.toList() as List<Product>;
  //   }
  //   notifyListeners();
  // }

  Future getProductDetailsScreen(String productID,
      {bool searchQuery = false}) async {
    final CartProvider cartProvider =
        Provider.of<CartProvider>(Get.context!, listen: false);

    _product = null;
    ApiResponseModel apiResponse = await productRepo.getProductDetails(
      productID,
      searchQuery,
    );

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      debugPrint("TESTTTTTTTTT ==> Inside product details success");
      _product = Product.fromJson(apiResponse.response!.data);
      cartProvider.initData(_product!);
    } else {
      debugPrint(
          " TESTTTTTTTTT ==> after product details error ${apiResponse.error} ${apiResponse.response}");

      ApiCheckerHelper.checkApi(apiResponse);
    }

    notifyListeners();

    debugPrint(
        " TESTTTTTTTTT ==> after product details success ${_product?.name}");
    // return _product;
  }

  void setImageSliderSelectedIndex(int selectedIndex) {
    _imageSliderIndex = selectedIndex;
    notifyListeners();
  }

  void onChangeProductFilterType(ProductFilterType type) {
    _selectedFilterType = type;
    notifyListeners();
  }

  void initializeAllSortBy(BuildContext context) {
    if (_allSortBy.isEmpty) {
      _allSortBy = [];
      _allSortBy = searchRepo.getAllSortByList();
    }
  }
}

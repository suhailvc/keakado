class OfferModel {
  int? id;
  String? itemCode;
  String? updatedDate;
  String? name;
  String? approximateWeight;
  String? slug;
  String? description;
  List<String>? image;
  double? price;
  List<dynamic>? variations;
  double? tax;
  int? status;
  String? createdAt;
  String? updatedAt;
  List<dynamic>? attributes;
  List<CategoryIds>? categoryIds;
  dynamic brandId;
  List<dynamic>? choiceOptions;
  double? discount;
  String? discountType;
  String? taxType;
  String? unit;
  int? totalStock;
  double? capacity;
  int? dailyNeeds;
  int? popularityCount;
  int? isFeatured;
  int? organic;
  int? viewCount;
  int? maximumOrderQuantity;
  String? approximateUom;
  int? wishlistCount;
  dynamic categoryDiscount;
  List<dynamic>? rating;

  OfferModel({
    this.id,
    this.itemCode,
    this.updatedDate,
    this.name,
    this.approximateWeight,
    this.slug,
    this.description,
    this.image,
    this.price,
    this.variations,
    this.tax,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.attributes,
    this.categoryIds,
    this.brandId,
    this.choiceOptions,
    this.discount,
    this.discountType,
    this.taxType,
    this.unit,
    this.totalStock,
    this.capacity,
    this.dailyNeeds,
    this.popularityCount,
    this.isFeatured,
    this.organic,
    this.viewCount,
    this.maximumOrderQuantity,
    this.approximateUom,
    this.wishlistCount,
    this.categoryDiscount,
    this.rating,
  });

  OfferModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemCode = json['ItemCode'];
    updatedDate = json['UpdatedDate'];
    name = json['name'];
    approximateWeight = json['ApproximateWeight'];
    slug = json['slug'];
    description = json['description'];
    image = json['image']?.cast<String>();
    price = json['price']?.toDouble();
    variations = json['variations'];
    tax = json['tax']?.toDouble();
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    attributes = json['attributes'];
    if (json['category_ids'] != null) {
      categoryIds = [];
      json['category_ids'].forEach((v) {
        categoryIds!.add(CategoryIds.fromJson(v));
      });
    }
    brandId = json['brand_id'];
    choiceOptions = json['choice_options'];
    discount = json['discount']?.toDouble();
    discountType = json['discount_type'];
    taxType = json['tax_type'];
    unit = json['unit'];
    totalStock = json['total_stock'];
    capacity = json['capacity']?.toDouble();
    dailyNeeds = json['daily_needs'];
    popularityCount = json['popularity_count'];
    isFeatured = json['is_featured'];
    organic = json['organic'];
    viewCount = json['view_count'];
    maximumOrderQuantity = json['maximum_order_quantity'];
    approximateUom = json['ApproximateUom'];
    wishlistCount = json['wishlist_count'];
    categoryDiscount = json['category_discount'];
    rating = json['rating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ItemCode'] = itemCode;
    data['UpdatedDate'] = updatedDate;
    data['name'] = name;
    data['ApproximateWeight'] = approximateWeight;
    data['slug'] = slug;
    data['description'] = description;
    data['image'] = image;
    data['price'] = price;
    data['variations'] = variations;
    data['tax'] = tax;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['attributes'] = attributes;
    if (categoryIds != null) {
      data['category_ids'] = categoryIds!.map((v) => v.toJson()).toList();
    }
    data['brand_id'] = brandId;
    data['choice_options'] = choiceOptions;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['tax_type'] = taxType;
    data['unit'] = unit;
    data['total_stock'] = totalStock;
    data['capacity'] = capacity;
    data['daily_needs'] = dailyNeeds;
    data['popularity_count'] = popularityCount;
    data['is_featured'] = isFeatured;
    data['organic'] = organic;
    data['view_count'] = viewCount;
    data['maximum_order_quantity'] = maximumOrderQuantity;
    data['ApproximateUom'] = approximateUom;
    data['wishlist_count'] = wishlistCount;
    data['category_discount'] = categoryDiscount;
    data['rating'] = rating;
    return data;
  }
}

class CategoryIds {
  String? id;
  int? position;

  CategoryIds({this.id, this.position});

  CategoryIds.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['position'] = position;
    return data;
  }
}

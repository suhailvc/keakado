class OrderDetailsModel {
  int? id;
  int? productId;
  int? orderId;
  double? price;
  ProductDetails? productDetails;
  double? discountOnProduct;
  String? discountType;
  int? quantity;
  int? maxQuantity;
  double? taxAmount;
  String? createdAt;
  String? updatedAt;
  String? variant;
  int? timeSlotId;
  bool? isVatInclude;
  Map<String, dynamic>? formattedVariation;
  int? isReturned; // New field
  OrderDetails? order; // New nested field for "order"
  String? remarks;
  OrderDetailsModel(
      {this.id,
      this.productId,
      this.orderId,
      this.price,
      this.productDetails,
      this.discountOnProduct,
      this.discountType,
      this.quantity,
      this.maxQuantity,
      this.taxAmount,
      this.createdAt,
      this.updatedAt,
      this.variant,
      this.timeSlotId,
      this.isVatInclude,
      this.formattedVariation,
      this.isReturned, // Initialize new field
      this.order,
      this.remarks // Initialize new nested field
      });

  OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    orderId = json['order_id'];
    price = json['price'].toDouble();
    productDetails =
        json['product_details'] != null && json['product_details'] != ""
            ? ProductDetails.fromJson(json['product_details'])
            : null;
    discountOnProduct = json['discount_on_product'].toDouble();
    discountType = json['discount_type'];
    quantity = json['quantity'];
    maxQuantity = json['quantity'];
    taxAmount = json['tax_amount'].toDouble();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isVatInclude = '${json['vat_status']}' == 'included';
    variant = json['variant'];
    timeSlotId = json['time_slot_id'] != null
        ? int.tryParse(json['time_slot_id'].toString())
        : null;
    formattedVariation = json['formatted_variation'];
    isReturned = json['is_returned'];
    order = json['order'] != null
        ? OrderDetails.fromJson(json['order'])
        : null; // Assign "order" field
    remarks = json['remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['order_id'] = orderId;
    data['price'] = price;
    if (productDetails != null) {
      data['product_details'] = productDetails!.toJson();
    }
    data['discount_on_product'] = discountOnProduct;
    data['discount_type'] = discountType;
    data['quantity'] = quantity;
    data['quantity'] = maxQuantity;
    data['tax_amount'] = taxAmount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['variant'] = variant;
    data['time_slot_id'] = timeSlotId;
    data['formatted_variation'] = formattedVariation;
    data['is_returned'] = isReturned;
    data['remarks'] = remarks;
    if (order != null) {
      data['order'] = order!.toJson(); // Include "order" field in toJson
    }
    return data;
  }
}

// Nested OrderDetails class for "order"
class OrderDetails {
  String? walletUsed;
  double? deliveryCharge;
  double? couponDiscountAmount;

  OrderDetails({
    this.walletUsed,
    this.deliveryCharge,
    this.couponDiscountAmount,
  });

  OrderDetails.fromJson(Map<String, dynamic> json) {
    walletUsed = json['wallet_used'];
    deliveryCharge = json['delivery_charge'].toDouble();
    couponDiscountAmount = json['coupon_discount_amount'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['wallet_used'] = walletUsed;
    data['delivery_charge'] = deliveryCharge;
    data['coupon_discount_amount'] = couponDiscountAmount;
    return data;
  }
}
// class OrderDetailsModel {
//   int? id;
//   int? productId;
//   int? orderId;
//   double? price;
//   ProductDetails? productDetails;
//   double? discountOnProduct;
//   String? discountType;
//   int? quantity;
//   double? taxAmount;
//   String? createdAt;
//   String? updatedAt;
//   String? variant;
//   int? timeSlotId;
//   bool? isVatInclude;
//   Map<String, dynamic>? formattedVariation;
//   int? isReturned; // New field

//   OrderDetailsModel({
//     this.id,
//     this.productId,
//     this.orderId,
//     this.price,
//     this.productDetails,
//     this.discountOnProduct,
//     this.discountType,
//     this.quantity,
//     this.taxAmount,
//     this.createdAt,
//     this.updatedAt,
//     this.variant,
//     this.timeSlotId,
//     this.isVatInclude,
//     this.formattedVariation,
//     this.isReturned, // Initialize new field
//   });

//   OrderDetailsModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     productId = json['product_id'];
//     orderId = json['order_id'];
//     price = json['price'].toDouble();
//     productDetails =
//         json['product_details'] != null && json['product_details'] != ""
//             ? ProductDetails.fromJson(json['product_details'])
//             : null;
//     discountOnProduct = json['discount_on_product'].toDouble();
//     discountType = json['discount_type'];
//     quantity = json['quantity'];
//     taxAmount = json['tax_amount'].toDouble();
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     isVatInclude = '${json['vat_status']}' == 'included';
//     variant = json['variant'];
//     timeSlotId = json['time_slot_id'] != null
//         ? int.tryParse(json['time_slot_id'].toString())
//         : null;
//     formattedVariation = json['formatted_variation'];
//     isReturned = json['is_returned']; // Add new field assignment
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['product_id'] = productId;
//     data['order_id'] = orderId;
//     data['price'] = price;
//     if (productDetails != null) {
//       data['product_details'] = productDetails!.toJson();
//     }
//     data['discount_on_product'] = discountOnProduct;
//     data['discount_type'] = discountType;
//     data['quantity'] = quantity;
//     data['tax_amount'] = taxAmount;
//     data['created_at'] = createdAt;
//     data['updated_at'] = updatedAt;
//     data['variant'] = variant;
//     data['time_slot_id'] = timeSlotId;
//     data['formatted_variation'] = formattedVariation;
//     data['is_returned'] = isReturned; // Include new field in toJson

//     return data;
//   }
// }

class ProductDetails {
  int? id;
  String? name;
  String? description;
  List<dynamic>? image;
  double? price;
  List<CategoryIds>? categoryIds;
  double? capacity;
  String? unit;
  double? tax;
  int? status;
  String? createdAt;
  String? updatedAt;
  double? discount;
  String? discountType;
  String? taxType;
  String? approximateUom; // Added field
  String? approximateWeight; // Added field

  ProductDetails(
      {this.id,
      this.name,
      this.description,
      this.image,
      this.price,
      this.categoryIds,
      this.capacity,
      this.unit,
      this.tax,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.discount,
      this.discountType,
      this.taxType,
      this.approximateUom, // Initialize added field
      this.approximateWeight // Initialize added field
      });

  ProductDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    price = json['price'].toDouble();
    if (json['category_ids'] != null) {
      categoryIds = [];
      json['category_ids'].forEach((v) {
        categoryIds!.add(CategoryIds.fromJson(v));
      });
    }
    capacity = json['capacity'].toDouble();
    unit = json['unit'];
    tax = json['tax'].toDouble();
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    discount = json['discount'].toDouble();
    discountType = json['discount_type'];
    taxType = json['tax_type'];
    approximateUom = json['ApproximateUom']; // Assign added field
    approximateWeight = json['ApproximateWeight']; // Assign added field
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image'] = image;
    data['price'] = price;
    if (categoryIds != null) {
      data['category_ids'] = categoryIds!.map((v) => v.toJson()).toList();
    }
    data['capacity'] = capacity;
    data['unit'] = unit;
    data['tax'] = tax;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['tax_type'] = taxType;
    data['ApproximateUom'] = approximateUom; // Include added field in toJson
    data['ApproximateWeight'] =
        approximateWeight; // Include added field in toJson
    return data;
  }
}

// class ProductDetails {
//   int? id;
//   String? name;
//   String? description;
//   List<dynamic>? image;
//   double? price;
//   List<CategoryIds>? categoryIds;
//   double? capacity;
//   String? unit;
//   double? tax;
//   int? status;
//   String? createdAt;
//   String? updatedAt;
//   double? discount;
//   String? discountType;
//   String? taxType;

//   ProductDetails(
//       {this.id,
//       this.name,
//       this.description,
//       this.image,
//       this.price,
//       this.categoryIds,
//       this.capacity,
//       this.unit,
//       this.tax,
//       this.status,
//       this.createdAt,
//       this.updatedAt,
//       this.discount,
//       this.discountType,
//       this.taxType});

//   ProductDetails.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     description = json['description'];
//     image = json['image'];
//     price = json['price'].toDouble();
//     if (json['category_ids'] != null) {
//       categoryIds = [];
//       json['category_ids'].forEach((v) {
//         categoryIds!.add(CategoryIds.fromJson(v));
//       });
//     }
//     capacity = json['capacity'].toDouble();
//     unit = json['unit'];
//     tax = json['tax'].toDouble();
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     discount = json['discount'].toDouble();
//     discountType = json['discount_type'];
//     taxType = json['tax_type'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['name'] = name;
//     data['description'] = description;
//     data['image'] = image;
//     data['price'] = price;
//     if (categoryIds != null) {
//       data['category_ids'] = categoryIds!.map((v) => v.toJson()).toList();
//     }
//     data['capacity'] = capacity;
//     data['unit'] = unit;
//     data['tax'] = tax;
//     data['status'] = status;
//     data['created_at'] = createdAt;
//     data['updated_at'] = updatedAt;
//     data['discount'] = discount;
//     data['discount_type'] = discountType;
//     data['tax_type'] = taxType;
//     return data;
//   }
// }

class CategoryIds {
  String? id;

  CategoryIds({this.id});

  CategoryIds.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    return data;
  }
}

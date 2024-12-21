import 'package:flutter_grocery/common/models/product_model.dart';

class CartModel {
  int? _id;
  String? _image;
  String? _name;
  double? _price;
  double? _discountedPrice;
  int? _quantity;
  Variations? _variation;
  double? _discount;
  double? _tax;
  double? _capacity;
  String? _unit;
  int? _stock;
  Product? _product;
  String? _approximateWeight;
  String? _approximateUom;
  String? _remarks; // Optional field

  CartModel(
      this._id,
      this._image,
      this._name,
      this._price,
      this._discountedPrice,
      this._quantity,
      this._variation,
      this._discount,
      this._tax,
      this._capacity,
      this._unit,
      this._stock,
      this._product,
      this._approximateWeight,
      this._approximateUom,
      [this._remarks]); // Optional in constructor (default to null)

  // Getters and Setters
  Variations? get variation => _variation;

  // ignore: unnecessary_getters_setters
  int? get quantity => _quantity;
  set quantity(int? value) {
    _quantity = value;
  }

  double? get price => _price;
  double? get capacity => _capacity;
  String? get unit => _unit;
  double? get discountedPrice => _discountedPrice;
  String? get name => _name;
  String? get image => _image;
  int? get id => _id;
  double? get discount => _discount;
  double? get tax => _tax;
  int? get stock => _stock;
  Product? get product => _product;

  String? get approximateWeight => _approximateWeight;
  String? get approximateUom => _approximateUom;
  String? get remarks => _remarks; // Getter for remarks
  set remarks(String? value) => _remarks = value; // Setter for remarks

  CartModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _image = json['image'];
    _price = json['price'];
    _discountedPrice = json['discounted_price'];
    _quantity = json['quantity'];
    _variation = json['variations'] != null
        ? Variations.fromJson(json['variations'])
        : null;
    _discount = json['discount'];
    _tax = json['tax'];
    _capacity = json['capacity'];
    _unit = json['unit'];
    _stock = json['stock'];
    _product =
        json['product'] != null ? Product.fromJson(json['product']) : null;
    _approximateWeight = json['approximate_weight'];
    _approximateUom = json['approximate_uom'];
    _remarks = json['remarks']; // Parse remarks from JSON if available
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _name;
    data['image'] = _image;
    data['price'] = _price;
    data['discounted_price'] = _discountedPrice;
    data['quantity'] = _quantity;
    if (_variation != null) {
      data['variations'] = _variation!.toJson();
    }
    data['discount'] = _discount;
    data['tax'] = _tax;
    data['capacity'] = _capacity;
    data['unit'] = _unit;
    data['stock'] = _stock;
    if (_product != null) {
      data['product'] = _product!.toJson();
    }
    data['approximate_weight'] = _approximateWeight;
    data['approximate_uom'] = _approximateUom;
    if (_remarks != null) {
      data['remarks'] = _remarks; // Add remarks to JSON only if not null
    }
    return data;
  }
}

// class CartModel {
//   int? _id;
//   String? _image;
//   String? _name;
//   double? _price;
//   double? _discountedPrice;
//   int? _quantity;
//   Variations? _variation;
//   double? _discount;
//   double? _tax;
//   double? _capacity;
//   String? _unit;
//   int? _stock;
//   Product? _product;
//   String? _approximateWeight;
//   String? _approximateUom;

//   CartModel(
//       this._id,
//       this._image,
//       this._name,
//       this._price,
//       this._discountedPrice,
//       this._quantity,
//       this._variation,
//       this._discount,
//       this._tax,
//       this._capacity,
//       this._unit,
//       this._stock,
//       this._product,
//       this._approximateWeight,
//       this._approximateUom);

//   Variations? get variation => _variation;

//   // ignore: unnecessary_getters_setters
//   int? get quantity => _quantity;
//   set quantity(int? value) {
//     _quantity = value;
//   }

//   double? get price => _price;
//   double? get capacity => _capacity;
//   String? get unit => _unit;
//   double? get discountedPrice => _discountedPrice;
//   String? get name => _name;
//   String? get image => _image;
//   int? get id => _id;
//   double? get discount => _discount;
//   double? get tax => _tax;
//   int? get stock => _stock;
//   Product? get product => _product;

//   String? get approximateWeight => _approximateWeight;
//   String? get approximateUom => _approximateUom;

//   CartModel.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _name = json['name'];
//     _image = json['image'];
//     _price = json['price'];
//     _discountedPrice = json['discounted_price'];
//     _quantity = json['quantity'];
//     _variation = json['variations'] != null
//         ? Variations.fromJson(json['variations'])
//         : null;
//     _discount = json['discount'];
//     _tax = json['tax'];
//     _capacity = json['capacity'];
//     _unit = json['unit'];
//     _stock = json['stock'];
//     _product =
//         json['product'] != null ? Product.fromJson(json['product']) : null;
//     _approximateWeight = json['approximate_weight'];
//     _approximateUom = json['approximate_uom'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = _id;
//     data['name'] = _name;
//     data['image'] = _image;
//     data['price'] = _price;
//     data['discounted_price'] = _discountedPrice;
//     data['quantity'] = _quantity;
//     if (_variation != null) {
//       data['variations'] = _variation!.toJson();
//     }
//     data['discount'] = _discount;
//     data['tax'] = _tax;
//     data['capacity'] = _capacity;
//     data['unit'] = _unit;
//     data['stock'] = _stock;
//     if (_product != null) {
//       data['product'] = _product!.toJson();
//     }
//     data['approximate_weight'] = _approximateWeight;
//     data['approximate_uom'] = _approximateUom;
//     return data;
//   }
// }
// class CartModel {
//   int? _id;
//   String? _image;
//   String? _name;
//   double? _price;
//   double? _discountedPrice;
//   int? _quantity;
//   Variations? _variation;
//   double? _discount;
//   double? _tax;
//   double? _capacity;
//   String? _unit;
//   int? _stock;
//   Product? _product;


//   CartModel(this._id, this._image, this._name, this._price, this._discountedPrice, this._quantity, this._variation, this._discount,
//        this._tax, this._capacity, this._unit, this._stock, this._product);


//   Variations? get variation => _variation;
//   // ignore: unnecessary_getters_setters
//   int? get quantity => _quantity;
//   // ignore: unnecessary_getters_setters
//   set quantity(int? value) {
//     _quantity = value;
//   }
//   double? get price => _price;
//   double? get capacity => _capacity;
//   String? get unit => _unit;
//   double? get discountedPrice => _discountedPrice;
//   String? get name => _name;
//   String? get image => _image;
//   int? get id => _id;
//   double? get discount => _discount;
//   double? get tax => _tax;
//   int? get stock => _stock;
//   Product? get product =>_product;


//   CartModel.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _name = json['name'];
//     _image = json['image'];
//     _price = json['price'];
//     _discountedPrice = json['discounted_price'];
//     _quantity = json['quantity'];
//     _variation = json['variations'] != null ? Variations.fromJson(json['variations']) : null;
//     _discount = json['discount'];
//     _tax = json['tax'];
//     _capacity = json['capacity'];
//     _unit = json['unit'];
//     _stock = json['stock'];
//     _product = json['product'] != null ? Product.fromJson(json['product']) : null;

//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = _id;
//     data['name'] = _name;
//     data['image'] = _image;
//     data['price'] = _price;
//     data['discounted_price'] = _discountedPrice;
//     data['quantity'] = _quantity;
//     if (_variation != null) {
//       data['variations'] = _variation!.toJson();
//     }
//     data['discount'] = _discount;
//     data['tax'] = _tax;
//     data['capacity'] = _capacity;
//     data['unit'] = _unit;
//     data['stock'] = _stock;
//     if (_product != null) {
//       data['product'] = _product!.toJson();
//     }
//     return data;
//   }
// }

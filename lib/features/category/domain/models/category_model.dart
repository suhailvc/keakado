class CategoryModel {
  int? _id;
  String? _name;
  String? _image;
  String? _subImage;
  String? _promotionImage; // Added nullable field
  int? _parentId;
  int? _position;
  int? _status;
  String? _createdAt;
  String? _updatedAt;

  CategoryModel({
    int? id,
    String? name,
    String? image,
    String? subImage,
    String? promotionImage, // Added nullable field to constructor
    int? parentId,
    int? position,
    int? status,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _name = name;
    _image = image;
    _subImage = subImage;
    _promotionImage = promotionImage; // Initialize field
    _parentId = parentId;
    _position = position;
    _status = status;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  int? get id => _id;
  String? get name => _name;
  String? get image => _image;
  String? get subImage => _subImage;
  String? get promotionImage => _promotionImage; // Added getter
  int? get parentId => _parentId;
  int? get position => _position;
  int? get status => _status;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  CategoryModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _image = json['image'];
    _subImage = json['subimage'];
    _promotionImage = json['promotion_image']; // Parse field from JSON
    _parentId = json['parent_id'];
    _position = json['position'];
    _status = json['status'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _name;
    data['image'] = _image;
    data['subimage'] = _subImage;
    data['promotion_image'] = _promotionImage; // Add field to JSON
    data['parent_id'] = _parentId;
    data['position'] = _position;
    data['status'] = _status;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    return data;
  }
}

// class CategoryModel {
//   int? _id;
//   String? _name;
//   String? _image;
//   String? _subImage;
//   int? _parentId;
//   int? _position;
//   int? _status;
//   String? _createdAt;
//   String? _updatedAt;

//   CategoryModel(
//       {int? id,
//       String? name,
//       String? image,
//       String? subImage,
//       int? parentId,
//       int? position,
//       int? status,
//       String? createdAt,
//       String? updatedAt}) {
//     _id = id;
//     _name = name;
//     _image = image;
//     _subImage = subImage;
//     _parentId = parentId;
//     _position = position;
//     _status = status;
//     _createdAt = createdAt;
//     _updatedAt = updatedAt;
//   }

//   int? get id => _id;
//   String? get name => _name;
//   String? get image => _image;
//   String? get subImage => _subImage;
//   int? get parentId => _parentId;
//   int? get position => _position;
//   int? get status => _status;
//   String? get createdAt => _createdAt;
//   String? get updatedAt => _updatedAt;

//   CategoryModel.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _name = json['name'];
//     _image = json['image'];
//     _subImage = json['subimage'];
//     _parentId = json['parent_id'];
//     _position = json['position'];
//     _status = json['status'];
//     _createdAt = json['created_at'];
//     _updatedAt = json['updated_at'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = _id;
//     data['name'] = _name;
//     data['image'] = _image;
//     data['subimage'] = _subImage;
//     data['parent_id'] = _parentId;
//     data['position'] = _position;
//     data['status'] = _status;
//     data['created_at'] = _createdAt;
//     data['updated_at'] = _updatedAt;
//     return data;
//   }
// }

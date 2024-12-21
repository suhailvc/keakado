import 'dart:convert';

BrandsModel brandsModelFromJson(String str) =>
    BrandsModel.fromJson(json.decode(str));

String brandsModelToJson(BrandsModel data) => json.encode(data.toJson());

class BrandsModel {
  final int currentPage;
  final List<Brands> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<Link> links;
  final dynamic nextPageUrl;
  final String path;
  final int perPage;
  final dynamic prevPageUrl;
  final int to;
  final int total;

  BrandsModel({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory BrandsModel.fromJson(Map<String, dynamic> json) => BrandsModel(
        currentPage: json["current_page"] ?? 1,
        data: json["data"] == null
            ? []
            : List<Brands>.from(json["data"].map((x) => Brands.fromJson(x))),
        firstPageUrl: json["first_page_url"] ?? "",
        from: json["from"] ?? 0,
        lastPage: json["last_page"] ?? 0,
        lastPageUrl: json["last_page_url"] ?? "",
        links: json["links"] == null
            ? []
            : List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
        nextPageUrl: json["next_page_url"] ?? "",
        path: json["path"] ?? "",
        perPage: json["per_page"] ?? 0,
        prevPageUrl: json["prev_page_url"] ?? "",
        to: json["to"] ?? 0,
        total: json["total"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": List<dynamic>.from(links.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

class Brands {
  final int id;
  final String name;
  final int status;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;

  Brands({
    required this.id,
    required this.name,
    required this.status,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Brands.fromJson(Map<String, dynamic> json) => Brands(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        status: json["status"] ?? 0,
        image: json["image"] ?? "",
        createdAt: json["created_at"] == null
            ? DateTime.now()
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? DateTime.now()
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "status": status,
        "image": image,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class Link {
  final String url;
  final String label;
  final bool active;

  Link({
    required this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"] ?? "",
        label: json["label"] ?? "",
        active: json["active"] ?? true,
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}

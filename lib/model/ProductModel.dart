import '/constants.dart';

class ProductModel {
  String categoryID;

  String description;

  String id;

  String photo;

  List<dynamic> photos;

  String price;

  String name;

  String vendorID;

  int quantity;

  bool publish;

  int calories;

  int grams;

  int proteins;

  int fats;

  bool veg;

  bool nonveg;

  String? disPrice = "0";
  bool takeaway;

  List<dynamic> size;

  List<dynamic> sizePrice;

  List<dynamic> addOnsTitle = [];

  List<dynamic> addOnsPrice = [];




  ProductModel(
      {this.categoryID = '',
      this.description = '',
      this.id = '',
      required this.photo,
      this.photos = const [],
      this.price = '',
      this.name = '',
      this.quantity = 1,
      this.vendorID = '',
      this.calories = 0,
      this.grams = 0,
      this.proteins = 0,
      this.fats = 0,
      this.publish = true,
      this.veg = true,
      this.nonveg = true,
      this.disPrice,
      this.takeaway = false,
      this.addOnsPrice = const [],
      this.addOnsTitle = const [],
      this.size = const [],
      this.sizePrice = const []});

  factory ProductModel.fromJson(Map<String, dynamic> parsedJson) {
    return new ProductModel(
      categoryID: parsedJson['categoryID'] ?? '',
      description: parsedJson['description'] ?? '',
      id: parsedJson['id'] ?? '',
      photo:
          parsedJson.containsValue('photo') ? placeholderImage : parsedJson['photo'],
      photos: parsedJson['photos'] ?? [],
      price: parsedJson['price'] ?? '',
      quantity: (parsedJson['quantity']!=null?int.parse(parsedJson['quantity'].toString()):0),
      name: parsedJson['name'] ?? '',
      vendorID: parsedJson['vendorID'] ?? '',
      publish: parsedJson['publish'] ?? true,
      calories: parsedJson['calories'] ?? 0,
      grams: parsedJson['grams'] ?? 0,
      proteins: parsedJson['proteins'] ?? 0,
      fats: parsedJson['fats'] ?? 0,
      nonveg: parsedJson['nonveg'] ?? false,
      veg: parsedJson['veg'] ?? false,
      disPrice: parsedJson['disPrice'] ?? '0',
      takeaway: parsedJson['takeawayOption'] == null
          ? false
          : parsedJson['takeawayOption'],
      size: parsedJson['size'] ?? [],
      sizePrice: parsedJson['sizePrice'] ?? [],
      addOnsPrice: parsedJson['addOnsPrice'] ?? [],
      addOnsTitle: parsedJson['addOnsTitle'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    photos.toList().removeWhere((element) => element == null);
    return {
      'categoryID': this.categoryID,
      'description': this.description,
      'id': this.id,
      'photo': this.photo,
      'photos': this.photos,
      'price': this.price,
      'name': this.name,
      'quantity': this.quantity,
      'vendorID': this.vendorID,
      'publish': this.publish,
      'calories': this.calories,
      'grams': this.grams,
      'proteins': this.proteins,
      'fats': this.fats,
      'veg': this.veg,
      'nonveg': this.nonveg,
      'takeawayOption': this.takeaway,
      'disPrice': this.disPrice,
      'size': this.size,
      'sizePrice': this.sizePrice,
      "addOnsTitle": this.addOnsTitle,
      "addOnsPrice": this.addOnsPrice
    };
  }
}

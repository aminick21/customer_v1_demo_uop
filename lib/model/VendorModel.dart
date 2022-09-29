import '../constants.dart';

class VendorModel {
  String author;

  String authorName;

  String authorProfilePic;

  String categoryID;

  String fcmToken;

  String categoryPhoto;

  String categoryTitle;

  CreatedAt createdAt;

  String description;
  
  String phonenumber;

  Map<String, dynamic> filters;

  String id;

  double latitude;

  double longitude;

  String photo;

  List<dynamic> photos;

  String location;

  String price;

  num reviewsCount;

  num reviewsSum;

  String title;

  String opentime;

  String closetime;

  bool hidephotos;

  bool reststatus;

  VendorModel(
      {this.author = '',
      this.hidephotos = false,
      this.authorName = '',
      this.authorProfilePic = '',
      this.categoryID = '',
      this.categoryPhoto = '',
      this.categoryTitle = '',
      createdAt,
      this.filters = const {},
      this.description = '',
      this.phonenumber = '',
      this.fcmToken = '',
      this.id = '',
      this.latitude = 0.1,
      this.longitude = 0.1,
      this.photo = '',
      this.photos = const [],
      this.location = '',
      this.price = '',
      this.reviewsCount = 0,
      this.reviewsSum = 0,
      this.closetime = '',
      this.opentime = '',
      this.title = '',
      this.reststatus =false})
      : this.createdAt = createdAt ?? CreatedAt(nanoseconds: 0, seconds: 0);
  // ,this.filters = filters ?? Filters(cuisine: '');

  factory VendorModel.fromJson(Map<String, dynamic> parsedJson) {
    return new VendorModel(
        author: parsedJson['author'] ?? '',
        hidephotos: parsedJson['hidephotos'] ?? false,
        authorName: parsedJson['authorName'] ?? '',
        authorProfilePic: parsedJson['authorProfilePic'] ?? '',
        categoryID: parsedJson['categoryID'] ?? '',
        categoryPhoto: parsedJson['categoryPhoto'] ?? '',
        categoryTitle: parsedJson['categoryTitle'] ?? '',
        createdAt: parsedJson.containsKey('createdAt')
            ? CreatedAt.fromJson(parsedJson['createdAt'])
            : CreatedAt(),
        description: parsedJson['description'] ?? '',
        phonenumber: parsedJson['phonenumber'] ?? '',
        filters:
            // parsedJson.containsKey('filters') ?
            parsedJson['filters'],
        // : Filters(cuisine: ''),
        id: parsedJson['id'] ?? '',
        latitude: getDoubleVal(parsedJson['latitude']),
        longitude: getDoubleVal(parsedJson['longitude']) ,
        photo: parsedJson['photo'] ?? '',
        photos: parsedJson['photos'] ?? [],
        location: parsedJson['location'] ?? '',
        fcmToken: parsedJson['fcmToken'] ?? '',
        price: parsedJson['price'] ?? '',
        reviewsCount: parsedJson['reviewsCount'] ?? 0,
        reviewsSum: parsedJson['reviewsSum'] ?? 0,
        title: parsedJson['title'] ?? '',
        closetime: parsedJson['closetime'] ?? '',
        opentime: parsedJson['opentime'] ?? '',
        reststatus: parsedJson['reststatus'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      'author': this.author,
      'hidephotos': this.hidephotos,
      'authorName': this.authorName,
      'authorProfilePic': this.authorProfilePic,
      'categoryID': this.categoryID,
      'categoryPhoto': this.categoryPhoto,
      'categoryTitle': this.categoryTitle,
      'createdAt': this.createdAt.toJson(),
      'description': this.description,
      'phonenumber': this.phonenumber,
      'filters': this.filters,
      'id': this.id,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'photo': this.photo,
      'photos': this.photos,
      'location': this.location,
      'fcmToken': this.fcmToken,
      'price': this.price,
      'reviewsCount': this.reviewsCount,
      'reviewsSum': this.reviewsSum,
      'title': this.title,
      'opentime': this.opentime,
      'closetime': this.closetime,
     'reststatus':this.reststatus
    };
  }
}

class CreatedAt {
  num nanoseconds;

  num seconds;

  CreatedAt({this.nanoseconds = 0.0, this.seconds = 0.0});

  factory CreatedAt.fromJson(Map<dynamic, dynamic> parsedJson) {
    return CreatedAt(
      nanoseconds: parsedJson['_nanoseconds'] ?? '',
      seconds: parsedJson['_seconds'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_nanoseconds': this.nanoseconds,
      '_seconds': this.seconds,
    };
  }
}

class Filters {
  String cuisine;

  String wifi;

  String breakfast;

  String dinner;

  String lunch;

  String seating;

  String vegan;

  String reservation;

  String music;

  String price;

  Filters(
      {required this.cuisine,
      this.seating = '',
      this.price = '',
      this.breakfast = '',
      this.dinner = '',
      this.lunch = '',
      this.music = '',
      this.reservation = '',
      this.vegan = '',
      this.wifi = ''});

  factory Filters.fromJson(Map<dynamic, dynamic> parsedJson) {
    return new Filters(
        cuisine: parsedJson["Cuisine"] ?? '',
        wifi: parsedJson["Free Wi-Fi"] ?? 'No',
        breakfast: parsedJson["Good for Breakfast"] ?? 'No',
        dinner: parsedJson["Good for Dinner"] ?? 'No',
        lunch: parsedJson["Good for Lunch"] ?? 'No',
        music: parsedJson["Live Music"] ?? 'No',
        price: parsedJson["Price"] ?? '\$',
        reservation: parsedJson["Takes Reservations"] ?? 'No',
        vegan: parsedJson["Vegetarian Friendly"] ?? 'No',
        seating: parsedJson["Outdoor Seating"] ?? 'No');
  }
  Map<String, dynamic> toJson() {
    return {
      'Cuisine': this.cuisine,
      'Free Wi-Fi': this.wifi,
      'Good for Breakfast': this.breakfast,
      'Good for Dinner': this.dinner,
      'Good for Lunch': this.lunch,
      'Live Music': this.music,
      'Price': this.price,
      'Takes Reservations': this.reservation,
      'Vegetarian Friendly': this.vegan,
      'Outdoor Seating': this.seating
    };
  }
}

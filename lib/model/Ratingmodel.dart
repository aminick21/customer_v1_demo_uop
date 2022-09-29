class RatingModel {
  String id;

  double rating;

  List<dynamic> photos;

  String comment;

  String orderId;

  String customerId;

  String vendorId;
  String uname;
  String profile;

  RatingModel(
      {this.id = '',
      this.comment = '',
      this.photos = const [],
      this.rating = 0.0,
      this.orderId = '',
      this.vendorId = '',
      this.customerId = '',
      this.uname = '',
      this.profile = ''});

  factory RatingModel.fromJson(Map<String, dynamic> parsedJson) {
    return RatingModel(
        comment: parsedJson['comment'] ?? '',
        photos: parsedJson['photos'] ?? '',
        rating: parsedJson['rating'] ?? '',
        id: parsedJson['Id'] ?? '',
        orderId: parsedJson['orderid'] ?? '',
        vendorId: parsedJson['VendorId'] ?? '',
        customerId: parsedJson['CustomerId'] ?? '',
        uname: parsedJson['uname'] ?? '',
        profile: parsedJson['profile'] ?? '');
  }
  Map<String, dynamic> toJson() {
    return {
      'comment': this.comment,
      'photos': this.photos,
      'rating': this.rating,
      'Id': this.id,
      'orderid': this.orderId,
      'VendorId': this.vendorId,
      'CustomerId': this.customerId,
      'uname': this.uname,
      'profile': this.profile
    };
  }
}

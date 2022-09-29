import 'package:cloud_firestore/cloud_firestore.dart';
import '/model/AddressModel.dart';
import '/model/User.dart';
import '/model/VendorModel.dart';
import '/services/localDatabase.dart';

class OrderModel {
  String authorID;

  User author;

  User? driver;

  String? driverID;

  List<CartProduct> products;

  Timestamp createdAt;

  String vendorID;

  VendorModel vendor;

  String status;

  AddressModel address;

  String id;
  double? discount;
  String? couponCode;
  String? couponId;
  // var extras = [];
  //String? extra_size;
  String? tipValue;
  String? adminCommission;
  String? adminCommissionType;
  final bool? takeAway ;
  String? deliveryCharge;

  OrderModel(
      {address,
      author,
      this.driver,
      this.driverID,
      this.authorID = '',
      createdAt,
      this.id = '',
      this.products = const [],
      this.status = '',
      this.discount = 0,
      this.couponCode = '',
      this.couponId = '',
      vendor,
        /*this.extras = const [], this.extra_size,*/ this.tipValue,this.adminCommission,this.takeAway = false,this.adminCommissionType,

        this.deliveryCharge,
        this.vendorID = ''})
      : this.address = address ?? AddressModel(),
        this.author = author ?? User(),
        this.createdAt = createdAt ?? Timestamp.now(),
        this.vendor = vendor ?? VendorModel();

  factory OrderModel.fromJson(Map<String, dynamic> parsedJson) {
    List<CartProduct> products = parsedJson.containsKey('products')
        ? List<CartProduct>.from((parsedJson['products'] as List<dynamic>)
        .map((e) => CartProduct.fromJson(e))).toList()
        : [].cast<CartProduct>();
    return OrderModel(
      address: parsedJson.containsKey('address')
          ? AddressModel.fromJson(parsedJson['address'])
          : AddressModel(),
      author: parsedJson.containsKey('author')
          ? User.fromJson(parsedJson['author'])
          : User(),
      authorID: parsedJson['authorID'] ?? '',
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
      id: parsedJson['id'] ?? '',
      products: products,
      status: parsedJson['status'] ?? '',
      discount:parsedJson['discount']!=null?parsedJson['discount']:"" ,
      couponCode: parsedJson['couponCode'] ?? '',
      couponId: parsedJson['couponId'] ?? '',
      vendor: parsedJson.containsKey('vendor')
          ? VendorModel.fromJson(parsedJson['vendor'])
          : VendorModel(),
      vendorID: parsedJson['vendorID'] ?? '',
      driver: parsedJson.containsKey('driver')
          ? User.fromJson(parsedJson['driver'])
          : null,
      driverID:
          parsedJson.containsKey('driverID') ? parsedJson['driverID'] : null,
      adminCommission: parsedJson["adminCommission"]!=null?parsedJson["adminCommission"]:"",
      adminCommissionType: parsedJson["adminCommissionType"]!=null?parsedJson["adminCommissionType"]:"",
      tipValue: parsedJson["tip_amount"]!=null?parsedJson["tip_amount"]:"",

      takeAway: parsedJson["takeAway"]!=null?parsedJson["takeAway"]:false,
      //extras: parsedJson["extras"]!=null?parsedJson["extras"]:[],
      // extra_size: parsedJson["extras_price"]!=null?parsedJson["extras_price"]:"",
      deliveryCharge:parsedJson["deliveryCharge"],



    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': this.address.toJson(),
      'author': this.author.toJson(),
      'authorID': this.authorID,
      'createdAt': this.createdAt,
      'id': this.id,
      'products': this.products.map((e) => e.toJson()).toList(),
      'status': this.status,
      'discount': this.discount,
      'couponCode': this.couponCode,
      'couponId': this.couponId,
      'vendor': this.vendor.toJson(),
      'vendorID': this.vendorID,
      'adminCommission':this.adminCommission,
      'adminCommissionType':this.adminCommissionType,
      "tip_amount":this.tipValue,
      // "extras":this.extras,
      //"extras_price":this.extra_size,
      "takeAway":this.takeAway,
      "deliveryCharge":this.deliveryCharge,

    };
  }
}
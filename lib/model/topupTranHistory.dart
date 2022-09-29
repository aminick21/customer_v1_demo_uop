import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '/constants.dart';
import '/model/AddressModel.dart';
import '/model/OrderModel.dart';

class TopupTranHistoryModel {


  String user_id;

  String payment_method;

  final amount;

  bool isTopup;

  String order_id;

  String payment_status;

  Timestamp date;

  String id;



  TopupTranHistoryModel(
      {
        required this.amount,
        required this.user_id,
        required this.order_id,
        required this.payment_method,
        required this.payment_status,
        required this.date,
        required this.id,
        required this.isTopup,
        });


  factory TopupTranHistoryModel.fromJson(Map<String, dynamic> parsedJson) {
    return TopupTranHistoryModel(
        amount: parsedJson['amount'] ?? 0.0,
        id: parsedJson['id'],
        isTopup: parsedJson['isTopUp'] == null?false:parsedJson['isTopUp'] ,
        date: parsedJson['date'] ?? '',
        order_id: parsedJson['order_id'] ?? '',
        payment_method: parsedJson['payment_method'] ?? '',
        payment_status: parsedJson['payment_status'] ?? false,
        user_id:  parsedJson['user_id'],
    );}



  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'amount' : this.amount,
      'id' : this.id,
      'date': this.date,
      'isTopUp' : this.isTopup,
      'payment_status': this.payment_status,
      'order_id': this.order_id,
      'payment_method': this.payment_method,
      'user_id': this.user_id,

    };
    return json;
  }



}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/stripeSettingData.dart';

class UserPreference{
  static late SharedPreferences _preferences;
  static Future init()async{
    _preferences = await SharedPreferences.getInstance();
  }

  static const _userId = "userId";

  static setUserId({required String userID}){
    print(userID);
    _preferences.setString(_userId, userID);
  }

  static String stripeKey = "stripeKey";

  static setStripeData(StripeSettingData stripeSettingModel)async{
    print(stripeSettingModel);
    final jsonData = jsonEncode(stripeSettingModel);
    await _preferences.setString(stripeKey, jsonData);
  }

  static Future<StripeSettingData> getStripeData()async{
    final String? jsonData = _preferences.getString(stripeKey);
    final stripeData = jsonDecode(jsonData!);
    print(stripeData);
    return StripeSettingData.fromJson(stripeData);
  }

  static const _orderId = "orderId";

  static setOrderId({required String orderId}){
    print("set OrderId");
    print(orderId);
    print("set OrderId");
    _preferences.setString(_orderId, orderId);
  }

  static const _paymentId = "paymentId";

  static setPaymentId({required String paymentId}){
    print("set PaymentId");
    print(paymentId);
    print("set PaymentId");
    _preferences.setString(_paymentId, paymentId);
  }

  static getOrderId(){
    final String? orderId = _preferences.getString(_orderId);
    return orderId != null ? orderId : "";
  }

}
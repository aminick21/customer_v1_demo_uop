

class PaypalSettingData {
  String braintree_merchantid;
  String braintree_privatekey;
  String braintree_publickey;
  String braintree_tokenizationKey;
  bool isEnabled;
  bool isLive;
  String paypalAppId;
  String paypalSecret;
  String paypalUserName;
  String paypalpassword;

  PaypalSettingData({
    this.braintree_merchantid = '',
    this.braintree_privatekey = '',
    this.braintree_publickey = '',
    this.braintree_tokenizationKey = '',
    required this.isLive,
    this.paypalAppId = '',
    this.paypalpassword = '',
    this.paypalUserName='',
    required this.isEnabled,
    required this.paypalSecret,
  });

  factory PaypalSettingData.fromJson(Map<String, dynamic> parsedJson) {
    return PaypalSettingData(
      paypalSecret: parsedJson['paypalSecret'] ?? '',
      braintree_merchantid: parsedJson['braintree_merchantid'] ?? '',
      isLive: parsedJson['isLive'],
      isEnabled: parsedJson['isEnabled'],
      braintree_privatekey: parsedJson['braintree_privatekey'] ?? '',
      braintree_publickey: parsedJson['braintree_publickey'] ?? '',
      braintree_tokenizationKey: parsedJson['braintree_tokenizationKey'] ?? '',
      paypalAppId: parsedJson['paypalAppId'] ?? '',
      paypalpassword: parsedJson['paypalpassword'] ?? '',
      paypalUserName: parsedJson['paypalUserName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paypalUserName': this.paypalUserName,
      'paypalpassword': this.paypalpassword,
      'isEnabled' : this.isEnabled,
      'isLive' : this.isLive,
      'paypalSecret': this.paypalSecret,
      'paypalAppId': this.paypalAppId,
      'braintree_tokenizationKey' : this.braintree_tokenizationKey,
      'braintree_publickey' : this.braintree_publickey,
      'braintree_privatekey' : this.braintree_privatekey,
      'braintree_merchantid' : this.braintree_merchantid,
    };
  }
}

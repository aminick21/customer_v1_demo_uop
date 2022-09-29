import 'dart:convert';
import 'package:http/http.dart' as http;
import '/constants.dart';
import '/model/stripeIntentModel.dart';


class StripeCreateIntent{
  static Future<StripeCreateIntentModel> stripeCreateIntent(
      {
        required currency,
        required amount,
        required stripesecret,
      })async{


    print("we Enter payment Settle");
    final url = "${GlobalURL}payments/stripepaymentintent";

    final response = await http.post(Uri.parse(url),
      body: {
        "currency" : currency,
        "stripesecret" : stripesecret,
        "amount" : amount,

      },
    );
    print(response.body);

    final data = jsonDecode(response.body);
    print(data);
    print("JBL sound");
    print(data['data']);

    return StripeCreateIntentModel.fromJson(data);//PayPalClientSettleModel.fromJson(data);

  }
}
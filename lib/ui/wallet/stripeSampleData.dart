import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../main.dart';

class NewStripeDemo extends StatefulWidget{
  const NewStripeDemo({Key? key}) : super(key: key);

  @override
  NewStripeDemoState createState() => NewStripeDemoState();
}

class NewStripeDemoState extends State<NewStripeDemo> {

  final String _paymentIntentClientSecret = "sk_test_51Kaaj9SE3HQdbrEJSmmdpM1yumzshT7yd7p0BMZDzuvpklOPmbOhtXrcdw66TMiG71ot1duKiq31RmJUYlz3keY7004oZKb97u";

  PaymentMethod? _paymentMethod;

  final billingDetails = BillingDetails(
    email: 'email@stripe.com',
    phone: '+48888000888',
    address: Address(
      city: 'Houston',
      country: 'US',
      line1: '1459  Circle Drive',
      line2: '',
      state: 'Texas',
      postalCode: '77063',
    ),
  ); // mocke

  @override
  void initState() {

    Stripe.publishableKey = "pk_test_51Kaaj9SE3HQdbrEJneDaJ2aqIyX1SBpYhtcMKfwchyohSZGp53F75LojfdGTNDUwsDV5p6x5BnbATcrerModlHWa00WWm5Yf5h";
    // TODO: implement initState
    super.initState();
  }
  Map<String, dynamic>? paymentIntentData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stripe Tutorial'),
      ),
      body: Center(
        child: InkWell(
          onTap: ()async{
            await makePayment();
          },
          child: Container(
            height: 50,
            width: 200,
            color: Colors.green,
            child: Center(
              child: Text('Pay' , style: TextStyle(color: Colors.white , fontSize: 20),),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      //_paymentMethod = await Stripe.instance.createPaymentMethod(PaymentMethodParams.card(billingDetails: billingDetails));

      paymentIntentData = await createPaymentIntent('2', 'USD',); //json.decode(response.body);

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              //setupIntentClientSecret: paymentIntentData!['client_secret'],
              applePay: true,
              allowsDelayedPaymentMethods: false,
              googlePay: true,
              testEnv: true,
              //billingDetails: BillingDetails(name: "",address: Address(state: "",postalCode: "",line2: "",line1: "",country: "",city: ""),email: "",phone: ""),
              style: ThemeMode.system,
              merchantCountryCode: 'US',
              merchantDisplayName: 'Gromart',
          )).then((value){
      });


      setState(() {});      ///now finally display payment sheeet
      displayPaymentSheet();
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();

      setState(() {
        paymentIntentData = null;
      });
      //     .then((newValue){
      //
      //       print("wee are in");
      //
      //
      //   print('payment intent'+paymentIntentData!['id'].toString());
      //   print('payment intent'+paymentIntentData!['client_secret'].toString());
      //   print('payment intent'+paymentIntentData!['amount'].toString());
      //   print('payment intent'+paymentIntentData.toString());
      //   //orderPlaceApi(paymentIntentData!['id'].toString());
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("paid successfully")));
      //
      //   paymentIntentData = null;
      //
      // }).onError((error, stackTrace){
      //   print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      // });


    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text("Cancelled "),
          ));
    } catch (e) {
      print('$e');
    }

  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency,) async {
    print("====");
    print(MyAppState.currentUser?.userID);
    print(MyAppState.currentUser?.firstName);
    print(MyAppState.currentUser?.shippingAddress.postalCode.length ?? "uday");
    print("====");
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
        "description" : "${MyAppState.currentUser?.userID} Wallet Topup",
        "shipping[name]" : "${MyAppState.currentUser?.firstName } ${MyAppState.currentUser?.lastName}",
        "shipping[address][line1]" : "510 Townsend St" ,
        "shipping[address][postal_code]" : "98140",
        "shipping[address][city]" : "San Francisco",
        "shipping[address][state]" : "CA" ,
        "shipping[address][country]" : "US",
        //"payment_method" : paymentMethod,
      };
      print(body);
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
            'Bearer $_paymentIntentClientSecret',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print('Create Intent response ===> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('error charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100 ;
    return a.toString();
  }

}


// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:stripe_payment/stripe_payment.dart';
// import '/model/stripeIntentModel.dart';
// import '/services/stripeIntentCreateAPI.dart';
//
//
// class StripeServiceDEMO extends StatefulWidget {
//   @override
//   _StripeServiceDEMOState createState() => new _StripeServiceDEMOState();
// }
//
// class _StripeServiceDEMOState extends State<StripeServiceDEMO> {
//   Token? _paymentToken;
//   PaymentMethod? _paymentMethod;
//   String? _error;
//
//   //this client secret is typically created by a backend system
//   //check https://stripe.com/docs/payments/payment-intents#passing-to-client
//   final String _paymentIntentClientSecret = "sk_test_51Kaaj9SE3HQdbrEJSmmdpM1yumzshT7yd7p0BMZDzuvpklOPmbOhtXrcdw66TMiG71ot1duKiq31RmJUYlz3keY7004oZKb97u";
//   PaymentIntentResult? _paymentIntent;
//   Source? _source;
//
//   ScrollController _controller = ScrollController();
//
//   final CreditCard testCard = CreditCard(
//     number: '4000002760003184',
//     expMonth: 12,
//     expYear: 26,
//     name: 'Test User',
//     cvc: '133',
//     addressLine1: 'Address 1',
//     addressLine2: 'Address 2',
//     addressCity: 'City',
//     addressState: 'CA',
//     addressZip: '1337',
//   );
//
//
//   StripeCreateIntentModel? paymentIntentData;
//
//   GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//
//   @override
//   initState() {
//     super.initState();
//
//     StripeCreateIntent.stripeCreateIntent(currency: "USD", amount: "50", stripesecret: _paymentIntentClientSecret).then((value){
//       paymentIntentData = value;
//     });
//
//     StripePayment.setOptions(StripeOptions(
//         publishableKey: "pk_test_51Kaaj9SE3HQdbrEJneDaJ2aqIyX1SBpYhtcMKfwchyohSZGp53F75LojfdGTNDUwsDV5p6x5BnbATcrerModlHWa00WWm5Yf5h",
//         merchantId: "Test",
//         androidPayMode: 'test'));
//   }
//
//   void setError(dynamic error) {
//     _scaffoldKey.currentState!
//         .showSnackBar(SnackBar(content: Text(error.toString())));
//     print("here problem");
//     print(error.toString());
//     setState(() {
//       _error = error.toString();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return new MaterialApp(
//       home: new Scaffold(
//         key: _scaffoldKey,
//         appBar: new AppBar(
//           title: new Text('Plugin example app'),
//           actions: <Widget>[
//             IconButton(
//               icon: Icon(Icons.clear),
//               onPressed: () {
//                 setState(() {
//                   _source = null;
//                   _paymentIntent = null;
//                   _paymentMethod = null;
//                   _paymentToken = null;
//                 });
//               },
//             )
//           ],
//         ),
//         body: ListView(
//           controller: _controller,
//           padding: const EdgeInsets.all(20),
//           children: <Widget>[
//             RaisedButton(
//               child: Text("Create Source"),
//               onPressed: () {
//                 StripePayment.createSourceWithParams(SourceParams(
//                   type: 'ideal',
//                   amount: 1099,
//                   currency: 'eur',
//                   returnURL: 'example://stripe-redirect',
//                 )).then((source) {
//                   _scaffoldKey.currentState!.showSnackBar(
//                       SnackBar(content: Text('Received ${source.sourceId}')));
//                   setState(() {
//                     _source = source;
//                   });
//                 }).catchError(setError);
//               },
//             ),
//             Divider(),
//             RaisedButton(
//               child: Text("Create Token with Card Form"),
//               onPressed: () {
//                 StripePayment.paymentRequestWithCardForm(
//                     CardFormPaymentRequest())
//                     .then((paymentMethod) {
//                       print("++++");
//                       print(paymentMethod.toJson().toString());
//                   _scaffoldKey.currentState!.showSnackBar(
//                       SnackBar(content: Text('Received ${paymentMethod.id}')));
//                   print(paymentMethod.created);
//                   setState(() {
//                     _paymentMethod = paymentMethod;
//                   });
//                 }).catchError(setError);
//               },
//             ),
//             RaisedButton(
//               child: Text("Create Token with Card"),
//               onPressed: () {
//
//                 StripePayment.createTokenWithCard(testCard).then((token) {
//                   _scaffoldKey.currentState!.showSnackBar(
//                       SnackBar(content: Text('Received ${token.tokenId}')));
//                   setState(() {
//                     _paymentToken = token;
//                   });
//                 }).catchError(setError);
//               },
//             ),
//             Divider(),
//             RaisedButton(
//               child: Text("Create Payment Method with Card"),
//               onPressed: () {
//                 StripePayment.createPaymentMethod(
//                   PaymentMethodRequest(
//                     card: testCard,
//                   ),
//                 ).then((paymentMethod) {
//                   _scaffoldKey.currentState!.showSnackBar(
//                       SnackBar(content: Text('Received ${paymentMethod.id}')));
//                   setState(() {
//                     print(paymentMethod.toJson().toString());
//                     _paymentMethod = paymentMethod;
//                   });
//                 }).catchError(setError);
//               },
//             ),
//             RaisedButton(
//               child: Text("Create Payment Method with existing token"),
//               onPressed: _paymentToken == null
//                   ? null
//                   : () {
//                 StripePayment.createPaymentMethod(
//                   PaymentMethodRequest(
//
//                     card: CreditCard(
//                       token: _paymentToken!.tokenId,
//                     ),
//                   ),
//                 ).then((paymentMethod) {
//                   _scaffoldKey.currentState!.showSnackBar(SnackBar(
//                       content: Text('Received ${paymentMethod.id}')));
//                   setState(() {
//                     _paymentMethod = paymentMethod;
//                   });
//                 }).catchError(setError);
//               },
//             ),
//             Divider(),
//             RaisedButton(
//               child: Text("Confirm Payment Intent"),
//               onPressed: ()async{
//                 print(paymentIntentData!.data.clientSecret);
//                 print(paymentIntentData!.data.paymentMethod);
//                 //StripePayment.setStripeAccount("acct_1Kb0ErSB73k9sekG");
//                 await StripePayment.confirmPaymentIntent(
//                   PaymentIntent(
//                     clientSecret: paymentIntentData!.data.clientSecret,//_paymentIntentClientSecret,
//                     paymentMethodId: _paymentMethod?.id,
//                   ),
//                 ).then((paymentIntent) {
//                   _scaffoldKey.currentState!.showSnackBar(SnackBar(
//                       content: Text(
//                           'Received ${paymentIntent.paymentIntentId}')));
//                   print(paymentIntent.status);
//                   setState(() {
//                     _paymentIntent = paymentIntent;
//                   });
//                 }).catchError(setError);
//               },
//             ),
//             RaisedButton(
//               child: Text(
//                 "Confirm Payment Intent with saving payment method",
//                 textAlign: TextAlign.center,
//               ),
//               onPressed:
//               _paymentMethod == null
//                   ? null
//                   : () {
//                 StripePayment.confirmPaymentIntent(
//                   PaymentIntent(
//                     clientSecret: paymentIntentData?.data.clientSecret,
//                     paymentMethodId: _paymentMethod?.id,
//                     isSavingPaymentMethod: true,
//                   ),
//                 ).then((paymentIntent) {
//                   _scaffoldKey.currentState?.showSnackBar(SnackBar(
//                       content: Text(
//                           'Received ${paymentIntent.paymentIntentId}')));
//                   setState(() {
//                     _paymentIntent = paymentIntent;
//                   });
//                 }).catchError(setError);
//               },
//             ),
//             RaisedButton(
//               child: Text("Authenticate Payment Intent"),
//               onPressed: _paymentIntentClientSecret == null
//                   ? null
//                   : () {
//                 StripePayment.authenticatePaymentIntent(
//                     clientSecret: paymentIntentData!.data.clientSecret)
//                     .then((paymentIntent) {
//                   _scaffoldKey.currentState!.showSnackBar(SnackBar(
//                       content: Text(
//                           'Received ${paymentIntent.paymentIntentId}')));
//                   setState(() {
//                     _paymentIntent = paymentIntent;
//                   });
//                 }).catchError(setError);
//               },
//             ),
//             Divider(),
//             RaisedButton(
//               child: Text("Native payment"),
//               onPressed: () {
//                 if (Platform.isIOS) {
//                   _controller.jumpTo(450);
//                 }
//                 StripePayment.paymentRequestWithNativePay(
//                   androidPayOptions: AndroidPayPaymentRequest(
//                     totalPrice: "1.20",
//                     currencyCode: "EUR",
//                   ),
//                   applePayOptions: ApplePayPaymentOptions(
//                     countryCode: 'DE',
//                     currencyCode: 'EUR',
//                     items: [
//                       ApplePayItem(
//                         label: 'Test',
//                         amount: '13',
//                       )
//                     ],
//                   ),
//                 ).then((token) {
//                   setState(() {
//                     _scaffoldKey.currentState!.showSnackBar(
//                         SnackBar(content: Text('Received ${token.tokenId}')));
//                     _paymentToken = token;
//                   });
//                 }).catchError(setError);
//               },
//             ),
//             RaisedButton(
//               child: Text("Complete Native Payment"),
//               onPressed: () {
//                 StripePayment.completeNativePayRequest().then((_) {
//                   _scaffoldKey.currentState!.showSnackBar(
//                       SnackBar(content: Text('Completed successfully')));
//                 }).catchError(setError);
//               },
//             ),
//             Divider(),
//             Text('Current source:'),
//             Text(
//               JsonEncoder.withIndent('  ').convert(_source?.toJson() ?? {}),
//               style: TextStyle(fontFamily: "Monospace"),
//             ),
//             Divider(),
//             Text('Current token:'),
//             Text(
//               JsonEncoder.withIndent('  ')
//                   .convert(_paymentToken?.toJson() ?? {}),
//               style: TextStyle(fontFamily: "Monospace"),
//             ),
//             Divider(),
//             Text('Current payment method:'),
//             Text(
//               JsonEncoder.withIndent('  ')
//                   .convert(_paymentMethod?.toJson() ?? {}),
//               style: TextStyle(fontFamily: "Monospace"),
//             ),
//             Divider(),
//             Text('Current payment intent:'),
//             Text(
//               JsonEncoder.withIndent('  ')
//                   .convert(_paymentIntent?.toJson() ?? {}),
//               style: TextStyle(fontFamily: "Monospace"),
//             ),
//             Divider(),
//             Text('Current error: $_error'),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import '/main.dart';


class StripeDemo12 extends StatefulWidget {
  const StripeDemo12({Key? key}) : super(key: key);

  @override
  _StripeDemo12State createState() => _StripeDemo12State();
}

class _StripeDemo12State extends State<StripeDemo12> {

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
              child: Text('Pay \$20' , style: TextStyle(color: Colors.white , fontSize: 20),),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {

      paymentIntentData =
      await createPaymentIntent('20', 'USD'); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              applePay: true,
              googlePay: true,
              testEnv: true,
              style: ThemeMode.dark,
              merchantCountryCode: 'US',
              merchantDisplayName: 'ANNIE')).then((value){
      });


      ///now finally display payment sheeet

      displayPaymentSheet();
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet() async {

    try {
      await Stripe.instance.presentPaymentSheet(
          parameters: PresentPaymentSheetParameters(
            clientSecret: paymentIntentData!['client_secret'],
            confirmPayment: true,
          )).then((newValue){


        print('payment intent'+paymentIntentData!['id'].toString());
        print('payment intent'+paymentIntentData!['client_secret'].toString());
        print('payment intent'+paymentIntentData!['amount'].toString());
        print('payment intent'+paymentIntentData.toString());
        //orderPlaceApi(paymentIntentData!['id'].toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("paid successfully")));

        paymentIntentData = null;

      }).onError((error, stackTrace){
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });


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

  final String _paymentIntentClientSecret = "sk_test_51Kaaj9SE3HQdbrEJSmmdpM1yumzshT7yd7p0BMZDzuvpklOPmbOhtXrcdw66TMiG71ot1duKiq31RmJUYlz3keY7004oZKb97u";


  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount('20'),
        'currency': currency,
        'payment_method_types[]': 'card',
        "description" : "${MyAppState.currentUser?.userID} Wallet Topup",
        "shipping[name]" : " ${MyAppState.currentUser?.carName}",
        "shipping[address][line1]":" ",
        "shipping[address][postal_code]":" ",
        "shipping[address][city]":" ",
        "shipping[address][state]":" ",
        "shipping[address][country]":" ",
        // 'address' : {
        //   'line1': '510 Townsend St',
        //   'postal_code': '98140',
        //   'city': 'San Francisco',
        //   'state': 'CA',
        //   'country': 'US',
        // }
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
      print('Create Intent reponse ===> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100 ;
    return a.toString();
  }

}
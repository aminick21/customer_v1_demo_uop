// import 'dart:io';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:stripe_payment/stripe_payment.dart';
// import '/constants.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import '/main.dart';
// import '/services/FirebaseHelper.dart';
// import '/services/helper.dart';
// import '/services/localDatabase.dart';
// import '/ui/checkoutScreen/CheckoutScreen.dart';

// class PaymentScreen extends StatefulWidget {
//   final double total;
//   final List<CartProduct> products;
//   final BillingAddress billingAddress;

//   const PaymentScreen(
//       {Key? key,
//       required this.total,
//       required this.products,
//       required this.billingAddress})
//       : super(key: key);

//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
//
// class StripeTransactionResponse {
//   String message;
//   bool success;
//
//   StripeTransactionResponse({required this.message, required this.success});
// }
//

// class _PaymentScreenState extends State<PaymentScreen> {
//   String selectedCardID = '';
//   late Future<bool> hasNativePay;
//   List<PaymentMethod> _cards = [];

//   @override
//   void initState() {
//     hasNativePay = StripeService.checkIfNativePayReady();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: HexColor("#F1F4F7"),
//       appBar: AppBar(
//         title: Text(
//           "Checkout",
//           style: TextStyle(fontFamily: "Poppinsb"),
//         ),
//         centerTitle: false,
//         leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: Icon(Icons.arrow_back_ios_new, color: Colors.black)),
// class StripeTransactionResponse {
//   String message;
//   bool success;
//
//   StripeTransactionResponse({required this.message, required this.success});
// }
//

// class _PaymentScreenState extends State<PaymentScreen> {
//   String selectedCardID = '';
//   late Future<bool> hasNativePay;
//   List<PaymentMethod> _cards = [];

//   @override
//   void initState() {
//     hasNativePay = StripeService.checkIfNativePayReady();
//
// class StripeService {
//   static String apiBase = 'https://api.stripe.com/v1/transfers';
//   static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
//   static String secret = 'sk_test_51JSxh2SBrhOQ6gKpCQdYHvqVf38z5YtyCnZyLz4f36JRAQPwy6wzjtxmLzO860ZXEyb8O3HqsFHxKAt0Hyz3TrCd00z2axqus4';
//   static Map<String, String> headers = {
//     'Authorization': 'Bearer ${StripeService.secret}',
//     'Content-Type': 'application/x-www-form-urlencoded'
//   };
//
//   static init() {
//     super.initState();
//     // StripePayment.setOptions(StripeOptions(
//     //     // your own stripe publishable key
//     //     publishableKey: 'pk_test_51JSxh2SBrhOQ6gKpCaW25ZzepUsITRbJrZuJWBAvRqotTspPkAbuIAlS046R0JS4YCsF1SZsbMew6NX00Imr6WeV00lpd6mjGp',
//     //     //Optional, If you want to use Apple Pay you must provide your Merchant ID
//     //     merchantId: 'Test',
//     //     //androidPayMode String (Android only) - Corresponds to WALLET_ENVIRONMENT. Can be one of: test|production.
//     //     androidPayMode: 'test'));
//   }
//
//   static Future<bool> checkIfNativePayReady() async {
//     print('started to check if native pay ready');
//     bool deviceSupportNativePay =
//         await StripePayment.deviceSupportsNativePay() ?? false;
//     bool isNativeReady = await StripePayment.canMakeNativePayPayments(
//             ['american_express', 'visa', 'maestro', 'master_card']) ??
//         false;
//     return deviceSupportNativePay && isNativeReady;
//   }
//
//   static Future<void> createPaymentMethodNative(
//       double amount,
//       List<CartProduct> products,
//       String vendor,
//       BuildContext context,
//       String currency) async {
//     print('started NATIVE payment...');
//     StripePayment.setStripeAccount('');
//     List<ApplePayItem> items = [];
//     await Future.forEach(products, (CartProduct product) {
//       items.add(ApplePayItem(
//         label: '${product.name} X${product.quantity}',
//         amount: '${double.parse(product.price) * product.quantity}',
//       ));
//     });
//
//     items.add(ApplePayItem(
//       label: vendor,
//       amount: amount.toString(),
//     ));
//     print('amount in pence/cent which will be charged = $amount');
//     //step 1: add card
//     PaymentMethod paymentMethod = PaymentMethod();
//     Token token = await StripePayment.paymentRequestWithNativePay(
//       androidPayOptions: AndroidPayPaymentRequest(
//         totalPrice: amount.toStringAsFixed(2),
//         currencyCode: currency,
//       ),
//       body:
//           // SingleChildScrollView(
//           //   child: Padding(
//           //     padding: const EdgeInsets.all(25.0),
//           //     child: Column(
//           //       children: [
//           //         Card(
//           //           child: ExpansionTile(
//           //             iconColor: Colors.black,
//           //             // trailing: Icon(Icons.keyboard_arrow_up),
//           //             expandedAlignment: Alignment.centerLeft,
//           //             title: Text(
//           //               "Payment",
//           //               style: TextStyle(
//           //                 color: Color(COLOR_PRIMARY),
//           //                 fontFamily: "Poppinss",
//           //               ),
//           //             ),
//           //             children: [
//           //               Column(
//           //                 crossAxisAlignment: CrossAxisAlignment.start,
//           //                 children: [
//           //                   GestureDetector(
//           //                     onTap: () {},
//           //                     child: Container(
//           //                       padding: EdgeInsets.all(15),
//           //                       width: double.infinity,
//           //                       child: Text(
//           //                         "Strip",
//           //                         style: TextStyle(
//           //                             color: HexColor('#333333'),
//           //                             fontFamily: "Poppinsm"),
//           //                       ),
//           //                     ),
//           //                   ),
//           //                   // SizedBox(height: 3),
//           //                   // GestureDetector(
//           //                   //   onTap: () {},
//           //                   //   child: Container(
//           //                   //     padding: EdgeInsets.all(8),
//           //                   //     width: double.infinity,
//           //                   //     child: Text(
//           //                   //       "PayPal",
//           //                   //       style: TextStyle(fontFamily: "Poppinss"),
//           //                   //     ),
//           //                   //   ),
//           //                   // ),
//           //                 ],
//           //               ),
//           //             ],
//           //           ),
//           //         ),
//           //         SizedBox(height: 15),
//           //         Card(
//           //           child: ListTile(
//           //             title: Column(
//           //               crossAxisAlignment: CrossAxisAlignment.start,
//           //               children: [
//           //                 Row(
//           //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           //                   children: [
//           //                     Text(
//           //                       "Address",
//           //                       style: TextStyle(
//           //                         color: Color(COLOR_PRIMARY),
//           //                         fontFamily: "Poppinss",
//           //                       ),
//           //                     ),
//           //                     TextButton(
//           //                         onPressed: () {
//           //                           Navigator.pop(context);
//           //                         },
//           //                         child: Text(
//           //                           "Change",
//           //                           style: TextStyle(
//           //                             color: Color(COLOR_PRIMARY),
//           //                             fontFamily: "Poppinss",
//           //                           ),
//           //                         )),
//           //                   ],
//           //                 ),
//           //                 Text(
//           //                   "${widget.billingAddress.name}, ${widget.billingAddress.line1}, ${widget.billingAddress.line2}, ${widget.billingAddress.city}-${widget.billingAddress.postalCode}, ${widget.billingAddress.country}",
//           //                   style: TextStyle(fontFamily: "Poppinsm"),
//           //                   maxLines: 1,
//           //                 ),
//           //               ],
//           //             ),
//           //           ),
//           //         ),
//           //         SizedBox(height: 15),
//           //         Card(
//           //           child: ListTile(
//           //             title: Column(
//           //               crossAxisAlignment: CrossAxisAlignment.start,
//           //               children: [
//           //                 Text(
//           //                   "Total",
//           //                   style: TextStyle(
//           //                     color: Color(COLOR_PRIMARY),
//           //                     fontFamily: "Poppinss",
//           //                   ),
//           //                 ),
//           //                 SizedBox(height: 15),
//           //                 Text(
//           //                   widget.total.toString(),
//           //                   style: TextStyle(fontFamily: "Poppinsm"),
//           //                 ),
//           //               ],
//           //             ),
//           //           ),
//           //         )
//           //       ],
//           //     ),
//           //   ),
//           // ),
//           // bottomNavigationBar: Padding(
//           //   padding: const EdgeInsets.all(15.0),
//           //   child: SizedBox(
//           //     height: 45,
//           //     child: ElevatedButton(
//           //       style: ElevatedButton.styleFrom(
//           //           primary: Color(COLOR_PRIMARY),

//           //           // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
//           //           textStyle: TextStyle(
//           //             // fontSize: 30,
//           //             letterSpacing: 0.8,
//           //             fontFamily: "Poppinsb",
//           //           )),
//           //       child: Text("PROCEED TO PAY"),
//           //       onPressed: () {
//           //         Navigator.of(context).push(
//           //           MaterialPageRoute(
//           //             builder: (BuildContext context) => Paypal(),
//           //           ),
//           //         );
//           //       },
//           //     ),
//           //   ),
//           // )

//           ////// previos
//           // Container(
//           //   height: 50,
//           //   color: Color(COLOR_PRIMARY),
//           // ),
//           ListView(
//         padding: EdgeInsets.all(16),
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(bottom: 32.0, top: 16),
//             child: Icon(
//               FontAwesomeIcons.creditCard,
//               size: 150,
//               color: Color(COLOR_PRIMARY),
//             ),
//           ),
//           Divider(),
//           // native pay item
//           FutureBuilder<bool>(
//             future: hasNativePay,
//             builder: (context, snapshot) {
//               if (snapshot.hasData &&
//                   snapshot.data != null &&
//                   snapshot.connectionState != ConnectionState.waiting) {
//                 return snapshot.data ?? false
//                     ? ListTile(
//                         tileColor: Colors.amber,
//                         contentPadding: EdgeInsets.all(0),
//                         leading: FaIcon(
//                           Platform.isIOS
//                               ? FontAwesomeIcons.ccApplePay
//                               : FontAwesomeIcons.googlePay,
//                         ),
//                         title:
//                             Text(Platform.isIOS ? 'Apple Pay' : 'Google Pay'),
//                         onTap: () async {
//                           try {
//                             await StripeService.createPaymentMethodNative(
//                                 widget.total,
//                                 widget.products,
//                                 'InstaEats',
//                                 context,
//                                 STRIPE_CURRENCY_CODE);
//                           } catch (e, s) {
//                             print('_PaymentScreenState.build $e $s');
//                           }
//                           push(
//                             context,
//                             CheckoutScreen(
//                                 total: widget.total,
//                                 paymentOption:
//                                     Platform.isIOS ? 'Apple Pay' : 'Google Pay',
//                                 products: widget.products),
//                           );
//                         })
//                     : Container();
//               } else {
//                 return Container();
//               }
//             },
//           ),

//           /// saved cards item, uncomment when hooking cards to users
//           FutureBuilder<List<PaymentMethod>>(
//               future: StripeService.getUserCards(),
//               builder: (context, snapshot) {
//                 if (snapshot.data != null && snapshot.data!.isNotEmpty) {
//                   _cards = snapshot.data!;
//                   return ListView.builder(
//                       physics: NeverScrollableScrollPhysics(),
//                       itemCount: _cards.length,
//                       shrinkWrap: true,
//                       itemBuilder: (context, index) {
//                         PaymentMethod paymentMethod = _cards[index];
//                         IconData cardIcon;
//                         switch (paymentMethod.card!.brand) {
//                           case 'amex':
//                             cardIcon = FontAwesomeIcons.ccAmex;
//                             break;
//                           case 'diners':
//                             cardIcon = FontAwesomeIcons.ccDinersClub;
//                             break;
//                           case 'discover':
//                             cardIcon = FontAwesomeIcons.ccDiscover;
//                             break;
//                           case 'jcb':
//                             cardIcon = FontAwesomeIcons.ccJcb;
//                             break;
//                           case 'mastercard':
//                             cardIcon = FontAwesomeIcons.ccMastercard;
//                             break;
//                           case 'visa':
//                             cardIcon = FontAwesomeIcons.ccVisa;
//                             break;
//                           default:
//                             cardIcon = FontAwesomeIcons.ccStripe;
//                             break;
//                         }
//                         return CheckboxListTile(
//                           contentPadding: EdgeInsets.all(0),
//                           onChanged: (value) {
//                             setState(() {
//                               selectedCardID = paymentMethod.id!;
//                             });
//                           },
//                           value: selectedCardID == paymentMethod.id,
//                           secondary: FaIcon(cardIcon),
//                           title: Text(
//                               '${paymentMethod.card!.brand} Ending in ${paymentMethod.card!.last4}'),
//                         );
//                       });
//                 } else {
//                   return Container();
//                 }
//               }),
//           ListView.builder(
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: _cards.length,
//               shrinkWrap: true,
//               itemBuilder: (context, index) {
//                 PaymentMethod paymentMethod = _cards[index];
//                 IconData cardIcon;
//                 switch (paymentMethod.card?.brand) {
//                   case 'amex':
//                     cardIcon = FontAwesomeIcons.ccAmex;
//                     break;
//                   case 'diners':
//                     cardIcon = FontAwesomeIcons.ccDinersClub;
//                     break;
//                   case 'discover':
//                     cardIcon = FontAwesomeIcons.ccDiscover;
//                     break;
//                   case 'jcb':
//                     cardIcon = FontAwesomeIcons.ccJcb;
//                     break;
//                   case 'mastercard':
//                     cardIcon = FontAwesomeIcons.ccMastercard;
//                     break;
//                   case 'visa':
//                     cardIcon = FontAwesomeIcons.ccVisa;
//                     break;
//                   default:
//                     cardIcon = FontAwesomeIcons.creditCard;
//                     break;
//                 }
//                 return CheckboxListTile(
//                   contentPadding: EdgeInsets.all(0),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedCardID = paymentMethod.id ?? '';
//                     });
//                   },
//                   value: selectedCardID == paymentMethod.id,
//                   secondary: FaIcon(cardIcon),
//                   title: Text(
//                       '${paymentMethod.card?.brand?.toUpperCase()} Ending in ${paymentMethod.card?.last4}'),
//                 );
//               }),
//           CheckboxListTile(
//             onChanged: (value) {
//               setState(() {
//                 selectedCardID = '';
//               });
//             },
//             value: selectedCardID.isEmpty,
//             contentPadding: EdgeInsets.all(0),
//             secondary: FaIcon(FontAwesomeIcons.handHoldingUsd),
//             title: Text('Cash on Delivery'.tr()),
//           ),
//           Divider(),
//           ListTile(
//             contentPadding: EdgeInsets.all(0),
//             leading: Icon(Icons.add),
//             title: Text('Add new card'),
//             onTap: () async {
//               PaymentMethod? newCard =
//                   await StripeService.addNewCard(widget.billingAddress);
//               if (newCard != null) {
//                 selectedCardID = newCard.id ?? '';
//                 _cards.add(newCard);
//                 setState(() {});
//               }
//             },
//           ),
//           SizedBox(
//             height: 24,
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.all(20),
//               primary: Color(COLOR_PRIMARY),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             onPressed: () {
//               String paymentOption = 'Cash on Delivery'.tr();
//               if (selectedCardID.isNotEmpty) {
//                 PaymentMethod? paymentMethod = _cards
//                     .where((element) => element.id == selectedCardID)
//                     .first;
//                 paymentOption =
//                     '${paymentMethod.card?.brand?.toUpperCase() ?? 'Card'} Ending in '
//                     '${paymentMethod.card?.last4 ?? 0000}';
//               }
//               push(
//                 context,
//                 CheckoutScreen(
//                     total: widget.total,
//                     paymentOption: paymentOption,
//                     products: widget.products),
//               );
//             },
//             child: Text(
//               'PROCEED'.tr(),
//               style: TextStyle(
//                   color: isDarkMode(context) ? Colors.black : Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18),
//             ),
//           ),
//         ],
//       applePayOptions: ApplePayPaymentOptions(
//         countryCode: 'US',
//         currencyCode: currency,
//         items: items,
//       ),
//     );
//     paymentMethod = await StripePayment.createPaymentMethod(
//       PaymentMethodRequest(
//         card: CreditCard(
//           token: token.tokenId,
//         ),
//       ),
//     );
//     paymentMethod != null
//         ? processPaymentAsDirectCharge(paymentMethod, context, amount, currency)
//         : showDialog(
//             context: context,
//             builder: (BuildContext context) => ShowDialogToDismiss(
//                 title: 'Error',
//                 content:
//                     'It is not possible to pay with this card. Please try again with a different card',
//                 buttonText: 'CLOSE'));
//   }
//
//   static Future<StripeTransactionResponse> payViaExistingCard(
//       {double amount = 0.0,
//       String currency = 'USD',
//       required CreditCard card}) async {
//     try {
//       var paymentMethod = await StripePayment.createPaymentMethod(
//           PaymentMethodRequest(card: card));
//       var paymentIntent =
//           await StripeService.createPaymentIntent(amount, currency);
//       var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
//           clientSecret: paymentIntent?['client_secret'],
//
//           paymentMethodId: paymentMethod.id));
//       if (response.status == 'succeeded') {
//         return StripeTransactionResponse(
//             message: 'Transaction successful', success: true);
//       } else {
//         return StripeTransactionResponse(
//             message: 'Transaction failed', success: false);
//       }
//     } on PlatformException catch (err, s) {
//       return StripeService.getPlatformExceptionErrorResult(err, s);
//     } catch (err, s) {
//       return StripeTransactionResponse(
//           message: 'Transaction failed: ${err.toString()}, $s', success: false);
//     }
//   }
//
//   static Future<PaymentMethod?> addNewCard(
//       BillingAddress billingAddress) async {
//     try {
//       var paymentMethod = await StripePayment.paymentRequestWithCardForm(
//         CardFormPaymentRequest(
//           prefilledInformation:
//               PrefilledInformation(billingAddress: billingAddress),
//         ),
//       );
//       return paymentMethod;
//     } catch (e, s) {
//       print('StripeService.addNewCard $e $s');
//       return null;
//     }
//   }
//
//   static Future<StripeTransactionResponse> payWithNewCard(
//       {double amount = 0.0,
//       String currency = 'USD',
//       BillingAddress? billingAddress,
//       PaymentMethod? paymentMethod}) async {
//     try {
//       if (paymentMethod != null) {
//         saveCardToStripe(paymentMethod);
//         print('StripeService.payWithNewCard saveCardToStripe');
//         if (MyAppState.currentUser!.stripeCustomer == null ||
//             MyAppState.currentUser!.stripeCustomer!.isEmpty) {
//           print('StripeService.payWithNewCard createStripeCustomerWithCard');
//           //create new stripe customer and attach card id to this customer
//           createStripeCustomerWithCard(billingAddress!, paymentMethod);
//         } else {
//           print('StripeService.payWithNewCard attachCardToCustomer');
//           //add payment card to existing customer
//           attachCardToCustomer(paymentMethod);
//         }
//       }
//
//       var paymentIntent =
//           await StripeService.createPaymentIntent(amount, currency);
//       var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
//           clientSecret: paymentIntent?['client_secret'],
//           paymentMethodId: paymentMethod?.id));
//       if (response.status == 'succeeded') {
//         return StripeTransactionResponse(
//             message: 'Transaction successful', success: true);
//       } else {
//         return StripeTransactionResponse(
//             message: 'Transaction failed', success: false);
//       }
//     } on PlatformException catch (err, s) {
//       return StripeService.getPlatformExceptionErrorResult(err, s);
//     } catch (err, s) {
//       return StripeTransactionResponse(
//           message: 'Transaction failed: ${err.toString()} $s', success: false);
//     }
//   }
//
//   static Future<void> processPaymentAsDirectCharge(PaymentMethod paymentMethod,
//       BuildContext context, double amount, String currency) async {
//     showProgress(context, 'Processing Payment...', false);
//     //step 2: request to create PaymentIntent, attempt to confirm the payment & return PaymentIntent
//     final http.Response response = await http.post(Uri.parse(
//         '$apiBase?amount=$amount&currency=$currency&paym=${paymentMethod.id}'));
//     print('Now i decode');
//     if (response.body != null && response.body != 'error') {
//       final paymentIntentX = jsonDecode(response.body);
//       final status = paymentIntentX['paymentIntent']['status'];
//       final strAccount = paymentIntentX['stripeAccount'];
//       //step 3: check if payment was succesfully confirmed
//       if (status == 'succeeded') {
//         //payment was confirmed by the server without need for futher authentification
//         StripePayment.completeNativePayRequest();
//         // setState(() {
//         //   text =
//         //   'Payment completed. ${paymentIntentX['paymentIntent']['amount'].toString()}p succesfully charged';
//         //   showSpinner = false;
//         // });
//         hideProgress();
//       } else {
//         //step 4: there is a need to authenticate
//         StripePayment.setStripeAccount(strAccount);
//         await StripePayment.confirmPaymentIntent(PaymentIntent(
//                 paymentMethodId: paymentIntentX['paymentIntent']
//                     ['payment_method'],
//                 clientSecret: paymentIntentX['paymentIntent']['client_secret']))
//             .then(
//           (PaymentIntentResult paymentIntentResult) async {
//             //This code will be executed if the authentication is successful
//             //step 5: request the server to confirm the payment with
//             final statusFinal = paymentIntentResult.status;
//             if (statusFinal == 'succeeded') {
//               StripePayment.completeNativePayRequest();
//               // setState(() {
//               //   showSpinner = false;
//               // });
//               hideProgress();
//             } else if (statusFinal == 'processing') {
//               StripePayment.cancelNativePayRequest();
//               // setState(() {
//               //   showSpinner = false;
//               // });
//               hideProgress();
//               showDialog(
//                   context: context,
//                   builder: (BuildContext context) => ShowDialogToDismiss(
//                       title: 'Warning',
//                       content:
//                           'The payment is still in \'processing\' state. This is unusual. Please contact us',
//                       buttonText: 'CLOSE'));
//             } else {
//               StripePayment.cancelNativePayRequest();
//               // setState(() {
//               //   showSpinner = false;
//               // });
//               hideProgress();
//               showDialog(
//                   context: context,
//                   builder: (BuildContext context) => ShowDialogToDismiss(
//                       title: 'Error',
//                       content:
//                           'There was an error to confirm the payment. Details: $statusFinal',
//                       buttonText: 'CLOSE'));
//             }
//           },
//           //If Authentication fails, a PlatformException will be raised which can be handled here
//         ).catchError((e) {
//           StripePayment.cancelNativePayRequest();
//           hideProgress();
//           showDialog(
//               context: context,
//               builder: (BuildContext context) => ShowDialogToDismiss(
//                   title: 'Error',
//                   content:
//                       'There was an error to confirm the payment. Please try again with another card',
//                   buttonText: 'CLOSE'));
//         });
//       }
//     } else {
//       //case A
//       StripePayment.cancelNativePayRequest();
//       // setState(() {
//       //   showSpinner = false;
//       // });
//       hideProgress();
//       showDialog(
//           context: context,
//           builder: (BuildContext context) => ShowDialogToDismiss(
//               title: 'Error',
//               content:
//                   'There was an error in creating the payment. Please try again with another card',
//               buttonText: 'CLOSE'));
//     }
//   }
//
//   static getPlatformExceptionErrorResult(err, StackTrace s) {
//     String message = 'Something went wrong, $s';
//     if (err.code == 'cancelled') {
//       message = 'Transaction cancelled, $s';
//     }
//
//     return StripeTransactionResponse(message: message, success: false);
//   }
//
//   static Future<Map<String, dynamic>?> createPaymentIntent(
//       double amount, String currency) async {
//     try {
//       Map<String, dynamic> body = {
//         'amount': amount.toString(),
//         'currency': currency,
//         'confirmation_method': 'automatic',
//                 'confirm': 'true',
//         'application_fee_amount':'10',
//         'stripeAccount':'acct_1JzF8mSBbdmCmSXS',
//         'payment_method_types[]': 'card'
//       };
//       var response = await http.post(Uri.parse(StripeService.paymentApiUrl),
//           body: body, headers: StripeService.headers);
//       return jsonDecode(response.body);
//     } catch (err) {
//       print('err charging user: ${err.toString()}');
//     }
//     return null;
//   }
//
//   static void saveCardToStripe(PaymentMethod paymentMethod) async {
//     print('StripeService.saveCardToStripe saving  new card');
//     Map<String, Object> card = {
//       'number': paymentMethod.card?.number ?? '',
//       'exp_month': paymentMethod.card?.expMonth ?? '',
//       'exp_year': paymentMethod.card?.expYear ?? '',
//       'cvc': paymentMethod.card?.cvc ?? ''
//     };
//     http.Response response = await http.post(
//         Uri.parse('$apiBase/payment_methods'),
//         body: {'type': paymentMethod.type, 'card': jsonEncode(card)});
//     print('StripeService.saveCardToStripe ${response.statusCode}');
//   }
//
//   static void createStripeCustomerWithCard(
//       BillingAddress billingAddress, PaymentMethod paymentMethod) async {
//     http.Response response =
//         await http.post(Uri.parse('$apiBase/customers'), body: {
//       'email': MyAppState.currentUser!.email,
//       'address': jsonEncode(billingAddress),
//       'payment_method': paymentMethod.id
//     });
//     print('StripeService.createStripeCustomerWithCard ${response.statusCode}');
//     MyAppState.currentUser!.stripeCustomer = jsonDecode(response.body)['id'];
//     await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
//   }
//
//   static void attachCardToCustomer(PaymentMethod paymentMethod) async {
//     print('StripeService.attachCardToCustomer');
//     http.Response response = await http.post(
//         Uri.parse('$apiBase/payment_methods/${paymentMethod.id}/attach'),
//         body: {'email': MyAppState.currentUser!.email});
//     print('StripeService.createStripeCustomerWithCard ${response.statusCode}');
//   }
//
//   static Future<List<PaymentMethod>> getUserCards() async {
//     var params = {
//       'customer': MyAppState.currentUser!.stripeCustomer,
//       'type': 'card',
//     };
//
//     Uri uri = Uri.parse('$apiBase/payment_methods');
//     Uri newUri = uri.replace(queryParameters: params);
//     http.Response response = await http.get(newUri);
//     print('StripeService.getUserCards ${response.statusCode}');
//
//     return (jsonDecode(response.body)['data'] as List<dynamic>)
//         .map((e) => PaymentMethod.fromJson(e))
//         .toList();
//   }
// }

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe1;
import 'package:shared_preferences/shared_preferences.dart';
import '/constants.dart';
import '/main.dart';
import '/model/CodModel.dart';
import '/model/createRazorPayOrderModel.dart';
import '/model/razorpayKeyModel.dart';
import '/model/stripeSettingData.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';
import '/services/localDatabase.dart';
import '/ui/checkoutScreen/CheckoutScreen.dart';
import '/userPrefrence.dart';
import 'package:http/http.dart' as http;
import '../../model/OrderModel.dart';
import '../../model/PayPalCurrencyCodeErrorModel.dart';
import '../../model/RazorPayFailedModel.dart';
import '../../model/StripePayFailedModel.dart';
import '../../model/User.dart';
import '../../model/VendorModel.dart';
import '../../model/getPaytmTxtToken.dart';
import '../../model/paypalClientToken.dart';
import '../../model/paypalErrorSettle.dart';
import '../../model/paypalPaymentSettle.dart';
import '../../model/paypalSettingData.dart';
import '../../model/paytmSettingData.dart';
import '../placeOrderScreen/PlaceOrderScreen.dart';

class PaymentScreen extends StatefulWidget {
  final double total;
  final double? discount;
  final String? couponCode;
  final String? couponId;
  final List<CartProduct> products;

  final List<String>? extra_addons;
  final String? extra_size;
  final String? tipValue;
  final bool? take_away;
  final String? deliveryCharge;

  const PaymentScreen({
    Key? key,
    required this.total,
    this.discount,
    this.couponCode,
    this.couponId,
    required this.products,
    this.extra_addons,
    this.extra_size,
    this.tipValue,
    this.take_away,
    this.deliveryCharge,
  }) : super(key: key);

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  String selectedCardID = '';
  final fireStoreUtils = FireStoreUtils();
  late Future<bool> hasNativePay;
  //List<PaymentMethod> _cards = [];
  late Future<CodModel?> futurecod;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? userQuery;

  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  GlobalKey<ScaffoldState> _globalKey =  GlobalKey<ScaffoldState>();

  String paymentOption = 'Pay Via Wallet'.tr();

  StripeSettingData? stripeData;
  PaytmSettingData? paytmSettingData;
  PaypalSettingData? paypalSettingData;
  bool walletBalanceError = false;

  bool isStaging = true;
  String callbackUrl =
      "http://162.241.125.167/~foodie/payments/paytmpaymentcallback?ORDER_ID=";
  bool restrictAppInvoke = false;
  bool enableAssist = true;
  String result = "";

  late Map<String, dynamic>? adminCommission;
  String? adminCommissionValue = "",addminCommissionType="";
  bool? isEnableAdminCommission = false;

  getPaymentSettingData() async {
    await FireStoreUtils.createPaymentId();
    userQuery = fireStore
        .collection(USERS)
        .doc(MyAppState.currentUser!.userID)
        .snapshots();
    await UserPreference.getStripeData().then((value) {
      setState(() {
        stripeData = value;
        print('kommer');
        print(stripeData!.isEnabled);
        stripe1.Stripe.publishableKey = stripeData!.clientpublishableKey;
      });
    });
  }

  showAlert(BuildContext context123, {required String response, required Color colors}) {
    return ScaffoldMessenger.of(context123).showSnackBar(SnackBar(
      content: Text(response),
      backgroundColor: colors,
    ));
  }

  @override
  void initState() {
    getPaymentSettingData();
    FireStoreUtils.createOrder();
    futurecod = fireStoreUtils.getCod();

    fireStoreUtils.getAdminCommission().then((value) {
      if (value != null) {
        setState(() {
          adminCommission = value;
          adminCommissionValue = adminCommission!["adminCommission"].toString();
          addminCommissionType= adminCommission!["adminCommissionType"].toString();
          isEnableAdminCommission =adminCommission!["isAdminCommission"];
          print(adminCommission!["adminCommission"].toString() + "===____");
          print(adminCommission!["isAdminCommission"].toString() + "===____"+isEnableAdminCommission.toString());
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: false,
      key: _globalKey,
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 5.0,
            ),
            child: Icon(
              FontAwesomeIcons.moneyCheck,
              size: 60,
              color: Color(COLOR_PRIMARY),
            ),
          ),

          // native pay item
          // FutureBuilder<bool>(
          //   future: hasNativePay,
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData &&
          //         snapshot.data != null &&
          //         snapshot.connectionState != ConnectionState.waiting) {
          //       return snapshot.data ?? false
          //           ? ListTile(
          //           contentPadding: EdgeInsets.all(0),
          //           leading: FaIcon(
          //             Platform.isIOS
          //                 ? FontAwesomeIcons.ccApplePay
          //                 : FontAwesomeIcons.googlePay,
          //           ),
          //           title:
          //           Text(Platform.isIOS ? 'Apple Pay' : 'Google Pay'),
          //           onTap: () async {
          //             try {
          //               await StripeService.createPaymentMethodNative(
          //                   widget.total,
          //                   widget.products,
          //                   'InstaEats',
          //                   context,
          //                   STRIPE_CURRENCY_CODE);
          //             } catch (e, s) {
          //               print('_PaymentScreenState.build $e $s');
          //             }
          //             push(
          //               context,
          //               CheckoutScreen(
          //                   total: widget.total,
          //                   paymentOption:
          //                   Platform.isIOS ? 'Apple Pay' : 'Google Pay',
          //                   products: widget.products,
          //                   couponCode: widget.couponCode!,
          //                   couponId: widget.couponId!,
          //                   discount: widget.discount!),
          //             );
          //           })
          //           : Container();
          //     } else {
          //       return Container();
          //     }
          //   },
          // ),

          // FutureBuilder<List<PaymentMethod>>(
          //     future: StripeService.getUserCards(),
          //     builder: (context, snapshot) {
          //       if (snapshot.data != null && snapshot.data.isNotEmpty) {
          //         _cards = snapshot.data;
          //         return ListView.builder(
          //             physics: NeverScrollableScrollPhysics(),
          //             itemCount: _cards.length,
          //             shrinkWrap: true,
          //             itemBuilder: (context, index) {
          //               PaymentMethod paymentMethod = _cards[index];
          //               IconData cardIcon;
          //               switch (paymentMethod.card.brand) {
          //                 case 'amex':
          //                   cardIcon = FontAwesomeIcons.ccAmex;
          //                   break;
          //                 case 'diners':
          //                   cardIcon = FontAwesomeIcons.ccDinersClub;
          //                   break;
          //                 case 'discover':
          //                   cardIcon = FontAwesomeIcons.ccDiscover;
          //                   break;
          //                 case 'jcb':
          //                   cardIcon = FontAwesomeIcons.ccJcb;
          //                   break;
          //                 case 'mastercard':
          //                   cardIcon = FontAwesomeIcons.ccMastercard;
          //                   break;
          //                 case 'visa':
          //                   cardIcon = FontAwesomeIcons.ccVisa;
          //                   break;
          //                 default:
          //                   cardIcon = FontAwesomeIcons.ccStripe;
          //                   break;
          //               }
          //               return CheckboxListTile(
          //                 contentPadding: EdgeInsets.all(0),
          //                 onChanged: (value) {
          //                   setState(() {
          //                     selectedCardID = paymentMethod.id;
          //                   });
          //                 },
          //                 value: selectedCardID == paymentMethod.id,
          //                 secondary: FaIcon(cardIcon),
          //                 title: Text(
          //                     '${paymentMethod.card.brand} Ending in ${paymentMethod.card.last4}'),
          //               );
          //             });
          //       } else {
          //         return Container();
          //       }
          //     }),
          // ListView.builder(
          //     physics: NeverScrollableScrollPhysics(),
          //     itemCount: _cards.length,
          //     shrinkWrap: true,
          //     itemBuilder: (context, index) {
          //       PaymentMethod paymentMethod = _cards[index];
          //       IconData cardIcon;
          //       switch (paymentMethod.card?.brand) {
          //         case 'amex':
          //           cardIcon = FontAwesomeIcons.ccAmex;
          //           break;
          //         case 'diners':
          //           cardIcon = FontAwesomeIcons.ccDinersClub;
          //           break;
          //         case 'discover':
          //           cardIcon = FontAwesomeIcons.ccDiscover;
          //           break;
          //         case 'jcb':
          //           cardIcon = FontAwesomeIcons.ccJcb;
          //           break;
          //         case 'mastercard':
          //           cardIcon = FontAwesomeIcons.ccMastercard;
          //           break;
          //         case 'visa':
          //           cardIcon = FontAwesomeIcons.ccVisa;
          //           break;
          //         default:
          //           cardIcon = FontAwesomeIcons.creditCard;
          //           break;
          //       }
          //       return Column(
          //         children: [
          //           CheckboxListTile(
          //             contentPadding: EdgeInsets.all(0),
          //             onChanged: (value) {
          //               setState(() {
          //                 selectedCardID = paymentMethod.id ?? '';
          //                 razorPay = false; //razorPay ? false : true;
          //                 codPay = false;
          //                 payTm = false;
          //                 pay = false;
          //                 paymentOption = "Pay ${paymentMethod.card!.name}";
          //               });
          //             },
          //             value: selectedCardID == paymentMethod.id,
          //             secondary: FaIcon(cardIcon),
          //             title: Text(
          //                 '${paymentMethod.card?.brand
          //                     ?.toUpperCase()} Ending in ${paymentMethod.card
          //                     ?.last4}'),
          //           ),
          //           Divider(),
          //         ],
          //       );
          //     }),

          // Visibility(
          //   visible: UserPreference.getWalletData() ?? false,
          //   child: Column(
          //     children: [
          //       Divider(),
          //       StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          //           stream: userQuery,
          //           builder: (context,
          //               AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
          //                   asyncSnapshot) {
          //             if (asyncSnapshot.hasError) {
          //               return Text(
          //                 "error",
          //                 style: TextStyle(
          //                     color: Colors.white,
          //                     fontWeight: FontWeight.bold,
          //                     fontSize: 16),
          //               );
          //             }
          //             if (asyncSnapshot.connectionState ==
          //                 ConnectionState.waiting) {
          //               return Center(
          //                   child: SizedBox(
          //                       height: 20,
          //                       width: 20,
          //                       child: CircularProgressIndicator(
          //                         strokeWidth: 0.8,
          //                         color: Colors.white,
          //                         backgroundColor: Colors.transparent,
          //                       )));
          //             }
          //             if(asyncSnapshot==null || asyncSnapshot.data==null){
          //               return Container();
          //             }
          //             User userData = User.fromJson(asyncSnapshot.data!.data()!);
          //
          //             walletBalanceError = userData.wallet_amount < widget.total ? true : false;
          //             return Column(
          //               children: [
          //                 CheckboxListTile(
          //                   onChanged: (bool? value) {
          //                     setState(() {
          //                       if(!walletBalanceError){
          //                         wallet = true;
          //                       }else{
          //                         wallet=false;
          //                       }
          //
          //                       razorPay = false; //razorPay ? false : true;
          //                       codPay = false;
          //                       payTm = false;
          //                       pay = false;
          //                       paypal = false;
          //                       stripe = false;
          //                       selectedCardID = '';
          //                       paymentOption = "Pay Online Via Wallet";
          //                     });
          //                   },
          //                   value: wallet,
          //                   contentPadding: EdgeInsets.all(0),
          //                   secondary: FaIcon(FontAwesomeIcons.wallet),
          //                   title: Row(
          //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                     children: [
          //                       Text('Wallet'.tr()),
          //                       Column(
          //                         children: [
          //                           Text(
          //                             currencyData!.symbol +
          //                                 double.parse(
          //                                         userData.wallet_amount.toString())
          //                                     .toStringAsFixed(decimal),
          //                             style: TextStyle(
          //                                 color: walletBalanceError
          //                                     ? Colors.red
          //                                     : Colors.green,
          //                                 fontWeight: FontWeight.w600,
          //                                 fontSize: 18),
          //                           ),
          //                         ],
          //                       )
          //                     ],
          //                   ),
          //                 ),
          //                 Row(
          //                   mainAxisAlignment: MainAxisAlignment.end,
          //                   children: [
          //                     Visibility(
          //                       child: Padding(
          //                         padding: const EdgeInsets.only(right: 0.0),
          //                         child: walletBalanceError?Text(
          //                           'Your wallet doesn\'t have sufficient balance',
          //                           style: TextStyle(fontSize: 14, color: Colors.red),
          //                         ):Text(
          //                           'Sufficient Balance',
          //                           style: TextStyle(fontSize: 14, color: Colors.green),
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ],
          //             );
          //           }),
          //     ],
          //   ),
          // ),

          Visibility(
            visible: true,
            child: Column(
              children: [
                Divider(),
                FutureBuilder<CodModel?>(
                    future: futurecod,
                    // initialData: [],
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Center(
                          child: CircularProgressIndicator.adaptive(
                            valueColor:
                                AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                          ),
                        );
                      if (snapshot.hasData) {
                        return snapshot.data!.cod == true
                            ? CheckboxListTile(
                                onChanged: (bool? value) {
                                  setState(() {
                                    razorPay = false;
                                    wallet = false;
                                    codPay = true; //codPay ? false : true;
                                    selectedCardID = '';
                                    payTm = false;
                                    pay = false;
                                    paypal = false;
                                    stripe = false;
                                    paymentOption = 'Cash on Delivery'.tr();
                                  });
                                },
                                value: codPay,
                                contentPadding: EdgeInsets.all(0),
                                secondary:
                                    FaIcon(FontAwesomeIcons.handHoldingUsd),
                                title: Text('Cash on Delivery'.tr()),
                              )
                            : Center();
                      }
                      return Center();
                    }),
              ],
            ),
          ),


          Visibility(
            visible: (stripeData==null)?false:stripeData!.isEnabled,
            child: Column(
              children: [
                Divider(),
                CheckboxListTile(
                  onChanged: (bool? value) {
                    setState(() {
                      stripe = true;
                      wallet = false;
                      razorPay = false; //razorPay ? false : true;
                      codPay = false;
                      payTm = false;
                      pay = false;
                      paypal = false;
                      selectedCardID = '';
                      paymentOption = "Pay Online Via Stripe";
                    });
                  },
                  value: stripe,
                  contentPadding: EdgeInsets.all(0),
                  secondary: FaIcon(FontAwesomeIcons.stripe),
                  title: Text('Stripe'.tr()),
                ),
              ],
            ),
          ),

          Visibility(
            visible:(paytmSettingData==null)?false: paytmSettingData!.isEnabled,
            child: Column(
              children: [
                Divider(),
                CheckboxListTile(
                  onChanged: (bool? value) {
                    setState(() {
                      razorPay = false;
                      wallet = false; //razorPay ? false : true;
                      codPay = false;
                      payTm = true;
                      pay = false;
                      paypal = false;
                      stripe = false;
                      selectedCardID = '';
                      paymentOption = "Pay Online Via PayTm";
                    });
                  },
                  value: payTm,
                  contentPadding: EdgeInsets.all(0),
                  secondary: FaIcon(FontAwesomeIcons.alipay),
                  title: Text('PayTm'.tr()),
                ),
              ],
            ),
          ),

          Visibility(
            visible:(paypalSettingData==null)?false: paypalSettingData!.isEnabled,
            child: Column(
              children: [
                Divider(),
                CheckboxListTile(
                  onChanged: (bool? value) {
                    setState(() {
                      paypal = true;
                      wallet = false;
                      razorPay = false;
                      codPay = false;
                      payTm = false;
                      pay = false;
                      stripe = false;
                      selectedCardID = '';
                      paymentOption = "Pay Online PayPal";
                    });
                  },
                  value: paypal,
                  contentPadding: EdgeInsets.all(0),
                  secondary: FaIcon(FontAwesomeIcons.paypal),
                  title: Text(' Paypal'.tr()),
                ),
              ],
            ),
          ),

          Visibility(
            visible: false,
            child: Column(
              children: [
                Divider(),
                CheckboxListTile(
                  onChanged: (bool? value) {
                    setState(() {
                      razorPay = false; //razorPay ? false : true;
                      codPay = false;
                      payTm = false;
                      wallet = false;
                      pay = true;
                      paypal = false;
                      stripe = false;
                      selectedCardID = '';
                      paymentOption = "Pay Online Via Pay";
                    });
                  },
                  value: pay,
                  contentPadding: EdgeInsets.all(0),
                  secondary: FaIcon(FontAwesomeIcons.googlePay),
                  title: Text(' Pay'.tr()),
                ),
              ],
            ),
          ),

          Divider(),
          // ListTile(
          //   contentPadding: EdgeInsets.all(0),
          //   leading: Icon(Icons.add),
          //   title: Text('Add new card'.tr()),
          //   onTap: () async {
          //
          //     //PaymentMethod? newCard =
          //     await StripeService.addNewCard(widget.billingAddress);
          //
          //     if (newCard != null) {
          //       selectedCardID = newCard.id ?? '';
          //       _cards.add(newCard);
          //       setState(() {});
          //     }
          //   },
          // ),
          SizedBox(
            height: 24,
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              primary: Color(COLOR_PRIMARY),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // paymentOption = razorPay ? "Pay Online Via RazorPay"
              //     : 'Cash on Delivery141';

              // if (selectedCardID.isNotEmpty) {
              //   PaymentMethod? paymentMethod = _cards
              //       .where((element) => element.id == selectedCardID)
              //       .first;
              //   paymentOption =
              //   '${paymentMethod.card?.brand?.toUpperCase() ??
              //       'Card'} Ending in '
              //       '${paymentMethod.card?.last4 ?? 0000}';
              // }


              if (stripe) {
                showLoadingAlert();
                stripeMakePayment(amount: widget.total.toString());
              }
              else if (codPay) {
                print(DateTime.now().millisecondsSinceEpoch.toString());
                if(widget.take_away!){
                  placeOrder();
                }else {
                  push(
                    context,
                    CheckoutScreen(
                        isPaymentDone: false,
                        total: widget.total,
                        discount: widget.discount!,
                        couponCode: widget.couponCode!,
                        couponId: widget.couponId!,
                        paymentOption: paymentOption,
                        deliveryCharge: widget.deliveryCharge,
                        tipValue: widget.tipValue,
                        products: widget.products,
                        take_away: widget.take_away),
                  );
                }


              }else{
                final SnackBar snackBar = SnackBar(
                  content: Text(
                    "Select Payment Method",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Color(COLOR_PRIMARY),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            child: Text(
              'PROCEED'.tr(),
              style: TextStyle(
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  bool wallet = false;
  bool razorPay = false;
  bool codPay = false;
  bool payTm = false;
  bool pay = false;
  bool stripe = false;
  bool paypal = false;

  showLoadingAlert(){
    return showDialog<void>(
      context: _globalKey.currentContext!,
      useRootNavigator: true,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressIndicator(),
              const Text('Please wait!!'),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                SizedBox(height: 15,),
                Text('Please wait!! while completing Transaction',
                  style: TextStyle(
                      fontSize: 16
                  ),
                ),
                SizedBox(height: 15,),
              ],
            ),
          ),
        );
      },
    );
  }
  ///Stripe payment function
  Map<String, dynamic>? paymentIntentData;

  Future<void> stripeMakePayment({required String amount}) async {

    try {
      paymentIntentData = await createStripeIntent(amount);
      if(paymentIntentData!.containsKey("error")){
        Navigator.pop(context);
        showAlert(_globalKey.currentContext!, response: "Something went wrong, please contact admin.", colors: Colors.red);
      }else{

        await stripe1.Stripe.instance
            .initPaymentSheet(
            paymentSheetParameters: stripe1.SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              applePay: true,
              allowsDelayedPaymentMethods: false,
              googlePay: true,
              testEnv: false, //!stripeData!.isSandboxEnabled,
              style: ThemeMode.system,
              merchantCountryCode: 'US',
              currencyCode: currencyData!.code,
              primaryButtonColor: Colors.deepOrange,
              merchantDisplayName: 'Foodies',
            ))
            .then((value) {});
        setState(() {});
        displayStripePaymentSheet(amount: amount);
      }

    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  // displayStripePaymentSheet({required amount}) async {
  //   try {
  //     await stripe1.Stripe.instance.presentPaymentSheet().then((value) {
  //       print("wee are in");
  //       push(
  //         context,
  //         CheckoutScreen(
  //             total: widget.total,
  //             discount: widget.discount!,
  //             couponCode: widget.couponCode!,
  //             couponId: widget.couponId!,
  //             paymentOption: paymentOption,
  //             products: widget.products, isPaymentDone: true,),
  //       );
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text("paid successfully"),
  //         duration: Duration(seconds: 8),
  //         backgroundColor: Colors.green,
  //       ));
  //       paymentIntentData = null;
  //     }).onError((error, stackTrace) {
  //       print('Exception/DISPLAYPAYMENTSHEET==> ${error.toString()}');
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text("$error"),
  //         duration: Duration(seconds: 8),
  //         backgroundColor: Colors.red,
  //       ));
  //     });
  //   } on stripe1.StripeException catch (e) {
  //     Navigator.pop(context);
  //     var lo1 = jsonEncode(e);
  //     var lo2 = jsonDecode(lo1);
  //     StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
  //     showDialog(
  //         context: context,
  //         builder: (_) => AlertDialog(
  //           content: Text("${lom.error.message}"),
  //         ));
  //   } catch (e) {
  //     print('$e');
  //     ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(SnackBar(
  //       content: Text("$e"),
  //       duration: Duration(seconds: 8),
  //       backgroundColor: Colors.red,
  //     ));
  //   }
  // }
  displayStripePaymentSheet({required amount}) async {
    try {
      await stripe1.Stripe.instance.presentPaymentSheet().then((value) {
        print("wee are in");
        if(widget.take_away!){
          placeOrder();
        }else {
          push(
            context,
            CheckoutScreen(
              total: widget.total,
              discount: widget.discount!,
              couponCode: widget.couponCode!,
              couponId: widget.couponId!,
              paymentOption: paymentOption,
              products: widget.products, isPaymentDone: true,
              deliveryCharge: widget.deliveryCharge,
              tipValue: widget.tipValue,
              take_away: widget.take_away),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("paid successfully"),
          duration: Duration(seconds: 8),
          backgroundColor: Colors.green,
        ));
        paymentIntentData = null;
      }).onError((error, stackTrace) {
        Navigator.pop(context);
        var lo1 = jsonEncode(error);
        var lo2 = jsonDecode(lo1);
        StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
              content: Text("${lom.error.message}"),
            ));
      });
    } on stripe1.StripeException catch (e) {
      Navigator.pop(context);
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text("${lom.error.message}"),
          ));
    } catch (e) {
      print('$e');
      Navigator.pop(context);
      ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(SnackBar(
        content: Text("$e"),
        duration: Duration(seconds: 8),
        backgroundColor: Colors.red,
      ));
    }
  }

  createStripeIntent(
      String amount,
      ) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currencyData!.code,
        'payment_method_types[]': 'card',
        "description": "${MyAppState.currentUser?.userID} Wallet Topup",
        "shipping[name]":
        "${MyAppState.currentUser?.firstName} ${MyAppState.currentUser?.lastName}",
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "CA",
        "shipping[address][country]": "US",
      };
      print(body);
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
            'Bearer ${stripeData?.stripeSecret}', //$_paymentIntentClientSecret',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print('Create Intent response ===> ${response.body.toString()}');

      return jsonDecode(response.body);
    } catch (err) {
      print('error charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = ((double.parse(amount)) * 100).toInt();
    print(a);
    return a.toString();
  }

  // ///Stripe payment function
  // Map<String, dynamic>? paymentIntentData;


  // Future<void> stripeMakePayment({required String amount}) async {
  //   try {
  //     paymentIntentData = await createStripeIntent(amount);
  //     await stripe1.Stripe.instance
  //         .initPaymentSheet(
  //             paymentSheetParameters: stripe1.SetupPaymentSheetParameters(
  //           paymentIntentClientSecret: paymentIntentData!['client_secret'],
  //           applePay: true,
  //           allowsDelayedPaymentMethods: false,
  //           googlePay: true,
  //           testEnv: false, //!stripeData!.isSandboxEnabled,
  //           style: ThemeMode.system,
  //           merchantCountryCode: 'US',
  //           currencyCode: currencyData!.code,
  //           primaryButtonColor: Colors.deepOrange,
  //           merchantDisplayName: 'Foodies',
  //         ))
  //         .then((value) {});
  //     setState(() {});
  //     displayStripePaymentSheet(amount: amount);
  //   } catch (e, s) {
  //     print('exception:$e$s');
  //   }
  // }
  //
  // displayStripePaymentSheet({required amount}) async {
  //   try {
  //     await stripe1.Stripe.instance.presentPaymentSheet().then((value) {
  //       ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(SnackBar(
  //         content: Text("paid successfully"),
  //         duration: Duration(seconds: 8),
  //         backgroundColor: Colors.green,
  //       ));
  //       Navigator.pop(_globalKey.currentContext!);
  //       print("wee are in");
  //       push(_globalKey.currentContext!,
  //         CheckoutScreen(
  //             isPaymentDone: true,
  //             total: widget.total,
  //             discount: widget.discount!,
  //             couponCode: widget.couponCode!,
  //             couponId: widget.couponId!,
  //             paymentOption: paymentOption,
  //             products: widget.products),
  //       );
  //       paymentIntentData = null;
  //     });/*.onError((error, stackTrace){
  //       Navigator.pop(context);
  //      // StripePayFailedModel lom = StripePayFailedModel.fromJson(error.toString());
  //
  //
  //    // Map vavapue = jsonDecode(error.toString());
  //     //print(vavapue);
  //       print('Exception/DISPLAYPAYMENTSHEET==> ${error.toString()}');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("fkkcxd"//lom.error.message
  //           ),
  //             duration: Duration(seconds: 8),
  //             backgroundColor: Colors.red,
  //           ));
  //     });*/
  //
  //
  //   } on stripe1.StripeException catch (e) {
  //     Navigator.pop(_globalKey.currentContext!);
  //     var lo1 = jsonEncode(e);
  //     var lo2 = jsonDecode(lo1);
  //     StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
  //     showDialog(
  //         context: _globalKey.currentContext!,
  //         builder: (_) => AlertDialog(
  //           content: Text("${lom.error.message}"),
  //         ));
  //   } catch (e) {
  //     print('===>');
  //     print('$e');
  //     print('===>');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("$e"),
  //           duration: Duration(seconds: 8),
  //           backgroundColor: Colors.red,
  //         ));
  //     Navigator.pop(_globalKey.currentContext!);
  //
  //   }
  //
  // }
  //
  // createStripeIntent(
  //   String amount,
  // ) async {
  //   try {
  //     Map<String, dynamic> body = {
  //       'amount': calculateAmount(amount),
  //       'currency': currencyData!.code,
  //       'payment_method_types[]': 'card',
  //       "description": "${MyAppState.currentUser?.userID} Wallet Topup",
  //       "shipping[name]":
  //           "${MyAppState.currentUser?.firstName} ${MyAppState.currentUser?.lastName}",
  //       "shipping[address][line1]": "510 Townsend St",
  //       "shipping[address][postal_code]": "98140",
  //       "shipping[address][city]": "San Francisco",
  //       "shipping[address][state]": "CA",
  //       "shipping[address][country]": "US",
  //     };
  //     print(body);
  //     var response = await http.post(
  //         Uri.parse('https://api.stripe.com/v1/payment_intents'),
  //         body: body,
  //         headers: {
  //           'Authorization': 'Bearer ${stripeData?.stripeSecret}',
  //           'Content-Type': 'application/x-www-form-urlencoded'
  //         });
  //     return jsonDecode(response.body);
  //   } catch (err) {
  //     print('error charging user: ${err.toString()}');
  //   }
  // }
  //
  // calculateAmount(String amount) {
  //   final a = ((double.parse(amount)) * 100).toInt();
  //   print(a);
  //   return a.toString();
  // }




  // Future<void> _startTransaction(
  //   context, {
  //   required String txnTokenBy,
  //   required orderId,
  //   required double amount,
  // }) async {
  //   try {
  //     var response = AllInOneSdk.startTransaction(
  //       paytmSettingData!.PaytmMID,
  //       orderId,
  //       amount.toString(),
  //       txnTokenBy,
  //       "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId",
  //       //callbackUrl,
  //       isStaging,
  //       true,
  //     );
  //     response.then((value) {
  //       print(jsonEncode(value));
  //       if (value!["RESPMSG"] == "Txn Success") {
  //         print("txt done!!");
  //         if(widget.take_away!){
  //           placeOrder();
  //         }else {
  //           push(
  //             context,
  //             CheckoutScreen(
  //                 isPaymentDone: true,
  //                 total: widget.total,
  //                 discount: widget.discount!,
  //                 couponCode: widget.couponCode!,
  //                 couponId: widget.couponId!,
  //                 paymentOption: paymentOption,
  //                 products: widget.products,
  //                 deliveryCharge: widget.deliveryCharge,
  //                 tipValue: widget.tipValue,
  //                 take_away: widget.take_away),
  //           );
  //           print(amount);
  //
  //         }
  //         showAlert(context,
  //             response: "Payment Successful!!\n ${value['RESPMSG']}",
  //             colors: Colors.green);
  //       }
  //     }).catchError((onError) {
  //       if (onError is PlatformException) {
  //         Navigator.pop(_globalKey.currentContext!);
  //
  //         print("Error124 : $onError");
  //         result = onError.message.toString() +
  //             " \n  " +
  //             onError.code.toString();
  //         showAlert(
  //             _globalKey.currentContext!,
  //             response: onError.message.toString(),
  //             colors: Colors.red);
  //
  //       } else {
  //         print("======>>2");
  //
  //         result = onError.toString();
  //         Navigator.pop(_globalKey.currentContext!);
  //         showAlert(
  //             _globalKey.currentContext!,
  //             response: result,
  //             colors: Colors.red);
  //       }
  //     });
  //   } catch (err) {
  //     print("======>>3");
  //     result = err.toString();
  //     Navigator.pop(_globalKey.currentContext!);
  //     showAlert(
  //         _globalKey.currentContext!,
  //         response: result,
  //         colors: Colors.red);
  //   }
  // }

  placeOrder() async {

    FireStoreUtils fireStoreUtils = FireStoreUtils();

    List<CartProduct> tempProduc=[];

    for(CartProduct cartProduct in widget.products){
      CartProduct tempCart=cartProduct;
      tempCart.extras=cartProduct.extras?.split(",");
      tempProduc.add(tempCart);
    }
    //place order
    showProgress(context, 'Placing Order...'.tr(), false);
    VendorModel vendorModel = await fireStoreUtils
        .getVendorByVendorID(widget.products.first.vendorID)
        .whenComplete(() => setPrefData());
    print(vendorModel.fcmToken.toString() +
        "{}{}{}{======TOKENADD" +
        vendorModel.toJson().toString());
    OrderModel orderModel = OrderModel(
      address: MyAppState.currentUser!.shippingAddress,
      author: MyAppState.currentUser,
      authorID: MyAppState.currentUser!.userID,
      createdAt: Timestamp.now(),
      products: tempProduc,
      status: ORDER_STATUS_PLACED,
      vendor: vendorModel,
      vendorID: widget.products.first.vendorID,
      discount: widget.discount ,
      couponCode: widget.couponCode,
      couponId: widget.couponId,
      adminCommission:isEnableAdminCommission!? adminCommissionValue:"0",
      adminCommissionType: isEnableAdminCommission!? addminCommissionType:"",
      takeAway: true,
    );

    OrderModel placedOrder = await fireStoreUtils.placeOrderWithTakeAWay(orderModel);
    print("||||{}" + orderModel.toJson().toString());
    hideProgress();
    print('_CheckoutScreenState.placeOrder ${placedOrder.id}');
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceOrderScreen(orderModel: placedOrder),
    );
  }

  Future<void> setPrefData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    sp.setString("musics_key", "");
    sp.setString("addsize", "");
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/AppGlobal.dart';
import '/constants.dart';
import '/main.dart';
import '/model/CouponModel.dart';
import '/model/VendorModel.dart';
import '/model/offer_model.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';
import '/services/localDatabase.dart';
import '/ui/cartOptionsSheet/CartOptionsSheet.dart';
import '/ui/deliveryAddressScreen/DeliveryAddressScreen.dart';
import '/ui/placeOrderScreen/PlaceOrderScreen.dart';
import '/ui/productDetailsScreen/ProductDetailsScreen.dart';

import '../../model/AddressModel.dart';
import '../../model/OrderModel.dart';
import '../payment/PaymentScreen.dart';

class CartScreen extends StatefulWidget {
  final bool fromContainer;

  const CartScreen({Key? key, required this.fromContainer}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<CartProduct>> cartFuture;
  late List<CartProduct> cartProducts = [];


  double total = 0.0;
  double subTotal1 = 0.0;
  late CartDatabase cartDatabase;
  double grandtotal = 0.0;
  late var snapshot;
  var per = 0.0;
  late Future<List<OfferModel>> coupon;
  TextEditingController txt = TextEditingController(text: '');
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  var percentage, type = 0.0;
  var amount = 0.00;
  late String couponId = '';
  List<String> tempAddonsList = [];
  String priceValue = "",vendorID="";
  late List<AddAddonsDemo> lstExtras = [];
  late List<AddSizeDemo> lstExtrasPrice = [];
  late List<String> commaSepratedAddOns = [];
  late List<String> commaSepratedAddSize = [];
  String? commaSepratedAddOnsString = "";
  String? commaSepratedAddSizeString = "";
  double addOnsValue = 0.0, subTotalValue = 0.0, grandTotalValue = 0.0;
  String? adminCommissionValue = "",addminCommissionType="";
  bool? isEnableAdminCommission = false;
  var addSizeDemo;
  var deliveryCharges = "0.0";
  String? selctedOrderTypeValue = "Delivery";
  var tipValue = 0.0;
  bool isTipSelected = false,
      isTipSelected1 = false,
      isTipSelected2 = false,
      isTipSelected3 = false;
  TextEditingController _textFieldController = TextEditingController();

  late Map<String, dynamic>? adminCommission;
  @override
  void initState() {
    super.initState();
    coupon = _fireStoreUtils.getAllCoupons();
    getFoodType();
    print(widget.fromContainer.toString()+"------F");
  }

  getFoodType() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      selctedOrderTypeValue =
      sp.getString("foodType") == "" || sp.getString("foodType") == null
          ? "Delivery"
          : sp.getString("foodType");
    });
    if (selctedOrderTypeValue == "Delivery") {
      _fireStoreUtils.getDeliveryCharges().then((value) {
        setState(() {
          deliveryCharges = value!;
        });
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    cartDatabase = Provider.of<CartDatabase>(context, listen: true);
    cartFuture = cartDatabase.allCartProducts;
    print(cartDatabase);
    _fireStoreUtils.getAdminCommission().then((value) {
      print(value.toString() + "===____1");
      if (value != null) {
        setState(() {
          adminCommission = value;
          adminCommissionValue = adminCommission!["adminCommission"].toString();
          addminCommissionType= adminCommission!["addminCommissionType"].toString();
          isEnableAdminCommission =adminCommission!["isAdminCommission"];
          print(adminCommission!["adminCommission"].toString() + "===____");
          print(adminCommission!["isAdminCommission"].toString() + "===____");
        });
      }
    });
    getPrefData();
    //setPrefData();
  }

  @override
  Widget build(BuildContext context) {
    cartDatabase = Provider.of<CartDatabase>(context, listen: true);
    return Scaffold(
      appBar: widget.fromContainer
          ? null
          : widget.fromContainer==false?AppBar(
        title: Text('Your Cart',style: TextStyle(color: !isDarkMode(context) ? Colors.black : Color(0xffFFFFFF)),).tr(),
      ):AppBar(
        title: Text('Your Cart').tr(),
      ),
      body: StreamBuilder<List<CartProduct>>(
        stream: cartDatabase.watchProducts,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Container(
              child: Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                ),
              ),
            );

          if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return Container(
              width: MediaQuery.of(context).size.width * 1,
              child: Center(
                child: showEmptyState('Empty Cart'.tr(),
                    "Your cart is empty, Let's order item!".tr()),
              ),
            );
          } else {
            cartProducts = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  flex: 10,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: cartProducts.length,
                          itemBuilder: (context, index) {
                            vendorID = cartProducts[index].vendorID;
                            return Container(
                              margin: EdgeInsets.only(
                                  left: 13, top: 13, right: 13, bottom: 13),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: Offset(
                                        0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  buildCartRow(
                                      cartProducts[index], lstExtras, lstExtrasPrice),
                                ],
                              ),
                            );
                          },
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width * 1,
                            child: buildTotalRow(snapshot.data!, lstExtras,vendorID)),
                        SizedBox(
                            height: cartProducts.length <= 2
                                ? MediaQuery.of(context).size.height / 3
                                : 100),

                        // Spacer(flex: 1,),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      print(per == 0.0 ? type : per);
                      if(selctedOrderTypeValue == "Delivery") {
                        push(
                          context,
                          DeliveryAddressScreen(
                            total: grandtotal,
                            products: cartProducts,
                            discount: per == 0.0 ? type : per,
                            couponCode: txt.text,
                            couponId: couponId,
                            extra_size: commaSepratedAddSizeString,
                            extra_addons: commaSepratedAddOns,
                            tipValue: tipValue.toString(),
                            take_away: selctedOrderTypeValue == "Delivery"
                                ? false
                                : true,
                            deliveryCharge: deliveryCharges,
                          ),
                        );
                      }else{
                        push(
                          context,
                          PaymentScreen(
                            total: grandtotal,
                            discount:per == 0.0 ? type : per,
                            couponCode: txt.text,
                            couponId: couponId,
                            products: cartProducts,
                            extra_size: commaSepratedAddSizeString,
                            extra_addons: commaSepratedAddOns,
                            tipValue: "0",
                            take_away: true,
                            deliveryCharge: "0",
                          ),
                        );
                        // placeOrder();
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1,
                      height: MediaQuery.of(context).size.height * 0.065,
                      child: Container(
                        color: Color(COLOR_PRIMARY),
                        padding: EdgeInsets.only(
                            left: 15, right: 10, bottom: 8, top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Text("Total : ".tr(),
                                  style: TextStyle(
                                      fontFamily: "Poppinsl",
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 15)),
                              Text(
                                symbol +
                                    grandtotal
                                        .toDouble()
                                        .toStringAsFixed(decimal),
                                style: TextStyle(
                                  fontFamily: "Poppinsm",
                                  fontSize: 15,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ]),
                            Text("PROCEED TO CHECKOUT".tr(),
                                style: TextStyle(
                                  fontFamily: "Poppinsm",
                                  fontSize: 15,
                                  color: Color(0xFFFFFFFF),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          }
        },
      ),
      // bottomNavigationBar: Container(
      //     width: MediaQuery.of(context).size.width * 1,
      //     child: ConstrainedBox(
      //       constraints: BoxConstraints(minWidth: double.infinity),
      //       child: ElevatedButton(
      //         style: ElevatedButton.styleFrom(
      //           primary: Color(COLOR_PRIMARY),
      //           padding: Platform.isIOS
      //               ? const EdgeInsets.fromLTRB(16, 10, 16, 10)
      //               : const EdgeInsets.all(16),
      //         ),
      //         onPressed: () => push(
      //           context,
      //           DeliveryAddressScreen(
      //               total: grandtotal, products: cartProducts),
      //         ),
      //         child: Container(
      //           color: Color(COLOR_PRIMARY),
      //           padding:
      //               EdgeInsets.only(left: 15, right: 10, bottom: 8, top: 8),
      //           child: Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: [
      //               Row(children: [
      //                 Text("Total : ",
      //                     style: TextStyle(
      //                         fontFamily: "Poppinsl",
      //                         color: Color.fromRGBO(255, 255, 255, 100),
      //                         fontSize: 15)),
      //                 Text(
      //                   "\$" + grandtotal.toString(),
      //                   style: TextStyle(fontFamily: "Poppinsm", fontSize: 15),
      //                 ),
      //               ]),
      //               Text("PROCEED TO CHECKOUT",
      //                   style: TextStyle(fontFamily: "Poppinsm", fontSize: 15)),
      //             ],
      //           ),
      //         ),
      //       ),
      //     )),
    );
  }

  buildCartRow(CartProduct cartProduct, List<AddAddonsDemo> addons,
      List<AddSizeDemo> addonsPrrice) {
    var quen = cartProduct.quantity;
    double priceTotalValue =0.0;
    // priceTotalValue   = double.parse(cartProduct.price);
    bool isAddOnApplied = false;
    double AddOnVal = 0;
    for (int i = 0; i < lstExtras.length; i++) {
      AddAddonsDemo addAddonsDemo = lstExtras[i];
      if (addAddonsDemo.categoryID == cartProduct.id) {
        isAddOnApplied = true;
        AddOnVal = AddOnVal + double.parse(addAddonsDemo.price!);
      }
    }

    if(cartProduct.extras_price!=null && cartProduct.extras_price != "" && double.parse(cartProduct.extras_price!) !=0.0){
      priceTotalValue+=double.parse(cartProduct.extras_price!)*cartProduct.quantity;
    }
      priceTotalValue += double.parse(cartProduct.price)*cartProduct.quantity;

    // for (int innerA = 0; innerA < addons.length; innerA++) {
    //   if (addons[innerA].categoryID == cartProduct.id) {
    //     double aa = double.parse(addons[innerA].price!);
    //     priceTotalValue += aa;
    //     print(priceTotalValue.toString() + "====+---ADDONS111=="+addons.length.toString());
    //   } else {
    //     //addOnsValue = 0.0;
    //   }
    //   //}
    // }
    // if(addonsPrrice.length==0){
    //   print(cartProduct.price.toString()+"===PRICE");
    //   priceTotalValue   +=  cartProduct.discountPrice=="" || cartProduct.discountPrice=="0"?double.parse(cartProduct.price):double.parse(cartProduct.discountPrice!);
    // }else {
    //   for (int innerA = 0; innerA < addonsPrrice.length; innerA++) {
    //     if (addonsPrrice[innerA].categoryID == cartProduct.id) {
    //       double aa = double.parse(addonsPrrice[innerA].price!);
    //       // priceTotalValue = aa -  double.parse(cartProduct.price);
    //       priceTotalValue += aa;
    //       print(priceTotalValue.toString() + "====+---priceTotalValue" +
    //           double.parse(cartProduct.price).toString() + "[[" +
    //           aa.toString() + "--" + addonsPrrice.length.toString());
    //     } else {
    //       priceTotalValue   += cartProduct.discountPrice=="" || cartProduct.discountPrice=="0"?double.parse(cartProduct.price):double.parse(cartProduct.discountPrice!);;
    //     }
    //     //}
    //   }
    // }




    print(priceTotalValue.toString() + "====+---ADDONS---"+addons.length.toString());


    return ListTile(
      //  onTap: () { setState(() {

      //              quen=  cartProduct.quantity ;
      //                });},
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
            height: 80,
            width: 80,
            imageUrl: cartProduct.photo,
            imageBuilder: (context, imageProvider) => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  )),
            ),errorWidget: (context, url, error) => ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network(
              AppGlobal.placeHolderImage!,
              fit: BoxFit.cover,
            ))),
      ),
      title: Container(
        margin: EdgeInsets.only(top: 5),
        child: Text(
          cartProduct.name,
          style: TextStyle(fontSize: 18, fontFamily: "Poppinsm"),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 7),
            child:
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(
                symbol + priceTotalValue.toDouble().toStringAsFixed(decimal),
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Poppinsm",
                    color: Color(COLOR_PRIMARY)),
              ),
              Expanded(child: SizedBox()),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (quen != 0) {
                        quen--;
                        removetocard(cartProduct, quen);

                        // cartProduct.quantity = quen;
                      }
                    },
                    child: Image(
                      image: AssetImage("assets/images/minus.png"),
                      height: 30,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '${cartProduct.quantity}'.tr(),
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      quen++;
                      addtocard(cartProduct, quen);
                    },
                    child: Image(
                      image: AssetImage("assets/images/plus.png"),
                      height: 30,
                    ),
                  )
                ],
              ),
            ]),
          ),
          Container(
            height: addonsPrrice.length == 0 ? 0 : 30,
            child: ListView.builder(
                itemCount: addonsPrrice.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                      child: Text(
                        cartProduct.id == addonsPrrice[index].categoryID
                            ? addonsPrrice[index].name!.toString() + ", "
                            : "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ));
                }),
          ),
          Container(
            height: addons.length == 0 ? 0 : 30,
            child: ListView.builder(
                itemCount: addons.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                      child: Text(
                        cartProduct.id == addons[index].categoryID
                            ? addons[index].name!.toString() + ", "
                            : "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ));
                }),
          ),
        ],
      ),
    );
  }

  Widget buildTotalRow(List<CartProduct> data, List<AddAddonsDemo> lstExtras, String vendorID) {
    var _font = 18.00;
    var subTotal = 0.00;
    grandtotal = 0;
    //  Future.delayed(Duration.zero, (){
    // setState(() {
    /*data.forEach((element) {
      total += element.quantity * double.parse(element.price);
      grandtotal = total + 6;
    });*/

    for (int a = 0; a < data.length; a++) {
      //var finalValue =  (data[a].discountPrice=="" || data[a].discountPrice=="0")?double.parse(data[a].price):double.parse(data[a].discountPrice!);

      // subTotal += data[a].quantity * finalValue/*double.parse(data[a].price)*/;
      print(subTotal.toString()+"====S1");

      CartProduct e=data[a];
      bool isAddOnApplied = false;
      double AddOnVal = 0;
      for (int i = 0; i < lstExtras.length; i++) {
        AddAddonsDemo addAddonsDemo = lstExtras[i];
        if (addAddonsDemo.categoryID == e.id) {
          isAddOnApplied = true;
          AddOnVal = AddOnVal + double.parse(addAddonsDemo.price!);
        }
      }
      if(e.extras_price!=null &&e.extras_price != "" && double.parse(e.extras_price!) !=0.0){
        subTotal+=double.parse(e.extras_price!)*e.quantity;
      }
        subTotal += double.parse(e.price)*e.quantity;



      // for (int innerA = 0; innerA < lstExtras.length; innerA++) {
      //   if (lstExtras[innerA].categoryID == data[a].id) {
      //
      //     double aa = data[a].quantity * double.parse(lstExtras[innerA].price!);
      //
      //     subTotal += aa;
      //     print(subTotal.toString()+"====S2");
      //   } else {
      //     //addOnsValue = 0.0;
      //   }
      //   //}
      // }
      //
      // for (int innerA = 0; innerA < lstExtrasPrice.length; innerA++) {
      //   if (lstExtrasPrice[innerA].categoryID == data[a].id) {
      //     print("====S03="+lstExtrasPrice[innerA].price!);
      //     double aa = data[a].quantity * double.parse(lstExtrasPrice[innerA].price!);
      //
      //     print("====S3="+aa.toString()+"-{}-"+data[a].price);
      //
      //     //subTotal = aa -  double.parse(data[a].price);
      //     print(subTotal.toString()+"====S4="+aa.toString());
      //
      //     subTotal += aa;
      //     subTotal -=  data[a].discountPrice=="" || data[a].discountPrice=="0"?double.parse(data[a].price):double.parse(data[a].discountPrice!);
      //     print(subTotal.toString()+"====S5="+aa.toString());
      //   } else {
      //     //addOnsValue = 0.0;
      //   }
      //   //}
      // }
      grandtotal = subTotal + double.parse(deliveryCharges) + tipValue;
    }

    //subTotalValue += price;

    // var per =int.parse(percentage);

    if (percentage != null) {
      print('per:' + percentage.toString());
      print('garndd:' + grandtotal.toString());
      amount = 0;
      amount = subTotal * percentage / 100;
      print('amount:' + amount.toString());
      grandtotal = grandtotal - amount;
      print('garndd:' + grandtotal.toString());
      print('per:' + percentage.toString());
      per = amount.toDouble();
      // print(amount);
    }
    if (type != null) {
      amount = grandtotal - type;
      grandtotal = amount;
      // print(amount);
      print('type:' +type.toString());
    }

    // });
    // });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            margin: EdgeInsets.only(left: 13, top: 45, right: 13, bottom: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Image(
                    image: AssetImage("assets/images/reedem.png"),
                    width: 50,
                  ),
                  // SizedBox(
                  //   width: MediaQuery.of(context).size.width * 0.05,
                  // ),
                  Column(
                    children: [
                      Text(
                        "Redeem Coupon".tr(),
                        style: TextStyle(
                            fontFamily: "Poppinsm", color: Color(0xff2A2A2A)),
                      ),
                      Text("Add coupon code".tr(),
                          style: TextStyle(
                              fontFamily: "Poppinsr",
                              color: Color(0xff9091A4))),
                    ],
                  )
                ]),
                GestureDetector(
                  onTap: () {
                    //  txt.clear();
                    grandtotal = 0;
                    percentage = 0.0;
                    type = 0.0;
                    amount = 0;
                    showModalBottomSheet(
                        isScrollControlled: true,
                        isDismissible: true,
                        context: context,
                        backgroundColor: Colors.transparent,
                        enableDrag: true,
                        builder: (BuildContext context) => sheet());
                  },
                  child: Image(
                      image: AssetImage("assets/images/add.png"), width: 40),
                )
              ],
            )),
        Container(
          margin: EdgeInsets.only(left: 13, top: 10, right: 13, bottom: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Delivery Option: ".tr(),
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            color: isDarkMode(context)
                                ? Color(0xffFFFFFF)
                                : Color(0xff333333),
                            fontSize: _font),
                      ),
                      Text(
                        selctedOrderTypeValue == "Delivery"
                            ? "Delivery (${symbol + deliveryCharges.toString()})"
                            : selctedOrderTypeValue! + " (Free)",
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            color: isDarkMode(context)
                                ? Color(0xffFFFFFF)
                                : Color(0xff333333),
                            fontSize: selctedOrderTypeValue == "Delivery"?_font:15),
                      ),
                    ],
                  )),
              Divider(
                color: Color(0xffE2E8F0),
                height: 0.1,
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subtotal".tr(),
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            color: Color(0xff9091A4),
                            fontSize: _font),
                      ),
                      Text(
                        symbol + subTotal.toStringAsFixed(decimal),
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            color: isDarkMode(context)
                                ? Color(0xffFFFFFF)
                                : Color(0xff333333),
                            fontSize: _font),
                      ),
                    ],
                  )),
              Divider(
                color: Color(0xffE2E8F0),
                height: 0.1,
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Discount".tr(),
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            color: Color(0xff9091A4),
                            fontSize: _font),
                      ),
                      Text(
                        percentage != 0.0
                            ? percentage != null
                            ? symbol +
                            per.toDouble().toStringAsFixed(decimal)
                            : symbol + 0.toStringAsFixed(decimal)
                            : type != null
                            ? symbol +
                            type.toDouble().toStringAsFixed(decimal)
                            : symbol + 0.toStringAsFixed(decimal),
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            color: isDarkMode(context)
                                ? Color(0xffFFFFFF)
                                : Color(0xff333333),
                            fontSize: _font),
                      ),
                    ],
                  )),
              Divider(
                color: Color(0xffE2E8F0),
                height: 0.1,
              ),
              selctedOrderTypeValue == "Delivery"
                  ? Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Delivery Charges".tr(),
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            color: Color(0xff9091A4),
                            fontSize: _font),
                      ),
                      Text(
                        symbol + deliveryCharges,
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            color: isDarkMode(context)
                                ? Color(0xffFFFFFF)
                                : Color(0xff333333),
                            fontSize: _font),
                      ),
                    ],
                  ))
                  : Container(),
              Divider(
                color: Color(0xffE2E8F0),
                height: 0.1,
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order Total".tr(),
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            color: isDarkMode(context)
                                ? Color(0xffFFFFFF)
                                : Color(0xff333333),
                            fontSize: _font),
                      ),
                      Text(
                        symbol + grandtotal.toDouble().toStringAsFixed(decimal),
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            color: isDarkMode(context)
                                ? Color(0xffFFFFFF)
                                : Color(0xff333333),
                            fontSize: _font),
                      ),
                    ],
                  )),
            ],
          ),
        ),
        selctedOrderTypeValue == "Delivery"?Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tip your delivery partner".tr(),
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontFamily: "Poppinsm",
                    fontWeight: FontWeight.bold,
                    color: isDarkMode(context)
                        ? Color(0xffFFFFFF)
                        : Color(0xff333333),
                    fontSize: 15),
              ),
              Text(
                "100% of the tip will go to your delivery partner".tr(),
                style: TextStyle(
                    fontFamily: "Poppinsm",
                    color: Color(0xff9091A4),
                    fontSize: 14),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        tipValue = 10;
                        grandtotal += tipValue;
                        isTipSelected = true;
                        isTipSelected1 = false;
                        isTipSelected2 = false;
                        isTipSelected3 = false;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                      decoration: BoxDecoration(
                        color: tipValue == 10 && isTipSelected
                            ? Color(COLOR_PRIMARY)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xff9091A4), width: 1),
                      ),
                      child: Center(
                          child: Text(
                            symbol + "10",
                            style: TextStyle(
                                fontFamily: "Poppinsm",
                                color: isDarkMode(context)
                                    ? Color(0xffFFFFFF)
                                    : Color(0xff333333),
                                fontSize: 14),
                          )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        tipValue = 20;
                        isTipSelected = false;
                        isTipSelected1 = true;
                        isTipSelected2 = false;
                        isTipSelected3 = false;
                        grandtotal += tipValue;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                      decoration: BoxDecoration(
                        color: tipValue == 20 && isTipSelected1
                            ? Color(COLOR_PRIMARY)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xff9091A4), width: 1),
                      ),
                      child: Center(
                          child: Text(
                            symbol + "20",
                            style: TextStyle(
                                fontFamily: "Poppinsm",
                                color: isDarkMode(context)
                                    ? Color(0xffFFFFFF)
                                    : Color(0xff333333),
                                fontSize: 14),
                          )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        tipValue = 30;
                        isTipSelected = false;
                        isTipSelected1 = false;
                        isTipSelected2 = true;
                        isTipSelected3 = false;
                        grandtotal += tipValue;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                      decoration: BoxDecoration(
                        color: tipValue == 30 && isTipSelected2
                            ? Color(COLOR_PRIMARY)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xff9091A4), width: 1),
                      ),
                      child: Center(
                          child: Text(
                            symbol + "30",
                            style: TextStyle(
                                fontFamily: "Poppinsm",
                                color: isDarkMode(context)
                                    ? Color(0xffFFFFFF)
                                    : Color(0xff333333),
                                fontSize: 14),
                          )),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _displayDialog(context);
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border:
                          Border.all(color: Color(0xff9091A4), width: 1),
                        ),
                        child: Center(
                            child: Text(
                              "Other",
                              style: TextStyle(
                                  fontFamily: "Poppinsm",
                                  color: Color(COLOR_PRIMARY),
                                  fontSize: 14),
                            )),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ):Container(),
      ],
    );
  }

  // showSheet(CartProduct cartProduct) async {
  //   bool? shouldUpdate = await showModalBottomSheet(
  //     isDismissible: true,
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => CartOptionsSheet(
  //       cartProduct: cartProduct,
  //     ),
  //   );
  //   if (shouldUpdate != null) {
  //     cartFuture = cartDatabase.allCartProducts;
  //     setState(() {});
  //   }
  // }

  addtocard(CartProduct cartProduct, qun) async {
    await cartDatabase.updateProduct(CartProduct(
      id: cartProduct.id,
      name: cartProduct.name,
      photo: cartProduct.photo,
      price: cartProduct.price,
      vendorID: cartProduct.vendorID,
      quantity: qun,
    ));
  }

  removetocard(CartProduct cartProduct, qun) async {
    if (qun >= 1) {
      await cartDatabase.updateProduct(CartProduct(
          id: cartProduct.id,
          name: cartProduct.name,
          photo: cartProduct.photo,
          price: cartProduct.price,
          vendorID: cartProduct.vendorID,
          quantity: qun,
          discountPrice: cartProduct.discountPrice!
      ));
    } else {
      cartDatabase.removeProduct(cartProduct.id);
    }
  }

  sheet() {
    return Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height / 4.3,
            left: 25,
            right: 25),
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(style: BorderStyle.none)),
        child: FutureBuilder<List<OfferModel>>(
            future: coupon,
            initialData: [],
            builder: (context, snapshot) {
              snapshot = snapshot;
              print(snapshot.data!.length.toString()+"[][]][][][][][][][][]][][====");
              if (snapshot.connectionState == ConnectionState.waiting)
                return Container(
                  child: Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                    ),
                  ),
                );

              // coupon = snapshot.data as Future<List<CouponModel>> ;
              return Column(children: [
                InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 0.3),
                          color: Colors.transparent,
                          shape: BoxShape.circle),

                      // radius: 20,
                      child: Center(
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    )),
                SizedBox(
                  height: 25,
                ),
                Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                                padding: EdgeInsets.only(top: 30),
                                child: Image(
                                  image:
                                  AssetImage('assets/images/redeem_coupon.png'),
                                  width: 100,
                                )),
                            Container(
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                  'Redeem Your Coupons'.tr(),
                                  style: TextStyle(
                                      fontFamily: 'Poppinssb',
                                      color: Color(0XFF2A2A2A),
                                      fontSize: 16),
                                )),
                            Container(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  'Enter your Voucher or Coupon code to \n'
                                      'get the discount on all over the budget',
                                  style: TextStyle(
                                      fontFamily: 'Poppinsr',
                                      color: Color(0XFF9091A4),
                                      letterSpacing: 0.5,
                                      height: 2),
                                ).tr()),
                            Container(
                                padding:
                                EdgeInsets.only(left: 20, right: 20, top: 20),
                                // height: 120,
                                child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: Radius.circular(12),
                                    dashPattern: [4, 2],
                                    color: Color(0XFFB7B7B7),
                                    child: ClipRRect(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                        child: Container(
                                            padding: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                                top: 20,
                                                bottom: 20),
                                            color: Color(0XFFF1F4F7),
                                            // height: 120,
                                            alignment: Alignment.center,
                                            child: TextFormField(
                                              textAlign: TextAlign.center,
                                              controller: txt,

                                              // textAlignVertical: TextAlignVertical.center,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Write Coupon Code'.tr(),
                                                hintStyle: TextStyle(
                                                    color: Color(0XFF9091A4)),
                                                labelStyle: TextStyle(
                                                    color: Color(0XFF333333)),
                                                //  hintTextDirection: TextDecoration.lineThrough
                                                // contentPadding: EdgeInsets.only(left: 80,right: 30),
                                              ),
                                            ))))),
                            Padding(
                              padding: const EdgeInsets.only(top: 30, bottom: 30),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 100, vertical: 15),
                                  primary: Color(COLOR_PRIMARY),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  // buildcouponItem();
                                  setState(() {
                                    //buildcouponItem(snapshot);
                                    for(int a=0;a<snapshot.data!.length;a++) {
                                      OfferModel couponModel = snapshot.data![a];
                                      print(couponModel.offerCode.toString() +
                                          "-----------" + txt.text+"  v--"+vendorID+"  r--"+couponModel.storeId.toString()+'  d--'+couponModel.discountOffer.toString());

                                      if (vendorID == couponModel.storeId || couponModel.storeId=="" ) {
                                        if (txt.text.toString() == couponModel.offerCode!.toString()) {
                                          couponId = couponModel.offerId!;
                                          if (couponModel.discountTypeOffer == 'Percentage'
                                              || couponModel.discountTypeOffer == 'Percent') {
                                            percentage = double.parse(
                                                couponModel.discountOffer!);
                                            print(couponModel.discountOffer
                                                .toString() + "====OFFER");
                                            break;
                                            // widget.per =couponModel.discount;
                                          } else {
                                            /*if (txt.text.toString() == couponModel.offerCode.toString() &&
                                          couponModel.isEnableOffer == true &&
                                          couponModel.discountTypeOffer == 'Fix Price' || couponModel.discountTypeOffer == 'fixed') {*/
                                            type = double.parse(couponModel.discountOffer!);
                                            print(
                                                type.toString() + "====OFFERtype");
                                            //break;
                                            //  print(couponModel.discount);
                                            //}
                                          }
                                        }
                                      }else{
                                        
                                      }
                                    }
                                  });

                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'REDEEM NOW'.tr(),
                                  style: TextStyle(
                                      color: isDarkMode(context)
                                          ? Colors.black
                                          : Colors.white,
                                      fontFamily: 'Poppinsm',
                                      fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                //buildcouponItem(snapshot)
                //  listData(snapshot)
              ]);
            }));
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Tip your driver partner'.tr()),
            content: TextField(
              controller: _textFieldController,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(hintText: "Enter your tip"),
            ),
            actions: <Widget>[
              new ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Color(COLOR_PRIMARY),
                    textStyle:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
                child: new Text('cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Color(COLOR_PRIMARY),
                    textStyle:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
                child: new Text('Submit'),
                onPressed: () {
                  setState(() {
                    var value = _textFieldController.text.toString();
                    isTipSelected = false;
                    isTipSelected1 = false;
                    isTipSelected2 = false;
                    isTipSelected3 = true;
                    tipValue = double.parse(value);
                    Navigator.of(context).pop();
                  });
                },
              )
            ],
          );
        });
  }

// listData(snapshot){

//   return Container(height: 0,
//             child:
//           ListView.builder(
//                   itemCount: snapshot.data!.length,
//                   itemBuilder: (context, index) {

//                return
//           buildcouponItem(snapshot.data![index]);

//                   }));
// }
/*  buildcouponItem(snapshot) {
//   var time = DateTime.fromMicrosecondsSinceEpoch(couponModel.exipreAt.microsecondsSinceEpoch);
// //  print(txt.text);
//  print(time);
//  var nowtime =DateTime.now();
// //   print(couponModel.code);
// print(nowtime.compareTo(time));
//  print(couponModel.exipreAt);
    return Container(
        height: 0,
        child: ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              OfferModel couponModel = snapshot.data[index];
              couponId = couponModel.offerId!;

              if (txt.text == couponModel.offerCode! &&
                  couponModel.isEnableOffer == true &&
                  couponModel.discountTypeOffer == 'Percentage') {
                percentage = double.parse(couponModel.discountOffer!);
                print(couponModel.discountOffer.toString()+"====OFFER");
                // widget.per =couponModel.discount;
              }
              if (txt.text == couponModel.offerCode &&
                  couponModel.isEnableOffer == true &&
                  couponModel.discountTypeOffer == 'Fix Price') {
                type = double.parse(couponModel.discountOffer!);
                print(type.toString()+"====OFFERtype");
                //  print(couponModel.discount);
              } else {
                print("No====================");
              }
              return Center();
            }));
  }*/

  Future<void> getPrefData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String musicsString = await prefs.getString('musics_key')!;
    print("======******======CART GET" + musicsString);
    if(musicsString.isNotEmpty) {
      lstExtras = AddAddonsDemo.decode(musicsString);
      lstExtras.forEach((element) {
        commaSepratedAddOns.add(element.name!);
      });
      commaSepratedAddOnsString = commaSepratedAddOns.join(", ");
      commaSepratedAddSizeString = commaSepratedAddSize.join(", ");
    }

    final String size_price = await prefs.getString('addsize')!;

    if(size_price.isNotEmpty) {
      lstExtrasPrice = AddSizeDemo.decode(size_price);


      lstExtrasPrice.forEach((element) {
        commaSepratedAddSize.add(element.name!);
      });

    }


    print("====+====" + musicsString + " [][][ " + size_price);
  }

  Future<void> setPrefData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    sp.setString("musics_key", "");
    sp.setString("addsize", "");
  }

  Widget TipWidgetMethod({String? amount}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: 5),
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
        decoration: BoxDecoration(
          color: tipValue == 10 && isTipSelected
              ? Color(COLOR_PRIMARY)
              : tipValue == 20 && isTipSelected1
              ? Color(COLOR_PRIMARY)
              : tipValue == 30 && isTipSelected2
              ? Color(COLOR_PRIMARY)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xff9091A4), width: 1),
        ),
        child: Center(
            child: Text(
              symbol + amount!,
              style: TextStyle(
                  fontFamily: "Poppinsm",
                  color:
                  isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff333333),
                  fontSize: 14),
            )),
      ),
    );
  }

  placeOrder() async {

    FireStoreUtils fireStoreUtils = FireStoreUtils();


    //place order
    showProgress(context, 'Placing Order...'.tr(), false);
    VendorModel vendorModel = await fireStoreUtils
        .getVendorByVendorID(cartProducts.first.vendorID)
        .whenComplete(() => setPrefData());
    print(vendorModel.fcmToken.toString() +
        "{}{}{}{======TOKENADD" +
        vendorModel.toJson().toString());
    OrderModel orderModel = OrderModel(
      address: MyAppState.currentUser!.shippingAddress,
      author: MyAppState.currentUser,
      authorID: MyAppState.currentUser!.userID,
      createdAt: Timestamp.now(),
      products: cartProducts,
      status: ORDER_STATUS_PLACED,
      vendor: vendorModel,
      vendorID: cartProducts.first.vendorID,
      discount: per == 0.0 ? type : per,
      couponCode: txt.text,
      couponId: couponId,
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
}
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/constants.dart';
import '/model/ProductModel.dart';
import '/model/VendorModel.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';
import '/services/localDatabase.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel productModel;
  final VendorModel vendorModel;

  const ProductDetailsScreen(
      {Key? key, required this.productModel, required this.vendorModel})
      : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late String bigImageUrl;

  late CartDatabase cartDatabase;

  String radioItem = '';
  int id = -1;
  List<AddSizeDemo> lstAddSizeCustom = [];
  List<AddAddonsDemo> lstAddAddonsCustom = [];
  List<AddAddonsDemo> lstTemp = [];
  final FireStoreUtils fireStoreUtils = FireStoreUtils();
  String orderValue = "", tempSizeOfValue = "";
  double priceTemp = 0.0,
      totalAddonsValue = 0.0,
      finalValue = 0.0,
      lastPrice = 0.0;
  List<AddSizeDemo> lstTempAddSSize = [];
  bool isAddonsCheck = false;
  List<AddAddonsDemo> lstAddSizeCustomSave1 = [];
  List<AddAddonsDemo> lstAddAddonsCustomaaa = [];
  int productQnt = 0;

  @override
  void initState() {
    super.initState();
    bigImageUrl = widget.productModel.photo;
    productQnt = widget.productModel.quantity;
    getAddOnsData();

    if (widget.productModel.size.length != 0) {
      for (int a = 0; a < widget.productModel.size.length; a++) {
        AddSizeDemo addSizeDemo = AddSizeDemo(
            name: widget.productModel.size[a],
            index: a,
            categoryID: widget.productModel.id,
            price: widget.productModel.sizePrice[a]);
        lstAddSizeCustom.add(addSizeDemo);
      }
    }
  }

  @override
  void didChangeDependencies() {
    cartDatabase = Provider.of<CartDatabase>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var price = double.parse(widget.productModel.price);
    assert(price is double);

    return Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(style: BorderStyle.none)),
        child: Column(children: [
          InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 0.3),
                    color: Color(0xff000000),
                    shape: BoxShape.circle),

                // radius: 20,
                child: Center(
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              )),
          SizedBox(
            height: 20,
          ),
          Expanded(
              child: Stack(children: [
            Positioned(
                top: 60,
                child: Container(
                    padding: EdgeInsets.only(top: 150),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: isDarkMode(context)
                          ? Colors.grey[900]
                          : Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //                    Container(
                            //   height: 120,
                            //   child: ListView.builder(
                            //     padding: EdgeInsets.symmetric(vertical: 16),
                            //     itemCount: widget.productModel.photo.length,
                            //     scrollDirection: Axis.horizontal,
                            //     itemBuilder: (context, index) => Padding(
                            //       padding: const EdgeInsets.only(right: 16.0),
                            //       child:
                            //       GestureDetector(
                            //         onTap: () {
                            //           setState(() {
                            //             bigImageUrl = widget.productModel.photo[index];
                            //             print('_ProductDetailsScreenState.build $bigImageUrl');
                            //           });
                            //         },
                            //         child:
                            //         CachedNetworkImage(
                            //           imageUrl: widget.productModel.photo[index],
                            //           imageBuilder: (context, imageProvider) => Container(
                            //             height: 120,
                            //             width: 100,
                            //             decoration: BoxDecoration(
                            //               image: DecorationImage(
                            //                   image: imageProvider, fit: BoxFit.cover),
                            //             ),
                            //           ),
                            //           placeholder: (context, url) => Center(
                            //             child: CircularProgressIndicator.adaptive(
                            //               valueColor:
                            //                   AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                            //             ),
                            //           ),
                            //           errorWidget: (context, url, error) => Container(),
                            //           fit: BoxFit.cover,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Container(
                              color: isDarkMode(context)
                                  ? Colors.grey[900]
                                  : Color(0xFFFFFFFF),
                              height: MediaQuery.of(context).size.height / 2.0,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 12),
                                      child: Text(
                                        widget.productModel.name,
                                        style: TextStyle(
                                            fontFamily: "Poppinsm",
                                            fontSize: 22,
                                            color: isDarkMode(context)
                                                ? Color(0xffffffff)
                                                : Color(0xff000000)),
                                      ),
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: /*Text(
                                                symbol +
                                                    price
                                                        .toDouble()
                                                        .toStringAsFixed(
                                                            decimal),
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    fontFamily: "Poppinsm",
                                                    color: Color(COLOR_PRIMARY)),
                                              )*/
                                                widget.productModel.disPrice == "" || widget.productModel.disPrice == "0" ? Text(
                                                        symbol + '${price.toDouble().toStringAsFixed(decimal)}',
                                                        style: TextStyle(
                                                            fontSize: 22,
                                                            fontFamily:
                                                                "Poppinsm",
                                                            color: Color(
                                                                COLOR_PRIMARY)),
                                                      )
                                                    : Text(symbol + '${double.parse(widget.productModel.disPrice!).toDouble().toStringAsFixed(decimal)}',
                                                        style: TextStyle(
                                                            fontSize: 22,
                                                            fontFamily:
                                                                "Poppinsm",
                                                            color: Color(
                                                                COLOR_PRIMARY)),
                                                      ),
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              child: productQnt == 0 ? widget.vendorModel.reststatus != true
                                                      ? Center()
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 20,
                                                                  bottom: 10),
                                                          child:
                                                              TextButton.icon(
                                                            onPressed: () {
                                                              setState(() {
                                                                widget.productModel.quantity = 1;
                                                                print(widget.productModel.quantity.toString() + "======Q");
                                                                /*priceTemp += widget.productModel.disPrice==""||widget.productModel.disPrice=="0"?
                                                                    double.parse(widget.productModel.price) : double.parse(widget.productModel.disPrice!);*/
                                                                // widget.productModel.price = widget.productModel.disPrice == "" || widget.productModel.disPrice == "0" ? (widget.productModel.price) : (widget.productModel.disPrice!);
                                                                addtocard(widget.productModel,widget.productModel.quantity,false);
                                                              });
                                                            },
                                                            icon: Icon(
                                                                Icons.add,
                                                                color: Color(
                                                                    COLOR_PRIMARY)),
                                                            label: Text('ADD'.tr(),
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontFamily:
                                                                      "Poppinsm",
                                                                  color: Color(
                                                                      COLOR_PRIMARY)),
                                                            ),
                                                            style: TextButton
                                                                .styleFrom(
                                                              side: BorderSide(
                                                                  color: Colors.grey.shade300,
                                                                  width: 2),
                                                            ),
                                                          ),
                                                        )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceEvenly,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                if (productQnt != 0)
                                                                  productQnt--;
                                                                if (productQnt >= 0) {
                                                                  //

                                                                  // for (int d = 0; d < lstTemp.length; d++) {
                                                                  //   if (lstTemp[d].categoryID ==widget.productModel.id) {
                                                                  //     AddAddonsDemo addAddonsDemo = AddAddonsDemo(
                                                                  //         name: lstTemp[d].name,
                                                                  //         index: lstTemp[d].index,
                                                                  //         isCheck: true,
                                                                  //         categoryID: lstTemp[d].categoryID,
                                                                  //         price: lstTemp[d].price);
                                                                  //     priceTemp -= double.parse(lstTemp[d].price!);
                                                                  //   }
                                                                  // }
                                                                  removetocard(widget.productModel,productQnt);
                                                                } else {
                                                                  //addtocard(widget.productModel);
                                                                }

                                                                print(widget.productModel.quantity.toString() + "======Q1");
                                                              });
                                                            },
                                                            icon: Image(
                                                              image: AssetImage("assets/images/minus.png"),
                                                              height: 26,
                                                            )),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          productQnt.toString(),
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontFamily: "Poppinsm",
                                                              color: Color(COLOR_PRIMARY)),
                                                        ),
                                                        SizedBox(width: 5,),
                                                        IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                if (productQnt != 0)
                                                                  productQnt++;

                                                                print(priceTemp.toString() + "*-*-*-*-**-*-");

                                                                // widget.productModel.price = widget.productModel.disPrice == "" || widget.productModel.disPrice == "0" ? (widget.productModel.price) : (widget.productModel.disPrice!);
                                                                print(widget.productModel.price.toString() +"*-*-*-*-**-*-=====");
                                                                addtocard(widget.productModel, productQnt, false);
                                                                print(widget.productModel.quantity.toString() + "======Q2");
                                                              });
                                                            },
                                                            icon: Image(
                                                              image: AssetImage(
                                                                  "assets/images/plus.png"),
                                                              height: 26,
                                                            ))
                                                      ],
                                                    )),
                                        ]),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            top: 16, right: 20, left: 20),
                                        child: Text(
                                          widget.productModel.description,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: "Poppinsl",
                                              color: isDarkMode(context)
                                                  ? Color(0xffC6C4C4)
                                                  : Color(0xff5E5C5C)),
                                        )),
                                    SizedBox(height: 10),
                                    Container(
                                        padding: EdgeInsets.only(
                                            right: 20, left: 20, top: 16),
                                        child: Text(
                                            widget.productModel.description,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(COLOR_PRIMARY),
                                                fontFamily: "Poppinsl"))),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            right: 15, left: 15, top: 18),
                                        child: Card(
                                            color: isDarkMode(context)
                                                ? Color(DARK_COLOR)
                                                : Color(0xffF2F4F6),
                                            // Color(0XFFF9FAFE),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: 10,
                                                    right: 20,
                                                    left: 20,
                                                    bottom: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                          widget.productModel.calories.toString(),
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text("kcal".tr(),
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    "Poppinsl"))
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(widget.productModel.grams.toString(),
                                                            style: TextStyle(
                                                                fontSize: 20)),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text("grams".tr(),
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    "Poppinsl"))
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(widget.productModel.proteins.toString(),
                                                            style: TextStyle(
                                                                fontSize: 20)),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text("proteins".tr(),
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    "Poppinsl"))
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(widget.productModel.fats.toString(),
                                                            style: TextStyle(
                                                                fontSize: 20)),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text("fats".tr(),
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    "Poppinsl"))
                                                      ],
                                                    )
                                                  ],
                                                )))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          lstAddSizeCustom.length == 0
                                              ? Container()
                                              : Text(
                                                  "Customisation",
                                                  style: TextStyle(
                                                      fontFamily: "Poppinsm",
                                                      fontSize: 17,
                                                      color: isDarkMode(context)
                                                          ? Color(0xffffffff)
                                                          : Color(0xff000000)),
                                                ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                child: Column(
                                                  children: lstAddSizeCustom.map((data) => RadioListTile(title:Text(symbol + data.price!,
                                                    textAlign:TextAlign.end, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: "Poppinsm", color: Color(COLOR_PRIMARY)),),
                                                    secondary: Text("${data.name}", style: TextStyle(fontSize: 14, fontFamily: "Poppinsl",  color: isDarkMode(context) ? Color(0xffC6C4C4) : Color(0xff5E5C5C)),) ,
                                                    controlAffinity: ListTileControlAffinity.trailing,
                                                    contentPadding: EdgeInsets.zero,
                                                    groupValue: id,
                                                    value: data.index!,
                                                    onChanged: (val) {

                                                      setState(() {
                                                        radioItem = data.name!;
                                                        id = data.index!;
                                                        AddSizeDemo addSizeDemo = new AddSizeDemo(
                                                            categoryID: data.categoryID,
                                                            name: data.name,
                                                            price: data.price,
                                                            index: data.index,
                                                            addOnTotalValue: "");

                                                        if (lstTempAddSSize.length == 0) {
                                                          lstTempAddSSize.add(addSizeDemo);
                                                          // priceTemp = double.parse(data.price.toString());
                                                          // lastPrice = double.parse(data.price.toString());
                                                          print(priceTemp.toString() + "<><><><><><>2");
                                                        } else {
                                                          var isCategoryIdFound = false;
                                                          for (int a = 0; a < lstTempAddSSize.length; a++) {
                                                            if (lstTempAddSSize[a].categoryID == data.categoryID) {
                                                              isCategoryIdFound = true;
                                                              if (lstTempAddSSize[a].index != data.index!) {
                                                                print(priceTemp.toString() + "<><><><><><>3=" + lastPrice.toString());
                                                                lstTempAddSSize.removeAt(a);
                                                              }
                                                            }
                                                          }
                                                          if (isCategoryIdFound == false) {
                                                            priceTemp = 0;
                                                          }
                                                          lstTempAddSSize.add(addSizeDemo);
                                                            // setState(() {
                                                            //   print(priceTemp.toString() + "<><><><><><>44=" + lastPrice.toString() + '--DA--' + data.price!);
                                                            //   // priceTemp += double.parse(data.price!);
                                                            //   // lastPrice = double.parse(data.price!);
                                                            //   print(priceTemp.toString() + "<><><><><><>4=");
                                                            // });
                                                        }
                                                        saveObject(lstTempAddSSize);
                                                        updateValueList();
                                                                  });
                                                                },
                                                              ))
                                                      .toList(),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          lstAddAddonsCustom.length == 0
                                              ? Container()
                                              : Text(
                                                  "Addons",
                                                  style: TextStyle(
                                                      fontFamily: "Poppinsm",
                                                      fontSize: 17,
                                                      color: isDarkMode(context)
                                                          ? Color(0xffffffff)
                                                          : Color(0xff000000)),
                                                ),
                                          Container(
                                            height: 350,
                                            child: ListView.builder(
                                                itemCount:
                                                    lstAddAddonsCustom.length,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    margin: EdgeInsets.only(
                                                        top: 15, bottom: 15),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          lstAddAddonsCustom[index].name!,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  "Poppinsl",
                                                              color: isDarkMode(context) ? Color(0xffC6C4C4) : Color(0xff5E5C5C)),
                                                        ),
                                                        Expanded(
                                                            child: SizedBox()),
                                                        Text(
                                                          symbol + lstAddAddonsCustom[index].price!,
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.bold,
                                                              fontFamily: "Poppinsm",
                                                              color: Color(COLOR_PRIMARY)),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              lstAddAddonsCustom[index].isCheck = !lstAddAddonsCustom[index].isCheck;

                                                              if (lstAddAddonsCustom[index].isCheck == true) {
                                                                AddAddonsDemo addAddonsDemo = AddAddonsDemo(
                                                                    name: widget.productModel.addOnsTitle[index],
                                                                    index: index,
                                                                    isCheck: true,
                                                                    categoryID: widget.productModel.id,
                                                                    price: lstAddAddonsCustom[index].price);
                                                                lstTemp.add(addAddonsDemo);
                                                                saveAddOns(lstTemp);
                                                                //widget.productModel.price = widget.productModel.disPrice==""||widget.productModel.disPrice=="0"? (widget.productModel.price) :(widget.productModel.disPrice!);
                                                                addtocard(widget.productModel, widget.productModel.quantity, true);

                                                                print(widget.productModel.quantity.toString() + "======Q3");
                                                              } else {
                                                                var removeIndex = -1;
                                                                for (int a = 0; a < lstTemp.length; a++) {
                                                                  if (lstTemp[a].index == index && lstTemp[a].categoryID == lstAddAddonsCustom[index].categoryID) {
                                                                    removeIndex = a;
                                                                    break;
                                                                  }
                                                                }
                                                                lstTemp.removeAt(removeIndex);
                                                                print("prod quantu " + widget.productModel.quantity.toString() + "tempLis " + jsonEncode(lstTemp));
                                                                saveAddOns(lstTemp);
                                                                //widget.productModel.price = widget.productModel.disPrice==""||widget.productModel.disPrice=="0"? (widget.productModel.price) :(widget.productModel.disPrice!);
                                                                addtocard(widget.productModel, widget.productModel.quantity, true);
                                                                print(widget.productModel.quantity.toString() + "======Q4");
                                                              }
                                                            });
                                                          },
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 10),
                                                            child: Icon(!lstAddAddonsCustom[index].isCheck ? Icons.check_box_outline_blank : Icons.check_box),
                                                            /*color: !lstAddAddonsCustom[index].isCheck
                                                                ? Colors.grey
                                                                : Color(
                                                                    COLOR_PRIMARY),*/
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )

                                                      /*CheckboxListTile(
                                                          activeColor: Color(COLOR_PRIMARY),
                                                          dense: true,
                                                          //font change
                                                          title: Row(
                                                            children: [
                                                              new Text(
                                                                lstAddAddonsCustom[index].name!,
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight
                                                                        .w600,
                                                                    letterSpacing: 0.5),
                                                              ),
                                                              Expanded(child: SizedBox()),
                                                              Text(
                                                                symbol +
                                                                    lstAddAddonsCustom[index].price!,
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    fontFamily: "Poppinsm",
                                                                    color: Color(
                                                                        COLOR_PRIMARY)),
                                                              ),
                                                            ],
                                                          ),
                                                          value: lstAddAddonsCustom[index].isCheck,
                                                          contentPadding: EdgeInsets.zero,

                                                          */ /*secondary: Text(
                                                            symbol +
                                                                lstAddAddonsCustom[index].price!,
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight: FontWeight
                                                                    .bold,
                                                                fontFamily: "Poppinsm",
                                                                color: Color(
                                                                    COLOR_PRIMARY)),
                                                          ),*/ /*
                                                          onChanged: (
                                                              bool? val) {
                                                            itemChange(
                                                                val, index);
                                                          })*/
                                                      ;
                                                }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Container(
                            //   height: 120,
                            //   child: ListView.builder(
                            //     padding: EdgeInsets.symmetric(vertical: 16),
                            //     itemCount: widget.productModel.photos.length,
                            //     scrollDirection: Axis.horizontal,
                            //     itemBuilder: (context, index) => Padding(
                            //       padding: const EdgeInsets.only(right: 16.0),
                            //       child: GestureDetector(
                            //         onTap: () {
                            //           setState(() {
                            //             bigImageUrl = widget.productModel.photos[index];
                            //             print('_ProductDetailsScreenState.build $bigImageUrl');
                            //           });
                            //         },
                            //         child: CachedNetworkImage(
                            //           imageUrl: widget.productModel.photos[index],
                            //           imageBuilder: (context, imageProvider) => Container(
                            //             height: 120,
                            //             width: 100,
                            //             decoration: BoxDecoration(
                            //               image: DecorationImage(
                            //                   image: imageProvider, fit: BoxFit.cover),
                            //             ),
                            //           ),
                            //           placeholder: (context, url) => Center(
                            //             child: CircularProgressIndicator.adaptive(
                            //               valueColor:
                            //                   AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                            //             ),
                            //           ),
                            //           errorWidget: (context, url, error) => Container(),
                            //           fit: BoxFit.cover,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(height: 16),

                            // SizedBox(height: 16),
                            // Center(
                            //   child: Container(
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(350),
                            //       border: Border.all(color: Colors.grey.shade300),
                            //     ),
                            //     height: 50,
                            //     width: 150,
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            //       children: [
                            //         IconButton(
                            //           icon: Icon(Icons.remove),
                            //           onPressed: () {
                            //             if (widget.productModel.quantity != 1)
                            //               setState(
                            //                 () {
                            //                   widget.productModel.quantity--;
                            //                 },
                            //               );
                            //           },
                            //         ),
                            //         Text('${widget.productModel.quantity}'),
                            //         IconButton(
                            //           icon: Icon(Icons.add),
                            //           onPressed: () {
                            //             setState(
                            //               () {
                            //                 widget.productModel.quantity++;
                            //               },
                            //             );
                            //           },
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),

                            // Center(
                            //   child: Row(
                            //     mainAxisSize: MainAxisSize.max,
                            //     children: [Expanded(child:
                            //       Container(
                            //         margin: const EdgeInsets.symmetric(horizontal: 8),
                            //         padding: const EdgeInsets.all(12),
                            //         decoration: BoxDecoration(
                            //           borderRadius: BorderRadius.all(
                            //             Radius.circular(8),
                            //           ),
                            //           border: Border.all(color: Colors.grey.shade300),
                            //         ),
                            //         child: Text(
                            //           '\$${(widget.productModel.quantity * double.parse(widget.productModel.price)).toStringAsFixed(2)}',
                            //           style: TextStyle(
                            //               fontWeight: FontWeight.bold,
                            //               color: isDarkMode(context)
                            //                   ? Colors.grey[100]
                            //                   : Colors.grey[900],
                            //               fontSize: 16),
                            //         ),
                            //       )),
                            //       Expanded(
                            //         child: Padding(
                            //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            //           child: ElevatedButton(
                            //               style: ElevatedButton.styleFrom(
                            //                 padding: const EdgeInsets.all(12),
                            //                 primary: Color(COLOR_PRIMARY),
                            //                 shape: RoundedRectangleBorder(
                            //                   borderRadius: BorderRadius.all(
                            //                     Radius.circular(8),
                            //                   ),
                            //                 ),
                            //               ),
                            //               child: Text(
                            //                 'Add to Cart'.tr(),
                            //                 style: TextStyle(
                            //                     color: isDarkMode(context)
                            //                         ? Colors.black
                            //                         : Colors.white,
                            //                     fontWeight: FontWeight.bold,
                            //                     fontSize: 20),
                            //               ),
                            //               onPressed: () => onPressed()),
                            //         ),
                            //       )
                            //     ],
                            //   ),
                            // )
                          ]),
                    ))),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(bigImageUrl),
                        fit: BoxFit.cover,
                      )),
                  height: 200,
                  width: MediaQuery.of(context).size.width * 0.93),

              //  CachedNetworkImage(
              //       imageUrl:bigImageUrl,
              //       imageBuilder: (context, imageProvider) => Container(
              //         height: 250,
              //         decoration: BoxDecoration(
              //           image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              //         ),
              //       ),
              //       placeholder: (context, url) => Center(
              //         child: CircularProgressIndicator.adaptive(
              //           valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
              //         ),
              //       ),
              //       errorWidget: (context, url, error) => Icon(
              //         Icons.error,
              //         size: 50,
              //         color: Color(COLOR_PRIMARY),
              //       ),
              //       fit: BoxFit.cover,
              //     )
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Color(COLOR_PRIMARY),
                height: 60,
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Item Total \$" + priceTemp.toString(),
                            style: TextStyle(
                                fontFamily: "Poppinsm",
                                color: Colors.white,
                                fontSize: 18),
                          ).tr(),
                          SizedBox(
                            width: 15,
                          ),
                        ]),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.productModel.quantity++;
                          // priceTemp += widget.productModel.disPrice==""||widget.productModel.disPrice=="0"?
                          // double.parse(widget.productModel.price) : double.parse(widget.productModel.disPrice!);
                        });
                        // widget.productModel.price = widget.productModel.disPrice == "" || widget.productModel.disPrice == "0" ? (widget.productModel.price) : (widget.productModel.disPrice!);

                        addtocard(widget.productModel, widget.productModel.quantity, false);
                        print(widget.productModel.quantity.toString() + "======Q5");
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            (widget.vendorModel.reststatus != true)?Center():
                            Text(
                              "Add ITEM",
                              style: TextStyle(
                                  fontFamily: "Poppinsm",
                                  color: Colors.white,
                                  fontSize: 18),
                            ).tr(),
                            SizedBox(
                              width: 10,
                            ),
                          ]),
                    )
                  ],
                ),
              ),
            )
          ]))
        ]));
  }

  onPressed() async {
    List<CartProduct> cartProducts = await cartDatabase.allCartProducts;
    if (cartProducts.where((element) => element.vendorID != widget.productModel.vendorID).isEmpty) {
      cartDatabase.addProduct(widget.productModel);
      Navigator.pop(context);
    } else {
      await showDialog(
        context: context,
        builder: (BuildContext context) => ShowDialogToDismiss(
          title: 'Vendor Conflict'.tr(),
          content:
              'Do you want to remove all the other items from the cart and add this product only?'
                  .tr(),
          buttonText: 'NO'.tr(),
          secondaryButtonText: 'YES'.tr(),
          action: () async {
            cartDatabase.deleteAllProducts();
            cartDatabase.addProduct(widget.productModel);
            Navigator.pop(context);
          },
        ),
      );
      Navigator.pop(context);
    }
  }

  addtocard(productModel, int quantity, bool isCheckedValue) async {
    print("====ATEMP PRICE=== $priceTemp" + " qua " + jsonEncode(lstTempAddSSize).toString() + " prix " + widget.productModel.price);
    bool isAddOnApplied = false;
    double AddOnVal = 0;
    for (int i = 0; i < lstTemp.length; i++) {
      AddAddonsDemo addAddonsDemo = lstTemp[i];
      if (addAddonsDemo.categoryID == widget.productModel.id) {
        isAddOnApplied = true;
        AddOnVal = AddOnVal + double.parse(addAddonsDemo.price!);
      }
    }
    List<CartProduct> cartProducts = await cartDatabase.allCartProducts;
    /*List<CartProduct> cartProducts = await cartDatabase.allCartProducts;
    if (cartProducts
        .where((element) => element.vendorID != productModel.vendorID)
        .isEmpty) {
      print("====PDAdd");
      print(productModel);
      cartDatabase.addProduct(productModel);
      print("====PDAdd=Done");
    } else {
      {
        print("====PDUpdate");
        await cartDatabase.updateProduct(productModel);
        print("====PDUpdateDone");
      }
    }*/

    if (quantity > 1) {
      var joinTitleString = "";
      var joinPriceString = "";
      String mainPrice="";
      var joinSizeString = "";
      List<AddAddonsDemo> lstAddOns = [];
      List<String> lstAddOnsTemp = [];
      double extras_price = 0.0;

      List<AddSizeDemo> lstAddSize = [];
      List<String> lstAddSizeTemp = [];
      List<String> lstSizeTemp = [];
      SharedPreferences sp = await SharedPreferences.getInstance();
      String addOns = sp.getString("musics_key") != null ? sp.getString('musics_key')! : "";
      String addSize =sp.getString("addsize") != null ? sp.getString('addsize')! : "";

      bool isAddSame=false;
      if (addSize.isNotEmpty && addSize != null) {
        lstAddSize = AddSizeDemo.decode(addSize);

        for (int a = 0; a < lstAddSize.length; a++) {
          if (lstAddSize[a].categoryID == widget.productModel.id) {
            isAddSame=true;
            lstAddSizeTemp.add(lstAddSize[a].price!);
            lstSizeTemp.add(lstAddSize[a].name!);
            mainPrice = ((lstAddSize[a].price!));
          }
        }
        joinPriceString = lstAddSizeTemp.join(",");
        joinSizeString = lstSizeTemp.join(",");
      }

      if(!isAddSame) {
        if (productModel.disPrice != null &&
            productModel.disPrice!.isNotEmpty &&
            double.parse(productModel.disPrice!) != 0) {
          mainPrice = productModel.disPrice!;
        } else {
          mainPrice = productModel.price;
        }
      }

      if (addOns.isNotEmpty && addOns != null) {
        lstAddOns = AddAddonsDemo.decode(addOns);
        print(lstAddOns.length.toString() + "----LEN");
        for (int a = 0; a < lstAddOns.length; a++) {
          AddAddonsDemo newAddonsObject = lstAddOns[a];
          if (newAddonsObject.categoryID == widget.productModel.id) {
            if (newAddonsObject.isCheck == true) {
              lstAddOnsTemp.add(newAddonsObject.name!);
              extras_price += (double.parse(newAddonsObject.price!));
            }
          }
        }

        joinTitleString = lstAddOnsTemp.join(",");
      }

      await cartDatabase.updateProduct(CartProduct(
        id: productModel.id,
        name: productModel.name,
        photo: productModel.photo,
        price: mainPrice,
        discountPrice: productModel.disPrice,
        vendorID: productModel.vendorID,
        quantity: quantity,
        extras_price: extras_price.toString(),
        extras: joinTitleString,
        size: joinSizeString,
      ));
      setState(() {
        productQnt = quantity;
        // if (isCheckedValue) {
        // } else {
        //   if(extras_price != "" && extras_price != "0"){
        //     priceTemp=double.parse((extras_price*productQnt).toString());
        //   }else if(widget.productModel.disPrice != "" || widget.productModel.disPrice != "0") {
        //     priceTemp = double.parse((widget.productModel.disPrice!*productQnt).toString());
        //     if (isAddOnApplied && AddOnVal > 0) {
        //       priceTemp += (AddOnVal * productQnt);
        //     }
        //   }else{
        //     priceTemp = double.parse((widget.productModel.price*productQnt).toString());
        //     if (isAddOnApplied && AddOnVal > 0) {
        //       priceTemp += (AddOnVal * productQnt);
        //     }
        //     }
          // if (isAddOnApplied && AddOnVal > 0) {
          //   priceTemp += (AddOnVal * productQnt);
          // }
        // }
      });
      //  });
    } else {
      if (cartProducts.length == 0) {
        cartDatabase.addProduct(productModel);
        setState(() {
          productQnt = quantity;
          // if (isCheckedValue) {
          // } else {
          //   bool isFOund = false;
          //   double ProValue = 0;
          //   if (lstTempAddSSize.length != 0) {
          //     for (int a = 0; a < lstTempAddSSize.length; a++) {
          //       if (widget.productModel.id == lstTempAddSSize[a].categoryID) {
          //         isFOund = true;
          //         ProValue += double.parse(lstTempAddSSize[a].price!);
          //       }
          //     }
          //
          //     if (!isFOund) {
          //       priceTemp = ((widget.productModel.disPrice == "" || widget.productModel.disPrice == "0") ? double.parse(widget.productModel.price) : double.parse(widget.productModel.disPrice!) * productQnt);
          //     } else {
          //       priceTemp = (ProValue * productQnt);
          //     }
          //   } else {
          //     priceTemp = ((widget.productModel.disPrice == "" || widget.productModel.disPrice == "0") ? double.parse(widget.productModel.price) : double.parse(widget.productModel.disPrice!) * productQnt);
          //   }
          //   if (isAddOnApplied && AddOnVal > 0) {
          //     priceTemp += (AddOnVal * productQnt);
          //   }
          // }
        });
      } else {
        print(cartProducts[0].vendorID.toString() + "====VID===P=" +
            widget.vendorModel.id);
        if (cartProducts[0].vendorID == widget.vendorModel.id) {
          cartDatabase.addProduct(productModel);
          setState(() {
            bool isFOund = false;
            double ProValue = 0;
            productQnt = quantity;
            // if (isCheckedValue) {
            // } else {
            // if (lstTempAddSSize.length != 0) {
            //   for (int a = 0; a < lstTempAddSSize.length; a++) {
            //     if (widget.productModel.id == lstTempAddSSize[a].categoryID) {
            //       isFOund = true;
            //       ProValue += double.parse(lstTempAddSSize[a].price!);
            //     }
            //   }
            //
            //   if (!isFOund) {
            //     priceTemp = ((widget.productModel.disPrice == "" ||
            //         widget.productModel.disPrice == "0") ? double.parse(
            //         widget.productModel.price) : double.parse(
            //         widget.productModel.disPrice!) * productQnt);
            //   } else {
            //     priceTemp += ProValue;
            //   }
            // } else {
            //   priceTemp = (widget.productModel.disPrice == "" ||
            //       widget.productModel.disPrice == "0" ? double.parse(
            //       widget.productModel.price) : double.parse(
            //       widget.productModel.disPrice!) * productQnt);
            // }
            // }


          });

          // if (isAddOnApplied && AddOnVal > 0) {
          //   priceTemp += (AddOnVal * productQnt);
          // }
        } else {
          cartDatabase.deleteAllProducts();
          cartDatabase.addProduct(productModel);
          bool isFOund = false;
          double ProValue = 0;
          setState(() {
            productQnt = quantity;
            // if (isCheckedValue) {
            // } else {
            // if (lstTempAddSSize.length != 0) {
            //   for (int a = 0; a < lstTempAddSSize.length; a++) {
            //     if (widget.productModel.id == lstTempAddSSize[a].categoryID) {
            //       isFOund = true;
            //       ProValue += double.parse(lstTempAddSSize[a].price!);
            //     }
            //   }
            //
            //   if (!isFOund) {
            //     priceTemp = ((widget.productModel.disPrice == "" ||
            //         widget.productModel.disPrice == "0") ? double.parse(
            //         widget.productModel.price) : double.parse(
            //         widget.productModel.disPrice!) * productQnt);
            //   } else {
            //     priceTemp += ProValue;
            //   }
            // } else {
            //   priceTemp = (widget.productModel.disPrice == "" ||
            //       widget.productModel.disPrice == "0" ? double.parse(
            //       widget.productModel.price) : double.parse(
            //       widget.productModel.disPrice!) * productQnt);
            // }
            // }
          });

          if (isAddOnApplied && AddOnVal > 0) {
            priceTemp += (AddOnVal * productQnt);
          }
        }
      }
    }
    updatePrice();

  }

  updateToCart(productModel) async {
    List<CartProduct> cartProducts = await cartDatabase.allCartProducts;
    if (cartProducts
        .where((element) => element.vendorID != productModel.vendorID)
        .isNotEmpty) {
      await cartDatabase.updateProduct(productModel);
    }
  }

  removetocard(productModel, qun) async {
    bool isAddOnApplied = false;
    double AddOnVal = 0;
    for (int i = 0; i < lstTemp.length; i++) {
      AddAddonsDemo addAddonsDemo = lstTemp[i];
      isAddOnApplied = true;
      AddOnVal = AddOnVal + double.parse(addAddonsDemo.price!);
    }
    if (qun >= 1) {
      //setState(() async {
      print("******RMP=PD");

      var joinTitleString = "";
      var joinPriceString = "";
      String mainPrice="";
      var joinSizeString = "";
      List<AddAddonsDemo> lstAddOns = [];
      List<String> lstAddOnsTemp = [];
      double extras_price = 0.0;

      List<AddSizeDemo> lstAddSize = [];
      List<String> lstAddSizeTemp = [];
      List<String> lstSizeTemp = [];
      SharedPreferences sp = await SharedPreferences.getInstance();
      String addOns = sp.getString("musics_key") != null ? sp.getString('musics_key')! : "";
      String addSize =sp.getString("addsize") != null ? sp.getString('addsize')! : "";

      bool isAddSame=false;
      if (addSize.isNotEmpty && addSize != null) {
        lstAddSize = AddSizeDemo.decode(addSize);

        for (int a = 0; a < lstAddSize.length; a++) {
          if (lstAddSize[a].categoryID == widget.productModel.id) {
            isAddSame=true;
            lstAddSizeTemp.add(lstAddSize[a].price!);
            lstSizeTemp.add(lstAddSize[a].name!);
            mainPrice= ((lstAddSize[a].price!));
            print("===>AD****" + lstAddSize[a].price! + " " + lstAddSize[a].price!);
          }
        }
        joinPriceString = lstAddSizeTemp.join(",");
        joinSizeString = lstSizeTemp.join(",");
      }

      if(!isAddSame){
        if (productModel.disPrice != null && productModel.disPrice!.isNotEmpty &&
            double.parse(productModel.disPrice!) != 0) {
          mainPrice = productModel.disPrice!;
        } else {
          mainPrice = productModel.price;
        }      }

      if (addOns.isNotEmpty && addOns != null) {
        lstAddOns = AddAddonsDemo.decode(addOns);
        print(lstAddOns.length.toString() + "----LEN");
        for (int a = 0; a < lstAddOns.length; a++) {
          AddAddonsDemo newAddonsObject = lstAddOns[a];
          if (newAddonsObject.categoryID == widget.productModel.id) {
            if (newAddonsObject.isCheck == true) {
              lstAddOnsTemp.add(newAddonsObject.name!);
              extras_price += (double.parse(newAddonsObject.price!));
            }
          }
        }

        joinTitleString = lstAddOnsTemp.join(",");
      }

      await cartDatabase.updateProduct(CartProduct(
        id: productModel.id,
        name: productModel.name,
        photo: productModel.photo,
        price: productModel.price,
        vendorID: productModel.vendorID,
        quantity: qun,
        extras_price: extras_price.toString(),
        extras: joinTitleString,
        size: joinSizeString,
      ));
      setState(() {
        productQnt = qun;
        // if (isCheckedValue) {
        // } else {
        // priceTemp=double.parse((extras_price*productQnt).toString());
        // if(extras_price != "" && extras_price != "0"){
        // }else if(widget.productModel.disPrice != "" || widget.productModel.disPrice != "0") {
        //   priceTemp = double.parse((widget.productModel.disPrice!*productQnt).toString());
        //   if (isAddOnApplied && AddOnVal > 0) {
        //     priceTemp += (AddOnVal * productQnt);
        //   }
        // }else{
        //   priceTemp = double.parse((widget.productModel.price*productQnt).toString());
        //   if (isAddOnApplied && AddOnVal > 0) {
        //     priceTemp += (AddOnVal * productQnt);
        //   }
        // }
      });
      //});
    } else {
      cartDatabase.removeProduct(productModel.id);
      print("******RMP=PD=Done");
      setState(() {
        productQnt = qun;
        // if (productQnt == 0)
        //   priceTemp = 0;
        // else
        //   priceTemp = (widget.productModel.disPrice == "" || widget.productModel.disPrice == "0" ? double.parse(widget.productModel.price) : double.parse(widget.productModel.disPrice!))*productQnt;
        //
        // if (isAddOnApplied && AddOnVal > 0 && productQnt>0) {
        //   priceTemp += (AddOnVal * productQnt);
        // }
      });
    }
    updatePrice();
  }

  void getAddOnsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String musicsString = await prefs.getString('musics_key') != null ? prefs.getString('musics_key')! : "";
    final String addsize = await prefs.getString('addsize') != null ? prefs.getString('addsize')! : "";
    print("====+====GET " + addsize+" pq "+priceTemp.toString());

    if (musicsString.isNotEmpty && musicsString != null) {
      setState(() {
        lstTemp = AddAddonsDemo.decode(musicsString);
      });
    }

    if (widget.productModel.quantity > 0) {
      // priceTemp += ((widget.productModel.disPrice == "" || widget.productModel.disPrice == "0") ? double.parse(widget.productModel.price) : double.parse(widget.productModel.disPrice!)) * productQnt;
      lastPrice = widget.productModel.disPrice == "" || widget.productModel.disPrice == "0" ? double.parse(widget.productModel.price) : double.parse(widget.productModel.disPrice!) * productQnt;
    }

    if (addsize.isNotEmpty && addsize != null) {
      lstTempAddSSize = AddSizeDemo.decode(addsize);
      print("===>" + "AddSize If Condition--" + lstTempAddSSize.length.toString());
      for (int d = 0; d < lstTempAddSSize.length; d++) {
        if (lstTempAddSSize[d].categoryID == widget.productModel.id) {
          id = lstTempAddSSize[d].index!;
          // priceTemp += double.parse(lstTempAddSSize[d].price!);
          lastPrice = double.parse(lstTempAddSSize[d].price!);
        }
      }
    } else {
      /*else{
         lastPrice = priceTemp;
      }*/
    }

    if (lstTemp.length == 0) {
      print("===>" + "Addons If Condition");
      setState(() {
        if (widget.productModel.addOnsTitle.length != 0) {
          for (int a = 0; a < widget.productModel.addOnsTitle.length; a++) {
            AddAddonsDemo addAddonsDemo = AddAddonsDemo(
                name: widget.productModel.addOnsTitle[a],
                index: a,
                isCheck: false,
                categoryID: widget.productModel.id,
                price: widget.productModel.addOnsPrice[a]);
            lstAddAddonsCustom.add(addAddonsDemo);
            //saveAddonData(lstAddAddonsCustom);
          }
        }
      });
    } else {
      print("===>" + "Addons Else Condition");
      var tempArray = [];

      for (int d = 0; d < lstTemp.length; d++) {
        if (lstTemp[d].categoryID == widget.productModel.id) {
          AddAddonsDemo addAddonsDemo = AddAddonsDemo(
              name: lstTemp[d].name,
              index: lstTemp[d].index,
              isCheck: true,
              categoryID: lstTemp[d].categoryID,
              price: lstTemp[d].price);
          tempArray.add(addAddonsDemo);
          priceTemp += double.parse(lstTemp[d].price!) * productQnt;
        }
      }
      for (int a = 0; a < widget.productModel.addOnsTitle.length; a++) {
        var isAddonSelected = false;

        for (int temp = 0; temp < tempArray.length; temp++) {
          if (tempArray[temp].name == widget.productModel.addOnsTitle[a]) {
            isAddonSelected = true;
          }
        }
        if (isAddonSelected) {
          AddAddonsDemo addAddonsDemo = AddAddonsDemo(
              name: widget.productModel.addOnsTitle[a],
              index: a,
              isCheck: true,
              categoryID: widget.productModel.id,
              price: widget.productModel.addOnsPrice[a]);
          lstAddAddonsCustom.add(addAddonsDemo);
        } else {
          AddAddonsDemo addAddonsDemo = AddAddonsDemo(
              name: widget.productModel.addOnsTitle[a],
              index: a,
              isCheck: false,
              categoryID: widget.productModel.id,
              price: widget.productModel.addOnsPrice[a]);
          lstAddAddonsCustom.add(addAddonsDemo);
        }
      }
    }
    updatePrice();
  }

  void saveAddOns(List<AddAddonsDemo> lstTempDemo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = AddAddonsDemo.encode(lstTempDemo);
    await prefs.setString('musics_key', encodedData);
    print("====+====SAVE" + encodedData);
  }

  void saveObject(List<AddSizeDemo> lstTempAddSSize) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String musicsString = AddSizeDemo.encode(lstTempAddSSize);
    await prefs.setString('addsize', musicsString);
    print(musicsString.toString() + "======******======++++SIIZE");
  }

  void clearAddOnData() {
    bool isAddOnApplied = false;
    double AddOnVal = 0;

    for (int i = 0; i < lstTemp.length; i++) {
      if (lstTemp[i].categoryID == widget.productModel.id) {
        AddAddonsDemo addAddonsDemo = lstTemp[i];
        isAddOnApplied = true;
        AddOnVal = AddOnVal + double.parse(addAddonsDemo.price!);
      }
    }
    if (isAddOnApplied && AddOnVal > 0 && widget.productModel.quantity > 0) {
      priceTemp -= (AddOnVal * widget.productModel.quantity);
    }
  }

  Future<void> updateValueList() async {
    List<CartProduct> cartProducts = await cartDatabase.allCartProducts;
    if(cartProducts.length>0){
      addtocard(widget.productModel, widget.productModel.quantity, false);
    }
  }

  void updatePrice() {
    bool isAddOnApplied = false;
    double AddOnVal = 0;
    for (int i = 0; i < lstTemp.length; i++) {
      AddAddonsDemo addAddonsDemo = lstTemp[i];
      if (addAddonsDemo.categoryID == widget.productModel.id) {
        isAddOnApplied = true;
        AddOnVal = AddOnVal + double.parse(addAddonsDemo.price!);
      }
    }
    List<CartProduct> cartProducts=[];
    Future.delayed(const Duration(milliseconds: 500), () {
      cartProducts.clear();

      cartDatabase.allCartProducts.then((value){
        priceTemp=0;
        cartProducts.addAll(value);
        print("length cart "+cartProducts.length.toString());
        for(int i=0;i<cartProducts.length;i++){
          CartProduct e=cartProducts[i];
          if(e.extras_price!=null && e.extras_price != "" && double.parse(e.extras_price!)!=0){
            priceTemp+=double.parse(e.extras_price!)*e.quantity;
          }
            priceTemp += double.parse(e.price)*e.quantity;


        }
        setState(() {

        });
        print("cart price total $priceTemp");
      });
    });
  }

/*  void saveObject(List<AddSizeDemo> lstTempAddSSize) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String musicsString = AddSizeDemo.encode(lstTempAddSSize);

    await prefs.setString('addsize', musicsString);
    print(musicsString.toString() + "======******======++++SIIZE");
  }

  void saveAddonData(List<AddAddonsDemo> lstAddAddonsCustom1) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedDataOfAddOns = AddAddonsDemo.encode(lstAddAddonsCustom1);
    await prefs.setString('musics_key', encodedDataOfAddOns);
    //lstTemp.addAll(lstAddAddonsCustom1);

    print("======******======SAVE"+encodedDataOfAddOns.toString());
  }*/

/* getAddOnsDataFromSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String musicsString = await prefs.getString('musics_key')!??"";

    print("======******======GET"+musicsString);

    if(musicsString.isNotEmpty){
      lstAddAddonsCustomaaa = AddAddonsDemo.decode(musicsString);
    }
    setState(() {
      if ( musicsString.isEmpty || lstAddAddonsCustomaaa.length == 0) {
        if (widget.productModel.addOnsTitle.length != 0) {
          for (int a = 0; a < widget.productModel.addOnsTitle.length; a++) {
            AddAddonsDemo addAddonsDemo = AddAddonsDemo(
                name: widget.productModel.addOnsTitle[a],
                index: a,
                isCheck: false,
                categoryID: widget.productModel.id,
                price: widget.productModel.addOnsPrice[a]);
            lstAddAddonsCustom.add(addAddonsDemo);
            //saveAddonData(lstAddAddonsCustom);
          }
        }
      } else {
        for (int a = 0; a < lstAddAddonsCustomaaa.length; a++) {
          if (lstAddAddonsCustomaaa[a].categoryID == widget.productModel.id  ) {
            if(lstAddAddonsCustomaaa[a].isCheck ==true) {
              AddAddonsDemo addAddonsDemo = AddAddonsDemo(
                  name: lstAddAddonsCustomaaa[a].name,
                  index: a,
                  isCheck: true,
                  categoryID: lstAddAddonsCustomaaa[a].categoryID,
                  price: lstAddAddonsCustomaaa[a].price);
              lstAddAddonsCustom.add(addAddonsDemo);
            }else{
              AddAddonsDemo addAddonsDemo = AddAddonsDemo(
                  name: lstAddAddonsCustomaaa[a].name,
                  index: a,
                  isCheck: false,
                  categoryID: lstAddAddonsCustomaaa[a].categoryID,
                  price: lstAddAddonsCustomaaa[a].price);
              lstAddAddonsCustom.add(addAddonsDemo);
            }
            //saveAddonData(lstAddAddonsCustom);
          } else {

            if (widget.productModel.addOnsTitle.length != 0) {
              for (int a = 0; a < widget.productModel.addOnsTitle.length; a++) {
                AddAddonsDemo addAddonsDemo = AddAddonsDemo(
                    name: widget.productModel.addOnsTitle[a],
                    index: a,
                    isCheck: false,
                    categoryID: widget.productModel.id,
                    price: widget.productModel.addOnsPrice[a]);
                lstAddAddonsCustom.add(addAddonsDemo);
                //saveAddonData(lstAddAddonsCustom);
              }
            }
            break;
          }
        }
      }
    });

  }*/
}

class AddAddonsDemo {
  String? name;
  int? index;
  String? price;
  bool isCheck;
  String? categoryID;

  AddAddonsDemo(
      {this.name,
      this.index,
      this.price,
      this.isCheck = false,
      this.categoryID});

  static Map<String, dynamic> toMap(AddAddonsDemo music) => {
        'index': music.index,
        'name': music.name,
        'price': music.price,
        'isCheck': music.isCheck,
        "categoryID": music.categoryID
      };

  factory AddAddonsDemo.fromJson(Map<String, dynamic> jsonData) {
    return AddAddonsDemo(
        index: jsonData['index'],
        name: jsonData['name'],
        price: jsonData['price'],
        isCheck: jsonData['isCheck'],
        categoryID: jsonData["categoryID"]);
  }

  static String encode(List<AddAddonsDemo> item) => json.encode(
        item
            .map<Map<String, dynamic>>((item) => AddAddonsDemo.toMap(item))
            .toList(),
      );

  static List<AddAddonsDemo> decode(String item) =>
      (json.decode(item) as List<dynamic>)
          .map<AddAddonsDemo>((item) => AddAddonsDemo.fromJson(item))
          .toList();

  @override
  String toString() {
    return '{name: $name, index: $index, price: $price, isCheck: $isCheck, categoryID: $categoryID}';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'index': index,
      'price': price,
      'isCheck': isCheck,
      'categoryID': categoryID
    };
  }
}

class AddSizeDemo {
  String? name;
  int? index;
  String? price;
  String? categoryID;
  String? addOnTotalValue;

  AddSizeDemo(
      {this.name,
      this.index,
      this.price,
      this.categoryID,
      this.addOnTotalValue});

  static Map<String, dynamic> toMap(AddSizeDemo item) => {
        'index': item.index,
        'name': item.name,
        'price': item.price,
        "categoryID": item.categoryID,
        "addOnTotalValue": item.addOnTotalValue
      };

  factory AddSizeDemo.fromJson(Map<String, dynamic> jsonData) {
    return AddSizeDemo(
        index: jsonData['index'],
        name: jsonData['name'],
        price: jsonData['price'],
        categoryID: jsonData["categoryID"],
        addOnTotalValue: jsonData["addOnTotalValue"]);
  }

  /*Map<String, dynamic> toJson() => {
    'name': name,
    'index': index,
    'price': price,
    'categoryID':categoryID
  };*/

  static String encode(List<AddSizeDemo> musics) => json.encode(
        musics
            .map<Map<String, dynamic>>((music) => AddSizeDemo.toMap(music))
            .toList(),
      );

  static List<AddSizeDemo> decode(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<AddSizeDemo>((item) => AddSizeDemo.fromJson(item))
          .toList();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'index': index,
      'price': price,
      'categoryID': categoryID,
      'addOnTotalValue': addOnTotalValue
    };
  }
}

class SharedData {
  bool? isCheckedValue;
  String? categoryId;

  SharedData({this.categoryId, this.isCheckedValue});
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import '/constants.dart';
import '/main.dart';
import '/model/VendorModel.dart';
import '/model/offer_model.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';

import '../vendorProductsScreen/VendorProductsScreen.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key,required this.vendors}) : super(key: key);
final List<VendorModel> vendors;
  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  Future<List<OfferModel>>? lstOfferData;
  FireStoreUtils fireStoreUtils = FireStoreUtils();
  VendorModel? offerVendorModel = null;

  @override
  void initState() {
    super.initState();
    lstOfferData = fireStoreUtils.getViewAllOffer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    fireStoreUtils.closeOfferStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        //isDarkMode(context) ? Color(COLOR_DARK) : null,
        body: Builder(builder: (context) {
          return Stack(
            children: [

              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Image(
                    image: AssetImage(
                        "assets/images/offers_bg.png"),
                    fit: BoxFit.cover,
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Positioned(
                    left: 20,
                      child: Text("OFFERS\nFOR YOU",style: TextStyle(color: Colors.white,fontSize: 28,fontWeight: FontWeight.bold),)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      margin: EdgeInsets.fromLTRB(10, 200, 10, 0),
                      child: FutureBuilder<List<OfferModel>>(
                          future: lstOfferData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting)
                              return Container(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                              return Container(
                                height: MediaQuery.of(context).size.height * 0.9,
                                alignment: Alignment.center,
                                child: showEmptyState('No Coupons'.tr(),
                                    'All your coupons will show up here'.tr()),
                              );
                            } else {
                              return ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {

                                    if(widget.vendors.length!=0){
                                      for (int a = 0; a < widget.vendors.length; a++) {
                                          if ( snapshot.data![index].storeId==widget.vendors[a].id) {
                                            offerVendorModel = widget.vendors[a];
                                          }else{
                                          }
                                        //}
                                      }
                                    }
                                    return offerVendorModel == null
                                        ? Container() : offerItemView(offerVendorModel!,snapshot.data![index]);
                                  });
                            }
                          }),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.only(left: 5,top: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black38
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(
                      image: AssetImage(
                          "assets/images/ic_back.png"),
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String? getDate(String date) {
    final format = DateFormat("dd MMM, yyyy");
    String formattedDate = format.format(DateTime.parse(date));
    return formattedDate;
  }
  openCouponCode(
      BuildContext context,
      OfferModel offerModel,
      ) {
    return Container(
      height: 250,
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.only(
                left: 40,
                right: 40,
              ),
              padding: EdgeInsets.only(
                left: 50,
                right: 50,
              ),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/offer_code_bg.png"))),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  offerModel.offerCode!,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.9),
                ),
              )),
          GestureDetector(
            onTap: () {
              FlutterClipboard.copy(offerModel.offerCode!).then((value) {
                final SnackBar snackBar = SnackBar(
                  content: Text(
                    "Coupon code copied",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.black38,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return Navigator.pop(context);
              });
            },
            child: Container(
              margin: EdgeInsets.only(top: 30, bottom: 30),
              child: Text(
                "COPY CODE",
                style: TextStyle(
                    color: Color(COLOR_PRIMARY),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 30),
            child: RichText(
              text: TextSpan(
                text: "Use code ",
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                    fontWeight: FontWeight.w700),
                children: <TextSpan>[
                  TextSpan(
                    text: offerModel.offerCode,
                    style: TextStyle(
                        color: Color(COLOR_PRIMARY),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1),
                  ),
                  TextSpan(
                    text:
                    " & get ${offerModel.discountTypeOffer == "Fix Price" ? "\$" : ""}${offerModel.discountOffer}${offerModel.discountTypeOffer == "Percentage" ? "% off" : " off"} ",
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  offerItemView(VendorModel vendorModel, OfferModel offerModel) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // if you need this
              side: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Container(
              margin: EdgeInsets.fromLTRB(7, 7, 7, 7),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                    new BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl:
                      offerModel.imageOffer!.isEmpty ||
                          offerModel.imageOffer! == null
                          ? ""
                          : offerModel.imageOffer!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorWidget:
                          (context, url, error) =>
                          Container(
                            width: 100,
                            height: 100,
                            decoration: new BoxDecoration(
                              borderRadius:
                              new BorderRadius.circular(
                                  10),
                              color: Colors.black12,
                            ),
                            child: Image(
                              image: AssetImage("assets/images/place_holder_offer.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                      placeholder: (context, url) =>
                          Padding(padding: const EdgeInsets.all(32.0),
                            child:
                            CircularProgressIndicator(),
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5,
                        ),

                        vendorModel == null
                            ? Container()
                            : vendorModel.id.toString() == offerModel.storeId.toString()
                            ? Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap:(){
                                  push(
                                    context,
                                    VendorProductsScreen(vendorModel: vendorModel),
                                  );
                                },
                                child: Text(vendorModel.title,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily: "Poppinssm",
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      color: Color(0xff000000),
                                    )).tr(),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  ImageIcon(
                                    AssetImage(
                                        'assets/images/location3x.png'),
                                    size: 15,
                                    color: Color(0xff9091A4),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Text(vendorModel.location,
                                        maxLines: 1,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: "Poppinssr",
                                          letterSpacing: 0.5,
                                          color: Color(0xff555353),
                                        )),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ) : Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 5, 8),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text("Gromart's Offer",
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppinssm",
                                    letterSpacing: 0.5,
                                    color: Color(0xff000000),
                                  )),
                              SizedBox(
                                height: 10,
                              ),
                              Text("Apply Offer",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: "Poppinssr",
                                    letterSpacing: 0.5,
                                    color: Color(0xff555353),
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: (){
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          20.0),
                                    ),
                                    backgroundColor:
                                    Colors.transparent,
                                    enableDrag: true,
                                    builder: (context) =>
                                        openCouponCode(context, offerModel),
                                  );
                                },
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: Radius.circular(2),
                                  padding: EdgeInsets.all(2),
                                  color: Color(COUPON_DASH_COLOR),
                                  strokeWidth: 2,
                                  dashPattern: [5],
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),

                                    child: Container(
                                        height: 25,
                                        width: MediaQuery.of(context).size.width,
                                        decoration:
                                        new BoxDecoration(
                                          borderRadius:
                                          new BorderRadius
                                              .circular(2),
                                          color: Color(
                                              COUPON_BG_COLOR),
                                        ),
                                        padding: EdgeInsets.only(top: 4),
                                        child: Text(
                                          offerModel.offerCode!,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontFamily:
                                              "Poppins",
                                              fontWeight:
                                              FontWeight.bold,
                                              letterSpacing: 0.5,
                                              color: Color(
                                                  COLOR_PRIMARY)),
                                        )),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5,),

                            vendorModel.id.toString() == offerModel.storeId.toString()? Row(
                              mainAxisSize:
                              MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 20,
                                  color: Color(
                                      COLOR_PRIMARY),
                                ),
                                SizedBox(width: 3),
                                Text(
                                    vendorModel.reviewsCount !=
                                        0
                                        ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}'
                                        : 0.toString(),
                                    style: TextStyle(
                                      fontFamily:
                                      "Poppinssr",
                                      letterSpacing: 0.5,
                                      color: Color(
                                          0xff000000),
                                    )),
                                SizedBox(width: 3),
                                Text(
                                    '(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                                    style: TextStyle(
                                      fontFamily:
                                      "Poppinssr",
                                      letterSpacing: 0.5,
                                      color: Color(
                                          0xff666666),
                                    )),
                              ],
                            ):Container(),
                          ],
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                    width: 75,
                    margin: EdgeInsets.only(bottom: 10),
                    child: Image(
                        image: AssetImage(
                            "assets/images/offer_badge.png"))),
                Container(
                  margin: EdgeInsets.only(top: 3),
                  child: Text(
                    "${offerModel.discountTypeOffer=="Fix Price"?"\$":""}${offerModel.discountOffer}${offerModel.discountTypeOffer=="Percentage"?"% Off":" Off"}",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.7),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

}

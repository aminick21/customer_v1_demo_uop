import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/AppGlobal.dart';
import '/constants.dart';
import '/main.dart';
import '/model/AddressModel.dart';
import '/model/CuisineModel.dart';
import '/model/CurrencyModel.dart';
import '/model/FavouriteModel.dart';
import '/model/ProductModel.dart';
import '/model/User.dart';
import '/model/VendorModel.dart';
import '/model/offer_model.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';
import '/ui/categoryDetailsScreen/CategoryDetailsScreen.dart';
import '/ui/cuisinesScreen/CuisinesScreen.dart';
import '/ui/home/CurrentAddressChangeScreen.dart';
import '/ui/home/view_all_new_arrival_store_screen.dart';
import '/ui/home/view_all_offer_screen.dart';
import '/ui/home/view_all_popular_food_near_by_screen.dart';
import '/ui/home/view_all_popular_store_screen.dart';
import '/ui/vendorProductsScreen/VendorProductsScreen.dart';
import 'package:intl/intl.dart';
import 'package:clipboard/clipboard.dart';
import 'package:location/location.dart' as loc;


// import 'package:extended_list/extended_list.dart';
// import 'package:loadmore/loadmore.dart';
// import 'package:infinite_widgets/infinite_widgets.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final fireStoreUtils = FireStoreUtils();
  late Future<List<CuisineModel>> cuisinesFuture;
  late Future<List<VendorModel>> vendorsFuture;

  //late Future<List<VendorModel>> vendorsNewArrival;
  late Future<List<ProductModel>> productsFuture;
  List<ProductModel> _products = [];
  PageController _controller =
      PageController(viewportFraction: 0.8, keepPage: true);
  List<VendorModel> vendors = [];
  List<VendorModel> allvendors = [];
  List<VendorModel> storeAllLst = [];
  List<VendorModel> popularStoreLst = [];
  List<VendorModel> newArrivalLst = [];
  List<VendorModel> offerListVendor = [];
  late Future<List<CurrencyModel>> futureCurrency;
  String? data, d;
  VendorModel? offerVendorModel = null;
  VendorModel? popularNearFoodVendorModel = null;
  late Future<Position> currenLocation;
  var currentlatitude, currentlongitude;
  Stream<List<VendorModel>>? lstVendor;
  Stream<List<VendorModel>>? lstNewArrivalStore;
  Stream<List<VendorModel>>? lstAllStore;
  List<VendorModel> lstTempAllStore = [];
  List<ProductModel> lstNearByFood = [];
  bool showLoader = true;

  //Stream<List<FavouriteModel>>? lstFavourites;
  late Future<List<FavouriteModel>> lstFavourites;
  List<String> lstFav = [];
  FavouriteModel? selectedFavourites;

  // List<ProductModel> product = [];
  String? name = "";

  String? currentLocation = "", placeHolderImage = "";

  String? selctedOrderTypeValue = "Delivery";
  Stream<List<OfferModel>>? lstOfferData;

  //Stream<List<OfferModel>>? lstOfferData1;

  List<OfferModel> lstOfferData1 = [];
  List<OfferModel> lst = [];
  List<VendorModel> vendorssssss = [];

  // Init firestore and geoFlutterFire
  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;

  _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high)
        .whenComplete(() {});
    debugPrint('location: ${position.latitude}');
    final coordinates = Coordinates(position.latitude, position.longitude);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placeMark = placemarks[0];
    setState(() {
      currentLocation = placeMark.name.toString() +
          ", " +
          placeMark.subLocality.toString() +
          ", " +
          placeMark.locality.toString() +
          ", " +
          placeMark.administrativeArea.toString() +
          ", " +
          placeMark.postalCode.toString() +
          ", " +
          placeMark.country.toString();
    });
    AddressModel userAddress = AddressModel(
        name: MyAppState.currentUser!.fullName(),
        postalCode: placeMark.postalCode.toString(),
        line1:
            placeMark.name.toString() + ", " + placeMark.subLocality.toString(),
        line2: placeMark.administrativeArea.toString(),
        country: placeMark.country.toString(),
        city: placeMark.locality.toString(),
        location: MyAppState.currentUser!.location,
        email: MyAppState.currentUser!.email);
    MyAppState.currentUser!.shippingAddress = userAddress;
    await FireStoreUtils.updateCurrentUserAddress(userAddress);

    print(currentLocation.toString() +
        "======={}{}{}{}{}{{" +
        placeMark.country.toString());
  }

  bool isLocationPermissionAllowed = false;
  loc.Location location = new loc.Location();

  getLoc() async{
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();


      if (!_serviceEnabled) {
        print("+++NO THANKS");
        getLoc();
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();

      if (_permissionGranted != loc.PermissionStatus.granted) {

        return;
      }
    }
    _getLocation();
    getData();
    //_currentPosition = await location.getLocation();
  }

  // Database db;
  @override
  void initState() {
    super.initState();
    print("[[[[[]]]]]]");
    cuisinesFuture = fireStoreUtils.getCuisines();
    futureCurrency = FireStoreUtils().getCurrency();
    fireStoreUtils.getVendors().then((value) {
      if(value!=null){
        allvendors.clear();
        allvendors.addAll(value);
      }
    });
    // FireStoreUtils().getRazorPayDemo();
    // FireStoreUtils.getPaypalSettingData();
    FireStoreUtils.getStripeSettingData();
    // FireStoreUtils.getPaytmSettingData();
    print(razorpayKey.toString() + "====");
    print(isLocationPermissionAllowed);
   // if (isLocationPermissionAllowed == false) {
      getLoc();
    //} else {}




    // FireStoreUtils().getRazorPayDemo();
    // FireStoreUtils.getPaypalSettingData();
    FireStoreUtils.getStripeSettingData();
    // FireStoreUtils.getPaytmSettingData();
    // FireStoreUtils.getWalletSettingData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            isDarkMode(context) ? Color(DARK_COLOR) : Color(0xffFFFFFF),
        body: SingleChildScrollView(
          child: Container(
            color: isDarkMode(context) ? Color(DARK_COLOR) : Color(0xffFFFFFF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color:
                              isDarkMode(context) ? Colors.white : Colors.black,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Text(currentLocation.toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(COLOR_PRIMARY),
                                      fontFamily: "Poppinsr"))
                              .tr(),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      CurrentAddressChangeScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return child;
                              },
                            ))
                                .then((value) {
                              if (value != null) {
                                setState(() {
                                  currentLocation = value;
                                });
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            decoration: BoxDecoration(
                                borderRadius: new BorderRadius.circular(10),
                                color: Colors.black12,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ]),
                            child: Text("Change",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(COLOR_PRIMARY),
                                        fontFamily: "Poppinsr"))
                                .tr(),
                          ),
                        ),
                      ],
                    )),
                Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                    child: Text("Hello " + name! + ",",
                            style: TextStyle(
                                fontSize: 25,
                                color: Color(COLOR_PRIMARY),
                                fontFamily: "Poppinsr"))
                        .tr()),
                Container(
                    padding: const EdgeInsets.only(
                        top: 0, left: 16, bottom: 20, right: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text("Find your grocery",
                                  style: TextStyle(
                                      fontSize: 27,
                                      color: isDarkMode(context)
                                          ? Colors.white
                                          : Color(0xFF333333),
                                      fontFamily: "Poppinssb"))
                              .tr(),
                        ),
                        Row(
                          children: [
                            Container(
                              child: DropdownButton(
                                // Not necessary for Option 1
                                value: selctedOrderTypeValue,
                                onChanged: (newValue) {
                                  /*if(newValue!=null){
                                    lstNearByFood.clear();
                                  }*/
                                  setState(() {
                                    selctedOrderTypeValue = newValue.toString();

                                    saveFoodTypeValue();
                                    if (selctedOrderTypeValue == "Takeaway") {
                                      productsFuture = fireStoreUtils
                                          .getAllTakeAWayProducts();

                                      // lstAllRestaurant!.listen((event) {
                                      lstNearByFood.clear();
                                      productsFuture.then((value) {
                                        var length = lstTempAllStore.length <= 20
                                            ? lstTempAllStore.length
                                            : 20;

                                        for (int a = 0; a < lstTempAllStore.length; a++) {

                                          for (int d = 0; d < length; d++) {
                                            if (lstTempAllStore[a].id ==
                                                value[d].vendorID) {

                                              setState(() {
                                                lstNearByFood.add(value[d]);
                                              });

                                            }
                                          }
                                        }
                                        print(
                                            lstNearByFood.length.toString() +
                                                "==={}***{}===Takeaway");
                                      });
                                      // });
                                    } else {
                                      productsFuture =
                                          fireStoreUtils.getAllProducts();
                                      // lstAllRestaurant!.listen((event) {
                                      lstNearByFood.clear();
                                      productsFuture.then((value) {
                                        var length = lstTempAllStore.length <= 20
                                            ? lstTempAllStore.length
                                            : 20;

                                        for (int a = 0;
                                        a < lstTempAllStore.length;
                                        a++) {

                                          for (int d = 0; d < length; d++) {
                                            if (lstTempAllStore[a].id ==
                                                value[d].vendorID) {

                                              setState(() {
                                                lstNearByFood.add(value[d]);
                                              });
                                            }
                                          }
                                        }
                                        print(
                                            lstNearByFood.length.toString() +
                                                "==={}***{}===Delivery");
                                      });
                                      /*   }).onError((handleError) {
                                        print(handleError.toString() + "[][][");
                                      });*/
                                    }
                                    //print(selctedOrderTypeValue.toString() + "==={}{}===11");
                                  });
                                },
                                icon: Icon(Icons.keyboard_arrow_down),
                                items: [
                                  'Delivery',
                                  'Takeaway',
                                ].map((location) {
                                  return DropdownMenuItem(
                                    child: new Text(location),
                                    value: location,
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        )
                      ],
                    )),

                buildTitleRow(
                  titleValue: "Categories",
                  onClick: () {
                    push(
                      context,
                      CuisinesScreen(
                        isPageCallFromHomeScreen: true,
                      ),
                    );
                  },
                ),
                Container(
                  color: isDarkMode(context)
                      ? Color(DARK_COLOR)
                      : Color(0xffFFFFFF),
                  child: FutureBuilder<List<CuisineModel>>(
                      future: cuisinesFuture,
                      initialData: [],
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return Center(
                            child: CircularProgressIndicator.adaptive(
                              valueColor:
                              AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                            ),
                          );

                        if (snapshot.hasData ||
                            (snapshot.data?.isNotEmpty ?? false)) {
                          return Container(
                              padding: EdgeInsets.only(left: 10),
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.length >= 15
                                    ? 15
                                    : snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return buildCategoryItem(
                                      snapshot.data![index]);
                                },
                              ));
                        } else {
                          return showEmptyState('No Categories'.tr(),
                              'Start by adding categories to firebase.'.tr());
                        }
                      }),
                ),
                Container(
                  color: isDarkMode(context)
                      ? Color(DARK_COLOR)
                      : Color(0xffFFFFFF),
                  padding: EdgeInsets.only(bottom: 25),
                  child: FutureBuilder<List<CuisineModel>>(
                    future: cuisinesFuture,
                    initialData: [],
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Center(
                          child: CircularProgressIndicator.adaptive(
                            valueColor:
                                AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                          ),
                        );

                      if (snapshot.hasData ||
                          (snapshot.data?.isNotEmpty ?? false)) {
                        return Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.23,
                                child: PageView.builder(
                                    itemCount: snapshot.data!.length,
                                    scrollDirection: Axis.horizontal,
                                    controller: _controller,
                                    allowImplicitScrolling: true,
                                    itemBuilder: (context, index) =>
                                        buildBestDealPage(
                                            snapshot.data![index]))),

                            /*   Positioned(
                              bottom: 10,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: SmoothPageIndicator(
                                    controller: _controller,
                                    effect: ScaleEffect(
                                      spacing: 10,
                                      activeDotColor: Colors.white,
                                      dotColor: Colors.grey,
                                      dotWidth: 5,
                                      dotHeight: 5,
                                    ),
                                    count: snapshot.data!.length),
                              ),
                            )*/
                          ],
                        );
                      } else {
                        return showEmptyState('No Deals'.tr(),
                            'Start by adding best deals to firebase.'.tr());
                      }
                    },
                  ),
                ),

                buildTitleRow(
                  titleValue: "Top Selling",
                  onClick: () {
                    push(
                      context,
                      ViewAllPopularFoodNearByScreen(),
                    );
                  },
                ),
                Container(
                  height: 120,
                  child: showLoader
                      ? Center(
                          child: CircularProgressIndicator.adaptive(
                            valueColor:
                                AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                          ),
                        )
                      : lstNearByFood.length == 0
                          ? showEmptyState('No popular item found'.tr(),
                              'Start by adding categories to firebase.'.tr())
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: lstNearByFood.length >= 15
                                  ? 15
                                  : lstNearByFood.length,
                              itemBuilder: (context, index) {
                                print(lstNearByFood.length.toString() + "===<><><><");


                                if (vendors.length != 0) {
                                  for (int a = 0; a < vendors.length; a++) {
                                    print(vendors[a].categoryID.toString() + "===<><><><=="+lstNearByFood[index].categoryID);
                                    if (vendors[a].id == lstNearByFood[index].vendorID) {
                                      popularNearFoodVendorModel = vendors[a];

                                    } else {}
                                  }
                                }

                                return popularFoodItem(
                                    context, lstNearByFood[index],popularNearFoodVendorModel!);
                              }),
                ),
                buildTitleRow(
                  titleValue: "New Arrivals",
                  onClick: () {
                    push(
                      context,
                      ViewAllNewArrivalStoreScreen(),
                    );
                  },
                ),
                StreamBuilder<List<VendorModel>>(
                    stream: lstNewArrivalStore,
                    initialData: [],
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Center(
                          child: CircularProgressIndicator.adaptive(
                            valueColor:
                                AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                          ),
                        );

                      if (snapshot.hasData ||
                          (snapshot.data?.isNotEmpty ?? false)) {
                        newArrivalLst = snapshot.data!;

                        return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 260,
                            margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                itemCount: newArrivalLst.length >= 15
                                    ? 15
                                    : newArrivalLst.length,
                                itemBuilder: (context, index) =>
                                    buildNewArrivalItem(newArrivalLst[index])));
                      } else {
                        return showEmptyState('No Vendors'.tr(),
                            'Start by adding vendors to firebase.'.tr());
                      }
                    }),
                buildTitleRow(
                  titleValue: "Offers For You",
                  onClick: () {
                    push(
                      context,
                      OffersScreen(
                        vendors: allvendors,
                      ),
                    );
                  },
                ),
                StreamBuilder<List<OfferModel>>(
                    stream: lstOfferData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Container(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      /* if (!snapshot.hasData ||
                          (snapshot.data?.isEmpty ?? true)) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.9,
                          alignment: Alignment.center,
                          child: showEmptyState('No Coupons'.tr(),
                              'All your coupons will show up here'.tr()),
                        );
                      } else {
                        return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {

                                  for (int a = 0; a < vendors.length; a++) {
                                    for (int offa = 0;
                                        offa < snapshot.data!.length;
                                        offa++) {
                                      if (vendors[a].id ==
                                          snapshot.data![offa].restaurantId) {
                                        //setState(() {

                                        offerVendorModel = vendors[a];
                                        print(offerVendorModel!.id.toString() +
                                            "{}{{}{}{}}{}");

                                        //});
                                      }
                                    }
                                  }
                                  return offerVendorModel == null?Container():buildCouponsForYouItem(offerVendorModel!,
                                      snapshot.data![index]);
                                }));
                      }  */ /* else {
                        return showEmptyState('No Vendors'.tr(),
                            'Start by adding vendors to firebase.'.tr());
                      } */
                      if (snapshot.hasData ||
                          (snapshot.data?.isNotEmpty ?? false)) {
                        // lstVendor!.listen((event) {
                        //   vendors.addAll(event);
                        // });
                        print(allvendors.length.toString() +
                            "---------------------------+");
                        return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                itemCount: snapshot.data!.length >= 15
                                    ? 15
                                    : snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  print(snapshot.data!.length.toString() +
                                      "OFL=" +
                                      allvendors.length.toString());
                                  if (allvendors.length != 0) {
                                    for (int a = 0; a < allvendors.length; a++) {
                                      if (allvendors[a].id ==
                                          snapshot.data![index].storeId) {
                                        offerVendorModel = allvendors[a];
                                      }
                                    }
                                  }
                                  return offerVendorModel == null
                                      ? Container()
                                      : buildCouponsForYouItem(
                                          context,
                                          offerVendorModel!,
                                          snapshot.data![index]);
                                }));
                      } else {
                        return showEmptyState('No Vendors'.tr(),
                            'Start by adding vendors to firebase.'.tr());
                      }
                    }),
                buildTitleRow(
                  titleValue: "Most Popular",
                  onClick: () {
                    push(
                      context,
                      ViewAllPopularStoreScreen(),
                    );
                  },
                ),
                popularStoreLst.length == 0
                    ? showEmptyState('No Popular Items'.tr(),
                        'No popular Items found.'.tr())
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: 260,
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            itemCount: popularStoreLst.length >= 5
                                ? 5
                                : popularStoreLst.length,
                            itemBuilder: (context, index) => buildPopularsItem(
                                popularStoreLst[index]))),
                buildTitleRow(
                  titleValue: "All Items",
                  onClick: () {},
                  isViewAll: true,
                ),
                Builder(builder: (context) {
                  return StreamBuilder<List<VendorModel>>(
                      stream: lstAllStore,
                      initialData: [],
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return Center(
                            child: CircularProgressIndicator.adaptive(
                              valueColor:
                                  AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                            ),
                          );

                        if (snapshot.hasData ||
                            (snapshot.data?.isNotEmpty ?? false)) {
                          vendors.clear();
                          vendors.addAll(snapshot.data!);

                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                physics: BouncingScrollPhysics(),
                                itemCount: vendors.length,
                                itemBuilder: (context, index) =>
                                    //buildVendorItem(vendors[index])

                                    buildAllStoresData(vendors[index])),
                          );
                        } else {
                          return showEmptyState('No Items'.tr(),
                              'Start by adding vendors to firebase.'.tr());
                        }
                      });
                }),
                Container(
                  height: 0,
                  child: FutureBuilder<List<CurrencyModel>>(
                      future: futureCurrency,
                      initialData: [],
                      builder: (context, snapshot) {
                        return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return curcy(snapshot.data![index]);
                            });
                      }),
                )
              ],
            ),
          ),
        ));
  }

  Widget buildVendorItemData(
    BuildContext context,
    ProductModel product,
  ) {
    return Container(
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.circular(10),
        color: Colors.white,
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: new BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: product.photo,
              height: 100,
              width: 100,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
              )),
              errorWidget: (context, url, error) => ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(placeHolderImage!)),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  product.name,
                  style: TextStyle(
                    fontFamily: "Poppinssm",
                    fontSize: 18,
                    color: Color(0xff000000),
                  ),
                  maxLines: 1,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  product.description,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: "Poppinssm",
                    fontSize: 16,
                    color: Color(0xff9091A4),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "\$${product.price}",
                  style: TextStyle(
                    fontFamily: "Poppinssm",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffE87034),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget popularFoodItem(
      BuildContext context,
      ProductModel product, VendorModel popularNearFoodVendorModel,
      ) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => push(
        context,
        VendorProductsScreen(vendorModel: popularNearFoodVendorModel),
      ),
      child: Container(
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(10),
          color: Colors.white,
        ),
        width: MediaQuery.of(context).size.width * 0.8,
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: new BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: product.photo,
                height: 100,
                width: 100,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image:
                    DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                    )),
                errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(placeHolderImage!,fit: BoxFit.cover,)),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    product.name,
                    style: TextStyle(
                      fontFamily: "Poppinssm",
                      fontSize: 18,
                      color: Color(0xff000000),
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    product.description,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: "Poppinssm",
                      fontSize: 16,
                      color: Color(0xff9091A4),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  /*Text(
                    product.disPrice=="" || product.disPrice =="0"?"\$${product.price}":"\$${product.disPrice}",
                    style: TextStyle(
                      fontFamily: "Poppinssm",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffE87034),
                    ),
                  ),*/
                  product.disPrice == "" ||
                      product.disPrice == "0"
                      ? Text(
                    symbol +
                        '${product.price}',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Poppinssb",
                        letterSpacing: 0.5,
                        color: Color(COLOR_PRIMARY)),
                  ):Row(
                    children: [
                      Text(
                        '${product.price}',
                        style: TextStyle(
                            fontFamily: "Poppinssm",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough
                        ),
                      ),
                      SizedBox(width: 10,),
                      Text(
                        "\$${product.disPrice}",
                        style: TextStyle(
                          fontFamily: "Poppinssm",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(COLOR_PRIMARY),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildAllStoresData(VendorModel vendorModel) {
    return GestureDetector(
      onTap: () => push(
        context,
        VendorProductsScreen(vendorModel: vendorModel),
      ),
      child: Container(
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(10),
          color: Colors.white,
        ),
        width: MediaQuery.of(context).size.width * 0.8,
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: new BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: vendorModel.photo,
                height: 100,
                width: 100,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                )),
                errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(placeHolderImage!,fit: BoxFit.cover,)),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendorModel.title,
                          style: TextStyle(
                            fontFamily: "Poppinssm",
                            fontSize: 18,
                            color: Color(0xff000000),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (lstFav.contains(vendorModel.id) == true) {
                              print(lstFav.length.toString() + "----REMOVE");
                              FavouriteModel favouriteModel = FavouriteModel(
                                  store_id: vendorModel.id,
                                  user_id: MyAppState.currentUser!.userID);
                              lstFav.removeWhere(
                                  (item) => item == vendorModel.id);
                              fireStoreUtils
                                  .removeFavouriteStore(favouriteModel);
                            } else {
                              FavouriteModel favouriteModel = FavouriteModel(
                                  store_id: vendorModel.id,
                                  user_id: MyAppState.currentUser!.userID);
                              fireStoreUtils
                                  .setFavouriteStore(favouriteModel);
                              lstFav.add(vendorModel.id);
                              print(lstFav.length.toString() + "----ADD");
                            }
                          });
                        },
                        child: lstFav.contains(vendorModel.id) == true
                            ? Icon(
                                Icons.favorite,
                                color: Color(COLOR_PRIMARY),
                              )
                            : Icon(
                                Icons.favorite_border,
                                color: Colors.black38,
                              ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    vendorModel.location,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: "Poppinssm",
                      fontSize: 16,
                      color: Color(0xff9091A4),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 20,
                        color: Color(COLOR_PRIMARY),
                      ),
                      SizedBox(width: 3),
                      Text(
                          vendorModel.reviewsCount != 0
                              ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}'
                              : 0.toString(),
                          style: TextStyle(
                            fontFamily: "Poppinssr",
                            letterSpacing: 0.5,
                            color: Color(0xff000000),
                          )),
                      SizedBox(width: 3),
                      Text('(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                          style: TextStyle(
                            fontFamily: "Poppinssr",
                            letterSpacing: 0.5,
                            color: Color(0xff666666),
                          )),
                      SizedBox(width: 5),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  buildCategoryItem(CuisineModel model) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          push(
            context,
            CategoryDetailsScreen(
              category: model,
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedNetworkImage(
              imageUrl: model.photo,
              imageBuilder: (context, imageProvider) => Container(
                height: 75,
                width: 75,
                decoration: BoxDecoration(
                    border: Border.all(width: 3, color: Color(COLOR_PRIMARY)),
                    borderRadius: BorderRadius.circular(75)),
                child: Container(
                  // height: 80,width: 80,
                  decoration: BoxDecoration(
                      border: Border.all(
                        width: 3,
                        color: isDarkMode(context)
                            ? Color(DARK_COLOR)
                            : Color(0xffE0E2EA),
                      ),
                      borderRadius: BorderRadius.circular(75)),
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(75),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
              ),
              placeholder: (context, url) => ClipOval(
                child: Container(
                  // padding: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(75 / 1)),
                    border: Border.all(
                      color: Color(COLOR_PRIMARY),
                      style: BorderStyle.solid,
                      width: 2.0,
                    ),
                  ),
                  width: 75,
                  height: 75,
                  child: Icon(
                    Icons.fastfood,
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ),
            ),
            // displayCircleImage(model.photo, 90, false),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                  child: Text(model.title,
                      style: TextStyle(
                        color: isDarkMode(context)
                            ? Colors.white
                            : Color(0xFF000000),
                        fontFamily: "Poppinsr",
                      )).tr()),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    fireStoreUtils.closeOfferStream();
    fireStoreUtils.closeVendorStream();
    fireStoreUtils.closeNewArrivalStream();
    super.dispose();
  }

  Widget buildBestDealPage(CuisineModel categoriesModel) {
    return GestureDetector(
      onTap: () => push(
        context,
        CategoryDetailsScreen(category: categoriesModel),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          //s width: MediaQuery.of(context).size.width*0.9,
          // height: 80,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                  image: NetworkImage(categoriesModel.photo),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5), BlendMode.darken))),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.fromLTRB(10, 0, 3, 0),
              decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(20),
                  color: Colors.green),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Order Now",
                          style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFFFFFFFF),
                              fontFamily: "Poppinssb"))
                      .tr(),
                  SizedBox(
                    child: Icon(Icons.chevron_right, color: Color(0xFFFFFFFF)),
                  )
                ],
              ),
            ),
          ),
          /* child: Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.04),
            child: Text(
              categoriesModel.title,
              style: TextStyle(color: Colors.white, fontSize: 17),
            ).tr(),
          ),*/
        ),
      ),
    );
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

  Widget buildNewArrivalItem(VendorModel vendorModel) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
      child: GestureDetector(
        onTap: () => push(
          context,
          VendorProductsScreen(vendorModel: vendorModel),
        ),
        child: Container(
          // margin: EdgeInsets.all(5),
          width: MediaQuery.of(context).size.width * 0.75,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100, width: 0.1),
                boxShadow: [
                  isDarkMode(context)
                      ? BoxShadow()
                      : BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 8.0,
                          spreadRadius: 1.2,
                          offset: Offset(0.2, 0.2),
                        ),
                ],
                color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: CachedNetworkImage(
                  imageUrl: vendorModel.photo,
                  width: MediaQuery.of(context).size.width * 0.75,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => Center(
                      child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  )),
                  errorWidget: (context, url, error) => ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        placeHolderImage!,
                        width: MediaQuery.of(context).size.width * 0.75,
                        fit: BoxFit.fitWidth,
                      )),
                  fit: BoxFit.cover,
                )),
                SizedBox(height: 8),
                Container(
                  margin: EdgeInsets.fromLTRB(15, 0, 5, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendorModel.title,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: "Poppinssm",
                            letterSpacing: 0.5,
                            color: Color(0xff000000),
                          )).tr(),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            AssetImage('assets/images/location3x.png'),
                            size: 15,
                            color: Color(0xff9091A4),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(vendorModel.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: "Poppinssr",
                                  letterSpacing: 0.5,
                                  color: Color(0xff555353),
                                )),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 20,
                                  color: Color(COLOR_PRIMARY),
                                ),
                                SizedBox(width: 3),
                                Text(
                                    vendorModel.reviewsCount != 0
                                        ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}'
                                        : 0.toString(),
                                    style: TextStyle(
                                      fontFamily: "Poppinssr",
                                      letterSpacing: 0.5,
                                      color: Color(0xff000000),
                                    )),
                                SizedBox(width: 3),
                                Text(
                                    '(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                                    style: TextStyle(
                                      fontFamily: "Poppinssr",
                                      letterSpacing: 0.5,
                                      color: Color(0xff666666),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPopularsItem(VendorModel vendorModel) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      child: GestureDetector(
        onTap: () => push(
          context,
          VendorProductsScreen(vendorModel: vendorModel),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100, width: 0.1),
              boxShadow: [
                isDarkMode(context)
                    ? BoxShadow()
                    : BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 8.0,
                        spreadRadius: 1.2,
                        offset: Offset(0.2, 0.2),
                      ),
              ],
              color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  child: CachedNetworkImage(
                imageUrl: vendorModel.photo,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image:
                        DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                )),
                errorWidget: (context, url, error) =>ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    placeHolderImage!,
                    width: MediaQuery.of(context).size.width * 0.75,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                fit: BoxFit.cover,
              )),
              SizedBox(height: 8),
              Container(
                margin: EdgeInsets.fromLTRB(15, 0, 5, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendorModel.title,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: "Poppinssm",
                          letterSpacing: 0.5,
                          color: Color(0xff000000),
                        )).tr(),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageIcon(
                          AssetImage('assets/images/location3x.png'),
                          size: 15,
                          color: Color(0xff9091A4),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(vendorModel.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "Poppinssr",
                                letterSpacing: 0.5,
                                color: Color(0xff555353),
                              )),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 20,
                                color: Color(COLOR_PRIMARY),
                              ),
                              SizedBox(width: 3),
                              Text(
                                  vendorModel.reviewsCount != 0
                                      ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}'
                                      : 0.toString(),
                                  style: TextStyle(
                                    fontFamily: "Poppinssr",
                                    letterSpacing: 0.5,
                                    color: Color(0xff000000),
                                  )),
                              SizedBox(width: 3),
                              Text(
                                  '(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                                  style: TextStyle(
                                    fontFamily: "Poppinssr",
                                    letterSpacing: 0.5,
                                    color: Color(0xff666666),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCouponsForYouItem(
      BuildContext context1, VendorModel vendorModel, OfferModel offerModel) {
    return vendorModel == null
        ? Container()
        : Container(
          margin:EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    child: GestureDetector(
              onTap: () {
                //print(offerModel.offerCode+"====<><><>====");
                if (vendorModel.id.toString() ==
                    offerModel.storeId.toString()) {
                  push(
                    context,
                    VendorProductsScreen(vendorModel: vendorModel),
                  );
                } else {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    isDismissible: true,
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    backgroundColor: Colors.transparent,
                    enableDrag: true,
                    builder: (context) => openCouponCode(context, offerModel),
                  );
                }
              },
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.grey.shade100, width: 0.1),
                          boxShadow: [
                            isDarkMode(context)
                                ? BoxShadow()
                                : BoxShadow(
                                    color: Colors.grey.shade400,
                                    blurRadius: 8.0,
                                    spreadRadius: 1.2,
                                    offset: Offset(0.2, 0.2),
                                  ),
                          ],
                          color: Colors.white),
                      child: Column(
                        children: [
                          Expanded(
                              child: CachedNetworkImage(
                            imageUrl: offerModel.imageOffer!,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            placeholder: (context, url) => Center(
                                child: CircularProgressIndicator.adaptive(
                              valueColor:
                                  AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                            )),
                            errorWidget: (context, url, error) => ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                placeHolderImage!,
                                width: MediaQuery.of(context).size.width * 0.75,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            fit: BoxFit.cover,
                          )),
                          SizedBox(height: 8),
                          vendorModel == null
                              ? Container()
                              : vendorModel.id.toString() ==
                                      offerModel.storeId.toString()
                                  ? Container(
                                      margin: EdgeInsets.fromLTRB(15, 0, 5, 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(vendorModel.title,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontFamily: "Poppinssm",
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                                color: Color(0xff000000),
                                              )).tr(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0, bottom: 10),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      offerModel.offerCode!,
                                                      style: TextStyle(
                                                        fontFamily: "Poppinssm",
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(0xffE87034),
                                                      ),
                                                    ),
                                                    Row(
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
                                                        SizedBox(width: 5),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(
                                      margin: EdgeInsets.fromLTRB(15, 0, 5, 8),
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
                                          SizedBox(
                                            height: 10,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              FlutterClipboard.copy(
                                                      offerModel.offerCode!)
                                                  .then(
                                                      (value) => print('copied'));
                                            },
                                            child: Text(
                                              offerModel.offerCode!,
                                              style: TextStyle(
                                                fontFamily: "Poppinssm",
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xffE87034),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                        ],
                      ),
                    ),
                    /* vendorModel.id.toString()==offerModel.restaurantId.toString()?*/
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        margin: EdgeInsets.only(top: 150),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Container(
                                    width: 120,
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: Image(
                                        image: AssetImage(
                                            "assets/images/offer_badge.png"))),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Text(
                                    "${offerModel.discountTypeOffer == "Fix Price" ? "\$" : ""}${offerModel.discountOffer}${offerModel.discountTypeOffer == "Percentage" ? "% Off" : " Off"} ",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.7),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ) /*:Container()*/
                  ],
                ),
              ),
            ),
        );
  }

  Widget buildVendorItem(VendorModel vendorModel) {
    return GestureDetector(
      onTap: () => push(
        context,
        VendorProductsScreen(vendorModel: vendorModel),
      ),
      child: Container(
        height: 120,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100, width: 0.1),
            boxShadow: [
              isDarkMode(context)
                  ? BoxShadow()
                  : BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 8.0,
                      spreadRadius: 1.2,
                      offset: Offset(0.2, 0.2),
                    ),
            ],
            color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
                child: CachedNetworkImage(
              imageUrl: vendorModel.photo,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
              )),
              errorWidget: (context, url, error) => ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(placeHolderImage!)),
              fit: BoxFit.cover,
            )),
            SizedBox(height: 8),
            ListTile(
              title: Text(vendorModel.title,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: "Poppinssm",
                    letterSpacing: 0.5,
                    color: Color(0xff000000),
                  )).tr(),
              subtitle: Row(
                children: [
                  ImageIcon(
                    AssetImage('assets/images/location3x.png'),
                    size: 15,
                    color: Color(0xff9091A4),
                  ),
                  SizedBox(
                    width: 200,
                    child: Text(vendorModel.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: "Poppinssr",
                          letterSpacing: 0.5,
                          color: Color(0xff555353),
                        )),
                  ),
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 20,
                          color: Color(COLOR_PRIMARY),
                        ),
                        SizedBox(width: 3),
                        Text(
                            vendorModel.reviewsCount != 0
                                ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}'
                                : 0.toString(),
                            style: TextStyle(
                              fontFamily: "Poppinssr",
                              letterSpacing: 0.5,
                              color: Color(0xff000000),
                            )),
                        SizedBox(width: 3),
                        Text('(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                            style: TextStyle(
                              fontFamily: "Poppinssr",
                              letterSpacing: 0.5,
                              color: Color(0xff666666),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  getcurcy() {
    return FutureBuilder<List<CurrencyModel>>(
        future: futureCurrency,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data;

            Container(
                height: 0,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return curcy(data[index]);
                    }));
          }
          return Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
            ),
          );
        });
  }

  curcy(CurrencyModel currency) {
    if (currency.isactive == true) {
      symbol = currency.symbol;
      isRight = currency.symbolatright;
      decimal = currency.decimal;
      currName = currency.code;
      currencyData = currency;

      return Center();
    }
    return Center();
  }

  Future<void> saveFoodTypeValue() async {
    SharedPreferences sp = await SharedPreferences.getInstance();


    sp.setString('foodType', selctedOrderTypeValue!);
  }

  getFoodType() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      selctedOrderTypeValue =
          sp.getString("foodType") == "" || sp.getString("foodType") == null
              ? "Delivery"
              : sp.getString("foodType");
    });
    if (selctedOrderTypeValue == "Takeaway") {
      productsFuture = fireStoreUtils.getAllTakeAWayProducts();
    } else {
      productsFuture = fireStoreUtils.getAllProducts();
    }
    print(selctedOrderTypeValue.toString()+"[[[]]]]======OOO1");
  }

  void getData() {
    fireStoreUtils.getStoreNearBy().whenComplete(() {
      lstOfferData = fireStoreUtils.getOfferStream().asBroadcastStream();
      lstVendor = fireStoreUtils.getVendors1().asBroadcastStream();

      lstAllStore = fireStoreUtils.getAllStores().asBroadcastStream();
      lstNewArrivalStore =
          fireStoreUtils.getVendorsForNewArrival().asBroadcastStream();

      getFoodType();
print(selctedOrderTypeValue.toString()+"[[[]]]]======OOO");

      lstFavourites = fireStoreUtils.getFavouriteStore(MyAppState.currentUser!.userID);


      fireStoreUtils.getplaceholderimage().then((value) {
        placeHolderImage = value;
        AppGlobal.placeHolderImage = value;
      });
      print(placeHolderImage.toString() + "====PPP");

      // vendorsFuture = fireStoreUtils.getVendors();
      //vendorsNewArrival = fireStoreUtils.getVendorsForNewArrival();

      lstFavourites.then((event) {
        lstFav.clear();
        for (int a = 0; a < event.length; a++) {
          lstFav.add(event[a].store_id!);
        }
        print(lstFav.toList().toString() + "----1");
      });


      lstVendor!.listen((event) {
        if (event != null) {
          setState(() {
            print(event.toString() + "VVV");
            vendors.addAll(event);
          });

          storeAllLst.clear();
          storeAllLst.addAll(event);

          for (int a = 0; a < storeAllLst.length; a++) {
            print(storeAllLst[a].reviewsSum /
                storeAllLst[a].reviewsCount);
            if ((storeAllLst[a].reviewsSum /
                    storeAllLst[a].reviewsCount) >=
                4.0) {
              print(storeAllLst[a].reviewsSum /
                  storeAllLst[a].reviewsCount);
              popularStoreLst.add(storeAllLst[a]);
            }
          }
          print(popularStoreLst.length.toString() + "PR+++");
        }
      });

      name = toBeginningOfSentenceCase(widget.user.firstName);

      lstAllStore!.listen((event) {
        lstTempAllStore.clear();
        lstTempAllStore.addAll(event);
        productsFuture.then((value) {
          print(value.length.toString() + "==={}{}===value");
          for (int a = 0; a < event.length; a++) {
                for (int d = 0; d < value.length; d++) {
              if (event[a].id == value[d].vendorID) {

                lstNearByFood.add(value[d]);
              }
            }
          }
          setState(() {
            showLoader = false;
          });
          print(lstNearByFood.length.toString() + "==={}{}===");
        });
      });
    });
  }
}

class buildTitleRow extends StatelessWidget {
  final String titleValue;
  final Function? onClick;
  final bool? isViewAll;

  const buildTitleRow({
    Key? key,
    required this.titleValue,
    this.onClick,
    this.isViewAll = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDarkMode(context) ? Color(DARK_COLOR) : Color(0xffFFFFFF),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titleValue.tr(),
                  style: TextStyle(
                      color: isDarkMode(context)
                          ? Colors.white
                          : Color(0xFF000000),
                      fontFamily: "Poppinsm",
                      fontSize: 18)),
              isViewAll!
                  ? Container()
                  : GestureDetector(
                      onTap: () {
                        onClick!.call();
                      },
                      child: Text('View All'.tr(),
                          style: TextStyle(
                              color: Color(0xffE87034),
                              fontFamily: "Poppinsm",
                              fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

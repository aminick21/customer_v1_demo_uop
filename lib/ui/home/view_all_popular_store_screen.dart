import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/AppGlobal.dart';
import '/model/VendorModel.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';
import '/services/localDatabase.dart';
import '/ui/mapView/MapViewScreen.dart';
import '/ui/vendorProductsScreen/VendorProductsScreen.dart';

import '../../constants.dart';

class ViewAllPopularStoreScreen extends StatefulWidget {
  const ViewAllPopularStoreScreen({Key? key}) : super(key: key);

  @override
  _ViewAllPopularStoreScreenState createState() =>
      _ViewAllPopularStoreScreenState();
}


class _ViewAllPopularStoreScreenState
    extends State<ViewAllPopularStoreScreen> {
  Stream<List<VendorModel>>? vendorsFuture;
  final fireStoreUtils = FireStoreUtils();
  List<VendorModel> storeAllLst = [];
  List<VendorModel> popularStoreLst = [];
  List<VendorModel> vendors = [];
  var position = LatLng(23.12, 70.22);
  bool showLoader = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserLocation();
    fireStoreUtils.getStoreNearBy().whenComplete(() {
      vendorsFuture = fireStoreUtils.getVendors1().asBroadcastStream();

      vendorsFuture!.listen((value) {
        if (value != null) {
          storeAllLst.clear();
          storeAllLst.addAll(value);
          print(storeAllLst.length.toString() + "----storeAllList");
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
          setState(() {
            showLoader = false;
          });
        }
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppGlobal.buildAppBar(context,"Most Popular"),
      body: Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: MediaQuery
              .of(context)
              .size
              .height,
          margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
          child: showLoader?Center(
            child: CircularProgressIndicator.adaptive(
              valueColor:
              AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
            ),
          ):popularStoreLst.length==0?showEmptyState('No Items'.tr(),
              'Start by adding vendors to firebase.'.tr()):ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              itemCount: popularStoreLst.length,
              itemBuilder: (context, index) =>
                  buildPopularsItem(
                      popularStoreLst[index]))));
  }



  Widget buildPopularsItem(VendorModel vendorModel) {
    return GestureDetector(
      onTap: () =>
          push(
            context,
            VendorProductsScreen(vendorModel: vendorModel),
          ),
      child: Container(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.75,
        height: 260,
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
                  imageBuilder: (context, imageProvider) =>
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image:
                          DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                  placeholder: (context, url) =>
                      Center(
                          child: CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation(
                                Color(COLOR_PRIMARY)),
                          )),
                  errorWidget: (context, url,
                      error) =>
                      ClipRRect(
                          borderRadius:
                          BorderRadius
                              .circular(15),
                          child: Image.network(
                            AppGlobal
                                .placeHolderImage!,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          )),
                  fit: BoxFit.cover,
                )),
            SizedBox(height: 8),
            Container(
              margin: EdgeInsets.fromLTRB(15, 0, 5, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(vendorModel.title,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: "Poppinssm",
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff000000),
                            )).tr(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 0),
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
                                        ? '${(vendorModel.reviewsSum /
                                        vendorModel.reviewsCount)
                                        .toStringAsFixed(1)}'
                                        : 0.toString(),
                                    style: TextStyle(
                                      fontFamily: "Poppinssr",
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff666666),
                                    )),
                                SizedBox(width: 3),
                                Text("(${vendorModel.reviewsCount})",
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

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ImageIcon(
                        AssetImage('assets/images/location3x.png'),
                        size: 15,
                        color: Color(0xff555353),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        flex: 3,
                        child: Text(vendorModel.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: "Poppinssr",
                              letterSpacing: 0.5,

                              color: Color(0xff555353),
                            )),
                      ),
                      SizedBox(width: 10,),
                      Flexible(
                        flex: 1,
                        child: Row(
                          children: [
                            Container(height: 5,
                              width: 5,
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff555353),
                              ),),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Text(getKm(vendorModel.latitude, vendorModel.longitude)!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: "Poppinssr",

                                    color: Color(0xff555353),
                                  )),
                            ),
                          ],
                        ),
                      )


                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _getUserLocation() async {
    var positions = await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      position = LatLng(positions.latitude, positions.longitude);
      // cameraPosition = CameraPosition(
      //   target: LatLng(position.latitude, position.longitude),
      //   zoom: 14.4746,
      // );
    });
  }

  String? getKm(double latitude, double longitude) {
    double distanceInMeters = Geolocator.distanceBetween(
        latitude,
        longitude,
        position.latitude,
        position.longitude);
    double kilometer = distanceInMeters / 1000;
    print("KiloMeter${kilometer}");

    double minutes = 1.2;
    double value = minutes * kilometer;
    final int hour = value ~/ 60;
    final double minute = value % 60;
    print(
        '${hour.toString().padLeft(2, "0")}:${minute.toStringAsFixed(0).padLeft(
            2, "0")}');
    return kilometer.toStringAsFixed(2).toString();
  }


}

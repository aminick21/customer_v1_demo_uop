import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/AppGlobal.dart';
import '/main.dart';
import '/model/FavouriteModel.dart';
import '/model/VendorModel.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';
import '/services/localDatabase.dart';
import '/ui/mapView/MapViewScreen.dart';
import '/ui/vendorProductsScreen/VendorProductsScreen.dart';

import '../../constants.dart';

class FavouriteStoreScreen extends StatefulWidget {
  const FavouriteStoreScreen({Key? key}) : super(key: key);

  @override
  _FavouriteStoreScreenState createState() =>
      _FavouriteStoreScreenState();
}

class _FavouriteStoreScreenState extends State<FavouriteStoreScreen> {
  late Future<List<VendorModel>> vendorFuture;
  final fireStoreUtils = FireStoreUtils();
  List<VendorModel> storeAllLst = [];
  List<FavouriteModel> lstFavourite=[];
  var position = LatLng(23.12, 70.22);
  bool showLoader = true;
  String placeHolderImage = "";
  VendorModel? vendorModel = null;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fireStoreUtils.getplaceholderimage().then((value) {
      placeHolderImage = value!;
    });
    getData();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          ):lstFavourite.length==0?showEmptyState('No Favourite Stores'.tr(),
              'Start by adding favourite stores'.tr()):ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              itemCount: lstFavourite.length,
              itemBuilder: (context, index) {
                if (storeAllLst.length != 0) {
                  for (int a = 0; a < storeAllLst.length; a++) {
                    print(storeAllLst[a].id.toString() + "===<><>FR<><=="+lstFavourite[index].store_id!);
                    if (storeAllLst[a].id == lstFavourite[index].store_id) {
                      vendorModel = storeAllLst[a];

                    } else {}
                  }
                }
               return vendorModel == null
                   ? Container()
                   :buildAllStoreData(vendorModel!,index);
              })));
  }



  Widget buildAllStoreData(VendorModel vendorModel, int index) {
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
                    child: Image.network(placeHolderImage,fit: BoxFit.cover,)),
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
                              print(lstFavourite.length.toString() + "----REMOVE");
                              FavouriteModel favouriteModel = FavouriteModel(
                                  store_id: vendorModel.id,
                                  user_id: MyAppState.currentUser!.userID);
                              lstFavourite.removeWhere(
                                      (item) => item == vendorModel.id);
                              fireStoreUtils.removeFavouriteStore(favouriteModel);

                              lstFavourite.removeAt(index);
                          });
                        },
                        child:  Icon(
                          Icons.favorite,
                          color: Color(COLOR_PRIMARY),
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

  void getData() {
    fireStoreUtils.getFavouriteStore(MyAppState.currentUser!.userID).then((value) {
      if(value != null){
        setState(() {
          lstFavourite.clear();
          lstFavourite.addAll(value);
        });
      }
    });
    vendorFuture = fireStoreUtils.getVendors();

    vendorFuture.then((value) {
      if (value != null) {

        setState(() {
          storeAllLst.clear();
          storeAllLst.addAll(value);
          print(storeAllLst.length.toString()+"===FR"+value.length.toString());
          showLoader = false;
        });
      }
    });
  }


}

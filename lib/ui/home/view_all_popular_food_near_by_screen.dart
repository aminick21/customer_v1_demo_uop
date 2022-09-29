import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/model/ProductModel.dart';
import '/model/VendorModel.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';
import '/ui/mapView/MapViewScreen.dart';

import '../../AppGlobal.dart';
import '../../constants.dart';
import '../vendorProductsScreen/VendorProductsScreen.dart';

class ViewAllPopularFoodNearByScreen extends StatefulWidget {
  const ViewAllPopularFoodNearByScreen( {Key? key}) : super(key: key);


  @override
  _ViewAllPopularFoodNearByScreenState createState() => _ViewAllPopularFoodNearByScreenState();
}

class _ViewAllPopularFoodNearByScreenState extends State<ViewAllPopularFoodNearByScreen> {
  late Stream<List<VendorModel>> vendorsFuture;
  final fireStoreUtils = FireStoreUtils();
  Stream<List<VendorModel>>? lstAllStore;
  late Future<List<ProductModel>> productsFuture;
  List<ProductModel> lstNearByFood=[];
  List<VendorModel> vendors = [];
  bool showLoader = true;
  String? selctedOrderTypeValue = "Delivery";
  VendorModel? popularNearFoodVendorModel = null;
  Stream<List<VendorModel>>? lstVendor;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFoodType();
    fireStoreUtils.getStoreNearBy().whenComplete(() {
      lstAllStore = fireStoreUtils.getAllStores().asBroadcastStream();
      lstAllStore!.listen((event) {
        print(event.toString()+"==={}{}===");
      });
      lstVendor = fireStoreUtils.getVendors1().asBroadcastStream();
      lstVendor!.listen((event) {
        if (event != null) {
          setState(() {
            print(event.toString() + "VVV");
            vendors.addAll(event);
          });
        }});
      if(selctedOrderTypeValue=="Delivery"){
        productsFuture = fireStoreUtils.getAllProducts();
      }else{
        productsFuture = fireStoreUtils.getAllTakeAWayProducts();
      }




        productsFuture.then((value) {
          lstNearByFood.addAll(value);
          setState(() {
            showLoader = false;
          });
        });
      //});
    });


  }
  getFoodType() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      selctedOrderTypeValue =
      sp.getString("foodType") == "" || sp.getString("foodType") == null
          ? "Delivery"
          : sp.getString("foodType");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppGlobal.buildAppBar(context,"Top Selling"),

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
        child:  showLoader?Center(
          child: CircularProgressIndicator.adaptive(
            valueColor:
            AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
          ),
        ):lstNearByFood.length==0?showEmptyState('No top selling found'.tr(),
            'Start by adding categories to firebase.'.tr()):ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            itemCount: lstNearByFood.length,
            itemBuilder: (context, index) {
              if (vendors.length != 0) {
                print("item name ${lstNearByFood[index].name}");
                popularNearFoodVendorModel=null;
                for (int a = 0; a < vendors.length; a++) {
                  print(vendors[a].id.toString() + "===<><><><=="+lstNearByFood[index].vendorID);
                  if (vendors[a].id == lstNearByFood[index].vendorID) {
                    popularNearFoodVendorModel = vendors[a];

                  }
                }
              }
              return popularNearFoodVendorModel == null
                  ? Container()
                  : buildVendorItemData(context, index,popularNearFoodVendorModel!);
            }

            ),
      ),);
  }



  Widget buildVendorItemData(BuildContext context, int index, VendorModel popularNearFoodVendorModel) {
    return GestureDetector(
      onTap: () {
        print(popularNearFoodVendorModel.id.toString()+" *** "+popularNearFoodVendorModel.title.toString());
        push(
          context,
          VendorProductsScreen(vendorModel: popularNearFoodVendorModel),
        );
      },
      child: Container(
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(10),
          color: Colors.white,
        ),
        width: MediaQuery.of(context).size.width * 0.8,
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: new BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: lstNearByFood[index].photo,
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
                    lstNearByFood[index].name,
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
                    lstNearByFood[index].description,
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
                  lstNearByFood[index].disPrice == "" ||
                      lstNearByFood[index].disPrice == "0"
                      ? Text(
                    symbol +
                        '${lstNearByFood[index].price}',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Poppinssb",
                        letterSpacing: 0.5,
                        color: Color(COLOR_PRIMARY)),
                  ):Row(
                    children: [
                      Text(
                        '${lstNearByFood[index].price}',
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
                        "\$${lstNearByFood[index].disPrice}",
                        style: TextStyle(
                          fontFamily: "Poppinssm",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffE87034),
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
}

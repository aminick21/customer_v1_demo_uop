import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '/AppGlobal.dart';
import '/constants.dart';
import '/model/CuisineModel.dart';
import '/model/VendorModel.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';
import '/ui/vendorProductsScreen/VendorProductsScreen.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final CuisineModel category;

  const CategoryDetailsScreen({Key? key, required this.category})
      : super(key: key);

  @override
  _CategoryDetailsScreenState createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  late Future<List<VendorModel>> categoriesFuture;
  final FireStoreUtils fireStoreUtils = FireStoreUtils();

  @override
  void initState() {
    super.initState();
    print(widget.category.id);
    categoriesFuture = fireStoreUtils.getVendorsByCuisineID(widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.title,
          style: TextStyle(fontFamily: 'Poppinssb',
          color: isDarkMode(context)? Colors.white:  Colors.black)
        ).tr(),
      ),
      body: FutureBuilder<List<VendorModel>>(
        future: categoriesFuture,
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
            return Center(
              child: showEmptyState(
                'No Vendors'.tr(),
                'No vendors found for the selected cuisine'.tr(),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) =>
                  buildVendorItem(snapshot.data![index]),
            );
          }
        },
      ),
    );
  }

  buildVendorItem(VendorModel vendorModel) {
    return GestureDetector(
      onTap: () => push(
        context,
        VendorProductsScreen(vendorModel: vendorModel),
      ),
      child: Card(
        elevation: 0.5,
        color: isDarkMode(context) ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 200,

          // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            // mainAxisSize: MainAxisSize.max,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: vendorModel.photo,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover)),
                  ),
                  placeholder: (context, url) => Center(
                      child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  )),
                  errorWidget: (context, url, error) => ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        AppGlobal.placeHolderImage!,
                        fit: BoxFit.fitWidth,
                        width: MediaQuery.of(context).size.width,
                      )),
                  fit: BoxFit.cover,
                ),
              ),
              // SizedBox(height: 8),
              ListTile(
                title: Text(vendorModel.title,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode(context)
                          ? Colors.grey.shade400
                          : Colors.grey.shade800,
                      fontFamily: 'Poppinssb',
                    )),
                subtitle: Text(
                    vendorModel.location,maxLines: 1,
                    
                    // filters.keys
                    //     .where(
                    //         (element) => vendorModel.filters[element] == 'Yes')
                    //     .take(2)
                    //     .join(', '),


                    style: TextStyle(
                      fontFamily: 'Poppinssm',
                    )),
                trailing: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.star,
                              size: 20,
                              color: Color(COLOR_PRIMARY),
                            ),
                            Text(
                              (vendorModel.reviewsCount != 0)?(vendorModel.reviewsSum/vendorModel.reviewsCount).toStringAsFixed(1):"0",
                              style: TextStyle(
                                fontFamily: 'Poppinssb',
                              ),
                            ),
                            Visibility(
                                visible: vendorModel.reviewsCount != 0,
                                child: Text("(${vendorModel.reviewsCount.toStringAsFixed(1)})")),
                          ]),
                    ],
                  ),
                ),
              ),
              // SizedBox(height: 4),

              // SizedBox(height: 4),
              // Visibility(
              //   visible: vendorModel.reviewsCount != 0,
              //   child: RichText(
              //     text: TextSpan(
              //       style: TextStyle(
              //           color: isDarkMode(context)
              //               ? Colors.grey.shade200
              //               : Colors.black),
              //       children: [
              //         TextSpan(
              //             text:
              //                 '${double.parse((vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(2))} '),
              //         WidgetSpan(
              //           child: Icon(
              //             Icons.star,
              //             size: 20,
              //             color: Color(COLOR_PRIMARY),
              //           ),
              //         ),
              //         TextSpan(text: ' (${vendorModel.reviewsCount})'),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

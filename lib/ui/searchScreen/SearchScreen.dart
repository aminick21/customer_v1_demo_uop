import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '/AppGlobal.dart';
import '/constants.dart';
import '/model/ProductModel.dart';
import '/model/VendorModel.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';
import '/ui/productDetailsScreen/ProductDetailsScreen.dart';
import '/ui/vendorProductsScreen/VendorProductsScreen.dart';

List<ProductModel> _searchResult = [];
List<VendorModel> _Result = [];
List<ProductModel> _products = [];
List<VendorModel> _vendors = [];

TextEditingController searchController = TextEditingController();

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key, this.isCheckOnAppGlobal = false})
      : super(key: key);
  final bool isCheckOnAppGlobal;

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  late Future<List<ProductModel>> productsFuture;
  late Future<List<VendorModel>> vendorFuture;
  final FireStoreUtils fireStoreUtils = FireStoreUtils();
  List<ProductModel> id = [];
  late GlobalKey<SearchScreenState> _searchScreenStateKey;

  @override
  void initState() {
    super.initState();
    _searchScreenStateKey = GlobalKey();
    productsFuture = fireStoreUtils.getAllProducts();
    vendorFuture = fireStoreUtils.getVendors();
  }

  clearSearchQuery() {
    setState(() {
      final FocusScopeNode currentScope = FocusScope.of(context);
      if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
      searchController.clear();
      onSearchTextChanged('');
    });
  }

  Widget _buildSearchField() => TextField(
        controller: searchController,
        onChanged: (value) {
          onSearchTextChanged(value);
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10),
          isDense: true,
          fillColor: isDarkMode(context) ? Colors.grey[700] : Colors.grey[200],
          filled: true,
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: Colors.black,
          ),
          suffixIcon: IconButton(
              icon: Icon(
                CupertinoIcons.clear,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  final FocusScopeNode currentScope = FocusScope.of(context);
                  if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                  searchController.clear();
                  onSearchTextChanged('');
                });
              }),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              borderSide: BorderSide(style: BorderStyle.none)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              borderSide: BorderSide(style: BorderStyle.none)),
          hintText: tr('Search'),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(50, 50),
            child: widget.isCheckOnAppGlobal
                ? _buildSearchField()
                : Container(
                    height: 0,
                    width: 0,
                  ),
          ),
          body: SingleChildScrollView(
              child: Stack(children: [
            FutureBuilder<List<ProductModel>>(
                future: productsFuture,
                initialData: [],
                builder: (context, snapshot) {
                  _products = snapshot.data!;
                  // _vendors = snapshot.data!;
                  print('products');
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResult.length != 0 ||
                            searchController.text.isNotEmpty
                        ? _searchResult.length
                        : _products.length,
                    itemBuilder: (context, index) => data1(
                        _searchResult.length != 0 ||
                                searchController.text.isNotEmpty
                            ? _searchResult[index]
                            : _products[index]),
                  );
                }),
                FutureBuilder<List<VendorModel>>(
                    future: vendorFuture,
                initialData: [],
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Container(
                      child: Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor:
                              AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                        ),
                      ),
                    );
                  if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                    return Center(
                      child: showEmptyState('No Products Found'.tr(),
                          'Couldn\'t find any products to be displayed.'.tr()),
                    );
                  } else {
                    // _products = snapshot.data!;
                    _vendors = snapshot.data!;

                    return ListView.builder(
                        //  Padding(padding: EdgeInsets.only(top: 0,bottom: 0,left:20,right: 20),
                        //  child:Divider(height: 10,color: Color(0xffCAD1D8))
                        //  ),
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: _Result.length != 0 ||
                                searchController.text.isNotEmpty
                            ? _Result.length
                            : _vendors.length,
                        itemBuilder: (context, index) =>
                            // search(_vendors[index]);
                            vendor(_Result.length != 0 ||
                                    searchController.text.isNotEmpty
                                ? _Result[index]
                                : _vendors[index]));
                  }
                }),

            // Expanded(child:
            // ),
          ]))),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    _Result.clear();
    if (text.isEmpty) {
      setState(() {});

      return;
    }

    _products.forEach((contact) {
      if (contact.name.toLowerCase().contains(text.toLowerCase())) {
        _searchResult.add(contact);
      }
    });

    _searchResult.forEach((data) {
      _vendors.forEach((element) {
        if (element.id == data.vendorID) {
          _Result.add(element);
          _Result = _Result.toSet().toList();
        }
      });
    });

    setState(() {});
  }

  data1(data) {
    return Center();
  }

  @override
  void dispose() {
    _searchResult.clear();
    _Result.clear();
    super.dispose();
  }

// search(VendorModel vendormodel){
//  id == vendormodel.id?
//  _Result.add(vendormodel):null;
// }
  // buildRow() {
  //   // var id =productModel.vendorID;
  //   // return id;
  // }
  vendor(VendorModel vendormodel) {
    print(id);
    // if (vendormodel.id == id ) {

    return data(vendormodel);
    // }
    // else if(_Result.isEmpty){
    //   print('yapeee?');
    //   return data(vendormodel);
    // }
  }

  data(VendorModel vendormodel) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => push(
          context,
          VendorProductsScreen(
            vendorModel: vendormodel,
          )),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 8.0,
          ),
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: CachedNetworkImage(
                      height: MediaQuery.of(context).size.height * 0.075,
                      width: MediaQuery.of(context).size.width * 0.16,
                      imageUrl: vendormodel.photo,
                      imageBuilder: (context, imageProvider) => Container(
                            // width: 100,
                            // height: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                )),
                          ),
                      errorWidget: (context, url, error) => ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(
                            AppGlobal.placeHolderImage!,
                            fit: BoxFit.cover,
                          )))),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            // padding: EdgeInsets.symmetric(
                            //     vertical: 10, horizontal: 15),
                            child: Text(vendormodel.title,
                                style: TextStyle(
                                  fontFamily: "Poppinsr",
                                  fontSize: 16,
                                  color: isDarkMode(context)
                                      ? Color(0xffFFFFFF)
                                      : Color(0xff272727),
                                  // Color(0xff272727)
                                ))),
                        SizedBox(height: 3),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on_sharp,
                                color: Color(0xff9091A4),
                                size: 16,
                              ),
                              SizedBox(width: 3),
                              Container(
                                  constraints: BoxConstraints(
                                      maxWidth: 200, maxHeight: 50),
                                  child: Text(
                                    vendormodel.location,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontFamily: "Poppinsl",
                                        fontSize: 14,
                                        color: Color(0XFF555353)),
                                  ))
                            ]),
                        SizedBox(height: 8),
                        // Text(
                        //   '\$${productModel.price}',
                        //   style: TextStyle(fontSize: 15),
                        // )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
// product(ProductModel productModel) {
//   print(id);
//   // if (vendormodel.id == id) {
//   return GestureDetector(
//     // behavior: HitTestBehavior.translucent,
//     onTap: () => push(
//         context,
//         ProductDetailsScreen(
//           productModel: productModel,
//         )),

//     // height: MediaQuery.of(context).size.height / 9.6,
//     child: Padding(
//       padding: const EdgeInsets.symmetric(
//         vertical: 4,
//         horizontal: 8.0,
//       ),
//       child: Row(
//         // crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           Padding(
//               padding: EdgeInsets.only(left: 10),
//               child: CachedNetworkImage(
//                   height: MediaQuery.of(context).size.height * 0.075,
//                   width: MediaQuery.of(context).size.width * 0.16,
//                   imageUrl: productModel.photo,
//                   imageBuilder: (context, imageProvider) => Container(
//                         // width: 100,
//                         // height: 100,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(5),
//                             image: DecorationImage(
//                               image: imageProvider,
//                               fit: BoxFit.cover,
//                             )),
//                       ))),
//           SizedBox(
//             width: 10,
//           ),
//           ListTile(
//             title: Text(
//               productModel.name,
//               style: TextStyle(
//                 fontFamily: "Poppinsr",
//                 fontSize: 16,
//                 color: Color(0xff272727),
//               ),
//             ),
//             subtitle:
//                 Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//               Icon(
//                 Icons.location_on_sharp,
//                 color: Color(0xff9091A4),
//                 size: 16,
//               ),
//               SizedBox(width: 3),
//               Text(
//                 productModel.price,
//                 maxLines: 1,
//                 style: TextStyle(
//                     fontFamily: "Poppinsl",
//                     fontSize: 14,
//                     color: Color(0XFF555353)),
//               )
//             ]),
//           ),
//         ],
//       ),
//     ),
//   );
//   // } else {
//   //   return Text("data");
//   // }
// }
}

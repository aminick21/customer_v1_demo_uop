
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/model/VendorModel.dart';
import '/services/FirebaseHelper.dart';
import 'package:easy_localization/easy_localization.dart';
import '/services/helper.dart';
import '../../AppGlobal.dart';
import '../../constants.dart';


class StorePhotos extends StatefulWidget {
  final VendorModel vendorModel;
  StorePhotos({Key? key, required this.vendorModel}) : super(key: key);

  @override
  _StorePhotosState createState() => _StorePhotosState();
}

class _StorePhotosState extends State<StorePhotos> {
  late Future<VendorModel> photofuture;
final FireStoreUtils fireStoreUtils = FireStoreUtils();
  @override
  void initState() {
    super.initState();
      photofuture = fireStoreUtils.getVendorByVendorID(widget.vendorModel.id);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
           appBar: AppBar(centerTitle: false,
           iconTheme: IconThemeData(
                          color: Colors.black, //change your color here
                     ), 
              titleSpacing: 0,
             title: Text("Photos".tr(),
             style: TextStyle(fontFamily: "Poppinsr", 
             color: Colors.black,fontSize: 18),),
           ),
      body: SingleChildScrollView(
        child: Container( 
                            // first tab bar view widget
                          padding: EdgeInsets.only(top: 0),
                          child: FutureBuilder<VendorModel>(
                            future: photofuture,
                            // initialData: [],
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting)
                      return Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor:
                              AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                        ),
                      );
                     else  if (snapshot.data!.photos.isEmpty)
                      return Center(
                        child: showEmptyState("",'No images are available.')
                      );
                               return GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 10.0,
                                  childAspectRatio: 5/4,
                                  padding: EdgeInsets.all(10.0),
                                  children: List.generate(
                                      snapshot.data!.photos.length, (index) {
                                        if(snapshot.data!.hidephotos == false)
                                        {
                                    return Container(
                                      
                                      child: Card(
                                          color: Color(0xffE7EAED),
                                          elevation: 0.5,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              side: BorderSide(
                                                  color: Color(0xffDEE3ED))),
                                          child: CachedNetworkImage(
                                              height: 70,
                                              width: 100,
                                              imageUrl:
                                                  snapshot.data!.photos[index],
                                              imageBuilder: (context,
                                                      imageProvider) =>
                                                  Container(
                                                    width: 70,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        image: DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover)),
                                                  ),errorWidget: (context, url,
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
                                                  )))),
                                    );
                                        }
                                        else{
                                          return Container();
                                        }
                                      }
                                 ));
                            },
                          )),
    ));
  }
}
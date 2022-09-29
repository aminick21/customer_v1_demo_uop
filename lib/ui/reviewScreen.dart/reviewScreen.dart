import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '/constants.dart';
import '/main.dart';
import '/model/OrderModel.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '/model/Ratingmodel.dart';
import '/model/VendorModel.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';
import '/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
import '/ui/fullScreenImageViewer/fullscreenimage.dart';
import '/ui/ordersScreen/OrdersScreen.dart';

class ReviewScreen extends StatefulWidget {
  final OrderModel order;
  ReviewScreen({Key? key, required this.order}) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with TickerProviderStateMixin {
  late Future<RatingModel> ratingproduct;
  
  RatingModel? ratingModel;
  final ImagePicker _imagePicker = ImagePicker();
  List<dynamic> _mediaFiles = [];
  final _formKey = GlobalKey<FormState>();
  FireStoreUtils fireStoreUtils = FireStoreUtils();
  final comment = TextEditingController();
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  var ratings = 0.0;
  var futureCount,futureSum  ;
  late Future<VendorModel> photofuture;

  // RatingModel? rating;
  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ratingproduct = fireStoreUtils.getReviewsbyID(widget.order.id);
    ratingproduct.then((value) {
      if(value!=null){
        ratingModel=value;
        updatevendor();
      }
    });
    photofuture = fireStoreUtils.getVendorByVendorID(widget.order.vendorID);

    updatevendor();
  }

  bool id = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode(context) ? Color(DARK_COLOR) : Color(0XFFFDFEFE),
      appBar: AppBar(
        centerTitle: false,
        // iconTheme: IconThemeData(
        //   color: Colors.black, //change your color here
        // ),
        titleSpacing: 0,
        title: Text(
          "Add Review".tr(),
          style: TextStyle(
              fontFamily: "Poppinsr",
              color:
                  isDarkMode(context) ? Color(0XFFFDFEFE) : Color(DARK_COLOR),
              fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
              // color: Color(0XFFF1F142),
              // 0XFFF1F142
              // 0XFFF1F4F7
              padding: EdgeInsets.only(top: 20, left: 20),
              child: Form(
                key: _formKey,
                child:
                    // Text(ratingModel!.comment.isEmpty),
                    // widget.order.id == ''
                    // ?
                    //   Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    // children: [
                    // Text(ratingModel!.comment),
                    FutureBuilder<RatingModel>(
                        future: ratingproduct,
                        // initialData: ratingModel,
                        builder: (BuildContext context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation(
                                    Color(COLOR_PRIMARY)),
                              ),
                            );
                          if (snapshot.hasData) {
                            id = true;
                            _mediaFiles.isEmpty
                                ? _mediaFiles.addAll(snapshot.data!.photos)
                                : null;
                            comment.text.isEmpty
                                ? comment.text = snapshot.data!.comment
                                : null;
                            ratings = snapshot.data!.rating;
                            return Column(
                              children: [
                                Card(
                                    color: isDarkMode(context)
                                        ? Color(0xff35363A)
                                        : Color(0XFFFDFEFE),
                                    elevation: 1,
                                    margin: EdgeInsets.only(right: 15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Container(
                                        height: 150,
                                        child: Column(children: [
                                          Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.only(top: 15),
                                              child: Text(
                                                "Rate For".tr(),
                                                style: TextStyle(
                                                    color: Color(0XFF7C848E),
                                                    fontFamily: 'Poppinsr',
                                                    fontSize: 17),
                                              )),
                                          Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                  widget.order.products.first
                                                      .name,
                                                  style: TextStyle(
                                                      color: isDarkMode(context)
                                                          ? Color(0XFFFDFEFE)
                                                          : Color(0XFF000003),
                                                      fontFamily: 'Poppinsm',
                                                      fontSize: 20))),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          RatingBar.builder(
                                            initialRating:
                                                snapshot.data!.rating,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemPadding: EdgeInsets.symmetric(
                                                horizontal: 6.0),
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Color(COLOR_PRIMARY),
                                            ),
                                            onRatingUpdate: (double rate) {
                                              ratings = rate;
                                              // print(ratings);
                                            },
                                          ),
                                        ]))),

                                // SizedBox(height: 20,),

                                InkWell(
                                  onTap: () {
                                    _pickImage();
                                  },
                                  child: Card(
                                      color: isDarkMode(context)
                                          ? Color(0xff35363A)
                                          : Color(0XFFFDFEFE),
                                      elevation: 1,
                                      margin:
                                          EdgeInsets.only(right: 15, top: 25),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Container(
                                          height: 160,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              1,
                                          child: Column(children: [
                                            Container(
                                                padding:
                                                    EdgeInsets.only(top: 20),
                                                width: 100,
                                                child: Image(
                                                    image: AssetImage(
                                                        'assets/images/add_img.png'))),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text("Add Images".tr(),
                                                style: TextStyle(
                                                    color: Color(0XFF666666),
                                                    fontFamily: 'Poppinsr',
                                                    fontSize: 16))
                                          ]))),
                                ),
                                _mediaFiles.isEmpty
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            top: 35, bottom: 20),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 100,
                                                child: ListView.builder(
                                                  itemCount: _mediaFiles.length,
                                                  itemBuilder: (context,
                                                          index) =>
                                                      Container(
                                                          width: 150,
                                                          child: _imageBuilder(
                                                              _mediaFiles[
                                                                  index])),
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                Card(
                                    color: isDarkMode(context)
                                        ? Color(0xff35363A)
                                        : Color(0XFFFDFEFE),
                                    elevation: 1,
                                    margin: EdgeInsets.only(top: 10, right: 15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Container(
                                        height: 140,
                                        padding: EdgeInsets.only(
                                            top: 15,
                                            bottom: 15,
                                            right: 20,
                                            left: 20),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 0.5,
                                                color: Color(0XFFD1D1E4),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          constraints:
                                              BoxConstraints(maxHeight: 100),
                                          child: SingleChildScrollView(
                                            child: Container(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: TextFormField(
                                                  validator: validateEmptyField,
                                                  controller: comment,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  decoration: InputDecoration(
                                                      hintText:
                                                          'Type comment....'.tr(),
                                                      hintStyle: TextStyle(
                                                          color:
                                                              Color(0XFF8A8989),
                                                          fontFamily:
                                                              'Poppinsr'),
                                                      border: InputBorder.none),
                                                  maxLines: null,
                                                )),
                                          ),
                                        ))),
                              ],
                            );
                          }
                          //////add rate
                          id = false;
                          return Column(
                            children: [
                              Card(
                                  color: isDarkMode(context)
                                      ? Color(0xff35363A)
                                      : Color(0XFFFDFEFE),
                                  elevation: 1,
                                  margin: EdgeInsets.only(right: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(
                                      height: 150,
                                      child: Column(children: [
                                        Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(top: 15),
                                            child: Text(
                                              "Rate For".tr(),
                                              style: TextStyle(
                                                  color: Color(0XFF7C848E),
                                                  fontFamily: 'Poppinsr',
                                                  fontSize: 17),
                                            )),
                                        Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                                widget
                                                    .order.products.first.name,
                                                style: TextStyle(
                                                    color: isDarkMode(context)
                                                        ? Color(0XFFFDFEFE)
                                                        : Color(0XFF000003),
                                                    fontFamily: 'Poppinsm',
                                                    fontSize: 20))),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        RatingBar.builder(
                                          initialRating: 0,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemPadding: EdgeInsets.symmetric(
                                              horizontal: 6.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Color(COLOR_PRIMARY),
                                          ),
                                          onRatingUpdate: (double rate) {
                                            ratings = rate;
                                            print(ratings);
                                          },
                                        ),
                                      ]))),

                              // SizedBox(height: 20,),

                              InkWell(
                                onTap: () {
                                  _pickImage();
                                },
                                child: Card(
                                    color: isDarkMode(context)
                                        ? Color(0xff35363A)
                                        : Color(0XFFFDFEFE),
                                    elevation: 1,
                                    margin: EdgeInsets.only(right: 15, top: 25),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Container(
                                        height: 160,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        child: Column(children: [
                                          Container(
                                              padding: EdgeInsets.only(top: 20),
                                              width: 100,
                                              child: Image(
                                                  image: AssetImage(
                                                      'assets/images/add_img.png'))),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text("Add Images".tr(),
                                              style: TextStyle(
                                                  color: Color(0XFF666666),
                                                  fontFamily: 'Poppinsr',
                                                  fontSize: 16))
                                        ]))),
                              ),
                              _mediaFiles.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 35, bottom: 20),
                                      child: SizedBox(
                                        height: 100,
                                        child: ListView.builder(
                                          itemCount: _mediaFiles.length,
                                          itemBuilder: (context, index) =>
                                              Container(
                                                  width: 150,
                                                  child: _imageBuilder(
                                                      _mediaFiles[index])),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                        ),
                                      ),
                                    )
                                  : Center(),
                              Card(
                                  color: isDarkMode(context)
                                      ? Color(0xff35363A)
                                      : Color(0XFFFDFEFE),
                                  elevation: 1,
                                  margin: EdgeInsets.only(top: 10, right: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(
                                      height: 170,
                                      padding: EdgeInsets.only(
                                          top: 15,
                                          bottom: 15,
                                          right: 20,
                                          left: 20),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 0.5,
                                              color: Color(0XFFD1D1E4),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        constraints:
                                            BoxConstraints(maxHeight: 100),
                                        child: SingleChildScrollView(
                                          child: Container(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              child: TextField(
                                                controller: comment,
                                                textInputAction:
                                                    TextInputAction.send,
                                                decoration: InputDecoration(
                                                    hintText:
                                                        'Type comment....'.tr(),
                                                    hintStyle: TextStyle(
                                                        color:
                                                            Color(0XFF8A8989),
                                                        fontFamily: 'Poppinsr'),
                                                    border: InputBorder.none),
                                                maxLines: null,
                                              )),
                                        ),
                                      ))),
                            ],
                          );
                        }),
              ))),
      bottomNavigationBar: FutureBuilder<RatingModel>(
          future: ratingproduct,
          // initialData: ratingModel,
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    primary: Color(COLOR_PRIMARY),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await showProgress(
                        context, 'Updating data to database...', false);
                    //  if(_mediaFiles is File){
                    List<String> mediaFilesURLs = _mediaFiles
                        .where((element) => element is String)
                        .toList()
                        .cast<String>();
                    List<File> imagesToUpload = _mediaFiles
                        .where((element) => element is File)
                        .toList()
                        .cast<File>();
                    if (imagesToUpload.isNotEmpty) {
                      updateProgress(
                        'Uploading  Images {} of {}'
                            .tr(args: ['1', '${imagesToUpload.length}']),
                      );
                      for (int i = 0; i < imagesToUpload.length; i++) {
                        if (i != 0)
                          updateProgress(
                            'Uploading Review Images {} of {}'.tr(
                              args: ['${i + 1}', '${imagesToUpload.length}'],
                            ),
                          );
                        String url = await fireStoreUtils.uploadProductImage(
                          imagesToUpload[i],
                          'Uploading Review Images {} of {}'.tr(
                            args: ['${i + 1}', '${imagesToUpload.length}'],
                          ),
                        );
                        mediaFilesURLs.add(url);
                      }
                    }
                    VendorModel vendor = VendorModel(
                        author: widget.order.vendor.author,
                        authorName: widget.order.vendor.authorName,
                        authorProfilePic: widget.order.vendor.authorProfilePic,
                        categoryID: widget.order.vendor.categoryID,
                        categoryPhoto: widget.order.vendor.categoryPhoto,
                        categoryTitle: widget.order.vendor.categoryTitle,
                        closetime: widget.order.vendor.closetime,
                        createdAt: widget.order.vendor.createdAt,
                        description: widget.order.vendor.description,
                        fcmToken: widget.order.vendor.fcmToken,
                        filters: widget.order.vendor.filters,
                        hidephotos: widget.order.vendor.hidephotos,
                        id: widget.order.vendor.id,
                        latitude: widget.order.vendor.latitude,
                        location: widget.order.vendor.location,
                        longitude: widget.order.vendor.longitude,
                        opentime: widget.order.vendor.opentime,
                        phonenumber: widget.order.vendor.phonenumber,
                        photo: widget.order.vendor.photo,
                        price: widget.order.vendor.price,
                        photos: widget.order.vendor.photos,
                        title: widget.order.vendor.title,
                        reviewsCount: futureCount+1,
                        reviewsSum:  futureSum+ratings,
                        reststatus: widget.order.vendor.reststatus
                    );
                    RatingModel ratingproduct = RatingModel(
                      comment: comment.text,
                      photos: mediaFilesURLs,
                      rating: ratings,
                      customerId: snapshot.data!.customerId,
                      id: snapshot.data!.id,
                      orderId: snapshot.data!.orderId,
                      vendorId: snapshot.data!.vendorId,
                      uname: MyAppState.currentUser!.firstName +
                          MyAppState.currentUser!.lastName,
                      profile: MyAppState.currentUser!.profilePictureURL,
                    );
                    await FireStoreUtils.updateReviewbyId(ratingproduct);
                    await updateProgress("Review Update Successful");
                    await hideProgress();
                    String? errorMessage = await FireStoreUtils.firebaseCreateNewReview(ratingproduct);

                    var error=await  FireStoreUtils.updateVendor(vendor);
                    if (errorMessage== null&& error != null ) {
                      await hideProgress();
                      Navigator.pop(context, OrdersScreen());
                    } else {
                    }
                   // Navigator.pop(context, OrdersScreen());
                    print('sending...');
                    // await hideProgress();
                    // showUpdateDialog(this.context);
                    // return ratingproduct;
                    //  }
                  },
                  child: Text(
                    'UPDATE REVIEW'.tr(),
                    style: TextStyle(
                        fontFamily: 'Poppinsm',
                        color:
                            isDarkMode(context) ? Colors.black : Colors.white,
                        fontSize: 17),
                  ),
                ),
              );
            }
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  primary: Color(COLOR_PRIMARY),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => savereview(),
                child: Text(
                  'SUBMIT REVIEW'.tr(),
                  style: TextStyle(
                      fontFamily: 'Poppinsm',
                      color: isDarkMode(context) ? Colors.black : Colors.white,
                      fontSize: 17),
                ),
              ),
            );
          }),
      //
    );
  }

  savereview() async {
    
    
    if (_mediaFiles.isEmpty || comment.text == '' || ratings == 0) {
      showAlertDialog(
          context, 'Please add All Field', 'All Field Reqired ', true);
    } else if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      await showProgress(context, 'Saving data to database...', false);
      List<String> mediaFilesURLs = _mediaFiles
          .where((element) => element is String)
          .toList()
          .cast<String>();
      List<File> imagesToUpload =
          _mediaFiles.where((element) => element is File).toList().cast<File>();
      if (imagesToUpload.isNotEmpty) {
        updateProgress(
          'Uploading  Images {} of {}'
              .tr(args: ['1', '${imagesToUpload.length}']),
        );
        for (int i = 0; i < imagesToUpload.length; i++) {
          if (i != 0)
            updateProgress(
              'Uploading Review Images {} of {}'.tr(
                args: ['${i + 1}', '${imagesToUpload.length}'],
              ),
            );
          String url = await fireStoreUtils.uploadProductImage(
            imagesToUpload[i],
            'Uploading Review Images {} of {}'.tr(
              args: ['${i + 1}', '${imagesToUpload.length}'],
            ),
          );
          mediaFilesURLs.add(url);
        }
      }
       VendorModel vendor = VendorModel(
       author: widget.order.vendor.author,
       authorName: widget.order.vendor.authorName,
       authorProfilePic: widget.order.vendor.authorProfilePic,
       categoryID: widget.order.vendor.categoryID,
       categoryPhoto: widget.order.vendor.categoryPhoto,
       categoryTitle: widget.order.vendor.categoryTitle,
       closetime: widget.order.vendor.closetime,
       createdAt: widget.order.vendor.createdAt,
      description: widget.order.vendor.description,
      fcmToken: widget.order.vendor.fcmToken,
      filters: widget.order.vendor.filters,
      hidephotos: widget.order.vendor.hidephotos,
      id: widget.order.vendor.id,
      latitude: widget.order.vendor.latitude,
      location: widget.order.vendor.location,
      longitude: widget.order.vendor.longitude,
      opentime: widget.order.vendor.opentime,
      phonenumber: widget.order.vendor.phonenumber,
      photo: widget.order.vendor.photo,
      price: widget.order.vendor.price,
      photos: widget.order.vendor.photos,
      title: widget.order.vendor.title,
   reviewsCount: futureCount+1,
   reviewsSum: futureSum+ ratings,
         reststatus: widget.order.vendor.reststatus
     );
      //  widget.order.products.first.
      DocumentReference documentReference =
          firestore.collection(Order_Rating).doc();
      print(documentReference.id);
      print(ratings);
      RatingModel rate = RatingModel(
        id: documentReference.id,
        comment: comment.text,
        photos: mediaFilesURLs,
        rating: ratings,
        orderId: widget.order.id,
        vendorId: widget.order.vendorID,
        customerId: MyAppState.currentUser!.userID,
        uname: MyAppState.currentUser!.firstName +
            MyAppState.currentUser!.lastName,
        profile: MyAppState.currentUser!.profilePictureURL,
      );
      String? errorMessage = await FireStoreUtils.firebaseCreateNewReview(rate);
     
     var error=await  FireStoreUtils.updateVendor(vendor);
      if (errorMessage== null&& error != null ) {
        await hideProgress();
        Navigator.pop(context, OrdersScreen());
        return rate;
      } else {
        return errorMessage;
      }
    }
  }

  showAlertDialog(
      BuildContext context, String title, String content, bool addOkButton) {
    // set up the AlertDialog
    Widget? okButton;
    if (addOkButton) {
      okButton = TextButton(
        child: Text('OK').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      );
    }

    if (Platform.isIOS) {
      CupertinoAlertDialog alert = CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [if (okButton != null) okButton],
      );
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return alert;
          });
    } else {
      AlertDialog alert = AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [if (okButton != null) okButton]);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }

  _pickImage() {
    final action = CupertinoActionSheet(
      message: Text(
        'Add Images',
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Choose image from gallery'),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              // _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              // _mediaFiles.add(null);
              setState(() {});
            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture'),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              // _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              // _mediaFiles.add(null);
              setState(() {});
            }
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _imageBuilder(dynamic image) {
    // bool isLastItem = image == null;
    return
        // GestureDetector(
        //   onTap: () {
        //       _viewOrDeleteImage(image);
        //   },
        //   child:
        Stack(children: [
      Container(
        padding: EdgeInsets.only(right: 20),

        child: Card(
          // margin:  EdgeInsets.only(right: 10),
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(5),
          ),
          color: isDarkMode(context) ? Colors.black : Colors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: image is File
                ? Image.file(
                    image,
                    fit: BoxFit.cover,
                  )
                : displayImage(image),
          ),
        ),
        // ),
      ),
      Positioned(
          right: 10,
          top: -3,
          child: InkWell(
            onTap: () {
              _viewOrDeleteImage(image);
            },
            child: Image(
              image: AssetImage('assets/images/img_cancel.png'),
              width: 25,
            ),
          ))
    ]);
  }

  _updateImageBuilder(dynamic image) {
    // bool isLastItem = image == null;
    return
        // GestureDetector(
        //   onTap: () {
        //       _viewOrDeleteImage(image);
        //   },
        //   child:
        Stack(children: [
      Container(
        padding: EdgeInsets.only(right: 20),

        child: Card(
          // margin:  EdgeInsets.only(right: 10),
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(5),
          ),
          color: isDarkMode(context) ? Colors.black : Colors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: image is File
                ? Image.file(
                    image,
                    fit: BoxFit.cover,
                  )
                : displayImage(image),
          ),
        ),
        // ),
      ),
      // Positioned(
      //     right: 10,
      //     top: -3,
      //     child: InkWell(
      //       onTap: () {
      //         // _viewOrDeleteImage(image);
      //       },
      //       child: CircleAvatar(
      //         radius: 15,
      //         child: Image(
      //           image: AssetImage('assets/images/img_cancel.png'),
      //           width: 30,
      //         ),
      //       ),
      //     ))
    ]);
  }

  _viewOrDeleteImage(dynamic image) {
    final action = CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(context);
            // _mediaFiles.removeLast();

            if (image is File) {
              _mediaFiles != _mediaFiles.single
                  ? _mediaFiles.removeWhere(
                      (value) => value is File && value.path == image.path)
                  : null;
            } else {
              _mediaFiles != _mediaFiles.first
                  ? _mediaFiles
                      .removeWhere((value) => value is String && value == image)
                  : null;
            }
            // _mediaFiles.add(null);
            _mediaFiles != _mediaFiles.single ? setState(() {}) : null;
          },
          child: Text('Remove picture'),
          isDestructiveAction: true,
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            push(
                context,
                image is File
                    ? FullScreenImage(imageFile: image)
                    : FullScreenImage(imageUrl: image));
          },
          isDefaultAction: true,
          child: Text('View picture'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  updatevendor(){
   return photofuture.then((value){
     if(ratingModel!=null) {
       futureCount = value.reviewsCount-1;
       futureSum = value.reviewsSum-ratingModel!.rating;
     }else{
       futureCount = value.reviewsCount;
       futureSum = value.reviewsSum;
     }

     print("total  $futureCount after tsum $futureSum is null ${(ratingModel!=null)}" );
    //  print(data +data2);
    } );
    // FutureBuilder(future: photofuture,
    // builder: (context,snapshot){
    //   if(snapshot.connectionState == ConnectionState.waiting)
    //   {
    //     return CircularProgressIndicator();
    //   }
    //   else
    //   return 
    // },
    // );
  }
}

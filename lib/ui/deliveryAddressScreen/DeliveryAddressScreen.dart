import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '/constants.dart';
import '/main.dart';
import '/model/AddressModel.dart';
import '/model/User.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';
import '/services/localDatabase.dart';
import '/ui/payment/PaymentScreen.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';

class DeliveryAddressScreen extends StatefulWidget {
  static final kInitialPosition = LatLng(-33.8567844, 151.213108);

  final double total;
  final double? discount;
  final String? couponCode;
  final String? couponId;
  final List<CartProduct> products;
  final List<String>? extra_addons;
  final String? extra_size;
  final String? tipValue;
  final String? deliveryCharge;
  final bool? take_away;

  const DeliveryAddressScreen(
      {Key? key,
      required this.total,
      this.discount,
      this.couponCode,
      this.couponId,
      required this.products, this.extra_addons, this.extra_size, this.tipValue, this.take_away,this
      .deliveryCharge})
      : super(key: key);
  @override
  _DeliveryAddressScreenState createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  late PickResult selectedPlace;

  final _formKey = GlobalKey<FormState>();
  // String? line1, line2, zipCode, city;
  String? country;
  var street = TextEditingController();
  var street1 = TextEditingController();
  var landmark = TextEditingController();
  var landmark1 = TextEditingController();
  var zipcode = TextEditingController();
  var zipcode1 = TextEditingController();
  var city = TextEditingController();
  var city1 = TextEditingController();
  var cutries = TextEditingController();
  var cutries1 = TextEditingController();
  var lat;
  var long;

  // const GooglApiKey = 'AIzaSyBlGgnrGEFq9Y0RGSHmjXJGcTxaj67slP4';
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    street.dispose();
    landmark.dispose();
    city.dispose();
    // cutries.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState.currentUser!.shippingAddress.country != ''
        ? country = MyAppState.currentUser!.shippingAddress.country
        : null;
    street.text = MyAppState.currentUser!.shippingAddress.line1;
    landmark.text = MyAppState.currentUser!.shippingAddress.line2;
    city.text = MyAppState.currentUser!.shippingAddress.city;
    zipcode.text = MyAppState.currentUser!.shippingAddress.postalCode;
    cutries.text = MyAppState.currentUser!.shippingAddress.country;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delivery Address'.tr(),
          style: TextStyle(
              color: isDarkMode(context) ? Colors.white : Colors.black),
        ).tr(),
      ),
      body: Container(
          color: Color(0XFFF1F4F7),
          child: Form(
              key: _formKey,
              autovalidateMode: _autoValidateMode,
              child: SingleChildScrollView(
                  child: Column(children: [
                SizedBox(
                  height: 40,
                ),
                Card(
                  elevation: 0.5,
                  color: Color(0XFFFFFFFF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsetsDirectional.only(
                            start: 20, end: 20, bottom: 10),
                        child: TextFormField(
                            // controller: street,
                            controller: street1.text.isEmpty ? street : street1,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.next,
                            validator: validateEmptyField,
                            // onSaved: (text) => line1 = text,
                            onSaved: (text) => street.text = text!,
                            style: TextStyle(fontSize: 18.0),
                            keyboardType: TextInputType.streetAddress,
                            cursorColor: Color(COLOR_PRIMARY),
                            // initialValue:
                            //     MyAppState.currentUser!.shippingAddress.line1,
                            decoration: InputDecoration(
                              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                              labelText: 'Street 1'.tr(),
                              labelStyle: TextStyle(
                                  color: Color(0Xff696A75), fontSize: 17),
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(COLOR_PRIMARY)),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).errorColor),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).errorColor),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0XFFB1BCCA)),
                                // borderRadius: BorderRadius.circular(8.0),
                              ),
                            )),
                      ),
                      // ListTile(
                      //   contentPadding:
                      //       const EdgeInsetsDirectional.only(start: 40, end: 30, top: 24),
                      //   leading: Container(
                      //     // width: 0,
                      //     child: Text(
                      //       'Street 2'.tr(),
                      //       style: TextStyle(fontSize: 16),
                      //     ),
                      //   ),
                      // ),
                      Container(
                        padding: const EdgeInsetsDirectional.only(
                            start: 20, end: 20, bottom: 10),
                        child: TextFormField(
                          // controller: _controller,
                          controller:
                              landmark1.text.isEmpty ? landmark : landmark1,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.next,
                          validator: validateEmptyField,
                          onSaved: (text) => landmark.text = text!,
                          style: TextStyle(fontSize: 18.0),
                          keyboardType: TextInputType.streetAddress,
                          cursorColor: Color(COLOR_PRIMARY),
                          // initialValue:
                          //     MyAppState.currentUser!.shippingAddress.line2,
                          decoration: InputDecoration(
                            // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                            labelText: 'Landmark'.tr(),
                            labelStyle: TextStyle(
                                color: Color(0Xff696A75), fontSize: 17),
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(COLOR_PRIMARY)),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).errorColor),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).errorColor),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                              // borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      // ListTile(
                      //   contentPadding:
                      //       const EdgeInsetsDirectional.only(start: 40, end: 30, top: 24),
                      //   leading: Container(
                      //     // width: 0,
                      //     child: Text(
                      //       'Zip Code'.tr(),
                      //       style: TextStyle(fontSize: 16),
                      //     ),
                      //   ),
                      // ),
                      Container(
                        padding: const EdgeInsetsDirectional.only(
                            start: 20, end: 20, bottom: 10),
                        child: TextFormField(
                          controller:
                              zipcode1.text.isEmpty ? zipcode : zipcode1,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.next,
                          validator: validateEmptyField,
                          onSaved: (text) => zipcode.text = text!,
                          style: TextStyle(fontSize: 18.0),
                          keyboardType: TextInputType.phone,
                          cursorColor: Color(COLOR_PRIMARY),
                          // initialValue: MyAppState
                          //     .currentUser!.shippingAddress.postalCode,
                          decoration: InputDecoration(
                            // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                            labelText: 'Zip Code'.tr(),
                            labelStyle: TextStyle(
                                color: Color(0Xff696A75), fontSize: 17),
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(COLOR_PRIMARY)),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).errorColor),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).errorColor),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                              // borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      // ListTile(
                      //   contentPadding:
                      //       const EdgeInsetsDirectional.only(start: 40, end: 30, top: 24),
                      //   leading: Container(
                      //     // width: 0,
                      //     child: Text(
                      //       'City'.tr(),
                      //       style: TextStyle(fontSize: 16),
                      //     ),
                      //   ),
                      // ),
                      Container(
                          padding: const EdgeInsetsDirectional.only(
                              start: 20, end: 20, bottom: 10),
                          child: TextFormField(
                            controller: city1.text.isEmpty ? city : city1,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.next,
                            validator: validateEmptyField,
                            onSaved: (text) => city.text = text!,
                            style: TextStyle(fontSize: 18.0),
                            keyboardType: TextInputType.streetAddress,
                            cursorColor: Color(COLOR_PRIMARY),
                            // initialValue:
                            //     MyAppState.currentUser!.shippingAddress.city,
                            decoration: InputDecoration(
                              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                              labelText: 'City'.tr(),
                              labelStyle: TextStyle(
                                  color: Color(0Xff696A75), fontSize: 17),
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(COLOR_PRIMARY)),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).errorColor),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).errorColor),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0XFFB1BCCA)),
                                // borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          )),

                      Container(
                          padding: const EdgeInsetsDirectional.only(
                              start: 20, end: 20, bottom: 10),
                          child: TextFormField(
                            controller:
                                cutries1.text.isEmpty ? cutries : cutries1,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.next,
                            validator: validateEmptyField,
                            onSaved: (text) => cutries.text = text!,
                            style: TextStyle(fontSize: 18.0),
                            keyboardType: TextInputType.streetAddress,
                            cursorColor: Color(COLOR_PRIMARY),
                            // initialValue:
                            //     MyAppState.currentUser!.shippingAddress.city,
                            decoration: InputDecoration(
                              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                              labelText: 'Country'.tr(),
                              labelStyle: TextStyle(
                                  color: Color(0Xff696A75), fontSize: 17),
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(COLOR_PRIMARY)),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).errorColor),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).errorColor),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0XFFB1BCCA)),
                                // borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          )),

                      // ListTile(
                      //   contentPadding:
                      //       const EdgeInsetsDirectional.only(start: 40, end: 30, top: 24),
                      //   leading: Container(
                      //     // width: 0,
                      //     child: Text(
                      //       'Country'.tr(),
                      //       style: TextStyle(fontSize: 16),
                      //     ),
                      //   ),
                      // ),

                      // ListTile(
                      //     contentPadding: const EdgeInsetsDirectional.only(
                      //         start: 5, end: 10),
                      //     subtitle: Padding(
                      //         padding: EdgeInsets.only(left: 16, right: 10),
                      //         child: Divider(
                      //           color: Color(0XFFB1BCCA),
                      //           thickness: 1.5,
                      //         )),
                      //     title: ButtonTheme(
                      //         alignedDropdown: true,
                      //         child: DropdownButtonHideUnderline(
                      //             child: DropdownButton<String>(
                      //           icon: Icon(Icons.keyboard_arrow_down_outlined),
                      //           hint: country == null
                      //               ? Text('Country'.tr())
                      //               : Text(
                      //                   country!,
                      //                   style: TextStyle(
                      //                       color: Color(COLOR_PRIMARY)),
                      //                 ),
                      //           items: <String>[
                      //             'USA',
                      //             'UK',
                      //             'India',
                      //             'France',
                      //             'Russia',
                      //             'Japan',
                      //             'UAE',
                      //             'Qatar',
                      //             'Netherland',
                      //             'Canada'
                      //           ].map((String value) {
                      //             return DropdownMenuItem<String>(
                      //               value: value,
                      //               child: Text(value),
                      //             );
                      //           }).toList(),
                      //           isExpanded: true,
                      //           iconSize: 30.0,
                      //           onChanged: (value) {
                      //             setState(() {
                      //               country = value;
                      //             });
                      //           },
                      //         )))
                      // ),
                      // leading: Container(
                      //   width: 60,
                      //   child: Text(
                      //     'Country'.tr(),
                      //     style: TextStyle(fontWeight: FontWeight.bold),
                      //   ),
                      // ),
                      // title: TextFormField(
                      //   textAlignVertical: TextAlignVertical.center,
                      //   textInputAction: TextInputAction.done,
                      //   validator: validateEmptyField,
                      //   onFieldSubmitted: (_) => validateForm(),
                      //   maxLength: 2,
                      //   onSaved: (text) => country = text,
                      //   style: TextStyle(fontSize: 18.0),
                      //   keyboardType: TextInputType.streetAddress,
                      //   cursorColor: Color(COLOR_PRIMARY),
                      //   initialValue: MyAppState.currentUser!.shippingAddress.country,
                      //   decoration: InputDecoration(
                      //     contentPadding: EdgeInsets.symmetric(horizontal: 24),
                      //     hintText: 'UK'.tr(),
                      //     hintStyle: TextStyle(color: Colors.grey.shade400),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8.0),
                      //       borderSide:
                      //           BorderSide(color: Color(COLOR_PRIMARY), width: 2.0),
                      //     ),
                      //     errorBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(color: Theme.of(context).errorColor),
                      //       borderRadius: BorderRadius.circular(8.0),
                      //     ),
                      //     focusedErrorBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(color: Theme.of(context).errorColor),
                      //       borderRadius: BorderRadius.circular(8.0),
                      //     ),
                      //     enabledBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(color: Colors.grey.shade300),
                      //       borderRadius: BorderRadius.circular(8.0),
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Card(
                            child: ListTile(
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // ImageIcon(
                                    //   AssetImage('assets/images/current_location1.png'),
                                    //   size: 23,
                                    //   color: Color(COLOR_PRIMARY),
                                    // ),
                                    Icon(
                                      Icons.location_searching_rounded,
                                      color: Color(COLOR_PRIMARY),
                                    ),
                                  ],
                                ),
                                title: Text(
                                  "Current Location",
                                  style: TextStyle(color: Color(COLOR_PRIMARY)),
                                ),
                                subtitle: Text(
                                  "Using GPS",
                                  style: TextStyle(color: Color(COLOR_PRIMARY)),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlacePicker(
                                        apiKey:
                                            "AIzaSyDXElUA0WZfr__W0259g_ubofCw7Iyru-4",
                                        // "AIzaSyAseYt_NDZtWHrdPsz6UZqJZAFbAi_rHic", // Put YOUR OWN KEY here.
                                        onPlacePicked: (result) async {
                                          List<Placemark> placemark =
                                              await placemarkFromCoordinates(
                                                  result.geometry!.location.lat,
                                                  result
                                                      .geometry!.location.lng);
                                          landmark1.text =
                                              placemark.first.subLocality!;
                                          // zipcode1.text =
                                          //     placemark.first.postalCode!;
                                          city1.text =
                                              placemark.first.locality!;
                                          cutries1.text =
                                              placemark.first.country!;
                                          street1.text = result
                                              .addressComponents!
                                              .first
                                              .longName;
                                          // print(placemark.first.locality);

                                          // street.text = result.
                                          // ListView.builder(
                                          //     itemCount:
                                          //         result.addressComponents!.length,
                                          //     itemBuilder: (context, index) {
                                          //      result.addressComponents![index]
                                          //                   .types.first ==
                                          //               "postal_code"
                                          //           ? return zipcode1.text = result
                                          //               .addressComponents![5].longName
                                          //           : null;
                                          //     });

                                          ////////////////////////////////

                                          result.addressComponents!
                                              .forEach((element) {
                                            element.types.forEach((elements) {
                                              elements == "postal_code"
                                                  ? zipcode1.text =
                                                      element.longName
                                                  : zipcode1.text = '';
                                            });
                                          });

                                          // result.addressComponents!
                                          //     .forEach((countryelement) {
                                          //   countryelement.types.forEach((elements1) {
                                          //     elements1 == "country"
                                          //         ? cutries1.text =
                                          //             countryelement.longName
                                          //         : cutries1.text = '';
                                          //   });
                                          // });

                                          // element.types.forEach((elements) {
                                          //   elements == "landmark"
                                          //       ? landmark1.text = element.longName
                                          //       : landmark1.text = '';
                                          // });
                                          // element.types.forEach((elements) {
                                          //   elements == "locality"
                                          //       ? city1.text = element.longName
                                          //       : city1.text = '';
                                          // });
                                          // element.types.forEach((elements) {
                                          //   elements == "country"
                                          //       ? cutries1.text = element.longName
                                          //       : cutries1.text = '';
                                          // });

                                          // street1.text =
                                          //     result.addressComponents![0].longName;
                                          // landmark1.text =
                                          //     result.addressComponents![3].longName;
                                          // city1.text =
                                          //     result.addressComponents![1].longName;
                                          // if(result.addressComponents![5].types.first == "postal_code")
                                          // zipcode1.text =
                                          //     result.addressComponents![5].longName;
                                          // cutries1.text =
                                          //     result.addressComponents![4].longName;


                                          lat = result.geometry!.location.lat;
                                          long = result.geometry!.location.lng;
                                          // Location locations = new lo;

                                          Navigator.of(context).pop();
                                          setState(() {});
                                        },
                                        initialPosition: DeliveryAddressScreen
                                            .kInitialPosition,
                                        useCurrentLocation: true,
                                      ),
                                    ),
                                  );
                                  // PlacePicker(
                                  //   apiKey:
                                  //       "AIzaSyAseYt_NDZtWHrdPsz6UZqJZAFbAi_rHic", // Put YOUR OWN KEY here.
                                  //   onPlacePicked: (result) {
                                  //     print(result.adrAddress);
                                  //     Navigator.of(context).pop();
                                  //   },

                                  //   initialPosition:
                                  //       DeliveryAddressScreen.kInitialPosition,
                                  //   useCurrentLocation: true,
                                  // ),
                                })),
                      ),


                      SizedBox(
                        height: 40,
                      )
                    ],
                  ),
                ),
                SizedBox()
              ])))),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(15),
            primary: Color(COLOR_PRIMARY),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => validateForm(),
          child: Text(
            'CONTINUE'.tr(),
            style: TextStyle(
                color: isDarkMode(context) ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
      ),
    );
  }

  validateForm() async {
    Position? locationData;
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      // if (country == null) {
      //   showDialog(
      //     context: context,
      //     builder: (BuildContext context) => ShowDialogToDismiss(
      //       title: 'Error'.tr(),
      //       content: 'Please Select Country'.tr(),
      //       buttonText: 'CLOSE'.tr(),
      //     ),
      //   );
      // } else
      {
        showProgress(context, 'Saving Address...'.tr(), false);
        try {
          locationData = await getCurrentLocation();
        } catch (e) {
          //  (e.code == 'LOCATION_SERVICES_DISABLED')
          print('Permission Denied');
          hideProgress();
          showDialog(
            context: context,
            builder: (BuildContext context) => ShowDialogToDismiss(
              title: 'Error'.tr(),
              content: 'There was an error while getting your location. Please '
                      'enable GPS and grant location permission and try '
                      'again.'
                  .tr(),
              buttonText: 'CLOSE'.tr(),
            ),
          );
        }

        MyAppState.currentUser!.location = UserLocation(
          latitude: lat == null
              ? MyAppState.currentUser!.shippingAddress.location.latitude ==
                      0.01
                  ? showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          content: Text(
                              'Please select current address using GPS location. Move pin to exact location'),
                          actions: [
                            // FlatButton(
                            //   onPressed: () => Navigator.pop(
                            //       context, false), // passing false
                            //   child: Text('No'),
                            // ),
                            TextButton(
                              onPressed: () {
                                hideProgress();
                                Navigator.pop(context, true);
                              }, // passing true
                              child: Text('OK'),
                            ),
                          ],
                        );
                      }).then((exit) {
                      if (exit == null) return;

                      if (exit) {
                        // user pressed Yes button
                      } else {
                        // user pressed No button
                      }
                    })
                  : MyAppState.currentUser!.shippingAddress.location.latitude
              : lat,
          longitude: long == null
              ? MyAppState.currentUser!.shippingAddress.location.longitude ==
                      0.01
                  ? showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          content: Text(
                              'Please select current address using GPS location. Move pin to exact location'),
                          actions: [
                            // FlatButton(
                            //   onPressed: () => Navigator.pop(
                            //       context, false), // passing false
                            //   child: Text('No'),
                            // ),
                            TextButton(
                              onPressed: () {
                                hideProgress();
                                Navigator.pop(context, true);
                              }, // passing true
                              child: Text('OK'),
                            ),
                          ],
                        );
                      }).then((exit) {
                      if (exit == null) return;

                      if (exit) {
                        // user pressed Yes button
                      } else {
                        // user pressed No button
                      }
                    })
                  : MyAppState.currentUser!.shippingAddress.location.longitude
              : long,
          // locationData!.longitude,
        );

        AddressModel userAddress = AddressModel(
            name: MyAppState.currentUser!.fullName(),
            postalCode: zipcode.text.toString(),
            line1: street.text.toString(),
            line2: landmark.text.toString(),
            country: cutries.text.toString(),
            city: city.text.toString(),

            location: MyAppState.currentUser!.location,
            email: MyAppState.currentUser!.email.toString());
        MyAppState.currentUser!.shippingAddress = userAddress;
        await FireStoreUtils.updateCurrentUserAddress(userAddress);
        hideProgress();
        print('==>-');
        print(widget.discount!);
        print(widget.couponCode!);
        print(widget.couponId!);
        push(
          context,


          PaymentScreen(
            total: widget.total,
            discount: widget.discount!,
            couponCode: widget.couponCode!,
            couponId: widget.couponId!,
            products: widget.products,
            extra_size: widget.extra_size,
            extra_addons: widget.extra_addons,
            tipValue: widget.tipValue,
            take_away: widget.take_away,
            deliveryCharge: widget.deliveryCharge,
          ),
        );
      }
    } else {

      setState(() {
        _autoValidateMode = AutovalidateMode.onUserInteraction;
      });

    }
  }
}

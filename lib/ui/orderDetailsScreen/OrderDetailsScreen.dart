import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart' as lottie;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/AppGlobal.dart';
import '/constants.dart';
import '/model/ConversationModel.dart';
import '/model/HomeConversationModel.dart';
import '/model/OrderModel.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';
import '/ui/chat/ChatScreen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/localDatabase.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel orderModel;

  const OrderDetailsScreen({Key? key, required this.orderModel})
      : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  FireStoreUtils fireStoreUtils = FireStoreUtils();
  int estimatedSecondsFromDriverToStore = 900;
  late String orderStatus;
  String currentEvent = '';
  int estimatedTime = 0;
  Timer? timerCountDown;
  String? latestArrivalTime;
  double total = 0.0;
  var discount;
  GoogleMapController? _mapController;
  PolylinePoints polylinePoints = PolylinePoints();
  StreamController<String> arrivalTimeStreamController = StreamController();
  var tipAmount = "0.0";

  //latlng of the vendor
  LatLng? vendorLocation;

  //latlng of the user
  LatLng? userLocation;

  List<LatLng> polylineCoordinates = [];
  Future<PolylineResult>? polyLinesFuture;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> orderStream;
  late bool orderDelivered;
  late bool orderRejected;

  List<Polyline> polylines = [];
  List<Marker> mapMarkers = [];
  late BitmapDescriptor driverIcon;
  late BitmapDescriptor storeIcon;

  @override
  void initState() {
    setMarkerIcon();
    orderStatus = widget.orderModel.status;
    orderRejected = orderStatus == ORDER_STATUS_REJECTED;
    orderDelivered = orderStatus == ORDER_STATUS_COMPLETED;
    if (!orderDelivered && !orderRejected) {
      vendorLocation = LatLng(widget.orderModel.vendor.latitude,
          widget.orderModel.vendor.longitude);
      userLocation = LatLng(widget.orderModel.author.location.latitude,
          widget.orderModel.author.location.longitude);
      estimateTime();

      latestArrivalTime = DateFormat('h:mm a').format(
        DateTime.now().add(
          Duration(hours: 1),
        ),
      );
    }

    orderStream = fireStoreUtils.watchOrderStatus(widget.orderModel.id);
    widget.orderModel.products.forEach((element) {
      if (element.extras_price! != null &&
          element.extras_price!.isNotEmpty &&
          double.parse(element.extras_price!) != 0.0) {
        total += element.quantity * double.parse(element.extras_price!);
      }
      total += element.quantity * double.parse(element.price);
      discount = widget.orderModel.discount;
    });
    super.initState();
  }

  @override
  void dispose() {
    timerCountDown?.cancel();
    arrivalTimeStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F4F6),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        centerTitle: false,
        title: Text(
          'Your Order'.tr(),
          style: TextStyle(
              fontSize: 18,
              letterSpacing: 0.5,
              color: isDarkMode(context)
                  ? Colors.grey.shade200
                  : Color(0XFF000000),
              fontFamily: "Poppinsm"),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: orderStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              OrderModel orderModel =
                  OrderModel.fromJson(snapshot.data!.data()!);
              orderStatus = orderModel.status;
              print('_PlaceOrderScreenState.initState $orderStatus');
              switch (orderStatus) {
                case ORDER_STATUS_PLACED:
                  currentEvent = 'We sent your order to {}'
                      .tr(args: ['${orderModel.vendor.title}']);
                  break;
                case ORDER_STATUS_ACCEPTED:
                  currentEvent = 'Preparing your order...'.tr();
                  break;
                case ORDER_STATUS_REJECTED:
                  orderRejected = true;
                  break;
                case ORDER_STATUS_DRIVER_PENDING:
                  currentEvent = 'Looking for a driver...'.tr();
                  break;
                case ORDER_STATUS_DRIVER_REJECTED:
                  currentEvent = 'Looking for a driver...'.tr();
                  break;
                case ORDER_STATUS_SHIPPED:
                  currentEvent = '{} has picked up your order.'.tr(args: [
                    '${orderModel.driver?.firstName ?? 'Our Driver'}',
                    // '${orderModel.vendor.title}'
                  ]);
                  polyLinesFuture = polylinePoints.getRouteBetweenCoordinates(
                      GOOGLE_API_KEY,
                      PointLatLng(orderModel.driver?.location.latitude ?? 0.0,
                          orderModel.driver?.location.longitude ?? 0.0),
                      PointLatLng(orderModel.vendor.latitude,
                          orderModel.vendor.longitude));
                  break;
                case ORDER_STATUS_IN_TRANSIT:
                  currentEvent = 'Your order is on the way'.tr();
                  polyLinesFuture = polylinePoints.getRouteBetweenCoordinates(
                      GOOGLE_API_KEY,
                      PointLatLng(orderModel.vendor.latitude,
                          orderModel.vendor.longitude),
                      PointLatLng(orderModel.author.location.latitude,
                          orderModel.author.location.longitude));
                  break;
                case ORDER_STATUS_COMPLETED:
                  orderDelivered = true;
                  timerCountDown?.cancel();
                  break;
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 12),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  StreamBuilder<String>(
                                      stream:
                                          arrivalTimeStreamController.stream,
                                      initialData: '',
                                      builder: (context, snapshot) {
                                        return Text(
                                          orderDelivered || orderRejected
                                              ? orderDelivered
                                                  ? 'Order Delivered'.tr()
                                                  : 'Order Rejected'.tr()
                                              : '${snapshot.data}',
                                          style: TextStyle(
                                              fontSize: 20,
                                              letterSpacing: 0.5,
                                              color: isDarkMode(context)
                                                  ? Colors.grey.shade200
                                                  : Color(0XFF000000),
                                              fontFamily: "Poppinsb"),
                                        );
                                      }),
                                  // if (estimatedTime != 0 ||
                                  //     !orderDelivered ||
                                  //     !orderRejected)
                                  estimatedTime == 0 ||
                                          orderDelivered ||
                                          orderRejected
                                      ? Container()
                                      : Text(
                                          'Estimated Arrival'.tr(),
                                          style: TextStyle(
                                              // fontSize: 20,
                                              letterSpacing: 0.5,
                                              color: isDarkMode(context)
                                                  ? Colors.grey.shade200
                                                  : Color(0XFF000000),
                                              fontFamily: "Poppinsm"),
                                        )
                                ],
                              ),

                              // estimatedTime == 0 || orderDelivered || orderRejected
                              estimatedTime == 0 ||
                                      orderDelivered ||
                                      orderRejected
                                  ? Container()
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: LinearPercentIndicator(
                                        animation: true,
                                        lineHeight: 8.0,
                                        animationDuration: estimatedTime * 1000,
                                        percent: 1,
                                        linearStrokeCap:
                                            LinearStrokeCap.roundAll,
                                        progressColor: Colors.green,
                                      ),
                                    ),
                              if (!orderRejected && !orderDelivered)
                                ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 0),
                                  title: Text(
                                    'ORDER ID'.tr(),
                                    style: TextStyle(
                                      fontFamily: 'Poppinsm',
                                      fontSize: 17,
                                      letterSpacing: 0.5,
                                      color: isDarkMode(context)
                                          ? Colors.grey.shade300
                                          : Color(0xff9091A4),
                                    ),
                                  ),
                                  trailing: Text(
                                    widget.orderModel.id,
                                    style: TextStyle(
                                      fontFamily: 'Poppinsm',
                                      letterSpacing: 0.5,
                                      fontSize: 17,
                                      color: isDarkMode(context)
                                          ? Colors.grey.shade300
                                          : Color(0xff333333),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 0.0, left: 0.0, top: 6, bottom: 12),
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: currentEvent,
                                      style: TextStyle(
                                        letterSpacing: 0.5,
                                        color: isDarkMode(context)
                                            ? Colors.grey.shade200
                                            : Color(0XFF2A2A2A),
                                        fontFamily: "Poppinsm",
                                        // fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '\nLatest arrival by {}'
                                          .tr(args: ['${(latestArrivalTime!=null)?latestArrivalTime:""}']),
                                      style: TextStyle(
                                        letterSpacing: 0.5,
                                        color: isDarkMode(context)
                                            ? Colors.grey.shade200
                                            : Colors.grey.shade700,
                                        fontFamily: "Poppinss",
                                        fontSize: 15,
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (orderStatus == ORDER_STATUS_PLACED ||
                        orderStatus == ORDER_STATUS_ACCEPTED ||
                        orderStatus == ORDER_STATUS_DRIVER_PENDING ||
                        orderStatus == ORDER_STATUS_DRIVER_REJECTED)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        child: lottie.Lottie.asset(
                          isDarkMode(context)
                              ? 'assets/images/chef_dark_bg.json'
                              : 'assets/images/chef_light_bg.json',
                        ),
                      ),
                    if (orderStatus == ORDER_STATUS_SHIPPED ||
                        orderStatus == ORDER_STATUS_IN_TRANSIT)
                      buildDeliveryMap(orderModel),
                    SizedBox(height: 10),
                    if (orderStatus == ORDER_STATUS_SHIPPED ||
                        orderStatus == ORDER_STATUS_IN_TRANSIT)
                      buildDriverCard(orderModel),
                    SizedBox(height: 16),
                    buildDeliveryDetailsCard(),
                    SizedBox(height: 16),
                    buildOrderSummaryCard(),
                  ],
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  ),
                ),
              );
            } else {
              return Center(
                child: showEmptyState(
                    'Order Not Found'.tr(),
                    'Couldn\'t get '
                            'order info'
                        .tr()),
              );
            }
          }),
    );
  }

  estimateTime() async {
    double originLat, originLong, destLat, destLong;
    originLat = widget.orderModel.vendor.latitude;
    originLong = widget.orderModel.vendor.longitude;
    destLat = widget.orderModel.author.location.latitude;
    destLong = widget.orderModel.author.location.longitude;

    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
    http.Response storeToCustomerTime =
        await http.get(Uri.parse('$url?units=metric&origins=$originLat,'
            '$originLong&destinations=$destLat,$destLong&key=$GOOGLE_API_KEY'));
    print(
        '_OrderDetailsScreenState.estimateTime ${storeToCustomerTime.body}');
    var decodedResponse = jsonDecode(storeToCustomerTime.body);
    if (decodedResponse['status'] == 'OK' &&
        decodedResponse['rows'].first['elements'].first['status'] == 'OK') {
      int secondsFromStoreToClient =
          decodedResponse['rows'].first['elements'].first['duration']['value'];
      if (orderStatus == ORDER_STATUS_SHIPPED) {
        http.Response driverToStoreTime = await http.get(Uri.parse(
            '$url?units=metric&origins=$originLat,'
            '$originLong&destinations=$destLat,$destLong&key=$GOOGLE_API_KEY'));
        var decodedDriverToStoreTimeResponse =
            jsonDecode(driverToStoreTime.body);
        if (decodedDriverToStoreTimeResponse['status'] == 'OK' &&
            decodedDriverToStoreTimeResponse['rows']
                    .first['elements']
                    .first['status'] ==
                'OK') {
          int secondsFromDriverToStore =
              decodedDriverToStoreTimeResponse['rows']
                  .first['elements']
                  .first['duration']['value'];
          estimatedTime =
              secondsFromStoreToClient + secondsFromDriverToStore;
        } else {
          estimatedTime = secondsFromStoreToClient +
              estimatedSecondsFromDriverToStore;
        }
      } else if (orderStatus == ORDER_STATUS_IN_TRANSIT) {
        estimatedTime = secondsFromStoreToClient;
      } else {
        estimatedTime = secondsFromStoreToClient +
            estimatedSecondsFromDriverToStore;
      }
      setState(() {});
      timerCountDown = Timer.periodic(
        Duration(seconds: 1),
        (timer) {
          if (estimatedTime == 0) {
            arrivalTimeStreamController.sink.add('');
            timer.cancel();
            setState(() {});
          } else {
            estimatedTime--;
            arrivalTimeStreamController.sink.add(
              _formatArrivalTimeDuration(
                Duration(seconds: estimatedTime),
              ),
            );
          }
        },
      );
    }
  }

  String _formatArrivalTimeDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String formattedTime =
        '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds'
            .replaceAll('00:', '');
    return formattedTime.length == 2 ? '$formattedTime Seconds' : formattedTime;
  }

  Widget buildDeliveryDetailsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        color: isDarkMode(context) ? Colors.grey.shade900 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.orderModel.takeAway == false
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Details'.tr(),
                          style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 0.5,
                              color: isDarkMode(context)
                                  ? Colors.grey.shade200
                                  : Color(0XFF000000),
                              fontFamily: "Poppinsb"),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Address'.tr(),
                          style: TextStyle(
                              fontSize: 17,
                              letterSpacing: 0.5,
                              color: isDarkMode(context)
                                  ? Colors.grey.shade200
                                  : Color(COLOR_PRIMARY),
                              fontFamily: "Poppinsm"),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${widget.orderModel.address.line1} ${widget.orderModel.address.line2}, ${widget.orderModel.address.city}, ${widget.orderModel.address.country}',
                          style: TextStyle(
                              fontFamily: "Poppinss",
                              fontSize: 18,
                              letterSpacing: 0.5,
                              color: isDarkMode(context)
                                  ? Colors.grey.shade200
                                  : Colors.grey.shade700),
                        ),
                        Divider(height: 40),
                      ],
                    )
                  : Container(),
              Text(
                'Type'.tr(),
                style: TextStyle(
                    fontSize: 17,
                    letterSpacing: 0.5,
                    color: isDarkMode(context)
                        ? Colors.grey.shade200
                        : Color(COLOR_PRIMARY),
                    fontFamily: "Poppinsm"),
              ),
              SizedBox(height: 8),
              widget.orderModel.takeAway == false
                  ? Text(
                      'Deliver to door'.tr(),
                      style: TextStyle(
                          fontFamily: "Poppinss",
                          fontSize: 18,
                          letterSpacing: 0.5,
                          color: isDarkMode(context)
                              ? Colors.grey.shade200
                              : Colors.grey.shade700),
                    )
                  : Text(
                      'Takeaway'.tr(),
                      style: TextStyle(
                          fontFamily: "Poppinss",
                          fontSize: 18,
                          letterSpacing: 0.5,
                          color: isDarkMode(context)
                              ? Colors.grey.shade200
                              : Colors.grey.shade700),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOrderSummaryCard() {
    double tipValue = widget.orderModel.tipValue!.isEmpty
        ? 0.0
        : double.parse(widget.orderModel.tipValue!);
    var totalamount = widget.orderModel.deliveryCharge == null ||
            widget.orderModel.deliveryCharge!.isEmpty
        ? total - discount
        : total +
            double.parse(widget.orderModel.deliveryCharge!) +
            tipValue -
            discount;
    //  total = total-Deliverycharge -discount;
    print("order total ${symbol + totalamount.toDouble().toStringAsFixed(decimal)}");
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, top: 8,bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary'.tr(),
                  style: TextStyle(
                    fontFamily: 'Poppinsm',
                    fontSize: 18,
                    letterSpacing: 0.5,
                    color: Color(0XFF000000),
                  ),
                ),
                SizedBox(height: 11),
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.orderModel.products.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: CachedNetworkImage(
                                    height: 55,
                                    // width: 50,
                                    imageUrl:
                                        '${widget.orderModel.products[index].photo}',
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Image.network(
                                              AppGlobal.placeHolderImage!,
                                              fit: BoxFit.cover,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                            ))),
                              ),
                              Expanded(
                                flex: 10,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 14.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${widget.orderModel.products[index].name}',
                                            style: TextStyle(
                                                fontFamily: 'Poppinsr',
                                                fontSize: 17,
                                                letterSpacing: 0.5,
                                                color: isDarkMode(context)
                                                    ? Colors.grey.shade200
                                                    : Color(0xff333333)),
                                          ),
                                          Icon(Icons.close, size: 18),
                                          Text(
                                            '${widget.orderModel.products[index].quantity}',
                                            style: TextStyle(
                                                fontFamily: 'Poppinsr',
                                                fontSize: 17,
                                                letterSpacing: 0.5,
                                                color: isDarkMode(context)
                                                    ? Colors.grey.shade200
                                                    : Color(0xff333333)),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      /*Text(
                                          symbol +
                                              double.parse(widget.orderModel
                                                      .products[index].price)
                                                  .toStringAsFixed(decimal),
                                          style: TextStyle(
                                            fontFamily: 'Poppinsm',
                                            fontSize: 17,
                                            letterSpacing: 0.5,
                                            color: isDarkMode(context)
                                                ? Color(COLOR_PRIMARY)
                                                : Color(0xffFF683A),
                                          ))*/

                                getPriceTotalText(widget.orderModel.products[index]),

                                    ],
                                  ),
                                ),
                              )
                            ],
                          ));
                    }),
                SizedBox(height: 15),
                Divider(
                  height: 0.5,
                  color: isDarkMode(context) ? Color(0Xff35363A) : null,
                ),
                ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  title: Text(
                    'Subtotal'.tr(),
                    style: TextStyle(
                      fontFamily: 'Poppinsm',
                      fontSize: 17,
                      letterSpacing: 0.5,
                      color: isDarkMode(context)
                          ? Colors.grey.shade300
                          : Color(0xff9091A4),
                    ),
                  ),
                  trailing: Text(
                    symbol + total.toDouble().toStringAsFixed(decimal),
                    style: TextStyle(
                      fontFamily: 'Poppinsm',
                      letterSpacing: 0.5,
                      fontSize: 17,
                      color: isDarkMode(context)
                          ? Colors.grey.shade300
                          : Color(0xff333333),
                    ),
                  ),
                ),
                ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  title: Text(
                    'Discount'.tr(),
                    style: TextStyle(
                      fontFamily: 'Poppinsm',
                      fontSize: 17,
                      letterSpacing: 0.5,
                      color: isDarkMode(context)
                          ? Colors.grey.shade300
                          : Color(0xff9091A4),
                    ),
                  ),
                  trailing: Text(
                    symbol + discount.toDouble().toStringAsFixed(decimal),
                    style: TextStyle(
                      fontFamily: 'Poppinsm',
                      letterSpacing: 0.5,
                      fontSize: 17,
                      color: isDarkMode(context)
                          ? Colors.grey.shade300
                          : Color(0xff333333),
                    ),
                  ),
                ),
                widget.orderModel.takeAway == false
                    ? ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        title: Text(
                          'Delivery Charges'.tr(),
                          style: TextStyle(
                            fontFamily: 'Poppinsm',
                            fontSize: 17,
                            letterSpacing: 0.5,
                            color: isDarkMode(context)
                                ? Colors.grey.shade300
                                : Color(0xff9091A4),
                          ),
                        ),
                        trailing: Text(
                          widget.orderModel.deliveryCharge == null
                              ? symbol + "0.0"
                              : symbol + widget.orderModel.deliveryCharge!,
                          style: TextStyle(
                            fontFamily: 'Poppinsm',
                            letterSpacing: 0.5,
                            fontSize: 17,
                            color: isDarkMode(context)
                                ? Colors.grey.shade300
                                : Color(0xff333333),
                          ),
                        ),
                      )
                    : Container(),
                widget.orderModel.takeAway == false
                    ? ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        title: Text(
                          'Tip Amount'.tr(),
                          style: TextStyle(
                            fontFamily: 'Poppinsm',
                            fontSize: 17,
                            letterSpacing: 0.5,
                            color: isDarkMode(context)
                                ? Colors.grey.shade300
                                : Color(0xff9091A4),
                          ),
                        ),
                        trailing: Text(
                          widget.orderModel.tipValue!.isEmpty
                              ? symbol + "0.0"
                              : symbol + widget.orderModel.tipValue!,
                          style: TextStyle(
                            fontFamily: 'Poppinsm',
                            letterSpacing: 0.5,
                            fontSize: 17,
                            color: isDarkMode(context)
                                ? Colors.grey.shade300
                                : Color(0xff333333),
                          ),
                        ),
                      )
                    : Container(),
                widget.orderModel.couponCode!.trim().isNotEmpty
                    ? ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        title: Text(
                          'Coupon Code'.tr(),
                          style: TextStyle(
                            fontFamily: 'Poppinsm',
                            fontSize: 17,
                            letterSpacing: 0.5,
                            color: isDarkMode(context)
                                ? Colors.grey.shade300
                                : Color(0xff9091A4),
                          ),
                        ),
                        trailing: Text(
                          widget.orderModel.couponCode!,
                          style: TextStyle(
                            fontFamily: 'Poppinsm',
                            letterSpacing: 0.5,
                            fontSize: 17,
                            color: isDarkMode(context)
                                ? Colors.grey.shade300
                                : Color(0xff333333),
                          ),
                        ),
                      )
                    : Container(),
                ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  title: Text(
                    'Order Total'.tr(),
                    style: TextStyle(
                      fontFamily: 'Poppinsm',
                      fontSize: 17,
                      letterSpacing: 0.5,
                      color: isDarkMode(context)
                          ? Colors.grey.shade300
                          : Color(0xff333333),
                    ),
                  ),
                  trailing: Text(
                    symbol + totalamount.toDouble().toStringAsFixed(decimal),
                    style: TextStyle(
                      fontFamily: 'Poppinsm',
                      letterSpacing: 0.5,
                      fontSize: 17,
                      color: isDarkMode(context)
                          ? Colors.grey.shade300
                          : Color(COLOR_PRIMARY),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget buildOrderSummaryCard() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //     child: Card(
  //       color: isDarkMode(context) ? Colors.grey.shade900 : Colors.white,
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Order Summary'.tr(),
  //               style: TextStyle(
  //                   fontWeight: FontWeight.w700,
  //                   fontSize: 20,
  //                   color: isDarkMode(context)
  //                       ? Colors.grey.shade200
  //                       : Colors.grey.shade700),
  //             ),
  //             SizedBox(height: 16),
  //             Text(
  //               '${widget.orderModel.vendor.title}',
  //               style: TextStyle(
  //                   fontWeight: FontWeight.w400,
  //                   fontSize: 17,
  //                   color: isDarkMode(context)
  //                       ? Colors.grey.shade200
  //                       : Colors.grey.shade700),
  //             ),
  //             SizedBox(height: 16),
  //             ListView.builder(
  //               physics: NeverScrollableScrollPhysics(),
  //               shrinkWrap: true,
  //               itemCount: widget.orderModel.products.length,
  //               itemBuilder: (context, index) => Padding(
  //                 padding: EdgeInsets.symmetric(vertical: 12),
  //                 child: Row(
  //                   children: [
  //                     Container(
  //                       color: isDarkMode(context)
  //                           ? Colors.grey.shade700
  //                           : Colors.grey.shade200,
  //                       padding: EdgeInsets.all(6),
  //                       child: Text(
  //                         '${widget.orderModel.products[index].quantity}',
  //                         style: TextStyle(
  //                             fontSize: 18, fontWeight: FontWeight.bold),
  //                       ),
  //                     ),
  //                     SizedBox(width: 16),
  //                     Text(
  //                       '${widget.orderModel.products[index].name}',
  //                       style: TextStyle(
  //                           color: isDarkMode(context)
  //                               ? Colors.grey.shade300
  //                               : Colors.grey.shade800,
  //                           fontWeight: FontWeight.w500,
  //                           fontSize: 18),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 16),
  //             ListTile(
  //               title: Text(
  //                 'Total'.tr(),
  //                 style: TextStyle(
  //                   fontSize: 25,
  //                   fontWeight: FontWeight.w700,
  //                   color: isDarkMode(context)
  //                       ? Colors.grey.shade300
  //                       : Colors.grey.shade700,
  //                 ),
  //               ),
  //               trailing: Text(
  //                 '\$${total.toStringAsFixed(2)}',
  //                 style: TextStyle(
  //                   fontSize: 25,
  //                   fontWeight: FontWeight.w400,
  //                   color: isDarkMode(context)
  //                       ? Colors.grey.shade300
  //                       : Colors.grey.shade700,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void setMarkerIcon() async {
    driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(44, 44)),
        'assets/images/location_black3x.png');
    storeIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(44, 44)),
        'assets/images/location_orange3x.png');
  }

  Widget buildDeliveryMap(OrderModel orderModel) {
    return FutureBuilder<PolylineResult>(
        future: polyLinesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.status == 'OK') {
              polylineCoordinates.clear();
              for (PointLatLng point in snapshot.data!.points) {
                polylineCoordinates
                    .add(LatLng(point.latitude, point.longitude));
              }
            }
            polylines.clear();
            mapMarkers.clear();
            if (polylineCoordinates.isNotEmpty) {
              if (orderStatus == ORDER_STATUS_SHIPPED) {
                mapMarkers.add(
                  Marker(
                    markerId: MarkerId('driverMarker'),
                    position: polylineCoordinates.first,
                    icon: driverIcon,
                    infoWindow: InfoWindow(
                      title: orderModel.driver?.fullName() ?? 'Driver',
                    ),
                  ),
                );
                mapMarkers.add(
                  Marker(
                    markerId: MarkerId('storeMarker'),
                    position: polylineCoordinates.last,
                    icon: storeIcon,
                    infoWindow: InfoWindow(
                      title: orderModel.vendor.title,
                    ),
                  ),
                );

                Polyline polyline = Polyline(
                  polylineId: PolylineId(
                      'polyline_id_${orderModel.driver?.firstName ?? 'driver'}_to_${orderModel.vendor.title}'),
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                  width: 5,
                  points: polylineCoordinates,
                );
                polylines.add(polyline);
              } else if (orderStatus == ORDER_STATUS_IN_TRANSIT) {
                mapMarkers.add(
                  Marker(
                    markerId: MarkerId('storeMarker'),
                    position: polylineCoordinates.first,
                    icon: storeIcon,
                    infoWindow: InfoWindow(
                      title: orderModel.vendor.title,
                    ),
                  ),
                );
                mapMarkers.add(
                  Marker(
                    markerId: MarkerId('customer'),
                    position: polylineCoordinates.last,
                    icon: driverIcon,
                    infoWindow: InfoWindow(
                      title: orderModel.vendor.authorName,
                    ),
                  ),
                );

                Polyline polyline = Polyline(
                  polylineId: PolylineId(
                      'polyline_id_${orderModel.vendor.title}_to_${orderModel.author.firstName}'),
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                  width: 5,
                  points: polylineCoordinates,
                );
                polylines.add(polyline);
              }
            }
            return SizedBox(
              height: MediaQuery.of(context).size.height / 2.7,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  child: GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    compassEnabled: true,
                    gestureRecognizers: Set()
                      ..add(Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer())),
                    markers: Set<Marker>.from(mapMarkers),
                    polylines: Set<Polyline>.of(polylines),
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: vendorLocation!,
                      zoom: 15,
                    ),
                    onMapCreated: (controller) =>
                        _onMapCreated(controller, orderModel),
                  ),
                ),
              ),
            );
          }
          return Container();
        });
  }

  void _onMapCreated(GoogleMapController controller, OrderModel orderModel) {
    _mapController = controller;
    if (isDarkMode(context))
      _mapController!.setMapStyle('[{"featureType": "all","'
          'elementType": "'
          'geo'
          'met'
          'ry","stylers": [{"color": "#242f3e"}]},{"featureType": "all","elementType": "labels.text.stroke","stylers": [{"lightness": -80}]},{"featureType": "administrative","elementType": "labels.text.fill","stylers": [{"color": "#746855"}]},{"featureType": "administrative.locality","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi.park","elementType": "geometry","stylers": [{"color": "#263c3f"}]},{"featureType": "poi.park","elementType": "labels.text.fill","stylers": [{"color": "#6b9a76"}]},{"featureType": "road","elementType": "geometry.fill","stylers": [{"color": "#2b3544"}]},{"featureType": "road","elementType": "labels.text.fill","stylers": [{"color": "#9ca5b3"}]},{"featureType": "road.arterial","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.arterial","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "road.highway","elementType": "geometry.fill","stylers": [{"color": "#746855"}]},{"featureType": "road.highway","elementType": "geometry.stroke","stylers": [{"color": "#1f2835"}]},{"featureType": "road.highway","elementType": "labels.text.fill","stylers": [{"color": "#f3d19c"}]},{"featureType": "road.local","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.local","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "transit","elementType": "geometry","stylers": [{"color": "#2f3948"}]},{"featureType": "transit.station","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "water","elementType": "geometry","stylers": [{"color": "#17263c"}]},{"featureType": "water","elementType": "labels.text.fill","stylers": [{"color": "#515c6d"}]},{"featureType": "water","elementType": "labels.text.stroke","stylers": [{"lightness": -20}]}]');
    if (orderStatus == ORDER_STATUS_IN_TRANSIT) {
      updateCameraLocation(vendorLocation!, userLocation!, _mapController);
    } else if (orderStatus == ORDER_STATUS_SHIPPED) {
      updateCameraLocation(
          LatLng(orderModel.driver?.location.latitude ?? 0,
              orderModel.driver?.location.longitude ?? 0),
          vendorLocation!,
          _mapController);
    }
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
      CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  Widget buildDriverCard(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        color: isDarkMode(context) ? Colors.grey.shade900 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: '{} is in {}'.tr(
                          args: [
                            '${order.driver?.firstName ?? 'Our driver'}',
                            '${order.driver?.carName ?? 'his car'}'
                          ],
                        ),
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDarkMode(context)
                                ? Colors.grey.shade200
                                : Colors.grey.shade600,
                            fontSize: 17)),
                    TextSpan(
                      text: '\n${order.driver?.carNumber ?? 'No car number '
                          'provided'}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: isDarkMode(context)
                              ? Colors.grey.shade200
                              : Colors.grey.shade800),
                    ),
                  ]),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    displayCircleImage(
                        order.driver?.carPictureURL ??
                            'https://firebasestorage.googleapis.com/v0/b/gromart-5dd93.appspot.com/o/images%2Fcar_default_image.png?alt=media&token=503e1888-2231-4621-a2d0-51f9bb7e7208',
                        80,
                        true),
                    Positioned.directional(
                        textDirection: Directionality.of(context),
                        start: -65,
                        child: displayCircleImage(
                            order.author.profilePictureURL, 80, true))
                  ],
                ),
              ]),
              SizedBox(height: 16),
              ListTile(
                leading: FloatingActionButton(
                  onPressed: order.driver == null
                      ? null
                      : () {
                          String url = 'tel:${order.driver!.phoneNumber}';
                          launch(url);
                        },
                  mini: true,
                  tooltip: 'Call {}'.tr(
                    args: ['${order.driver?.firstName ?? 'Driver'}'],
                  ),
                  backgroundColor:
                      // isDarkMode(context) ? Colors.grey.shade700 :
                      Colors.green,
                  elevation: 0,
                  child: Icon(Icons.phone, color: Color(0xFFFFFFFF)),
                ),
                title: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode(context)
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.all(
                        Radius.circular(360),
                      ),
                    ),
                    child: Text(
                      'Send a message'.tr(),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  onTap: order.driver == null
                      ? null
                      : () async {
                          String channelID;
                          if (order.driver!.userID
                                  .compareTo(order.author.userID) <
                              0) {
                            channelID =
                                order.driver!.userID + order.author.userID;
                          } else {
                            channelID =
                                order.author.userID + order.driver!.userID;
                          }

                          ConversationModel? conversationModel =
                              await fireStoreUtils
                                  .getChannelByIdOrNull(channelID);
                          push(
                            context,
                            ChatScreen(
                              homeConversationModel: HomeConversationModel(
                                  members: [order.driver!],
                                  conversationModel: conversationModel),
                            ),
                          );
                        },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  getPriceTotalText(CartProduct s) {
    double total = 0.0;

    if (s.extras_price != null && s.extras_price!.isNotEmpty &&
        double.parse(s.extras_price!) !=0.0) {
      total += s.quantity * double.parse(s.extras_price!);
    }
    total += s.quantity * double.parse(s.price);

    return Text(
      symbol + total.toString(),
      style: TextStyle(
          fontSize: 20,
          color: isDarkMode(context)
              ? Colors.grey.shade200
              : Color(COLOR_PRIMARY),
          fontFamily: "Poppinsm"),
    );
  }
}

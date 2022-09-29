import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/services/helper.dart';
import '/ui/cartScreen/CartScreen.dart';
import '/ui/mapView/MapViewScreen.dart';
import '/ui/searchScreen/SearchScreen.dart';

import 'constants.dart';

class AppGlobal {
  static late GlobalKey<SearchScreenState> _searchScreenStateKey = GlobalKey();

  static double  deliveryCharges = 0.0;

  static String? placeHolderImage = "";

  static AppBar buildAppBar(BuildContext context, String title) {
    return AppBar(
      centerTitle: false,
      backgroundColor: isDarkMode(context) ? Color(DARK_COLOR) : null,
      // iconTheme: IconThemeData(color: Colors.blue),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              width: 25,
              height: 25,
              child: Image(
                image: AssetImage("assets/images/ic_back.png"),
                color: !isDarkMode(context) ? Colors.black : Colors.white,
              ),
            ),
          ),
         Text(
            title,
            style: TextStyle(
                fontFamily: "Poppinsm",
                fontSize: 15.5,
                color: isDarkMode(context) ? Colors.white : Colors.black,
                fontWeight: FontWeight.normal),
          ),
        ],
      ),
      actions: [
        IconButton(
            visualDensity: VisualDensity(horizontal: -4),
            padding: EdgeInsets.only(right: 7),
            icon: Image(
              image: AssetImage("assets/images/search.png"),
              width: 20,
              color: isDarkMode(context) ? Colors.white : null,
            ),
            onPressed: () async {

              push(
                context,
                SearchScreen(
                  key: _searchScreenStateKey,
                  isCheckOnAppGlobal: true,
                ),
              );
              await Future.delayed(Duration(seconds: 1), () {

              });
            }),
        IconButton(
          visualDensity: VisualDensity(horizontal: -4),
          padding: EdgeInsets.only(right: 7),
          icon: Image(
            image: AssetImage("assets/images/map.png"),
            width: 20,
            color: isDarkMode(context) ? Colors.white : Color(0xFF333333),
          ),
          onPressed: () => push(
            context,
            MapViewScreen(),
          ),
        ),
        IconButton(
            padding: EdgeInsets.only(right: 17),
            visualDensity: VisualDensity(horizontal: -4),
            tooltip: 'Cart'.tr(),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Image(
                  image: AssetImage("assets/images/cart.png"),
                  width: 20,
                  color: isDarkMode(context) ? Colors.white : null,
                ),
              ],
            ),
            onPressed: () {
              push(
                context,
                CartScreen(
                  fromContainer: false,
                ),
              );
            }),
      ],
    );
  }


}

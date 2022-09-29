import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import '/constants.dart';
import '/main.dart';
import '/model/User.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';
import '/services/localDatabase.dart';
import '/ui/auth/AuthScreen.dart';
import '/ui/cartScreen/CartScreen.dart';
import '/ui/contactUs/ContactUsScreen.dart';
import '/ui/cuisinesScreen/CuisinesScreen.dart';
import '/ui/home/HomeScreen.dart';
import '/ui/home/favourite_store.dart';
import '/ui/mapView/MapViewScreen.dart';
import '/ui/ordersScreen/OrdersScreen.dart';
import '/ui/profile/ProfileScreen.dart';
import '/ui/searchScreen/SearchScreen.dart';
import '/userPrefrence.dart';
import 'package:flutter_facebook_keyhash/flutter_facebook_keyhash.dart';

enum DrawerSelection { Home, Wallet, Cuisines, Search, Cart, Profile, Orders, Logout,LikedStore }

class ContainerScreen extends StatefulWidget {
  final User user;
  final Widget currentWidget;
  final String appBarTitle;
  final DrawerSelection drawerSelection;


  ContainerScreen(
      {Key? key,
      required this.user,
      currentWidget,
      appBarTitle,
      this.drawerSelection = DrawerSelection.Home})
      : this.appBarTitle = appBarTitle ?? 'Home'.tr(),
        this.currentWidget = currentWidget ??
            HomeScreen(
              user: MyAppState.currentUser!,
            ),
        super(key: key);

  @override
  _ContainerScreen createState() {
    return _ContainerScreen();
  }
}

class _ContainerScreen extends State<ContainerScreen> {
  late GlobalKey<SearchScreenState> _searchScreenStateKey;
  var key = GlobalKey<ScaffoldState>();

  late CartDatabase cartDatabase;
  late User user;
  late String _appBarTitle;
  final fireStoreUtils = FireStoreUtils();

  late Widget _currentWidget;
  late DrawerSelection _drawerSelection;

  int cartCount = 0;
  bool? isWalletEnable;

  Future<void> getKeyHash() async {
    String keyHash;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      keyHash = await FlutterFacebookKeyhash.getFaceBookKeyHash ??
          'Unknown platform KeyHash';
    } on PlatformException {
      keyHash = 'Failed to get Kay Hash.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
       keyHash;
      print("::::KEYHASH::::");
      print(keyHash);
    });
  }
  @override
  void initState() {
    super.initState();
    //FireStoreUtils.walletSettingData().then((value) => isWalletEnable = value);
    user = widget.user;
    _searchScreenStateKey = GlobalKey();
    _currentWidget = widget.currentWidget;
    _appBarTitle = widget.appBarTitle;
    _drawerSelection = widget.drawerSelection;
    //getKeyHash();
    /// On iOS, we request notification permissions, Does nothing and returns null on Android
    FireStoreUtils.firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cartDatabase = Provider.of<CartDatabase>(context);
  }
  DateTime pre_backpress = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final timegap = DateTime.now().difference(pre_backpress);
        final cantExit = timegap >= Duration(seconds: 2);
        pre_backpress = DateTime.now();
        if(cantExit){
          //show snackbar
          final snack = SnackBar(content: Text('Press Back button again to Exit',style: TextStyle(color:Colors.white),),duration: Duration(seconds: 2),backgroundColor: Colors.black,);
          ScaffoldMessenger.of(context).showSnackBar(snack);
          return false; // false will do nothing when back press
        }else{
          return true;   // true will exit the app
        }
      },
      child: ChangeNotifierProvider.value(
        value: user,
        child: Consumer<User>(
          builder: (context, user, _) {
            return Scaffold(
              extendBodyBehindAppBar: _drawerSelection == DrawerSelection.Wallet ? true : false,
              key: key,
              drawer: Drawer(
                child: Container(
                    color: isDarkMode(context) ? Color(DARK_COLOR) : null,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        Consumer<User>(builder: (context, user, _) {
                          return DrawerHeader(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                displayCircleImage(
                                    user.profilePictureURL, 75, false),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    user.fullName(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      user.email,
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ],
                            ),
                            decoration: BoxDecoration(
                              color: Color(COLOR_PRIMARY),
                            ),
                          );
                        }),
                        ListTileTheme(
                          style: ListTileStyle.drawer,
                          selectedColor: Color(COLOR_PRIMARY),
                          child: ListTile(
                            selected: _drawerSelection == DrawerSelection.Home,
                            title: Text('Stores').tr(),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _drawerSelection = DrawerSelection.Home;
                                _appBarTitle = 'Stores'.tr();
                                _currentWidget = HomeScreen(
                                  user: MyAppState.currentUser!,
                                );
                              });
                            },
                            leading: Icon(CupertinoIcons.home),
                          ),
                        ),
                        ListTileTheme(
                          style: ListTileStyle.drawer,
                          selectedColor: Color(COLOR_PRIMARY),
                          child: ListTile(
                              selected:
                                  _drawerSelection == DrawerSelection.Cuisines,
                              leading: Image.asset(
                                'assets/images/category.png',
                                color:
                                    _drawerSelection == DrawerSelection.Cuisines
                                        ? Color(COLOR_PRIMARY)
                                        : isDarkMode(context)
                                            ? Colors.grey.shade200
                                            : Colors.grey.shade600,
                                width: 24,
                                height: 24,
                              ),
                              title: Text('Categories').tr(),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _drawerSelection = DrawerSelection.Cuisines;
                                  _appBarTitle = 'Categories'.tr();
                                  _currentWidget = CuisinesScreen();
                                });
                              }),
                        ),
                        ListTileTheme(
                          style: ListTileStyle.drawer,
                          selectedColor: Color(COLOR_PRIMARY),
                          child: ListTile(
                              selected:
                                  _drawerSelection == DrawerSelection.Search,
                              title: Text('search').tr(),
                              leading: Icon(Icons.search),
                              onTap: () async {
                                Navigator.pop(context);
                                setState(() {
                                  _drawerSelection = DrawerSelection.Search;
                                  _appBarTitle = 'search'.tr();
                                  _currentWidget = SearchScreen(
                                    key: _searchScreenStateKey,
                                  );
                                });
                                await Future.delayed(Duration(seconds: 1), () {
                                  setState(() {});
                                });


                              }),
                        ),
                        ListTileTheme(
                          style: ListTileStyle.drawer,
                          selectedColor: Color(COLOR_PRIMARY),
                          child: ListTile(
                            selected: _drawerSelection == DrawerSelection.LikedStore,
                            title: Text('Favourite Stores').tr(),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _drawerSelection = DrawerSelection.LikedStore;
                                _appBarTitle = 'Favourite Stores'.tr();
                                _currentWidget = FavouriteStoreScreen();
                              });
                            },
                            leading: Icon(CupertinoIcons.heart),
                          ),
                        ),

                        ListTileTheme(
                          style: ListTileStyle.drawer,
                          selectedColor: Color(COLOR_PRIMARY),
                          child: ListTile(
                            selected: _drawerSelection == DrawerSelection.Cart,
                            leading: Icon(CupertinoIcons.cart),
                            title: Text('Cart').tr(),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _drawerSelection = DrawerSelection.Cart;
                                _appBarTitle = 'Your Cart'.tr();
                                _currentWidget = CartScreen(
                                  fromContainer: true,
                                );
                              });
                            },
                          ),
                        ),

                        ListTileTheme(
                          style: ListTileStyle.drawer,
                          selectedColor: Color(COLOR_PRIMARY),
                          child: ListTile(
                            selected:
                                _drawerSelection == DrawerSelection.Profile,
                            leading: Icon(CupertinoIcons.person),
                            title: Text('Profile').tr(),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _drawerSelection = DrawerSelection.Profile;
                                _appBarTitle = 'My Profile'.tr();
                                _currentWidget = ProfileScreen(
                                  user: user,
                                );
                              });
                            },
                          ),
                        ),
                        ListTileTheme(
                          style: ListTileStyle.drawer,
                          selectedColor: Color(COLOR_PRIMARY),
                          child: ListTile(
                            selected:
                                _drawerSelection == DrawerSelection.Orders,
                            leading: Image.asset(
                              'assets/images/truck.png',
                              color: _drawerSelection == DrawerSelection.Orders
                                  ? Color(COLOR_PRIMARY)
                                  : isDarkMode(context)
                                      ? Colors.grey.shade200
                                      : Colors.grey.shade600,
                              width: 24,
                              height: 24,
                            ),
                            title: Text('Orders').tr(),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _drawerSelection = DrawerSelection.Orders;
                                _appBarTitle = 'Orders'.tr();
                                _currentWidget = OrdersScreen();
                              });
                            },
                          ),
                        ),
                        ListTileTheme(
                          style: ListTileStyle.drawer,
                          selectedColor: Color(COLOR_PRIMARY),
                          child: ListTile(
                            selected:
                                _drawerSelection == DrawerSelection.Logout,
                            leading: Icon(Icons.logout),
                            title: Text('Log Out').tr(),
                            onTap: () async {
                              Navigator.pop(context);
                              //user.active = false;
                              user.lastOnlineTimestamp = Timestamp.now();
                              user.fcmToken="";
                              await FireStoreUtils.updateCurrentUser(user);
                              await auth.FirebaseAuth.instance.signOut();
                              MyAppState.currentUser = null;
                              pushAndRemoveUntil(context, AuthScreen(), false);
                            },
                          ),
                        ),
                      ],
                    )),
              ),
              appBar: AppBar(
                elevation: _drawerSelection == DrawerSelection.Wallet ? 0 : 0,
                centerTitle: _drawerSelection == DrawerSelection.Wallet ? true : false,
                backgroundColor: _drawerSelection == DrawerSelection.Wallet ? Colors.transparent : isDarkMode(context) ? Color(DARK_COLOR) : Colors.white,
                //isDarkMode(context) ? Color(DARK_COLOR) : null,
                leading: IconButton(
                    visualDensity: VisualDensity(horizontal: -4),
                    padding: EdgeInsets.only(right: 5),
                    icon: Image(
                      image: AssetImage("assets/images/menu.png"),
                      width: 20,
                      color: _drawerSelection == DrawerSelection.Wallet ? Colors.white : isDarkMode(context) ? Colors.white : Color(DARK_COLOR),
                    ),
                    onPressed: () => key.currentState!.openDrawer()),
                // iconTheme: IconThemeData(color: Colors.blue),
                title: _currentWidget is SearchScreen
                    ? _buildSearchField()
                    : Text(
                        _appBarTitle,
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            fontSize: 18,
                            color: _drawerSelection == DrawerSelection.Wallet ? Colors.white : isDarkMode(context) ? Colors.white : Color(DARK_COLOR),
                            //isDarkMode(context) ? Colors.white : Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                actions: _drawerSelection == DrawerSelection.Wallet ? [] : [
                  IconButton(
                      visualDensity: VisualDensity(horizontal: -4),
                      padding: EdgeInsets.only(right: 10),
                      icon: Image(
                        image: AssetImage("assets/images/search.png"),
                        width: 20,
                        color: isDarkMode(context) ? Colors.white : null,
                      ),
                      onPressed: () {
                        setState(() {
                          _drawerSelection = DrawerSelection.Search;
                          _appBarTitle = 'search'.tr();
                          _currentWidget = SearchScreen(
                            key: _searchScreenStateKey,
                          );
                        });
                      }),
                  if (!(_currentWidget is CartScreen) ||
                      !(_currentWidget is ProfileScreen))
                    IconButton(
                      visualDensity: VisualDensity(horizontal: -4),
                      padding: EdgeInsets.only(right: 10),
                      icon: Image(
                        image: AssetImage("assets/images/map.png"),
                        width: 20,
                        color: isDarkMode(context)
                            ? Colors.white
                            : Color(0xFF333333),
                      ),
                      onPressed: () => push(
                        context,
                        MapViewScreen(),
                      ),
                    ),
                  if (!(_currentWidget is CartScreen) ||
                      !(_currentWidget is ProfileScreen))
                    IconButton(
                        padding: EdgeInsets.only(right: 20),
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
                            StreamBuilder<List<CartProduct>>(
                              stream: cartDatabase.watchProducts,
                              builder: (context, snapshot) {
                                cartCount = 0;
                                if (snapshot.hasData) {
                                  snapshot.data!.forEach((element) {
                                    cartCount += element.quantity;
                                  });
                                }
                                return Visibility(
                                  visible: cartCount >= 1,
                                  child: Positioned(
                                    right: -6,
                                    top: -8,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(COLOR_PRIMARY),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 12,
                                        minHeight: 12,
                                      ),
                                      child: Center(
                                        child: new Text(
                                          cartCount <= 99
                                              ? '$cartCount'
                                              : '+99',
                                          style: new TextStyle(
                                            color: Colors.white,
                                            // fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            _drawerSelection = DrawerSelection.Cart;
                            _appBarTitle = 'Your Cart'.tr();
                            _currentWidget = CartScreen(
                              fromContainer: true,
                            );
                          });
                        }),
                ],
              ),
              body: _currentWidget,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() => TextField(
        controller: searchController,
        onChanged: _searchScreenStateKey.currentState == null
            ? (str) {
                setState(() {});
              }
            : _searchScreenStateKey.currentState!.onSearchTextChanged,
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
                  _searchScreenStateKey.currentState?.clearSearchQuery();
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

}

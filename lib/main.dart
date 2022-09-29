import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import '/constants.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/model/ConversationModel.dart';
import '/model/CurrencyModel.dart';
import '/model/HomeConversationModel.dart';
import '/model/stripeKey.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';
import '/services/localDatabase.dart';
import '/ui/auth/AuthScreen.dart';
import '/ui/chat/ChatScreen.dart';
import '/ui/container/ContainerScreen.dart';
import '/ui/onBoarding/OnBoardingScreen.dart';
import '/userPrefrence.dart';

import 'constants.dart';
import 'model/User.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await UserPreference.init();


  runApp(
    MultiProvider(
      providers: [
        Provider<CartDatabase>(
          create: (_) => CartDatabase(),
        )
      ],
      child: EasyLocalization(
          supportedLocales: [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          fallbackLocale: Locale('en'),
          saveLocale: false,
          useOnlyLangCode: true,
          useFallbackTranslations: true,
          child: MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  /// this key is used to navigate to the appropriate screen when the
  /// notification is clicked from the system tray
  final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey(debugLabel: 'Main Navigator');

  static User? currentUser;
  late StreamSubscription tokenStream;

  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  //  late Stream<StripeKeyModel> futureStirpe;
  //  String? data,d;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {

    try {
      /// Wait for Firebase to initialize and set `_initialized` state to true
      if (Platform.isIOS) {
        await Firebase.initializeApp(
            options: FirebaseOptions(
                apiKey: "AIzaSyAulrOEqdcDM49i2grZZsMsLT0VUURt5rk",
                appId: "1:476214478020:ios:3f2cd2e0981fdfcb7e7591",
                messagingSenderId: "476214478020",
                projectId: "gromart-5dd93"));
      } else {
        await Firebase.initializeApp();
      }

      RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleNotification(initialMessage.data, navigatorKey);
      }

      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage? remoteMessage) {
        if (remoteMessage != null) {
          _handleNotification(remoteMessage.data, navigatorKey);
        }
      });

      /// configure the firebase messaging , required for notifications handling
      if (!Platform.isIOS) {

        FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

      }

      /// listen to firebase token changes and update the user object in the
      /// database with it's new token
      ///

      tokenStream = FireStoreUtils.firebaseMessaging.onTokenRefresh.listen((event) {
            if (currentUser != null) {
              print('token $event');
              currentUser!.fcmToken = event;
              FireStoreUtils.updateCurrentUser(currentUser!);
            }
          });

      setState(() {
        _initialized = true;
      });

    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      return MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          home: Scaffold(
            body: Container(
              color: Colors.white,
              child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 25,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Failed to initialise firebase!',
                        style: TextStyle(color: Colors.red, fontSize: 25),
                      ),
                    ],
                  )),
            ),
          ));
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {

      return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
          ),
        ),
      );
    }

    return MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'GROMART'.tr(),
        theme: ThemeData(
            appBarTheme: AppBarTheme(
                centerTitle: true,
                color: Colors.transparent,
                elevation: 0,
                actionsIconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
                iconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
                textTheme: TextTheme(
                    headline6: TextStyle(
                        color: Colors.black,
                        fontSize: 17.0,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700)),
                brightness: Brightness.light),
            bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: Colors.white),
            accentColor: Color(COLOR_PRIMARY),
            primaryColor: Color(COLOR_PRIMARY),
            brightness: Brightness.light),
        darkTheme: ThemeData(
            appBarTheme: AppBarTheme(
                centerTitle: true,
                color: Colors.transparent,
                elevation: 0,
                actionsIconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
                iconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
                textTheme: TextTheme(
                    headline6: TextStyle(
                        color: Colors.grey[200],
                        fontSize: 17.0,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700)),
                brightness: Brightness.dark),
            bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: Colors.grey.shade900),
            accentColor: Color(COLOR_PRIMARY),
            primaryColor: Color(COLOR_PRIMARY),
            brightness: Brightness.dark),
        debugShowCheckedModeBanner: false,
        color: Color(COLOR_PRIMARY),
        home: OnBoarding()
    );
  }


  @override
  void initState() {

    initializeFlutterFire();

    WidgetsBinding.instance?.addObserver(this);

    super.initState();


  }

  @override
  void dispose() {
    tokenStream.cancel();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /*if (auth.FirebaseAuth.instance.currentUser != null && currentUser != null) {
      if (state == AppLifecycleState.paused) {
        //user offline
        tokenStream.pause();
        currentUser!.active = false;
        currentUser!.lastOnlineTimestamp = Timestamp.now();
        FireStoreUtils.updateCurrentUser(currentUser!);
      } else if (state == AppLifecycleState.resumed) {
        //user online
        tokenStream.resume();
        currentUser!.active = true;
        FireStoreUtils.updateCurrentUser(currentUser!);
      }
    }*/
  }


}

class OnBoarding extends StatefulWidget {
  @override
  State createState() {
    return OnBoardingState();
  }
}
class OnBoardingState extends State<OnBoarding> {
  late Future<List<CurrencyModel>> futureCurrency;
  Future hasFinishedOnBoarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool finishedOnBoarding = (prefs.getBool(FINISHED_ON_BOARDING) ?? false);

    if (finishedOnBoarding) {

      auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        User? user = await FireStoreUtils.getCurrentUser(firebaseUser.uid);
        print(user!.toJson().toString());
        print("====>");
        if (user != null && user.role == USER_ROLE_CUSTOMER) {
          user.active = true;
          user.role = USER_ROLE_CUSTOMER;
          user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
          await FireStoreUtils.updateCurrentUser(user);
          MyAppState.currentUser = user;
          //UserPreference.setUserId(userID: user.userID);
          //
          pushReplacement(context, ContainerScreen(user: user));
        } else {
          pushReplacement(context, AuthScreen());
        }
      } else {
        pushReplacement(context, AuthScreen());
      }
    } else {


      pushReplacement(context, OnBoardingScreen());
    }
  }

  @override
  void initState() {
    super.initState();
    hasFinishedOnBoarding();
    // futureCurrency= FireStoreUtils().getCurrency();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
        ),
      ),
    );
  }



}
/// this faction is called when the notification is clicked from system tray
/// when the app is in the background or completely killed
void _handleNotification(
    Map<String, dynamic> message, GlobalKey<NavigatorState> navigatorKey) {
  /// right now we only handle click actions on chat messages only
  try {
    print("data is ${message.toString()}");
    if (message.containsKey('members') &&
        message.containsKey('isGroup') &&
        message.containsKey('conversationModel')) {
      List<User> members = List<User>.from(
          (jsonDecode(message['members']) as List<dynamic>)
              .map((e) => User.fromPayload(e))).toList();
      ConversationModel conversationModel = ConversationModel.fromPayload(
          jsonDecode(message['conversationModel']));
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            homeConversationModel: HomeConversationModel(
                members: members, conversationModel: conversationModel),
          ),
        ),
      );
    }
  } catch (e, s) {
    print('MyAppState._handleNotification $e $s');
  }
}

Future<dynamic> backgroundMessageHandler(RemoteMessage remoteMessage) async {
  await Firebase.initializeApp();
  Map<dynamic, dynamic> message = remoteMessage.data;
  if (message.containsKey('data')) {
    // Handle data message
    print('backgroundMessageHandler message.containsKey(data)');
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }
}

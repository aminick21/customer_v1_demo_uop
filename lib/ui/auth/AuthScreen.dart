import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '/constants.dart';
import '/services/helper.dart';
import '/ui/login/LoginScreen.dart';
import '/ui/signUp/SignUpScreen.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Image.asset(
              'assets/images/app_logo_new.png',
              fit: BoxFit.cover,
              width: 150,
              height: 150,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 32, right: 16, bottom: 8),
            child: Text(
              'Welcome to Universal Organic Products',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(COLOR_PRIMARY),
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ).tr(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: Text(
              'Order item from store around you and track order in real-time',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ).tr(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(COLOR_PRIMARY),
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(
                      color: Color(COLOR_PRIMARY),
                    ),
                  ),
                ),
                child: Text(
                  'Log In',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ).tr(),
                onPressed: () {
                  push(context, LoginScreen());
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                right: 40.0, left: 40.0, top: 20, bottom: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: TextButton(
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(COLOR_PRIMARY)),
                ).tr(),
                onPressed: () {
                  push(context, SignUpScreen());
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.only(top: 12, bottom: 12),
                  ),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(
                        color: Color(COLOR_PRIMARY),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

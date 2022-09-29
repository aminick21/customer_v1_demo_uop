import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '/constants.dart';
import '/services/helper.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'Contact Us',
        
        onPressed: () {
          String url = 'tel:12345678';
          launch(url);
        },
        backgroundColor: Color(COLOR_ACCENT),
        child: Icon(
          CupertinoIcons.phone_solid,
          color: isDarkMode(context) ? Colors.black : Colors.white,
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Contact Us',
          style: TextStyle( color: isDarkMode(context) ? Colors.white : Colors.black,),
        ).tr(),
      ),
      body: Column(children: <Widget>[
        Material(
            elevation: 2,
            color: isDarkMode(context) ? Colors.black12 : Colors.white,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 16.0, left: 16, top: 16),
                    child: Text(
                      'Our Address',
                      style: TextStyle(
                          color:
                              isDarkMode(context) ? Colors.white : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ).tr(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, left: 16, top: 16, bottom: 16),
                    child:
                        Text('Siddhi Infosoft \nC-407, Ganesh meridian, Opp. Amiraj Farm, Ahmedabad - 380013, INDIA'),
                  ),
                  ListTile(
                   
                    title: Text(
                      'Email Us',
                      style: TextStyle(
                          color:
                              isDarkMode(context) ? Colors.white : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ).tr(),
                    subtitle: Text('info@siddhiinfosoft.com'),
                    trailing: Icon(
                      CupertinoIcons.chevron_forward,
                      color:
                          isDarkMode(context) ? Colors.white54 : Colors.black54,
                    ),
                  )
                ]))
      ]),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '/AppGlobal.dart';
import '/constants.dart';
import '/model/CuisineModel.dart';
import '/services/FirebaseHelper.dart';
import '/services/helper.dart';
import '/ui/categoryDetailsScreen/CategoryDetailsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CuisinesScreen extends StatefulWidget {
  const CuisinesScreen({Key? key, this.isPageCallFromHomeScreen = false})
      : super(key: key);

  @override
  _CuisinesScreenState createState() => _CuisinesScreenState();
  final bool? isPageCallFromHomeScreen;
}

class _CuisinesScreenState extends State<CuisinesScreen> {
  final fireStoreUtils = FireStoreUtils();
  late Future<List<CuisineModel>> categoriesFuture;
  SharedPreferences? sp;
  String? lastID="0";

  @override
  void initState() {
    super.initState();
    getLastId();
    categoriesFuture = fireStoreUtils.getCuisines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(DARK_COLOR):  Color(0xffFBFBFB),
        appBar: widget.isPageCallFromHomeScreen!?AppGlobal.buildAppBar(context, "Categories"):null,
        body: FutureBuilder<List<CuisineModel>>(
            future: categoriesFuture,
            initialData: [],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  ),
                );

              if (snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) {
                return GridView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: snapshot.data!.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return snapshot.data != null
                          ? buildCuisineCell(snapshot.data![index],lastID!)
                          : showEmptyState('No Categories'.tr(),
                              'Start by adding categories to firebase.'.tr());
                    }, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,mainAxisSpacing: 0,crossAxisSpacing: 8,mainAxisExtent: 200),);
              }
              return CircularProgressIndicator();
            }));
  }

  Widget buildCuisineCell(CuisineModel cuisineModel, String lastID) {
    bool isSelected=(lastID==cuisineModel.id);
    return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: GestureDetector(

          onTap: () {
            if(sp!=null){
              this.lastID=cuisineModel.id;
              sp!.setString("CatLastID", cuisineModel.id);
              setState(() {

              });
            }
            push(context,CategoryDetailsScreen(category: cuisineModel));

          },
          child: Container(
            decoration: BoxDecoration(color: isSelected?Color(COLOR_PRIMARY):Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: const Offset(
                    5.0,
                    5.0,
                  ),
                  blurRadius: 3.0,
                  spreadRadius: 2.0,
                ), //BoxShadow
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 0.0,
                  offset: const Offset(0.0, 0.0),
                  blurRadius: 0.0,

                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  ClipOval(
                      child: Image.network(
                        cuisineModel.photo,height: 70,width: 70,fit: BoxFit.cover,)),
                  SizedBox(height: 10,),
                  
                  Text(
                    cuisineModel.title,textAlign: TextAlign.center,
                    style: TextStyle(color:isSelected?Colors.white:Colors.black, fontFamily: "Poppinsm", fontSize: 18),
                  ).tr(),
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> getLastId() async {

    sp= await SharedPreferences.getInstance();
    if(sp!.getString("CatLastID")!=null) {
      lastID = sp?.getString("CatLastID");
    }
  }
}

//Container(
//             decoration: BoxDecoration(
// 
//               borderRadius: BorderRadius.circular(8),
//               image: DecorationImage(
//                 image: NetworkImage(cuisineModel.photo),
//                 fit: BoxFit.cover,
//                 colorFilter: ColorFilter.mode(
//                     Colors.black.withOpacity(0.5), BlendMode.darken),
//               ),
//             ),
//             child: Center(
//               child: Text(
//                 cuisineModel.title,
//                 style: TextStyle(
//                     color: Colors.white, fontFamily: "Poppinsm", fontSize: 20),
//               ).tr(),
//             ),
//           ),

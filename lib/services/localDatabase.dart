import 'package:moor/moor.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/model/ProductModel.dart';
import '/ui/productDetailsScreen/ProductDetailsScreen.dart';

part 'localDatabase.g.dart';

class CartProducts extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(max: 50)();

  TextColumn get photo => text()();

  TextColumn get price => text()();

  TextColumn get discountPrice => text().nullable()();

  TextColumn get vendorID => text()();

  IntColumn get quantity => integer()();

  TextColumn get extras_price => text().nullable()();

  TextColumn get extras => text().nullable()();

  TextColumn get size => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseMoor(tables: [CartProducts])
class CartDatabase extends _$CartDatabase {
  CartDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(
            path: 'db.sqlite', logStatements: true));

  addProduct(ProductModel model) async {
    print(model.quantity.toString() +
        "===MODEntry ");
    var joinTitleString = "";
    var joinPriceString = "";
    String mainPrice="";
    var joinSizeString = "";
    List<AddAddonsDemo> lstAddOns = [];
    List<String> lstAddOnsTemp = [];
    double extras_price = 0.0;

    List<AddSizeDemo> lstAddSize = [];
    List<String> lstAddSizeTemp = [];
    List<String> lstSizeTemp = [];
    SharedPreferences sp = await SharedPreferences.getInstance();
    String addOns =
        sp.getString("musics_key") != null ? sp.getString('musics_key')! : "";
    String addSize =
        sp.getString("addsize") != null ? sp.getString('addsize')! : "";

    print("======>ADDONS" + addOns);
    print("======>ADDONSIZE" + addSize);

    bool isAddSame=false;

    if (addSize != null && addSize.isNotEmpty)  {
      lstAddSize = AddSizeDemo.decode(addSize);

      for (int a = 0; a < lstAddSize.length; a++) {
        if (lstAddSize[a].categoryID == model.id) {
          isAddSame=true;
          lstAddSizeTemp.add(lstAddSize[a].price!);
          lstSizeTemp.add(lstAddSize[a].name!);
          mainPrice=double.parse(lstAddSize[a].price!).toString();
          print("===>AD****" + lstAddSize[a].price! + " " + lstAddSize[a].price!);
        }
      }
      joinPriceString = lstAddSizeTemp.join(",");
      joinSizeString = lstSizeTemp.join(",");
    }
    if(!isAddSame){
      if (model.disPrice != null && model.disPrice!.isNotEmpty &&
          double.parse(model.disPrice!) != 0) {
        mainPrice = model.disPrice!;
      } else {
        mainPrice = model.price;
      }

    }

    if (addOns.isNotEmpty && addOns != null) {
      lstAddOns = AddAddonsDemo.decode(addOns);
      print(lstAddOns.length.toString() + "----LEN");
      // extras_price += model.disPrice==""|| model.disPrice=="0"?double.parse(model.price):double.parse(model.disPrice!);
      for (int a = 0; a < lstAddOns.length; a++) {
        AddAddonsDemo newAddonsObject = lstAddOns[a];
        print("====<><><>===");
        print(newAddonsObject.price.toString() +
            " " +
            newAddonsObject.index.toString() +
            " " +
            newAddonsObject.name.toString() +
            " " +
            newAddonsObject.categoryID.toString() +
            " " +
            newAddonsObject.isCheck.toString());
        print(model.id.toString() + "====<><><>===-----IDDDD");
        if (newAddonsObject.categoryID == model.id) {
          //print("======>ADDONS"+lstAddOns[a].categoryID.toString()+" CAT "+model.id);
          //print("======>ADDONS"+lstAddOns[a].isCheck.toString()+" isCheck ");
          if (newAddonsObject.isCheck == true) {
            //print("======>ADDONS"+lstAddOns[a].isCheck.toString()+" name "+lstAddOns[a].name!);
            lstAddOnsTemp.add(newAddonsObject.name!);
            extras_price += (double.parse(newAddonsObject.price!));
          }
        }
      }

      joinTitleString = lstAddOnsTemp.join(",");
      print("===>AD" + joinTitleString + " === " + extras_price.toString());
    }


    allCartProducts.then((products) {
      print(model.quantity.toString() +
          "===MODELEntry " +
          extras_price.toString());
      CartProduct entity = CartProduct(
          id: model.id,
          name: model.name,
          photo: model.photo,
          price: mainPrice,
          vendorID: model.vendorID,
          quantity: model.quantity,
          extras_price: extras_price.toString(),
          extras: joinTitleString,
          size: joinSizeString,
          discountPrice: model.disPrice!);
      if (products.where((element) => element.id == model.id).isEmpty) {
        into(cartProducts).insert(entity);
      } else {
        updateProduct(entity);
      }
    });
  }

  reAddProduct(CartProduct cartProduct) =>
      into(cartProducts).insert(cartProduct);

  removeProduct(String productID) =>
      (delete(cartProducts)..where((product) => product.id.equals(productID)))
          .go();

  deleteAllProducts() => (delete(cartProducts)).go();

  updateProduct(CartProduct entity) =>
      (update(cartProducts)..where((product) => product.id.equals(entity.id)))
          .write(entity);

  @override
  int get schemaVersion => 1;

  Future<List<CartProduct>> get allCartProducts => select(cartProducts).get();

  Stream<List<CartProduct>> get watchProducts => select(cartProducts).watch();
}

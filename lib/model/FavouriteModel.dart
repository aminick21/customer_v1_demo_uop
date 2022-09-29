class FavouriteModel {
  String? store_id;
  String? user_id;

  FavouriteModel({this.store_id, this.user_id});

  factory FavouriteModel.fromJson(Map<String, dynamic> parsedJson) {
    return new FavouriteModel(
        store_id:parsedJson["store_id"]??"",
      user_id: parsedJson["user_id"]??""
    );
  }
  Map<String, dynamic> toJson(){
   return{
     "store_id":this.store_id,
     "user_id":this.user_id
   };
  }
}

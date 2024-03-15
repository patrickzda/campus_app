import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:campus_app/constants/network_constants.dart';
import '../constants/constants.dart';

enum Badge{
  green,
  yellow,
  red,
  none
}

const String mealCollectionId = "65e5a849a0ae48495ccf";

class Meal{
  String name, type;
  Badge health, emission, water;
  double studentPrice, memberPrice, externalPrice;
  int canteenId;

  Meal({required this.name, required this.type, required this.health, required this.emission, required this.water, required this.studentPrice, required this.memberPrice, required this.externalPrice, required this.canteenId});

  static Meal fromJson(Map<String, dynamic> jsonData){
    return Meal(
      name: jsonData["name"],
      type: jsonData["type"],
      health: badgeFromString(jsonData["health_badge"]),
      emission: badgeFromString(jsonData["emission_badge"]),
      water: badgeFromString(jsonData["water_badge"]),
      studentPrice: double.parse(jsonData["prices"][0].toString()),
      memberPrice: double.parse(jsonData["prices"][1].toString()),
      externalPrice: double.parse(jsonData["prices"][2].toString()),
      canteenId: jsonData["canteen_id"]
    );
  }

  static Badge badgeFromString(String badge){
    if(badge == "green"){
      return Badge.green;
    }else if(badge == "yellow"){
      return Badge.yellow;
    }else if(badge == "red"){
      return Badge.red;
    }else{
      return Badge.none;
    }
  }

  static Future<List<Meal>> getCanteenMealPlan(int canteenId) async{
    List<Meal> mealPlan = [];

    DocumentList result = await NetworkConstants.database.listDocuments(
      databaseId: databaseId,
      collectionId: mealCollectionId,
      queries: [Query.equal("canteen_id", canteenId), Query.limit(100)],
    );

    print("LADE DEN SPEISEPLAN FÜR MENSA $canteenId HERUNTER");
    print(result.documents.length);

    for(int i = 0; i < result.documents.length; i++){
      mealPlan.add(Meal.fromJson(result.documents[i].data));
    }

    return mealPlan;
  }

}
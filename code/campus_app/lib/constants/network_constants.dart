import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'constants.dart';

class NetworkConstants{
  static late Client client;
  static late Account account;
  static late Databases database;
  static late Storage storage;
  static models.Session? session;
  static bool _initialized = false;

  static Future<void> initialize() async{
    if(!_initialized){
      client = Client();
      client.setEndpoint(domain).setProject(projectId).setSelfSigned(status: true);
      account = Account(client);
      database = Databases(client);
      storage = Storage(client);

      try{
        await account.createAnonymousSession();
      }catch(e){
        print(e);
      }

      _initialized = true;
    }
  }
}
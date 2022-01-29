import 'package:familiar_faces/services/saved_media_database.dart';
import 'package:familiar_faces/contracts_sql/saved_media.dart';

class SavedMediaService {
  static Future<List<SavedMedia>> getAll() async {
    return await SavedMediaDatabase.instance.getAll();
  }

  static Future<SavedMedia> get(int id) async {
    return await SavedMediaDatabase.instance.get(id);
  }

  static Future<SavedMedia> add(SavedMedia media) async {
    return await SavedMediaDatabase.instance.create(media);
  }

  static Future<bool> remove(int id) async {
    var deleted = await SavedMediaDatabase.instance.delete(id);
    return deleted == 1;
  }
}

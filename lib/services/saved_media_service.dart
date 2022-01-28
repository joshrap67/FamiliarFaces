import 'package:familiar_faces/services/saved_media_database.dart';
import 'package:familiar_faces/sql_contracts/saved_media.dart';

class SavedMediaService{
	static Future<List<SavedMedia>> getAll() async{
		return await SavedMediaDatabase.instance.getAll();
	}

	static Future<SavedMedia> get(int id) async{
		return await SavedMediaDatabase.instance.get(id);
	}

	static Future<SavedMedia> add(SavedMedia media) async{
		return await SavedMediaDatabase.instance.create(media);
	}

	// 1 means removed successfully todo make this a bool
	static Future<int> remove(int id) async{
		return await SavedMediaDatabase.instance.delete(id);
	}
}
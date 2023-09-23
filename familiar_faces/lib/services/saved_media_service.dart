import 'package:familiar_faces/domain/saved_media.dart';
import 'package:familiar_faces/providers/saved_media_provider.dart';
import 'package:familiar_faces/services/saved_media_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class SavedMediaService {
  static Future<List<SavedMedia>> load(BuildContext context) async {
    var media = <SavedMedia>[];
    context.read<SavedMediaProvider>().setLoading(true);
    try {
      media = await SavedMediaDatabase.instance.getAll();
      context.read<SavedMediaProvider>().setMedia(media);
    } finally {
      context.read<SavedMediaProvider>().setLoading(false);
    }
    return media;
  }

  static Future<SavedMedia?> getByMediaId(int mediaId) async {
    return await SavedMediaDatabase.instance.getByMediaId(mediaId);
  }

  static Future<void> add(BuildContext context, SavedMedia media) async {
    var createdMedia = await SavedMediaDatabase.instance.create(media);
    context.read<SavedMediaProvider>().addMedia(createdMedia);
  }

  static Future<bool> remove(BuildContext context, int id) async {
    var deleted = (await SavedMediaDatabase.instance.delete(id)) == 1;
    if (deleted) {
      context.read<SavedMediaProvider>().removeMedia(id);
    }
    return deleted;
  }
}

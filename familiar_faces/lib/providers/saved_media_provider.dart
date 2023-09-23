import 'package:familiar_faces/domain/saved_media.dart';
import 'package:familiar_faces/imports/globals.dart';
import 'package:flutter/material.dart';

class SavedMediaProvider with ChangeNotifier {
  bool _isLoading = true;
  List<SavedMedia> _savedMedia = <SavedMedia>[];
  SortValue _sort = SortValue.ReleaseDateDescending;

  List<SavedMedia> get savedMedia => [..._savedMedia]; // spread since otherwise widgets could bypass mutation methods
  Set<int> get savedMediaSet => _savedMedia.map((m) => m.mediaId).toSet();

  bool get isLoading => _isLoading;

  SortValue get sort => _sort;

  void setMedia(List<SavedMedia> media) {
    _savedMedia = media;
    sortMedia();
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void addMedia(SavedMedia media) {
    _savedMedia.add(media);
    sortMedia();
    notifyListeners();
  }

  void removeMedia(int id) {
    _savedMedia.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void setSort(SortValue sort) {
    _sort = sort;
    sortMedia();
    notifyListeners();
  }

  void sortMedia() {
    switch (_sort) {
      case SortValue.AlphaDescending:
        _savedMedia.sort((a, b) {
          if (a.title == null || b.title == null) {
            return 1;
          } else {
            return b.title!.toLowerCase().compareTo(a.title!.toLowerCase());
          }
        });
        break;
      case SortValue.AlphaAscending:
        _savedMedia.sort((a, b) {
          if (a.title == null || b.title == null) {
            return 1;
          } else {
            return a.title!.toLowerCase().compareTo(b.title!.toLowerCase());
          }
        });
        break;
      case SortValue.ReleaseDateDescending:
        _savedMedia.sort((a, b) {
          if (a.releaseDate == null || b.releaseDate == null) {
            return 1;
          } else {
            return b.releaseDate!.compareTo(a.releaseDate!);
          }
        });
        break;
      case SortValue.ReleaseDateAscending:
        _savedMedia.sort((a, b) {
          if (a.releaseDate == null || b.releaseDate == null) {
            return 1;
          } else {
            return a.releaseDate!.compareTo(b.releaseDate!);
          }
        });
        break;
    }
  }
}

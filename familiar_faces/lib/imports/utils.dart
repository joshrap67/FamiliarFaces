import 'package:familiar_faces/domain/media_type.dart';
import 'package:familiar_faces/imports/globals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

bool isStringNullOrEmpty(String? value) {
  return value?.isEmpty ?? true;
}

String getTmdbPicture(String? path) {
  if (path == null) {
    return 'https://familiar-faces-images.s3.amazonaws.com/not_found.png';
  } else {
    return 'https://image.tmdb.org/t/p/w500/$path';
  }
}

DateTime? parseDate(String? date) {
  if (isStringNullOrEmpty(date)) {
    return null;
  } else {
    return DateTime.parse(date!);
  }
}

String formatDateYearOnly(DateTime? date) {
  return DateFormat('yyyy').format(date!);
}

String formatDateFull(DateTime? date) {
  return DateFormat.yMMMd('en_US').format(date!);
}

int compareToBool(bool a, bool b) {
  if (a == b) {
    return 0;
  } else if (a) {
    return -1;
  }
  return 1;
}

extension DurationExtensions on Duration {
  int inYears() {
    return this.inDays ~/ 365;
  }
}

String getAge(DateTime birthday, DateTime? deathday) {
  if (deathday == null) {
    // yay still alive
    var now = DateTime.now();
    var age = now.difference(birthday).inYears();
    return '${formatDateFull(birthday)} (age $age)';
  } else {
    var age = deathday.difference(birthday).inYears();
    return '${formatDateFull(birthday)} - ${formatDateFull(deathday)} (aged $age)';
  }
}

void showSnackbar(String message, BuildContext context, {int milliseconds = 1500}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  var snackBar = SnackBar(
    content: Text(message),
    duration: Duration(milliseconds: milliseconds),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void hideKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

void closePopup(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop('dialog');
}

bool isMediaSeen(int mediaId, MediaType mediaType, Set<String> seenMedia) {
  var searchVal = '$mediaId$savedMediaDelimiter$mediaType';
  return seenMedia.contains(searchVal);
}

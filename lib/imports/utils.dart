import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

bool isStringNullOrEmpty(String? value) {
  return value?.isEmpty ?? true;
}

String getImageUrl(String? path) {
  if (path == null) {
    return 'https://picsum.photos/200';
  } else {
    return 'https://image.tmdb.org/t/p/w500/$path';
  }
}

String filterDate(DateTime? date) {
  return DateFormat('yyyy').format(date!);
}

void showSnackbar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  var snackBar = SnackBar(content: Text(message));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void hideKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(new FocusNode());
}

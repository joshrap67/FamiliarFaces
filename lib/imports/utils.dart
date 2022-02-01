import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

bool isStringNullOrEmpty(String? value) {
  return value?.isEmpty ?? true;
}

String getImageUrl(String? path) {
  if (path == null) {
    return 'https://picsum.photos/200'; // todo put placeholder in s3
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

void hideKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(new FocusNode());
}

void closePopup(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop('dialog');
}

void showLoadingDialog(BuildContext context, {String msg = 'Loading...', bool dismissible = false}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => dismissible,
        child: AlertDialog(
          content: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              CircularProgressIndicator(),
              Padding(
                padding: EdgeInsets.all(20),
              ),
              Flexible(
                flex: 8,
                child: Text(msg),
              )
            ],
          ),
        ),
      );
    },
  );
}

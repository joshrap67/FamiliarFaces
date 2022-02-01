import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_result.dart';
import 'http_action.dart';

const String rootUrl = 'api.themoviedb.org';

Future<ApiResult<String>> makeApiRequest(HttpAction action, String route, Map<String, String> queryParameters,
    {Map<String, dynamic>? requestContent}) async {
  ApiResult<String> retVal = new ApiResult();

  try {
    var url = Uri.https(rootUrl, '3/$route', queryParameters);
    http.Response response;
    switch (action) {
      case HttpAction.GET:
        response = await http.get(url);
        break;
      case HttpAction.POST:
        response = await http.post(url, body: json.encode(requestContent));
        break;
      case HttpAction.PUT:
        response = await http.put(url, body: json.encode(requestContent));
        break;
      case HttpAction.DELETE:
        response = await http.delete(url);
        break;
      default:
        response = new http.Response("Error", 400);
    }

    if (response.statusCode >= 200 || response.statusCode < 300) {
      retVal.data = response.body;
    } else {
      retVal.errorMessage = response.body;
    }
  } on SocketException catch (_) {
    retVal.errorMessage = 'Error connecting to server.';
  } on Exception catch (e) {
    retVal.errorMessage = e.toString();
  }
  return retVal;
}

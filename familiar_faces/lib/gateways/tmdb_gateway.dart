import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_result.dart';
import 'http_action.dart';

const String rootUrl = 'api.themoviedb.org';
const int version = 3;

Future<ApiResult<String>> makeApiRequest(HttpAction action, String route, Map<String, String> queryParameters,
    {Map<String, dynamic>? requestContent}) async {
  ApiResult<String> retVal;

  try {
    var url = Uri.https(rootUrl, '$version/$route', queryParameters);
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
      retVal = new ApiResult.success(response.body);
    } else {
      retVal = new ApiResult.failure(response.body);
    }
  } on SocketException catch (_) {
    retVal = new ApiResult.failure('Error connecting to server.');
  } on Exception catch (e) {
    retVal = new ApiResult.failure(e.toString());
  }
  return retVal;
}

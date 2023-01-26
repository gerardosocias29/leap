import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

class Api {
  final backendUrl = dotenv.env['API_BACKEND_URL'] ?? 'http://192.168.0.186:8081';
  var headers = {'content-type': 'application/json'};

  Future<Object> getRequest(url) async {
    var uri = Uri.parse("$backendUrl/api/$url");
    Response response = await get(
        uri,
        headers: headers
    );
    return jsonDecode(response.body);
  }

  multipleGetRequest(urls) {
    List<Future<Object>> taskList = [];
    for(var url in urls){
      taskList.add(getRequest(url));
    }
    return Future.wait(taskList).then((List results) {
      return results;
    });
  }

  postRequest(data, url) async {
    var uri = Uri.parse("$backendUrl/$url");
    Map<String, dynamic> body = data;
    String jsonBody = json.encode(body);
    var encoding = Encoding.getByName('utf-8');

    Response response = await post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );
    return response;
  }

  putRequest(data, url) async {
    var uri = Uri.parse("$backendUrl/$url");
    Map<String, dynamic> body = data;
    String jsonBody = json.encode(body);
    var encoding = Encoding.getByName('utf-8');

    Response response = await put(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );
    return response;
  }

}
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
    var uri = Uri.parse("$backendUrl/api/$url");
    Map<String, dynamic> body = data;
    String jsonBody = json.encode(body);
    var encoding = Encoding.getByName('utf-8');

    Response response = await post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );
    return response.body;
  }

  putRequest(data, url) async {
    var uri = Uri.parse("$backendUrl/api/$url");
    Map<String, dynamic> body = data;
    String jsonBody = json.encode(body);

    Response response = await put(
      uri,
      headers: {"Accept": "application/json",'content-type': 'application/json'},
      body: jsonBody
    );
    return jsonDecode(response.body);
  }

  deleteRequest(url) async {
    var uri = Uri.parse("$backendUrl/api/$url");
    Response response = await delete(
      uri,
      headers: {"Accept": "application/json"},
    );
    return jsonDecode(response.body);
  }

  triggerAchievementCalculation(achievement_id, achievement_score, chapter_ids, user_id, type) async {
    var url = "";
    if(type == "finished_lessons"){
      url = "achievement/calculate_finished_lessons";
    } else if ( type == "all_quizzes" ){
      url = "achievement/calculate_all_quizzes";
    }
    print("trigger achievement calculation :::: $url");
    print({
      'achievement_id': achievement_id,
      'achievement_achievement_score': achievement_score,
      'achievement_chapter_ids': chapter_ids,
      'user_id': user_id
    });
    if(url != ""){
      await postRequest({
        'achievement_id': achievement_id,
        'achievement_achievement_score': achievement_score,
        'achievement_chapter_ids': chapter_ids,
        'user_id': user_id
      }, url);

      // need to call achievements check progress if there is 100 percent
      /*var urls = [
        'achievements/full_progress/$user_id'
      ];
      var datas = await Api().multipleGetRequest(urls);
      if(datas.length > 0){
        print("HAS DATA!!!");
      }*/
    }
  }

  /* Params
  * user_id
  * type = "finished_lessons" or "all_quizzes" or "all_topics" or "all lectures"
  */
  getAchievements(userId, type) async {
    print("getting achievements:::");
    var urls = [
      'achievements/list/all'
    ];
    var datas = await Api().multipleGetRequest(urls);
    var achievements = datas[0];
    for(var achievement in achievements){
      if(achievement['type'] == type){
        await triggerAchievementCalculation(achievement['id'], achievement['score_to_achieve'], achievement['chapter_ids'], userId, type);
      }
    }
  }

}
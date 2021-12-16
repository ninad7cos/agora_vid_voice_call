import 'dart:developer';
import 'package:http/http.dart';

const urlR  = 'http://www.fishcary.com/fishcary/api/Agora_RTC_RTM/sample/';
class ApiCalls {
  Future <dynamic> commonApiCallResponse( String url, Map<String, dynamic> body) async {
    url = urlR + url;
    log('--');
    try {
      Response response = await post(Uri.parse(url), body: body);
      log("$urlR------------>>>>>>${response.statusCode}<----response---->", time: DateTime.now());
      if(response.statusCode == 200) {
        return (response.body);
      }else{
        return "[]";
      }
    } catch (e) {
      log('$urlR-Error catching data', name: e.toString());
      // Fluttertoast.showToast(msg: "Something went wrong !!");
      return "[]";
    }
  }
}
import 'dart:developer';
import 'package:http/http.dart';

const urlR  = 'http://192.168.0.114/book/php/sample/RtcTokenBuilderSample.php';
class ApiCalls {
  Future <dynamic> commonApiCallResponse(Map<String, dynamic> body) async {
    log('--');
    try {
      Response response = await post(Uri.parse(urlR), body: body);
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
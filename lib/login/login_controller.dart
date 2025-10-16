import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:retailers/fetch_vehicle/fetch_vehicle_controller.dart';

import '../fetch_vehicle/fetch_vehicle_screen.dart';
import '../utills/NoInternetScreen.dart';
import '../utills/api_helper.dart';
import '../utills/network_service.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  final usernameController = TextEditingController(text:'store_manager');
  final passwordController = TextEditingController(text: 'Secure@123');
  RxBool isLoading = false.obs;
  // final RxList<String> countries = ['India', 'Cambodia'].obs;
  final RxString isSelectedCountry = ''.obs;


  void login() async {

    isLoading.value = true;
    final netService = Get.put(NetworkService());
    bool connected = await netService.checkConnection();
    ApiHelper().box.put('isLogin', false);

    if (!connected) {
      isLoading.value = false;
      Get.snackbar("No Internet", "Please check your connection",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      isLoading.value = false;
      Get.snackbar("Error", "Please enter both username and password",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // Call API
    final response = await postFormApi(
      url:ApiHelper.loginApi,
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response != null && response.containsKey('offers')) {
        isLoading.value = false;
         List getOffer = response['offers']??[];
        String? getUrl = ApiHelper().conutryUrl[isSelectedCountry.value]??"";
        print('country_url..$getUrl');
        await ApiHelper().box.put('username', username);
        await ApiHelper().box.put('pwd', password);
        await ApiHelper().box.put('isLogin', true);
        await ApiHelper().box.put('country_url', getUrl);
        await ApiHelper().box.put('country', isSelectedCountry.value);
        await ApiHelper().box.put('site_id', response['site_id']??'0');
        ApiHelper().parkingSiteId = response['site_id']??'0';
        FetchVehicleController controller = Get.put(FetchVehicleController());
        controller.voucherList.value = getOffer;

        // Navigate to next screen
        Get.offAll(() => FetchVehicleScreen());
        Get.snackbar("Success", "Login Successful",
            backgroundColor: Colors.green, colorText: Colors.white,duration: Duration(seconds: 1));
        isSelectedCountry.value = "";
        if(getOffer.isEmpty){
          Get.snackbar("Invalid", "no offer available.",
              backgroundColor: Colors.red, colorText: Colors.white,duration: Duration(seconds: 1));
        }
    }
    else{
      String errorSms = (response?['error'])??"Try Again";
      isLoading.value = false;
      ApiHelper().box.put('isLogin', false);
      Get.snackbar("Error", errorSms,
          backgroundColor: Colors.red, colorText: Colors.white,duration: Duration(seconds: 1));
    }
  }


  void checkInternet() async {
    final connected = await Get.find<NetworkService>().checkConnection();
    if (!connected) {
      Get.to(() => NoInternetScreen());
    }
  }
  /// Check network availability
  Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  /// Generic API POST function
  Future<Map<String, dynamic>?> postFormApi({
    required String url,
    required Map<String, String> body,
  }) async {
    if (!await isConnected()) {
      Get.snackbar("No Internet", "Please check your connection.");
      return null;
    }

    try {
      print("➡️ Sending POST (form-data) to: ${ApiHelper.loginApi}");
      print("📦 Request body: $body");

      // 🔹 Use 'application/x-www-form-urlencoded' for form data
      final response = await http.post(
        Uri.parse(ApiHelper.loginApi),
        headers: {
          'Authorization': 'Bearer ${ApiHelper.token}',
          'Content-Type': 'application/x-www-form-urlencoded',
          'token': 'kql3_bhd45_mauq34',
        },
        body: body, // no jsonEncode here!
      );

      print("✅ Response Status: ${response.statusCode}");
      print("✅ Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return jsonDecode(response.body);
      }
    } catch (e) {
      return null;
    }

/*    try {
      print('Login Request:-$body __URL: $url');
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['token'] = 'kql3_bhd45_mauq34';

      body.forEach((key, value) {
        request.fields[key] = value;
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Login Response:${response.statusCode}___${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return jsonDecode(response.body);
      }
    } catch (e) {
      return null;
    }*/



  }



}

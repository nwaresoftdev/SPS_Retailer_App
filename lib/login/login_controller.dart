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
  final String loginApi = 'https://crm.secureparking.co.in/retailer/login_offers/';
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
      url:loginApi,
      body: {
        'username': username,
        'password': password,
      },
      // token: 'kql3_bhd45_mauq34', // Replace with your token
    );

    if (response != null) {

      isLoading.value = false;
      List getOffer = response['offers']??[];

      if(/*getOffer.isNotEmpty*/  true){
        String? getUrl = ApiHelper().conutryUrl[isSelectedCountry.value]??"";
        await ApiHelper().box.put('username', username);
        ApiHelper().box.put('pwd', password);
        ApiHelper().box.put('isLogin', true);
        ApiHelper().box.put('country_url', getUrl);
        ApiHelper().box.put('country', isSelectedCountry.value);
        FetchVehicleController controller = Get.put(FetchVehicleController());
        // controller.voucherList.value = getOffer;

        // Navigate to next screen
        Get.offAll(() => FetchVehicleScreen());
        Get.snackbar("Success", "Login Successful",
            backgroundColor: Colors.green, colorText: Colors.white,duration: Duration(seconds: 1));
        isSelectedCountry.value = "";
      }
      else{
        Get.snackbar("Invalid", "Try Again",
            backgroundColor: Colors.red, colorText: Colors.white,duration: Duration(seconds: 1));
      }


    }
    else{
      isLoading.value = false;
      ApiHelper().box.put('isLogin', false);
      Get.snackbar("Error", "Try Again",
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
      print('Login Request:-$body __URL: $url');
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['token'] = 'kql3_bhd45_mauq34';

      body.forEach((key, value) {
        request.fields[key] = value;
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Login Response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }



}
